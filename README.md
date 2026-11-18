# 21 Days

Eine Habit-Tracker-App zum Angewöhnen und Abgewöhnen von Gewohnheiten. Die ersten 21 Tage sind die Startphase, danach geht es weiter bis zur Automatik.

**Beta, Play Store, iPhone und Premium:** siehe [BETA.md](BETA.md).

## Auf dem PC hosten

1. Doppelklick auf **`start.bat`**.
2. Der Browser öffnet sich automatisch unter **http://localhost:8021**.
3. Das schwarze Fenster offen lassen. Wenn du es schließt, stoppt der Server.

`start.bat` braucht keine Installation:
- **Ist Python installiert**, startet ein Server, der auch im WLAN erreichbar ist. Die Adresse fürs Handy steht im Fenster, z. B. `http://192.168.0.23:8021`. Windows fragt beim ersten Start eventuell nach einer Firewall-Freigabe. Dafür „Private Netzwerke“ erlauben.
- **Ohne Python** läuft der eingebaute PowerShell-Server (`server.ps1`). Er ist nur auf diesem PC erreichbar.

### Als App installieren

Öffne http://localhost:8021 in Chrome oder Edge und klick auf das Installieren-Symbol in der Adressleiste (oder **Profil → Als App installieren**). 21 Days bekommt dann ein eigenes Fenster und ein Startmenü-Symbol und funktioniert auch offline.

Ein Hinweis zum Handy: Über eine WLAN-Adresse wie `http://192.168…` läuft die App im Handy-Browser, kann dort aber nicht installiert werden. Dafür verlangen Browser HTTPS.

## Android-APK und iPhone-IPA

Beides baut GitHub für dich. Auf dem PC ist dafür nichts nötig.

1. Lade alle Dateien dieses Ordners in das GitHub-Repository hoch (inklusive des versteckten Ordners `.github`, der Ordner `assets`, `fonts`, `scripts`, `package.json` und `package-lock.json`).
2. Öffne im Repository den Reiter **Actions**, wähle **„Android-APK und iPhone-IPA“** und klicke auf **Run workflow**.
3. Nach ein paar Minuten liegen unten auf der Seite des Laufs zwei Downloads:
   - **21Days-apk** → `21Days.apk`. Aufs Android-Handy kopieren, antippen und installieren (einmal „Unbekannte Apps installieren“ erlauben).
   - **21Days-ipa** → `21Days.ipa`. Ungesigniert. Mit **Sideloadly** und deiner Apple-ID aufs iPhone bringen. Die Signatur gilt 7 Tage, danach neu installieren.

Die App ist dieselbe Weboberfläche in einer Hülle (Capacitor). Dazu kommt:
- **Haptik** bei Antippen, Erfolgen und Belohnungen (in der App echt über Android und iOS, im Browser per Vibration). Abschaltbar unter **Profil → Haptik**.
- **Soundeffekte** bei Antippen, Öffnen von Fenstern und allen Belohnungen. Abschaltbar unter **Profil → Sound**. Auf dem iPhone folgt der Ton dem Stumm-Schalter.
- **Erinnerungen**: pro Gewohnheit eine Uhrzeit (Bearbeiten → Erinnerung) und eine **Abend-Erinnerung** unter Profil, die nur kommt, wenn noch etwas offen ist. Erledigtes erinnert nicht mehr. Geplant wird immer eine Woche im Voraus: Wer die App eine Woche lang nicht öffnet, bekommt danach keine Erinnerungen mehr, bis er sie wieder öffnet.
- **Widget (Android)**: lange auf den Startbildschirm drücken → Widgets → 21 Days. Es zeigt den Stand von heute, deine Serie und deinen Platz in der Gruppe samt Team-Serie. Ein iPhone-Widget gibt es nicht.
- Hochformat, eigenes Icon und Startbild, Schrift in der App, Android-Zurück-Taste schließt Fenster.

Die Daten liegen in der App auf dem Gerät. Die App im Browser und die App auf dem Handy haben getrennte Daten. Übertragen geht über **Profil → Backup**.

## Training (Gym-Logger)

