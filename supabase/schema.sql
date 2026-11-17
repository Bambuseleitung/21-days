-- 21 Days: Gruppen, Rangliste und Gruppen-Challenges
-- Im Supabase-Dashboard unter "SQL Editor" einfügen und ausführen.
-- Die Datei lässt sich gefahrlos erneut ausführen (z. B. nach einem App-Update), vorhandene Daten bleiben.
--
-- Datenschutz: Die Tabellen sind für die App gesperrt (Row Level Security ohne Regeln).
-- Die App darf nur die Funktionen unten aufrufen. Gespeichert wird pro Mitglied nur:
-- Name, Farbe, Level, XP, XP dieser Woche, Serie und "erledigt heute von heute".
-- Namen oder Inhalte von Gewohnheiten und das Tagebuch verlassen das Gerät nie.

create table if not exists groups (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists players (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references groups(id) on delete cascade,
  secret text not null,
  name text not null,
  color text not null default '#FF8A3D',
  level int not null default 1,
  xp bigint not null default 0,
  week_xp int not null default 0,
  week_start date,
  streak int not null default 0,
  done_today int not null default 0,
  total_today int not null default 0,
  day date,
  updated_at timestamptz not null default now()
);
create index if not exists players_group_idx on players (group_id);

create table if not exists cheers (
  id bigint generated always as identity primary key,
  group_id uuid not null references groups(id) on delete cascade,
  from_player uuid not null references players(id) on delete cascade,
  to_player uuid not null references players(id) on delete cascade,
  day date not null default current_date,
  created_at timestamptz not null default now(),
  unique (from_player, to_player, day)
);

-- Gruppen-Challenges: Der Leader legt sie an, jedes Mitglied hakt sie täglich ab.
alter table groups add column if not exists leader uuid;
alter table players add column if not exists joined date not null default current_date;

create table if not exists challenges (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references groups(id) on delete cascade,
  name text not null,
  kind text not null default 'build' check (kind in ('build', 'break')),
  icon text not null default 'star',
  color text not null default '#FF6B2C',
  days int[] not null default '{0,1,2,3,4,5,6}',
  start_day date not null default current_date,
  end_day date, -- gesetzt, wenn der Leader sie beendet; bis dahin zählt sie für die Gruppen-Serie
  created_at timestamptz not null default now()
);
create index if not exists challenges_group_idx on challenges (group_id);

create table if not exists checks (
  challenge_id uuid not null references challenges(id) on delete cascade,
  player_id uuid not null references players(id) on delete cascade,
  day date not null,
  created_at timestamptz not null default now(),
  primary key (challenge_id, player_id, day)
);

alter table groups enable row level security;
alter table players enable row level security;
alter table cheers enable row level security;
alter table challenges enable row level security;
alter table checks enable row level security;

-- Prüft Mitglied und Geheimnis und liefert die Gruppe.
create or replace function _group_of(p_player uuid, p_secret text) returns uuid
language plpgsql security definer set search_path = public as $$
declare g uuid;
begin
  select group_id into g from players where id = p_player and secret = p_secret;
  if g is null then raise exception 'not_authorized'; end if;
  return g;
end $$;

-- Macht aus einer getippten Eingabe einen Gruppencode (Großbuchstaben, ohne Striche, O wird 0, I und L werden 1).
create or replace function _clean_code(p_code text) returns text
language sql immutable as $$
  select translate(upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g')), 'OIL', '011')
$$;

create or replace function _new_secret() returns text
language sql as $$ select replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', '') $$;

create or replace function create_group(p_group_name text, p_player_name text, p_color text) returns json
language plpgsql security definer set search_path = public as $$
declare g groups; p players; s text; c text; tries int := 0;
begin
  if length(trim(coalesce(p_group_name, ''))) = 0 or length(trim(coalesce(p_player_name, ''))) = 0 then raise exception 'bad_name'; end if;
  loop
    c := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10));
    exit when not exists (select 1 from groups where code = c);
    tries := tries + 1; if tries > 10 then raise exception 'try_again'; end if;
  end loop;
  insert into groups (code, name) values (c, left(trim(p_group_name), 30)) returning * into g;
  s := _new_secret();
  insert into players (group_id, secret, name, color)
    values (g.id, s, left(trim(p_player_name), 20), left(coalesce(p_color, '#FF8A3D'), 9)) returning * into p;
  update groups set leader = p.id where id = g.id;
  return json_build_object('group_id', g.id, 'group_name', g.name, 'code', g.code, 'player_id', p.id, 'secret', s);
end $$;

