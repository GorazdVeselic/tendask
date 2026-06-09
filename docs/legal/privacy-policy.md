# Tendask — Politika zasebnosti / Privacy Policy / Datenschutzerklärung

> **v1, 2026-06-09.** Velja za aplikacijo **Tendask** (Android).
> **Objavljeno na:** https://tendask.netlify.app/ (Netlify, iz `privacy-policy.html`).
> Ta URL je vpisan v Play Console (App content → Privacy policy).
> **Datum uveljavitve:** 2026-06-09 · **Različica:** 1.0
>
> _Opomba (ni del besedila politike): trije jeziki so v enem dokumentu zaradi lažjega pregleda
> in vzdrževanja — ob gostovanju jih lahko razdeliš na tri strani (`/privacy`, `/privacy-en`,
> `/privacy-de`). Za fizično osebo kot upravljavca zadošča ime + e-pošta; če želiš, lahko dodaš
> poštni naslov za močnejšo GDPR skladnost (neobvezno)._

---

## 🇸🇮 Slovenščina

### 1. Upravljavec podatkov

Upravljavec osebnih podatkov je **Gorazd Veselic** (fizična oseba).
Kontakt za vprašanja o zasebnosti in uveljavljanje pravic: **gorazd@spletnakoda.si**.

### 2. Načelo: zasebnost po zasnovi

Tendask je vrtnarska evidenčna aplikacija, ki deluje **offline-first** — tvoji podatki živijo
najprej na napravi. V oblak (Supabase, strežniki v EU) se sinhronizirajo le, če se prijaviš z
računom; brez prijave ostanejo izključno na napravi.

**Tvoje natančne lokacijske koordinate (GPS) nikoli ne zapustijo naprave za shranjevanje.**
Iz koordinat na napravi izračunamo le približno celico (sistem H3, ločljivost ~1 km) in v oblak
shranimo **samo to celico**, nikoli surovih koordinat. (Izjema je vremenska storitev — glej §5.)

### 3. Kateri podatki se obdelujejo

- **Podatki računa (ob prijavi):** e-poštni naslov (za prijavo s kodo) oz. identifikator Google
  računa (ob prijavi z Googlom). Brez prijave teh podatkov ni.
- **Vsebina vrta:** opravila, območja, rastline, opombe, opomniki, nastavitve obvestil. Brez
  prijave so samo na napravi; ob prijavi se sinhronizirajo v oblak.
- **Približna lokacija:** celice H3 (≈ 1 km in širše), izpeljane na napravi. Natančne koordinate
  so shranjene **samo lokalno** in se uporabljajo le za vreme.
- **Diagnostični podatki (Sentry):** ob napaki/sesutju poročilo o napaki, sled klicev, različica
  aplikacije ter tip naprave/OS. Namenjeni stabilnosti, ne identifikaciji.

### 4. Nameni obdelave in pravna podlaga (čl. 6 GDPR)

- **Zagotavljanje storitve** (vodenje vrtnega dnevnika, sinhronizacija med napravami) — pogodba
  (čl. 6(1)(b)).
- **Lokacija in obvestila** — privolitev (čl. 6(1)(a)); podaš jo prek sistemskih dovoljenj in jo
  lahko kadar koli prekličeš v nastavitvah naprave ali aplikacije.
- **Diagnostika in varnost** (odpravljanje napak, preprečevanje zlorab) — zakoniti interes
  (čl. 6(1)(f)).

### 5. Tretje osebe (obdelovalci in storitve)

- **Supabase** (zaledje — avtentikacija in baza). Strežniki v **EU (Frankfurt)**. Shranjuje:
  e-pošto, celice H3, vsebino vrta, nastavitve obvestil. Koordinate se ne pošiljajo.
- **Open-Meteo** (vreme in geokodiranje). Ob pridobivanju vremena se na storitev **pošljejo
  natančne koordinate**, ob iskanju kraja pa vpisano ime kraja. Podatki se uporabijo le za odgovor
  in se pri nas ne hranijo; Open-Meteo je brezplačen in ne zahteva računa.
- **Sentry** (diagnostika napak). Lahko obdeluje podatke izven EU (npr. ZDA) na podlagi standardnih
  pogodbenih klavzul.
- **Google** (prijava z Google računom — neobvezno). Ob prijavi poteka izmenjava prijavnega žetona.
- **Resend** (dostava e-pošte s prijavno kodo z naslova `no-reply@tendask.com`). Prejme naslov
  prejemnika za dostavo sporočila.

### 6. Hramba podatkov

Podatki računa in vrta se hranijo, dokler obstaja tvoj račun. Ob izbrisu računa (glej §7) se
oblačni podatki nepovratno izbrišejo (kaskadni izbris). Lokalni podatki ostanejo na napravi, dokler
ne odjaviš računa ali odstraniš aplikacije. Diagnostični podatki se hranijo omejen čas v skladu s
politiko Sentry.

### 7. Tvoje pravice

