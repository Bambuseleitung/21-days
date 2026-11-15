-- 21 Days: Gruppen und Rangliste
-- Einmal im Supabase-Dashboard unter "SQL Editor" einfügen und ausführen.
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

alter table groups enable row level security;
alter table players enable row level security;
alter table cheers enable row level security;

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
    'players', coalesce((
      select json_agg(json_build_object(
        'id', p.id, 'name', p.name, 'color', p.color, 'level', p.level, 'xp', p.xp,
        'week_xp', p.week_xp, 'week_start', p.week_start, 'streak', p.streak,
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
  if not exists (select 1 from players where group_id = g) then delete from groups where id = g; end if;
end $$;

-- Nur diese fünf Funktionen darf die App aufrufen.
revoke all on function _group_of(uuid, text), _clean_code(text), _new_secret() from public, anon, authenticated;
revoke all on function create_group(text, text, text), join_group(text, text, text),
  report(uuid, text, text, text, int, bigint, int, date, int, int, int, date),
  board(uuid, text), cheer(uuid, text, uuid), leave_group(uuid, text) from public;
grant execute on function create_group(text, text, text), join_group(text, text, text),
  report(uuid, text, text, text, int, bigint, int, date, int, int, int, date),
  board(uuid, text), cheer(uuid, text, uuid), leave_group(uuid, text) to anon, authenticated;