create or replace function join_group(p_code text, p_player_name text, p_color text) returns json
language plpgsql security definer set search_path = public as $$
declare g groups; p players; s text;
begin
  if length(trim(coalesce(p_player_name, ''))) = 0 then raise exception 'bad_name'; end if;
  select * into g from groups where code = _clean_code(p_code);
  if g.id is null then raise exception 'group_not_found'; end if;
  if (select count(*) from players where group_id = g.id) >= 20 then raise exception 'group_full'; end if;
  s := _new_secret();
  insert into players (group_id, secret, name, color)
    values (g.id, s, left(trim(p_player_name), 20), left(coalesce(p_color, '#FF8A3D'), 9)) returning * into p;
  return json_build_object('group_id', g.id, 'group_name', g.name, 'code', g.code, 'player_id', p.id, 'secret', s);
end $$;

create or replace function report(
  p_player uuid, p_secret text, p_name text, p_color text, p_level int, p_xp bigint,
  p_week_xp int, p_week_start date, p_streak int, p_done int, p_total int, p_day date
) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform _group_of(p_player, p_secret);
  update players set
    name = coalesce(nullif(left(trim(p_name), 20), ''), name),
    color = left(coalesce(p_color, color), 9),
    level = least(greatest(coalesce(p_level, 1), 1), 1000),
    xp = least(greatest(coalesce(p_xp, 0), 0), 100000000),
    week_xp = least(greatest(coalesce(p_week_xp, 0), 0), 1000000),
    week_start = p_week_start,
    streak = least(greatest(coalesce(p_streak, 0), 0), 100000),
    done_today = least(greatest(coalesce(p_done, 0), 0), 1000),
    total_today = least(greatest(coalesce(p_total, 0), 0), 1000),
    day = p_day,
    updated_at = now()
  where id = p_player;
end $$;

create or replace function board(p_player uuid, p_secret text) returns json
language plpgsql security definer set search_path = public as $$
declare g uuid; res json;
begin
  g := _group_of(p_player, p_secret);
  select json_build_object(
    'group', (select json_build_object('name', name, 'code', code) from groups where id = g),
    'me', p_player,
    'leader', (select leader from groups where id = g),
    'challenges', coalesce((
      select json_agg(json_build_object('id', c.id, 'name', c.name, 'kind', c.kind, 'icon', c.icon, 'color', c.color,
        'days', c.days, 'start_day', c.start_day, 'end_day', c.end_day) order by c.created_at)
      from challenges c where c.group_id = g and (c.end_day is null or c.end_day > current_date - 36)), '[]'::json),
    -- Häkchen der letzten 5 Wochen als [Challenge, Mitglied, Tag, Zeitpunkt]: reicht für Gruppen-Serie und Aktivität
    'checks', coalesce((
      select json_agg(json_build_array(k.challenge_id, k.player_id, k.day, k.created_at))
      from checks k join challenges c on c.id = k.challenge_id
      where c.group_id = g and k.day > current_date - 36), '[]'::json),
    'cheer_feed', coalesce((
      select json_agg(json_build_array(x.from_player, x.to_player, x.created_at) order by x.created_at desc)
      from (select * from cheers where group_id = g and created_at > now() - interval '2 days' order by created_at desc limit 30) x), '[]'::json),
    'players', coalesce((
      select json_agg(json_build_object(
        'id', p.id, 'name', p.name, 'color', p.color, 'level', p.level, 'xp', p.xp,
        'week_xp', p.week_xp, 'week_start', p.week_start, 'streak', p.streak, 'joined', p.joined,
        'done_today', p.done_today, 'total_today', p.total_today, 'day', p.day,
        'cheers', (select count(*) from cheers c where c.to_player = p.id and c.created_at > now() - interval '7 days'),
        'cheered', exists (select 1 from cheers c where c.to_player = p.id and c.from_player = p_player and c.day = current_date)
      ) order by p.week_xp desc, p.xp desc)
      from players p where p.group_id = g), '[]'::json)
  ) into res;
  return res;
end $$;

create or replace function cheer(p_player uuid, p_secret text, p_to uuid) returns void
language plpgsql security definer set search_path = public as $$
declare g uuid;
begin
  g := _group_of(p_player, p_secret);
  if p_to = p_player then raise exception 'self_cheer'; end if;
  if not exists (select 1 from players where id = p_to and group_id = g) then raise exception 'not_authorized'; end if;
  insert into cheers (group_id, from_player, to_player) values (g, p_player, p_to) on conflict do nothing;
end $$;

create or replace function leave_group(p_player uuid, p_secret text) returns void
language plpgsql security definer set search_path = public as $$
declare g uuid;
begin
  g := _group_of(p_player, p_secret);
  delete from players where id = p_player;
  if not exists (select 1 from players where group_id = g) then delete from groups where id = g; return; end if;
  -- wer zuerst beigetreten ist, übernimmt die Leitung
  update groups set leader = (select id from players where group_id = g order by joined, id limit 1)
    where id = g and (leader = p_player or leader is null);
end $$;

