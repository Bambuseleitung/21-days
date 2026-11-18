# 21 Days: Beta, Play Store, iPhone und Premium

Diese Schritte kann nur der Besitzer der Konten machen. Der Code ist dafür vorbereitet.

## 1. Datenbank aktualisieren (einmal, 2 Minuten)

Supabase → SQL Editor → den ganzen Inhalt von `supabase/schema.sql` einfügen → Run.
Das ist gefahrlos wiederholbar. Neu sind: Wetten für die Gruppe (`set_bet`) und die Treue-Messung (`ping`, `retention`).

## 2. Android-Beta im Play Store

1. **Konto:** Google Play Console anlegen (einmalig 25 $).
2. **Upload-Schlüssel erzeugen** (einmal, gut aufheben, nie ins Repo):
   ```
   keytool -genkeypair -v -keystore upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```
3. **GitHub → Settings → Secrets and variables → Actions** → vier Secrets anlegen:
   - `ANDROID_KEYSTORE_B64`: Inhalt von `upload.jks` als Base64 (PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload.jks"))`)
   - `ANDROID_KEYSTORE_PASSWORD`: Passwort des Keystores
   - `ANDROID_KEY_ALIAS`: `upload`
   - `ANDROID_KEY_PASSWORD`: Passwort des Schlüssels
4. **Workflow „Android-APK und iPhone-IPA“ starten.** Danach liegt unter Artifacts zusätzlich `21Days-aab`. Die Versionsnummer steigt bei jedem Lauf von selbst.
5. **Play Console → App erstellen → Testen → Interner Test** → `21Days.aab` hochladen → Tester per E-Mail-Liste einladen (bis 100).
6. **Datenschutzerklärung:** `privacypolicy.html` öffentlich erreichbar machen (z. B. GitHub Pages) und den Link in der Play Console eintragen. Vorher oben Name und E-Mail eintragen.
7. **Für eine öffentliche App** verlangt Google bei neuen privaten Konten einen geschlossenen Test mit mindestens 12 Testern über 14 Tage.

## 3. Messen, wer bleibt

Die Tester schalten in der Einführung oder unter Ich → Einstellungen „Anonym beim Verbessern helfen“ ein (aus Datenschutzgründen ist das aus, bis man zustimmt).

Auswertung in Supabase → SQL Editor:
```sql
select * from retention();
```
- **D1:** am Tag nach dem ersten Öffnen wieder da. Gut: über 40 %.
- **D7:** in der zweiten Woche wieder da. Gut: über 20 %.
- **D30:** zwischen Tag 30 und 59 wieder da. Gut: über 10 %.

## 4. iPhone (TestFlight und App Store)

1. **Apple Developer Program** (99 € im Jahr).
2. App-ID `de.bambuseleitung.days21` mit HealthKit anlegen.
3. Der Workflow baut die IPA bisher **ohne** Signatur (für Sideloadly). Für TestFlight braucht er ein Verteilungs-Zertifikat und ein Provisioning-Profil als Secrets. Das baue ich ein, sobald das Konto steht.
4. Der echte Wecker (AlarmKit) läuft nur ab iOS 26. Die Bildschirmzeit lässt sich auf dem iPhone ohne Sondergenehmigung von Apple nicht automatisch lesen.

## 5. Premium einschalten (erst nach der Beta)

1. Im Play Store und App Store ein Abo anlegen (z. B. 3,99 € im Monat, 24,99 € im Jahr).
2. Bei RevenueCat ein Projekt anlegen, beide Stores verbinden, ein Entitlement **`pro`** und ein Angebot mit den Abos anlegen.
3. Plugin einbauen: `npm install @revenuecat/purchases-capacitor` (dann baue ich die Anbindung fertig und teste sie).
4. In `config.js`: `premium: true` und `revenuecatKey: "…"` (öffentlicher SDK-Schlüssel von RevenueCat).

Solange `premium: false` ist, ist alles frei. Wer die App vor Premium schon genutzt hat, behält später alles (`flags.founder`).
Kostenlos bleiben dann: 3 Gewohnheiten, alle Beweise, Rettungstag, Wette mit dir selbst, Gruppen beitreten.
Premium: unbegrenzte Gewohnheiten, eigene Gruppen gründen, Wetten mit Freunden, Stufen bis Tag 66 und 100.