Training gehört zu deinen Gewohnheiten: Leg die Gewohnheit **„Sport“** an (oder schalte bei einer Gewohnheit „Mit Training verknüpfen“ ein). Ein Tipp auf ihren Haken öffnet das Training. 238 Übungen sind schon dabei, sortiert nach Muskelgruppe, dazu acht Vorlagen (Push, Pull, Beine, Oberkörper, Unterkörper, Ganzkörper, Zuhause, Bauch).

**Einrichten:** Beim ersten Mal fragt die App, ob du im **Fitnessstudio** oder mit **Calisthenics** trainierst, wie viel Erfahrung du hast (Einsteiger, Fortgeschritten, Profi) und an wie vielen Tagen. Dann schlägt sie einen Plan vor (Ganzkörper, Ober-/Unterkörper oder Drücken/Ziehen/Beine) und erklärt Sätze, Wiederholungen und Steigerung. Übernommen wird nur, was du bestätigst. Calisthenics-Übungen sind in der Übungsliste nach Stufe markiert. „Plan neu einrichten“ geht jederzeit.

**Eigene Routinen:** Unter „Routinen“ auf **Neu** tippen, Namen vergeben, Übungen suchen und hinzufügen, mit den Pfeilen sortieren, speichern. Jede Vorlage lässt sich als eigene Routine kopieren und anpassen, und jedes beendete Workout kann zur Routine werden.

1. Routine antippen und starten, oder **Freies Training** wählen und Übungen hinzufügen.
2. Gewicht und Wiederholungen eintragen und den Satz abhaken. Beim nächsten Mal stehen deine letzten Werte schon da.
3. Nach jedem Satz läuft der Pausen-Timer (90 Sekunden, mit −15 und +15 anpassbar).
4. **Beenden**: Du siehst Dauer, Sätze, Rekorde und das bewegte Gewicht, und die Gewohnheit ist abgehakt.

Mit dem Pfeil oben links blendest du das Workout aus, es läuft weiter. Die Gewohnheit zeigt dann die laufende Zeit, ein Tipp auf den Haken holt es zurück. Wer nicht protokollieren will, findet im Training „Ohne Protokoll abhaken“.

Was dazukommt:
- **Rekorde** werden beim Abhaken erkannt und gefeiert. Bei Gewichten zählt die geschätzte Maximalkraft, sonst Wiederholungen, Zeit oder Strecke.
- **Coach**: Dein Begleiter schlägt die Routine vor, deren Muskeln am besten erholt sind, und gibt je Übung einen Tipp („Letztes Mal 60 kg × 8. Schaffst du heute 9?“).
- **Erholung**: Unter Statistik steht für jede Muskelgruppe, ob sie bereit ist oder noch Pause braucht.
- **Scheibenrechner** für Langhantel-Übungen (20-kg-Stange).
- Ein Workout gibt XP und Münzen und hakt verknüpfte Gewohnheiten ab (z. B. „Sport“, Schalter „Mit Training verknüpfen“ beim Bearbeiten).
- Der Bildschirm bleibt während des Workouts an, wenn das Gerät das unterstützt.

## Erkenntnisse, Wochenrückblick und Zeitkapsel

- **Erkenntnisse** (Fortschritt): 21 Days liest aus deinen Daten Muster, z. B. deinen stärksten Wochentag, wackelige Gewohnheiten und ob Training oder starke Tage deine Stimmung heben.
- **Wochenrückblick**: Jede Woche erscheint auf „Heute“ ein Rückblick auf die Vorwoche mit Quote, XP, stärkster Gewohnheit und Training.
- **Zeitkapsel** (Detailansicht einer Gewohnheit): Schreib einen Brief an dein Ich in 21 Tagen. Er bleibt versiegelt und lässt sich erst dann öffnen.

## Gruppen einrichten (Rangliste mit Freunden)

Die Gruppe findest du unter **Profil → Gruppe**. Dort erstellst du eine Gruppe und lädst Freunde per QR-Code, Link oder Code ein. Alle sehen die XP der Woche und gesamt, Level, Serie und wie viele Gewohnheiten jeder heute geschafft hat. Sie sehen **nie** die Namen deiner Gewohnheiten, Rückfälle, SOS-Momente oder dein Tagebuch. Das ist technisch ausgeschlossen: Die App schickt diese Daten gar nicht erst los. Man kann sich außerdem gegenseitig anfeuern.

Dafür braucht die App einen kleinen kostenlosen Server (Supabase). Das richtest du einmal ein:

