# 21 Days: Projektkontext für Claude Code

## Was das ist
„21 Days“ ist eine Habit-Tracker-Web-App (Deutsch) zum Angewöhnen und Abgewöhnen von Gewohnheiten. Sie ist mobil-first gebaut und orientiert sich an Duolingo (Serie, Schutzschilde, Quests), Finch (Begleiter-Figur, Shop), I Am Sober (Live-Zähler, Ersparnis, SOS) und Streaks/Habitify (Mengenziele, Wochentage, Statistiken).
Die 21 Tage sind als Startphase gedacht. Laut Forschung (Lally 2010, Singh 2024) dauert Gewohnheitsbildung meist 2–5 Monate. Die App hat deshalb drei Phasen: Start (bis Tag 21), Festigen (bis Tag 66), Automatisch.

## Wünsche des Nutzers
- Antworten kurz halten, auf Deutsch.
- Die App soll Dopamin auslösen: viele Animationen, Konfetti, Sounds, Belohnungen.
- Keine Speicherung bei claude.ai. Alles lokal auf dem PC, Daten nur im Browser (localStorage).
- Wird lokal gehostet (`start.bat`). Später soll es auch eine echte App werden.
- GitHub-Repo: https://github.com/Bambuseleitung/21-days. Der Nutzer lädt Dateien bisher manuell hoch.

## Aufbau
- `index.html`: die komplette App (HTML, CSS und JS in einer Datei, kein Build-Schritt, Vanilla JS).
- `start.bat`: startet `python -m http.server 8021` (erreichbar im WLAN) oder ersatzweise `server.ps1` (PowerShell-HttpListener, nur localhost).
- `manifest.webmanifest`, `sw.js`, `icons/`: installierbare App (PWA), offline per Service Worker (zuerst Netzwerk, sonst Cache). Bei Änderungen am Cache-Inhalt `CACHE` in `sw.js` hochzählen.
- Gruppe/Rangliste: Modul „Gruppe“ in index.html (`rpc`, `pushStats`, `loadBoard`, `viewGruppe`), Backend Supabase ohne SDK per `fetch` auf `/rest/v1/rpc/<funktion>`. `supabase/schema.sql` sperrt die Tabellen (RLS ohne Regeln), die App darf nur `create_group`, `join_group`, `report`, `board`, `cheer`, `leave_group`. Gesendet wird nur Name, Farbe, Level, XP, Wochen-XP, Serie, erledigt/geplant heute. Nie Gewohnheiten oder Tagebuch. Zugang in `config.js` (oder localStorage `21days-config` zum Testen). Einladung: Code `XXXXX-XXXXX`, QR und Link `days21://join/CODE` (Intent-Filter und URL-Schema werden im Workflow gesetzt, Plugin App `appUrlOpen`), Web: `#join=CODE`. Test ohne Supabase: Schema in PGlite plus kleiner Server, der `/rest/v1/rpc/<fn>` anbietet.
- Vokabel-Pack: Gewohnheit mit `special: "vocab"` (Vorlage „Vokabel-Pack“, Ziel „Wortschatz erweitern“). Daten in `vocab.js` (`window.VOCAB`, 991 Einträge `[Wort mit Artikel, n|v|a, Bedeutung, Satz mit *Wort*]`). `state.vocab` = `got` (Sammlung, Index → Datum), `seen` (aktuelle Runde, kein Wort doppelt bis alle durch sind), `today` (`day`, `ids`, `rev` = aufgedeckte Karten, übersteht Neuladen). Seltenheit je Wort fest per `hash01` (`vRar`), dritter Platz bevorzugt seltene Karten. Pack-Öffnen: `openPack` → Halten (`pkHoldStart`, braucht `requestAnimationFrame`, bei „Bewegung reduzieren“ und Tastatur sofort) → `pkTear` → Karten (`pkFlip`, `pkReveal`) → Zusammenfassung → `finishVocab` hakt die Gewohnheit ab. Sammlung: `openCollection`, `openWord`. Zum Prüfen der Einträge: Skript, das Format, Markierung `*Wort*` und Abdeckung der Wortliste kontrolliert.
- Tagebuch: `state.journal` (Eintrag: day, habitId, hname, mood, text), `journalCard` in der Detailansicht, Reiter Journal unter Fortschritt. Nur lokal.
- Fenster und Animationen: `openSheet` tauscht den Inhalt eines offenen Fensters aus (kein erneutes Einblenden, Scroll bleibt), `closeSheet` blendet aus, `softRender("#id")` rendert nur einen Bereich (Shop-Reiter, Fortschritt-Reiter, Tag-Filter, Gruppe) statt der ganzen Seite. Easing überall sanft (`cubic-bezier(.32,.72,0,1)`), kein Überschwingen bei häufigen Tipps.
- Native Apps (Capacitor 8): `package.json`, `capacitor.config.json`, `scripts/build-web.mjs` (kopiert nach `www/`), `assets/` (Icon, Startbilder), `.github/workflows/mobile.yml` baut per GitHub Actions eine Debug-APK (ubuntu) und eine ungesignierte IPA (macos-15, für Sideloadly). `android/`, `ios/`, `www/` werden im Workflow erzeugt und sind nicht im Repo. Haptik: `vibrate()` nutzt `Capacitor.Plugins.Haptics` (iOS hat kein `navigator.vibrate`), Schalter `profile.haptics`. Jeder Tipp bekommt Klick und Haptik, außer Aktionen in `SELF_SOUND`/`SELF_HAPTIC` (haben eigenes Feedback). Android-Zurück-Taste über das Plugin App. Schrift Nunito liegt in `fonts/`. Sichere Ränder über `--sat`/`--sab`. Auf Windows lässt sich nur `npx cap add android` prüfen, die Builds laufen in der Cloud.