-- Ältere Gruppen haben noch keinen Leader: Das erste Mitglied, das tippt, übernimmt.
create or replace function claim_leader(p_player uuid, p_secret text) returns void
language plpgsql security definer set search_path = public as $$
declare g uuid;
begin
  g := _group_of(p_player, p_secret);
  update groups set leader = p_player where id = g and leader is null;
  if not found then raise exception 'not_leader'; end if;
end $$;

-- Tag des Geräts, solange er zum Server-Datum passt (Zeitzonen), sonst das Server-Datum.
create or replace function _day(p_day date) returns date
language sql stable as $$
  select case when p_day between current_date - 2 and current_date + 1 then p_day else current_date end
$$;

create or replace function challenge_save(
  p_player uuid, p_secret text, p_id uuid, p_name text, p_kind text, p_icon text, p_color text, p_days int[], p_day date
) returns uuid
language plpgsql security definer set search_path = public as $$
declare g uuid; n text := left(trim(coalesce(p_name, '')), 40); d int[]; cid uuid;
begin
  g := _group_of(p_player, p_secret);
  if (select leader from groups where id = g) is distinct from p_player then raise exception 'not_leader'; end if;
  select array_agg(distinct x order by x) into d from unnest(p_days) x where x between 0 and 6;
  if length(n) = 0 or d is null or p_kind not in ('build', 'break')
     or coalesce(p_icon, '') !~ '^[a-z0-9_-]{1,20}$' or coalesce(p_color, '') !~ '^#[0-9A-Fa-f]{6}$' then raise exception 'bad_challenge'; end if;
  if p_id is null then
    if (select count(*) from challenges where group_id = g and end_day is null) >= 10 then raise exception 'too_many'; end if;
    insert into challenges (group_id, name, kind, icon, color, days, start_day)
      values (g, n, p_kind, p_icon, p_color, d, _day(p_day)) returning id into cid;
  else
    update challenges set name = n, kind = p_kind, icon = p_icon, color = p_color, days = d
      where id = p_id and group_id = g and end_day is null returning id into cid;
    if cid is null then raise exception 'not_found'; end if;
  end if;
  return cid;
end $$;

create or replace function challenge_end(p_player uuid, p_secret text, p_id uuid, p_day date) returns void
language plpgsql security definer set search_path = public as $$
declare g uuid; d date := _day(p_day);
begin
  g := _group_of(p_player, p_secret);
  if (select leader from groups where id = g) is distinct from p_player then raise exception 'not_leader'; end if;
  -- heute angelegt: ganz weg; sonst endet sie heute und zählt für die Tage davor weiter
  delete from challenges where id = p_id and group_id = g and start_day >= d;
  update challenges set end_day = d where id = p_id and group_id = g and end_day is null;
end $$;

-- Setzt oder entfernt eigene Häkchen: [{"c": Challenge, "d": Tag, "v": true/false}, …], höchstens 40 auf einmal.
create or replace function set_checks(p_player uuid, p_secret text, p_checks json) returns void
language plpgsql security definer set search_path = public as $$
declare g uuid; x json; cid uuid; d date;
begin
  g := _group_of(p_player, p_secret);
  if json_typeof(p_checks) <> 'array' or json_array_length(p_checks) > 40 then raise exception 'bad_checks'; end if;
  for x in select * from json_array_elements(p_checks) loop
    cid := (x->>'c')::uuid; d := (x->>'d')::date;
    if d is distinct from _day(d) then continue; end if; -- nur heute und die Tage direkt davor
    if not exists (select 1 from challenges where id = cid and group_id = g and start_day <= d and (end_day is null or d < end_day)) then continue; end if;
    if (x->>'v')::boolean then
      insert into checks (challenge_id, player_id, day) values (cid, p_player, d) on conflict do nothing;
    else
      delete from checks where challenge_id = cid and player_id = p_player and day = d;
    end if;
  end loop;
end $$;

-- Nur diese Funktionen darf die App aufrufen.
revoke all on function _group_of(uuid, text), _clean_code(text), _new_secret(), _day(date) from public, anon, authenticated;
revoke all on function create_group(text, text, text), join_group(text, text, text),
  report(uuid, text, text, text, int, bigint, int, date, int, int, int, date),
  board(uuid, text), cheer(uuid, text, uuid), leave_group(uuid, text), claim_leader(uuid, text),
  challenge_save(uuid, text, uuid, text, text, text, text, int[], date), challenge_end(uuid, text, uuid, date),
  set_checks(uuid, text, json) from public;
grant execute on function create_group(text, text, text), join_group(text, text, text),
  report(uuid, text, text, text, int, bigint, int, date, int, int, int, date),
  board(uuid, text), cheer(uuid, text, uuid), leave_group(uuid, text), claim_leader(uuid, text),
  challenge_save(uuid, text, uuid, text, text, text, text, int[], date), challenge_end(uuid, text, uuid, date),
  set_checks(uuid, text, json) to anon, authenticated;