1. Auf https://supabase.com ein kostenloses Konto anlegen und ein neues Projekt erstellen.
2. Im Projekt links **SQL Editor** → **New query**. Den kompletten Inhalt von `supabase/schema.sql` einfügen und auf **Run** klicken. Das legt die Tabellen an und sperrt sie: Die App darf nur feste Funktionen aufrufen.
3. Unter **Project Settings → API** zwei Werte kopieren: die **Project URL** und den Schlüssel **anon public**.
4. Beide in `config.js` eintragen (`supabaseUrl` und `supabaseKey`), die Datei auf GitHub hochladen und den Workflow neu starten. Der anon-Schlüssel ist dafür gedacht, in Apps zu stehen.
5. Alle Freunde installieren die App aus **demselben** Lauf, dann haben alle denselben Server.

**Server aktualisieren:** Nach einem App-Update mit neuen Gruppen-Funktionen (zuletzt: Challenges) `supabase/schema.sql` im SQL Editor einfach noch einmal komplett ausführen. Die Datei ist dafür gemacht, vorhandene Gruppen und Daten bleiben erhalten. Solange das fehlt, zeigt die Gruppe einen Hinweis, die Rangliste läuft trotzdem weiter.

### Gruppen-Challenges

Der **Leader** (wer die Gruppe erstellt hat) legt unter **Gruppe → Challenges → Neu** Challenges an, zum Beispiel „10.000 Schritte“ (Angewöhnen) oder „Kein Zucker“ (Abgewöhnen), mit Symbol, Farbe und Wochentagen. Höchstens 10 laufen gleichzeitig.

- Jedes Mitglied bekommt die Challenge automatisch als Gewohnheit. Sie steht auf **Heute** oben im Block „Challenges“ und wird dort abgehakt wie jede Gewohnheit. Name, Tage und Aussehen legt nur der Leader fest, eigene Notizen und eine Erinnerung darf jeder setzen.
- An jeder Challenge siehst du, wer sie heute schon geschafft hat („2/3“ mit den Anfangsbuchstaben).
- **Team-Serie**: Sie wächst nur an Tagen, an denen alle Mitglieder alle Challenges geschafft haben. Fehlt einer, beginnt sie von vorn. Schafft die Gruppe einen Tag komplett, bekommt jeder +25 XP und +10 Münzen.
- Challenges zählen wie jede Gewohnheit für XP, deshalb steigen sie auch in der Wochen-Rangliste.
- **Aktivität**: Wer was geschafft hat und wer wen angefeuert hat, in den letzten zwei Tagen. Daneben kannst du direkt anfeuern.
- Beendet der Leader eine Challenge, verschwindet sie bei allen. Verlässt der Leader die Gruppe, übernimmt das Mitglied, das am längsten dabei ist. Ältere Gruppen ohne Leader: Das erste Mitglied, das auf „Leader werden“ tippt, übernimmt.
- Abgehakt werden kann nur heute (und gestern, wegen Zeitzonen). An den Server geht nur, welche Challenge du an welchem Tag geschafft hast, weiterhin nie deine privaten Gewohnheiten.

Gruppen haben höchstens 20 Mitglieder. Wer den Gruppen-Code kennt, kann beitreten, gib ihn also nur an Freunde weiter. Der Link `days21://join/CODE` öffnet die App direkt (in manchen Chat-Apps ist er nicht anklickbar, dann den Code eintippen). Im Browser geht auch `…/index.html#join=CODE`.

## Vokabel-Pack

Lege über das Plus die Gewohnheit **„Vokabel-Pack“** an (oder wähle beim Start das Ziel „Wortschatz erweitern“). Jeden Tag öffnest du ein Pack mit 3 neuen, seltenen deutschen Wörtern:

1. Pack gedrückt halten: Es bebt, leuchtet und reißt auf (mit Haptik und Sound, die immer stärker werden).
2. Jede Karte baut Spannung auf, die Aura zeigt die Seltenheit an, dann wird sie umgedreht. Die dritte Karte ist öfter selten, episch oder legendär. Seltene Karten geben Münzen und glitzern, legendäre lösen ein Feuerwerk aus.
3. Zu jedem Wort gibt es Wortart, Bedeutung und einen Beispielsatz mit hervorgehobenem Wort.
4. Am Ende hakst du die Gewohnheit ab.