Skladno z GDPR imaš pravico do dostopa, popravka, izbrisa, omejitve in prenosljivosti podatkov ter
do ugovora obdelavi. V aplikaciji sta neposredno na voljo:

- **Izvoz podatkov** (Nastavitve → izvoz) — vsi tvoji podatki v datoteki JSON.
- **Izbris računa** (Nastavitve → izbris računa) — nepovraten izbris oblačnih podatkov + počiščenje
  lokalne baze.

Za ostale zahteve piši na **gorazd@spletnakoda.si**. Pritožbo lahko vložiš tudi pri Informacijskem
pooblaščencu RS (`ip-rs.si`).

### 8. Otroci

Aplikacija ni namenjena otrokom, mlajšim od 16 let, in jih ciljno ne obravnava.

### 9. Spremembe

Politiko lahko posodobimo; o bistvenih spremembah obvestimo prek aplikacije ali objave na tej
strani. Veljavna je vedno zadnja objavljena različica z datumom uveljavitve.

---

## 🇬🇧 English

### 1. Data controller

The controller of personal data is **Gorazd Veselic** (a natural person).
Contact for privacy questions and exercising your rights: **gorazd@spletnakoda.si**.

### 2. Principle: privacy by design

Tendask is a garden-logging app that is **offline-first** — your data lives on your device first.
It is synced to the cloud (Supabase, servers in the EU) only if you sign in with an account; without
an account it stays solely on your device.

**Your precise location coordinates (GPS) never leave the device for storage.** From the coordinates
we compute only an approximate cell on-device (H3 system, ~1 km resolution) and store **only that
cell** in the cloud — never raw coordinates. (The weather service is an exception — see §5.)

### 3. Data we process

- **Account data (when signed in):** email address (for code sign-in) or a Google account
  identifier (for Google sign-in). None of this exists without signing in.
- **Garden content:** tasks, areas, plants, notes, reminders, notification settings. Without an
  account this stays on the device; when signed in it syncs to the cloud.
- **Approximate location:** H3 cells (≈ 1 km and coarser), derived on-device. Precise coordinates
  are stored **locally only** and used solely for weather.
- **Diagnostic data (Sentry):** on an error/crash, an error report, stack trace, app version and
  device/OS type. Used for stability, not identification.

### 4. Purposes and legal basis (Art. 6 GDPR)

- **Providing the service** (keeping your garden log, syncing across devices) — contract
  (Art. 6(1)(b)).
- **Location and notifications** — consent (Art. 6(1)(a)); given via system permissions and
  withdrawable at any time in device or app settings.
- **Diagnostics and security** (fixing bugs, preventing abuse) — legitimate interest
  (Art. 6(1)(f)).

### 5. Third parties (processors and services)

- **Supabase** (backend — authentication and database). Servers in the **EU (Frankfurt)**. Stores:
  email, H3 cells, garden content, notification settings. No coordinates are sent.
- **Open-Meteo** (weather and geocoding). Fetching weather **sends precise coordinates** to the
  service; searching for a place sends the typed place name. Data is used only to answer the request
  and is not retained by us; Open-Meteo is free and requires no account.
- **Sentry** (error diagnostics). May process data outside the EU (e.g. the US) under Standard
  Contractual Clauses.
- **Google** (Google sign-in — optional). Sign-in performs a token exchange.
- **Resend** (delivery of sign-in code emails from `no-reply@tendask.com`). Receives the recipient
  address to deliver the message.

### 6. Data retention

Account and garden data are kept while your account exists. Deleting your account (see §7)
irreversibly deletes cloud data (cascade delete). Local data remains on the device until you sign
out or remove the app. Diagnostic data is retained for a limited period per Sentry's policy.

### 7. Your rights

Under the GDPR you have the right to access, rectification, erasure, restriction and portability of
your data, and to object to processing. Directly available in the app:

- **Data export** (Settings → export) — all your data in a JSON file.
- **Account deletion** (Settings → delete account) — irreversible deletion of cloud data + wiping
  the local database.

For other requests email **gorazd@spletnakoda.si**. You may also lodge a complaint with the Slovenian
Information Commissioner (`ip-rs.si`) or your local supervisory authority.

### 8. Children

The app is not intended for, and does not target, children under 16.

### 9. Changes

We may update this policy; we will announce material changes in the app or on this page. The latest
published version with its effective date always applies.

---

## 🇩🇪 Deutsch

### 1. Verantwortlicher

Verantwortlicher für die Verarbeitung personenbezogener Daten ist **Gorazd Veselic** (natürliche
Person). Kontakt für Datenschutzfragen und die Ausübung Ihrer Rechte: **gorazd@spletnakoda.si**.

### 2. Grundsatz: Datenschutz durch Technikgestaltung

