# Tendask — »Go-live« plan (Google Play, interni test → produkcija)

> **Namen:** edini vir resnice za objavo Tendask na Google Play. Sledi fazam po vrsti.
> **Stanje:** 2026-06-09 · račun razvijalca ustvarjen (`exogenus@gmail.com`, osebni, »Tendask«),
> **čaka na preverjanje identitete** (blokira ustvarjanje aplikacije).
> **Legenda:** ✅ narejeno · ⏳ čaka/blokirano · 👤 tvoj korak · 🤖 lahko jaz (koda/dokument) · ⬜ odprto
>
> Povezani dokumenti: [`store-listing.md`](store-listing.md) · [`content-rating.md`](content-rating.md) ·
> [`assets/`](assets/) · [`../legal/privacy-policy.md`](../legal/privacy-policy.md) ·
> [`../legal/play-data-safety.md`](../legal/play-data-safety.md).
> **Politika zasebnosti (živa):** https://tendask.netlify.app/

---

## Faza 0 — Račun razvijalca + preverjanje (V TEKU)

- [x] ✅ Ustvarjen osebni račun (»Zase«), developer name **Tendask**, `exogenus@gmail.com`.
- [x] ✅ Profil za plačila (nov, pravi naslov), pristojbina 25 USD plačana.
- [x] ✅ Javni profil: ime **Gorazd Veselič**, kontakt email, SI; spletno mesto `spletnakoda.si`.
- [x] ✅ Preverjanje dostopa do Android naprave (prijava v Play Console mobilno app).
- [ ] ⏳ 👤 **Preverjanje identitete** — naložen osebni dokument; čaka Googlovo odobritev (nekaj dni,
  običajno 1–3 delovne dni). Dokument neobdelan, ime+naslov = profil za plačila.
- [ ] ⏳ 👤 **Preverjanje telefona** — odklene se **šele po** odobritvi identitete (Account details →
  Preveri → SMS/klic → koda).

> **Dokler identiteta ni potrjena, NI mogoče ustvariti aplikacije.** Faze 2+ čakajo. Faza 1 (priprava)
> teče vzporedno in je večinoma že narejena.

---

## Faza 1 — Priprava materialov (večinoma ✅, zunaj konzole)

- [x] ✅ 🤖 **Podpisan AAB** zgrajen + verjeven: `build/app/outputs/bundle/release/app-release.aab`
  (CN=Gorazd Veselič, v `1.0.0+1`, kanal beta). *Ni v repo — build artefakt.*
- [x] ✅ 🤖 **Politika zasebnosti** (SL/EN/DE) objavljena: https://tendask.netlify.app/
- [x] ✅ 🤖 **Data Safety mapiranje**: [`../legal/play-data-safety.md`](../legal/play-data-safety.md)
- [x] ✅ 🤖 **Store listing besedila** (SL/EN/DE): [`store-listing.md`](store-listing.md)
- [x] ✅ 🤖 **Content rating + target audience odgovori**: [`content-rating.md`](content-rating.md)
- [x] ✅ 🤖 **App icon 512×512**: [`assets/icon-512.png`](assets/icon-512.png)
- [x] ✅ 🤖 **Feature graphic 1024×500**: [`assets/feature-graphic-1024x500.png`](assets/feature-graphic-1024x500.png)
- [ ] ⬜ 👤 **Posnetki zaslona** (min. 2, telefonski) — zajeti na napravi. Navodila:
  [`assets/README.md`](assets/README.md).
- [x] ✅ 🤖 `targetSdkVersion` = `flutter.targetSdkVersion` (Flutterjev privzeti, pri tem skladu
  ≥34 — AAB se je uspešno zgradil). Ustreza Play minimumu; če bi bil prenizek, Play to javi ob uploadu.

---

## Faza 2 — Ustvari aplikacijo + interni testni track (po odobritvi identitete)

- [ ] ⏳ 👤 Play Console → **Create app**: ime »Tendask«, **privzeti jezik = English (United States)**
  (default/fallback; SL+DE dodaš kot prevoda), tip **App**, **Free**, potrdi deklaracije.
- [ ] ⏳ 👤 **Testing → Internal testing → Create new release**.
- [ ] ⏳ 👤 Upload `app-release.aab` (drag-drop). Release name = `1.0.0 (1)`.
- [ ] ⏳ 👤 Release notes (kratko, npr. »Prva interna različica.«).

---

## Faza 3 — Store listing (Main store listing)

- [ ] ⏳ 👤 App name, kratek + polni opis iz [`store-listing.md`](store-listing.md) (**EN = default**;
  dodaj SL, DE prek »Manage translations«).