Es gibt 991 Wörter (`vocab.js`). Ein Wort kommt erst wieder, wenn alle einmal dran waren (nach rund 330 Tagen). Alle gezogenen Karten stehen in der **Sammlung** (in der Detailansicht der Gewohnheit). Ohne Bewegung (Systemeinstellung „Bewegung reduzieren“) erscheinen die Karten sofort.

## Ziele je Gewohnheit (Messarten)

Im Editor wählst du unter **Ziel → Messart**, wie eine Gewohnheit zählt. Die Vorlagen bringen passende Ziele schon mit.

| Messart | Beispiel | So funktioniert's |
|---|---|---|
| **Abhaken** | Vitamine nehmen | Ein Tipp auf den Kreis, fertig. |
| **Menge** | Wasser 2.000 ml, 10 Seiten, 5 Portionen | Der Kreis addiert den ersten Schnell-Wert (z. B. +250 ml). In der Detailansicht gibt es alle Schnell-Buttons und eine freie Eingabe. Einheiten: Gläser, ml, Seiten, Portionen, Wdh., km, Kapitel oder eigene. |
| **Timer** | Lesen 20 Min, Meditieren 10 Min | Start, Pause, Speichern. Der Timer läuft weiter, wenn du die App schließt, und endet mit einem Gong. In der App kommt am Ziel eine Mitteilung. Minuten lassen sich auch nachtragen. |
| **Aufstehen** | Früh aufstehen, Ziel 06:30 + 30 Min Puffer | Zählt, wenn du bis Weckzeit plus Puffer auf „Ich bin wach“ tippst. Die Aufstehzeiten der letzten Woche stehen in der Detailansicht. |
| **Tagebuch** | Tagebuch schreiben, mind. 30 Wörter | Der Kreis öffnet das Tagebuch mit Wortzähler. Abgehakt wird, sobald die Einträge des Tages lang genug sind. |
| **Schritte** | 10.000 Schritte | Automatisch aus der Fitness-App, per iPhone-Kurzbefehl oder per Eingabe (siehe unten). |

### Wecker (Aufstehen)

- **Android-App:** „Wecker“ im Editor stellt einen echten, wiederkehrenden Wecker in deiner Uhr-App (an deinen geplanten Tagen). Zusätzlich kommt zur Weckzeit eine Mitteilung; Antippen zählt als „Ich bin wach“.
- **iPhone-App:** Apps dürfen keine Wecker in der Uhr-App stellen. Du bekommst zur Weckzeit eine Mitteilung (Antippen zählt als wach). Für einen lauten Wecker stellst du ihn in der Uhr-App und lässt dich automatisch abhaken: Kurzbefehle → Automation → **Wecker** → **Wird gestoppt** → Aktion **URL öffnen** mit `days21://wake`.
- **Browser:** In der Detailansicht gibt es den Wecker als wiederkehrenden Kalender-Termin mit Alarm (`.ics`).

### Schritte aus Apple Fitness, Google Fit, Samsung Health …

- **In der App:** Ist „Automatisch übernehmen“ an, liest 21 Days beim Öffnen die Schritte von heute aus **Apple Health** (iPhone, Apple Watch, Apple Fitness) bzw. **Health Connect** (Android; Google Fit, Samsung Health, Fitbit usw., wenn sie mit Health Connect verbunden sind). Beim ersten Mal fragt das Handy nach der Erlaubnis. Gelesen wird nur die Schrittzahl, nichts verlässt das Gerät (`privacypolicy.html`).
- **iPhone-Kurzbefehl** (klappt auch, wenn Health in der per Sideloadly installierten App nicht freigegeben wird): Aktion **Health-Beispiele suchen** (Schritte, Startdatum heute) → **Statistik berechnen** (Summe) → **URL öffnen** `days21://steps/` + Variable *Statistik*. Als Automation z. B. täglich um 21:00.
- **Browser:** Ein Link wie `http://localhost:8021/#steps=8500` trägt die Zahl ein, wenn du 21 Days auf demselben Gerät nutzt. Oder du gibst die Schritte in der Detailansicht ein.

Hinweis: HealthKit in einer per Sideloadly installierten iPhone-App hängt davon ab, ob deine Apple-ID die Berechtigung erhält. Klappt das nicht, nimm den Kurzbefehl.

## Tagebuch