Tendask ist eine App zur Gartendokumentation und arbeitet **offline-first** — Ihre Daten liegen
zuerst auf Ihrem Gerät. Eine Synchronisierung in die Cloud (Supabase, Server in der EU) erfolgt nur,
wenn Sie sich mit einem Konto anmelden; ohne Konto bleiben sie ausschließlich auf dem Gerät.

**Ihre genauen Standortkoordinaten (GPS) verlassen das Gerät niemals zur Speicherung.** Aus den
Koordinaten berechnen wir auf dem Gerät nur eine ungefähre Zelle (H3-System, ~1 km Auflösung) und
speichern **nur diese Zelle** in der Cloud — niemals Rohkoordinaten. (Ausnahme: der Wetterdienst —
siehe §5.)

### 3. Verarbeitete Daten

- **Kontodaten (bei Anmeldung):** E-Mail-Adresse (für die Code-Anmeldung) bzw. eine Google-Konto-
  Kennung (bei Google-Anmeldung). Ohne Anmeldung existieren diese Daten nicht.
- **Garteninhalte:** Aufgaben, Bereiche, Pflanzen, Notizen, Erinnerungen, Benachrichtigungs-
  einstellungen. Ohne Konto nur auf dem Gerät; bei Anmeldung Synchronisierung in die Cloud.
- **Ungefährer Standort:** H3-Zellen (≈ 1 km und gröber), auf dem Gerät abgeleitet. Genaue
  Koordinaten werden **nur lokal** gespeichert und ausschließlich für das Wetter verwendet.
- **Diagnosedaten (Sentry):** bei einem Fehler/Absturz ein Fehlerbericht, Stacktrace, App-Version
  sowie Geräte-/OS-Typ. Dienen der Stabilität, nicht der Identifizierung.

### 4. Zwecke und Rechtsgrundlage (Art. 6 DSGVO)

- **Bereitstellung des Dienstes** (Führung des Gartentagebuchs, geräteübergreifende
  Synchronisierung) — Vertrag (Art. 6(1)(b)).
- **Standort und Benachrichtigungen** — Einwilligung (Art. 6(1)(a)); erteilt über
  Systemberechtigungen und jederzeit in den Geräte- oder App-Einstellungen widerrufbar.
- **Diagnose und Sicherheit** (Fehlerbehebung, Missbrauchsprävention) — berechtigtes Interesse
  (Art. 6(1)(f)).

### 5. Dritte (Auftragsverarbeiter und Dienste)

- **Supabase** (Backend — Authentifizierung und Datenbank). Server in der **EU (Frankfurt)**.
  Speichert: E-Mail, H3-Zellen, Garteninhalte, Benachrichtigungseinstellungen. Es werden keine
  Koordinaten gesendet.
- **Open-Meteo** (Wetter und Geokodierung). Beim Abruf des Wetters werden **genaue Koordinaten** an
  den Dienst gesendet, bei der Ortssuche der eingegebene Ortsname. Die Daten dienen nur der Antwort
  und werden von uns nicht gespeichert; Open-Meteo ist kostenlos und erfordert kein Konto.
- **Sentry** (Fehlerdiagnose). Kann Daten außerhalb der EU (z. B. USA) auf Grundlage von
  Standardvertragsklauseln verarbeiten.
- **Google** (Google-Anmeldung — optional). Bei der Anmeldung erfolgt ein Token-Austausch.
- **Resend** (Zustellung der Anmelde-Code-E-Mails von `no-reply@tendask.com`). Erhält die
  Empfängeradresse zur Zustellung.

### 6. Speicherdauer

Konto- und Gartendaten werden gespeichert, solange Ihr Konto besteht. Beim Löschen des Kontos
(siehe §7) werden die Cloud-Daten unwiderruflich gelöscht (kaskadierende Löschung). Lokale Daten
verbleiben auf dem Gerät, bis Sie sich abmelden oder die App entfernen. Diagnosedaten werden gemäß
der Sentry-Richtlinie für einen begrenzten Zeitraum aufbewahrt.

### 7. Ihre Rechte

Nach der DSGVO haben Sie das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung und
Übertragbarkeit Ihrer Daten sowie auf Widerspruch gegen die Verarbeitung. Direkt in der App
verfügbar:

- **Datenexport** (Einstellungen → Export) — alle Ihre Daten in einer JSON-Datei.
- **Kontolöschung** (Einstellungen → Konto löschen) — unwiderrufliche Löschung der Cloud-Daten +
  Bereinigung der lokalen Datenbank.

Für weitere Anfragen schreiben Sie an **gorazd@spletnakoda.si**. Sie können auch Beschwerde bei der
zuständigen Aufsichtsbehörde einlegen.

### 8. Kinder

Die App ist nicht für Kinder unter 16 Jahren bestimmt und richtet sich nicht an diese.

### 9. Änderungen

Wir können diese Richtlinie aktualisieren; über wesentliche Änderungen informieren wir in der App
oder auf dieser Seite. Es gilt stets die zuletzt veröffentlichte Fassung mit ihrem Datum des
Inkrafttretens.