## Wichtige Teile in index.html (im Script)
- State: `freshState()`, `migrate()` (v1 → v2), localStorage-Key `21days-state-v2`.
- Gewohnheit: `kind` build/break, `target`/`unit` (Mengenziel), `days` (Wochentage 0=Mo), `time` (morning/noon/evening/any), `log{datum:anzahl}`, `xp{datum:xp}`, bei break zusätzlich `quitStart`, `money`, `minutes`, `reasons`, `relapses`.
- Serien: `hStreak` (pro Gewohnheit, nachsichtig: ein verpasster geplanter Tag ist erlaubt), `gStreak` (global, ein Häkchen pro Tag reicht), `applyFreezes` (Schutzschilde automatisch, maximal 3).
- Belohnungen: `addXP`, `addCoins`, `levelOf`/`lvlBase` (50·L·(L−1)), `BADGES` + `evaluateBadges`, `QUESTS` + `questsFor` (3 pro Tag, danach eine Truhe), `ITEMS` (Shop), eigene Belohnungen.
- Begleiter: `petSVG()` (Stufen nach Level, Stimmung, Outfits), `petLine()`.
- Effekte: `burst` (Konfetti-Canvas), `flyCoins`, `praise`, `pushOverlay` (Vollbild-Feiern), `sfx` (WebAudio).
- Views: `viewToday`, `viewProgress`, `viewPet` (Begleiter + Shop), `viewProfile`. Routing über den Hash: #heute, #fortschritt, #begleiter, #profil.
- Glücksrad: `WHEEL`, `openWheel`, `spinWheel`, `wheelCard`. Drehungen (`state.flags.spins`) gibt es bei Meilensteinen und jeder 7-Tage-Serie. Der Preis wird vor dem Drehen gezogen und gespeichert. Mit reduzierter Bewegung erscheint das Ergebnis sofort.
- Shop: `ITEMS` hat Hüte, Brillen, Halsschmuck (gezeichnet in `petSVG`) und Themen (`THEMES`). Neue Themenfarben brauchen mindestens 4,5:1 Kontrast zu weißem Text.
- Habitica-Funktionen: Schwierigkeit (`DIFFS`, `h.diff` 1–3, Faktor auf XP), Tags (`state.tags`, ein Tag pro Gewohnheit/Aufgabe, Filter `tagFilter`), Aufgaben (`state.todos`: Titel, Fälligkeit, Checkliste mit je 3 XP, `tapTodo`, `saveTodo`; überfällig wird nie bestraft), Wochen-Boss (`state.boss`, `ensureBoss`, `bossHit` in `addXP`: jede XP ist Schaden, Sieg gibt Münzen, Futter, Drehung). Nicht übernommen: HP-Verlust, Klassen/Mana, Party und Gilden (brauchen ein Backend oder widersprechen dem Prinzip ohne Strafe).
- Pflege (Pou/Tamagotchi): `state.pet` = food, hunger, fun, clean (0–100, sinken über die Zeit, rein aus `t` berechnet: `petNow`), best. Futter wächst 1:1 mit XP (Hook in `addXP`), wird aber getrennt ausgegeben (`feedPet`), das Level sinkt nie. Bedürfnisse bestrafen nicht (kein Serienverlust). Waschen: `washPet`. Zimmer: Items mit slot `bg` (`.scene.sc-*`). Stimmung „sad“ und Schmutzflecken in `petSVG`.
- Minispiele: `startGame` (Fruchtfang, Blasenjagd), `gameLoop`, `endGame`. Runden pro Tag = 1 + erledigte Gewohnheiten + 1 bei perfektem Tag (`playsLeft`). Belohnung: bis 40 Münzen, Laune, Rekorde in `state.pet.best`.
- Dopamin: `giftCard`/`openGift` (Tagesgeschenk, wächst bis Tag 7), 20 % Leckerli-Drop beim Abhaken, Salto bei jedem 10. Streicheln, Wohlfühl-Bonus (`careBonus`, alle Werte ≥ 80), roter Punkt am Begleiter-Reiter bei Bedarf.
- Aktionsprotokoll: `logChange` (aufgerufen in `save()`) vergleicht den State mit dem letzten Stand und schreibt jede Änderung in IndexedDB `21days-log` (Store `actions`: ts, device, action, target, changed, delta, habits). Die Geräte-ID steht in localStorage `21days-device`. Alles bleibt lokal. Export und Leeren unter Profil → Aktionsprotokoll. Max. 5000 Einträge. „Neu anfangen“ leert das Protokoll mit. Für ein gemeinsames Protokoll mehrerer Geräte bräuchte es ein Backend.
- Design: Die App folgt den Regeln des Skills apple-design (Kontrast, Touch-Ziele ab 44 px, Bewegung optional, Text statt nur Farbe). Themenfarbe: `--p0` roh, `--pb` für Flächen unter weißem Text, `--p` für Akzenttext (im Dunkelmodus aufgehellt). Schriftgrößen sind in rem, mindestens 11 px.
- Social- und db-Code (`viewFriends`, `startSocial`, `syncPlayer`) ist noch drin, aber deaktiviert, weil es kein Backend gibt. Für echte Freunde-Features bräuchte es ein eigenes Backend (z. B. Supabase).

## Mögliche nächste Schritte
- Weitere Outfits und Themen, Glücksrad-Preise erweitern (z. B. Outfit-Gutschein).
- Echte App (z. B. Capacitor oder React Native) mit Push-Erinnerungen.
- Backend mit Login für Freunde-Liga und Sync.