- [ ] ⏳ 👤 Naloži **icon-512.png** + **feature-graphic-1024x500.png** + **posnetke zaslona**.
- [ ] ⏳ 👤 **App category** = `House & Home` (alt: `Lifestyle`); tags = gardening/journal.
- [ ] ⏳ 👤 Kontaktni email (javno) = isti kot v politiki (`gorazd@spletnakoda.si`).

---

## Faza 4 — App content (deklaracije — obvezne za objavo)

- [ ] ⏳ 👤 **Privacy policy URL** = `https://tendask.netlify.app/`
- [ ] ⏳ 👤 **Data safety** — izpolni po [`../legal/play-data-safety.md`](../legal/play-data-safety.md)
  (pozor: *precise location* = Collected+Shared(Open-Meteo)+Ephemeral).
- [ ] ⏳ 👤 **Content rating** (IARC vprašalnik) — odgovori iz [`content-rating.md`](content-rating.md).
- [ ] ⏳ 👤 **Target audience & content** — starostne skupine **18+ (po želji 16–17)**; NE otroci;
  »appealing to children« = **No**.
- [ ] ⏳ 👤 **Ads** = **No ads**. **News app** = No. **COVID-19 contact tracing** = No.
- [ ] ⏳ 👤 **Government app** = No. **Data deletion** = v aplikaciji + email (že v Data Safety).
- [ ] ⏳ 👤 **Permissions** — če Play vpraša za lokacijo/obvestila: lokacija = vreme (ne shranjujemo
  koordinat), obvestila = opomniki opravil.

---

## Faza 5 — Testerji + objava na interni track

- [ ] ⏳ 👤 **Internal testing → Testers**: dodaj seznam emailov (do 100; vključi `exogenus@gmail.com`
  + svoj testni Gmail). Po želji naredi Google Group.
- [ ] ⏳ 👤 **Copy opt-in link** → odpri na napravi → »Become a tester« → namesti iz Play.
- [ ] ⏳ 👤 **Rollout** internega releasa.

---

## Faza 6 — On-device preverbe na RELEASE buildu iz Play (po namestitvi)

> Te so odprte že iz M9 in jih je najlažje opraviti na Play-distribuiranem buildu.

- [ ] ⏳ 👤 **Registriraj Play App Signing SHA-1** (Play Console → Test and release → App integrity →
  App signing key certificate → SHA-1) kot **dodaten Android OAuth client** (`app.tendask`) v Google
  Cloud (isti projekt kot `serverClientId`). *Brez tega Google login na Play buildu ne dela.*
- [ ] ⏳ 👤 **Google login** na release buildu (po propagaciji SHA-1).
- [ ] ⏳ 👤 **Email OTP** na poljuben naslov (tendask.com verificiran).
- [ ] ⏳ 👤 **GDPR izvoz** (share sheet) + **dejanski izbris računa** (RPC počisti oblak).
- [ ] ⏳ 👤 Splash → Domov, vreme, sync, opomniki — splošni smoke test.

---

## Faza 7 — Pred PRODUKCIJO (kasneje, ko se odločiš za javno objavo)

- [ ] ⬜ 🤖 **Sentry debug symbols upload** (rabi `sentry-cli` + auth token) — za berljive release stacktrace.
- [ ] ⬜ 🤖 Flip `kVersionChannel` `' (beta)'` → `''` (`core/config.dart`) za produkcijsko verzijo.
- [ ] ⬜ 👤 **Zaprti test 12 testerjev × 14 dni** — Googlova zahteva za **osebne** račune pred dostopom
  do produkcije (NE velja za interni test). Načrtuj zgodaj.
- [ ] ⬜ 👤 Dvigni `versionCode` (`pubspec version: 1.0.0+2`) ob vsakem novem uploadu.
- [ ] ⬜ 👤 Production release + postopen rollout.

---

## Hitri reference

| Postavka | Vrednost |
|---|---|
| Package / applicationId | `app.tendask` |
| Verzija (trenutna) | `1.0.0+1` (versionName 1.0.0, versionCode 1) |
| AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Build ukaz | `flutter build appbundle --release --dart-define-from-file=dart_defines.json` |
| Upload-key SHA-1 (že reg. kot OAuth client) | `62:CF:B4:A0:F4:6A:54:B4:7B:99:6A:02:16:7A:72:A7:62:14:2C:F9` |
| Privacy policy URL | `https://tendask.netlify.app/` |
| Developer name | Tendask · kontakt `gorazd@spletnakoda.si` |
| jarsigner (verify) | `C:\Program Files\Android\Android Studio\jbr\bin\jarsigner.exe` |
