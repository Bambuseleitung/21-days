# 21 Days

Eine Habit-Tracker-App zum Angewöhnen und Abgewöhnen von Gewohnheiten. Die ersten 21 Tage sind die Startphase, danach geht es weiter bis zur Automatik.

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
- **Haptik** bei Antippen, Erfolgen, Minispielen und Belohnungen (in der App echt über Android und iOS, im Browser per Vibration). Abschaltbar unter **Profil → Haptik**.
- **Soundeffekte** bei Antippen, Öffnen von Fenstern und allen Belohnungen. Abschaltbar unter **Profil → Sound**. Auf dem iPhone folgt der Ton dem Stumm-Schalter.
- Hochformat, eigenes Icon und Startbild, Schrift in der App, Android-Zurück-Taste schließt Fenster.

Die Daten liegen in der App auf dem Gerät. Die App im Browser und die App auf dem Handy haben getrennte Daten. Übertragen geht über **Profil → Backup**.

## Speicherung

Alle Daten bleiben lokal im Browser auf deinem Gerät. Nichts wird an einen Server geschickt.

- Jede Adresse hat ihren eigenen Speicher. Wenn du `index.html` direkt geöffnet hast, kommen deine Daten nicht automatisch nach `localhost:8021`. Übertragen kannst du sie mit **Profil → Backup**: dort herunterladen und an der neuen Adresse wiederherstellen.
- Regelmäßig ein Backup herunterladen schützt vor Datenverlust, z. B. wenn du den Browserverlauf löschst.

## Dateien

| Datei | Zweck |
|---|---|
| `index.html` | Die komplette App |
| `start.bat` | Startet den lokalen Server per Doppelklick |
| `server.ps1` | Server ohne Installation (wird von `start.bat` genutzt, wenn Python fehlt) |
| `manifest.webmanifest`, `sw.js`, `icons/`, `fonts/` | Installierbare App, Offline-Modus, Schrift |
| `package.json`, `capacitor.config.json`, `scripts/`, `assets/`, `.github/workflows/mobile.yml` | Bau der Android- und iOS-App |

## Features

- Begleiter-Figur, die aus einem Ei schlüpft, mit deinem Level wächst und auf deinen Tag reagiert
- Globale Tages-Serie mit automatischen Schutzschilden
- Tages-Quests mit Quest-Truhe
- Münzen und Shop: Outfits, Farbthemen, Schutzschilde und eigene echte Belohnungen
- Angewöhnen mit Mengenzielen, festen Wochentagen, Tageszeiten und Wenn-Dann-Plan
- Abgewöhnen mit sekundengenauem Zähler, gespartem Geld und gewonnener Zeit, Meilensteinen und SOS-Atemübung
- Morgen-Versprechen und Abend-Rückblick mit Stimmungsverlauf
- Statistiken: Serien-Kalender, Aktivität der letzten 20 Wochen, Wochenansicht, Auslöser-Analyse
- 22 Abzeichen, Level-System, Konfetti, Sounds und Animationen