Zu jeder Gewohnheit gibt es in der Detailansicht ein Tagebuch, und unter **Fortschritt → Journal** siehst du alle Einträge mit Filter. Fragen-Vorschläge helfen beim Start, der erste Eintrag am Tag gibt 5 Münzen und 5 XP. Das Tagebuch bleibt auf dem Gerät und ist im Backup enthalten.

## Speicherung

Alle Daten bleiben lokal auf deinem Gerät. Nur wenn du einer Gruppe beitrittst, schickt die App Name, Level, XP, Serie, den Tagesfortschritt und deine Häkchen bei Gruppen-Challenges an den Gruppen-Server.

- In der Android- und iPhone-App gibt es keinen Datei-Download. Dort kopierst du das Backup (**Profil → Backup → Backup kopieren**) und fügst es auf dem anderen Gerät unter „Oder kopiertes Backup einfügen“ ein.
- Jede Adresse hat ihren eigenen Speicher. Wenn du `index.html` direkt geöffnet hast, kommen deine Daten nicht automatisch nach `localhost:8021`. Übertragen kannst du sie mit **Profil → Backup**: dort herunterladen und an der neuen Adresse wiederherstellen.
- Regelmäßig ein Backup herunterladen schützt vor Datenverlust, z. B. wenn du den Browserverlauf löschst.

## Dateien

| Datei | Zweck |
|---|---|
| `index.html` | Die komplette App |
| `start.bat` | Startet den lokalen Server per Doppelklick |
| `server.ps1` | Server ohne Installation (wird von `start.bat` genutzt, wenn Python fehlt) |
| `manifest.webmanifest`, `sw.js`, `icons/`, `fonts/` | Installierbare App, Offline-Modus, Schrift |
| `config.js`, `supabase/schema.sql`, `vendor/` | Gruppen-Server (Zugangsdaten, Datenbank), QR-Code-Bibliothek |
| `package.json`, `capacitor.config.json`, `scripts/`, `assets/`, `.github/workflows/mobile.yml` | Bau der Android- und iOS-App |
| `native/android/` | Android-Widget und Wecker (Java, Layout), wird beim Bau ins Android-Projekt kopiert |
| `privacypolicy.html` | Datenschutz-Hinweis für Health Connect (Schritte lesen) |

## Features

- **Beweis statt Haken**: Was die App messen kann (Wecker-Mitteilung, Apple Health/Health Connect, Timer, Workout, Tagebuch, Bildschirmzeit auf Android), zählt als bewiesen und gibt volle XP. Was nur von Hand abgehakt wird, ist „selbst bezeugt“ (gestrichelt, 80 % XP).
- **21-Tage-Reise**: Heute zeigt deinen Tag im Ring aus 21 Segmenten und den Abschnitt (Start, Das Tal, Durchbruch, Festigen). Unter **Reise** hat jede Gewohnheit ihren Weg über 21 Tage, Keimi wächst vom Samen zur Pflanze. An Tag 21 gibt es ein **Zertifikat** zum Teilen.
- Reiter: **Heute · Beweise · Reise · Ich**
- Globale Tages-Serie mit automatischen Schutzschilden
- Tages-Quests mit Quest-Truhe
- Münzen für eigene echte Belohnungen und Schutzschilde (unter Ich)
- Angewöhnen mit Mengenzielen, festen Wochentagen, Tageszeiten und Wenn-Dann-Plan
- Abgewöhnen mit sekundengenauem Zähler, gespartem Geld und gewonnener Zeit, Meilensteinen und SOS-Atemübung
- Morgen-Versprechen und Abend-Rückblick mit Stimmungsverlauf
- Statistiken: Serien-Kalender, Aktivität der letzten 20 Wochen, Wochenansicht, Auslöser-Analyse
- Schlichtes Design nach Apples Gestaltungsregeln, hell und dunkel, Gewohnheiten zuerst
- Gym-Logger in der Gewohnheit „Sport“: 238 Übungen, eigene Routinen, Rekorde, Pausen-Timer, Coach und Erholungsübersicht
- Erkenntnisse aus den eigenen Daten, Wochenrückblick und Zeitkapsel
- Ruhetage: Tage ohne geplante Gewohnheit brechen die Serie nicht und kosten kein Schutzschild
- Abzeichen, Level-System, Konfetti, Sounds und Animationen
