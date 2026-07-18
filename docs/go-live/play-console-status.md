# Tendask — Play Console: stanje objave

> Sledenje konkretnim korakom v Google Play Console. Zadnja posodobitev: **2026-07-18**.
> Vir besedil/odgovorov: [`store-listing.md`](store-listing.md), [`content-rating.md`](content-rating.md),
> [`../legal/play-data-safety.md`](../legal/play-data-safety.md). Plan: [`README.md`](README.md).

## Račun in aplikacija

- [x] Razvijalski račun (osebni, developer name »Tendask«, `exogenus@gmail.com`)
- [x] **Preverjanje identitete odobreno** (telefon potrjen, 2026-06-10)
- [x] Plačilni profil = obstoječi osebni (Gorazd Veselič) — NE nov
- [x] **Aplikacija ustvarjena**
  - Listing ime: `Tendask – Garden Journal`
  - Package (NEPOVRATNO): `app.tendask` (ujema `android/app/build.gradle.kts:34`)
  - Privzeti jezik: **EN** · Tip: **Aplikacija** · Cena: **Brezplačna**
  - Deklaracije ob ustvarjanju: dev policies + **Play App Signing** + US export ✅

## VersionCode zgodovina

- `1.0.0+1` (vc1) — interni test (prva izdaja)
- `1.0.0+2` (vc2) — porabljen na Play (interni test, BUG-002/003 fix + allowBackup/i18n)
- `1.0.0+3` (vc3) — **že naložen v Play Console**
- `1.0.0+4` (vc4) — zgrajen 2026-06-13 za zaprti test, a **ZASTAREL**: ne vsebuje BUG-004 popravka
  (2026-06-18) ne FR-12 lokacijske prenove. Ne nalagaj ga; arhiviran.
- `1.0.0+5` (vc5) — **zgrajen iz `main` in naložen v Closed testing** (vsi bugi razrešeni, FR-8 + FR-12 notri).
  Bump `pubspec +4 → +5`: commit `8410106`.
- `1.0.0+6` (vc6) — zaprti test (katalog 139 rastlin, 0011, swipe-delete, privzeti opomnik).
- `1.0.0+7` … `1.0.0+11` (vc7–vc11) — R8 / `ic_stat_notify` saga (opomniki so bili na Play tihi; fix v **vc10** =
  density-neodvisen vektor v bazni `drawable/`). Podrobnosti v spominu `tendask-r8-shrinks-dynamic-resources`.
- `1.0.0+12` (vc12) — zaprti test + **obvestilo 32 testerjem** (`vc12-tester-email.md`).
- `1.0.0+13` (vc13) — **naložen v zaprti test 2026-06-30, AKTIVEN in odobren** (»Na voljo preizkuševalcem«).
  Vsebuje FR-5 (ponavljanje), **NE** vsebuje sredstev/pridelka (`kSuppliesEnabled=false` v času builda) —
  zato je bil ves čas združljiv s prod bazo pri migraciji `0013`.
- `1.0.0+14` (vc14) — **zgrajen 2026-07-13/14 iz `main` (`478d7c9`), NI naložen — namerno zadržan.**
  Prva izdaja s **sredstvi/recepti** (zavihek Vrt) + T11 pridelek + 3 UI popravki. Rabi prod migracije
  `0014`–`0016` — **te so aplicirane in e2e potrjene (2026-07-14)**. Zadržan, ker Google pregleduje prijavo
  za produkcijski dostop in pregledovalci app testirajo prek zaprtega tira → nova, na Play še neverificirana
  funkcija sredi pregleda = tveganje brez koristi. **Naloži po Googlovi odločitvi.**

## Interni test

- [x] AAB naložen na **interni test** (izdaja `1.0.0 – interni test`, versionCode 1)
  - 11,7 MB install · SDK 36 · API 24+ · 16 KB page support ✅ · multi-ABI · Play App Signing ON
  - Stanje: **Aktivno · Ni pregledano** (»app.tendask (unreviewed)«)

## Zaprti test (gate za produkcijo)

- [x] 👤 **Zgrajen svež `1.0.0+5`** iz `main` (vc4 je bil zastarel — glej VersionCode zgodovino)
- [x] 👤 **AAB `vc5` naložen** v Closed testing
- [x] 👤 **Rollout potrjen + spremembe poslane v pregled (2026-06-20)** — status »v pregledu« (Data Safety, testerji, države). Čaka Googlovo odobritev (zaprti pregled je krajši).
- [~] **Testerji povabljeni: 48** (2 vala; `testers.md`/`testers.csv`, gitignored). Razposlano prek **Mailmeteor**. Val 1 (30): 10 že potrdilo; val 2 (18): FB skupine (Vrtičkarije, Popolna trata) + znanci. Opt-in (»Postani preizkuševalec«) je obvezen za prenos IN šteje za gate.
- [x] **Prijava (e-koda + Google) na release vc5 dela** — on-device potrjeno 2026-06-20.
- [ ] **≥12 dejansko opted-in × 14 dni** — števec teče šele takrat (spremljaj v Play Console).
- Opomba: opt-in povezava (`https://play.google.com/apps/testing/app.tendask`) bo polno delovala šele po odobritvi izdaje; nov tester rabi ~ure za aktivacijo.

## Store presence

- [x] **Main store listing (EN)** shranjen
  - Ime + kratek + polni opis (iz `store-listing.md`)
  - Ikona 512 (`assets/icon-512.png`) + feature graphic (`assets/feature-graphic-1024x500.png`)
  - 6 telefonskih posnetkov (`assets/screenshots/play/01..06`)
  - Tablet/Chromebook posnetki: **preskočeno** (neobvezno za MVP)
- [x] **Store settings**: kategorija **Lifestyle**, kontakt `info@tendask.com`, web `tendask.com`, oznake (do 5)
- [ ] **Prevodi listinga: SL + DE** (Manage translations; besedila v `store-listing.md`)

## App content (vse KONČANO ✅)

- [x] **App access**: Ne (brez prijave — gostovski način; preverjeno `auth_service`/`login_screen._continueAsGuest`)
- [x] **Content rating (IARC)**: vse No → **Everyone / PEGI 3 / USK 0**
- [x] **Target audience**: 16-17 + 18+ · appealing-to-children = No
- [x] **Data safety — POSODOBLJENO po FR-8 (2026-06-20):** precise location **odznačena** na seznamu vrst
  (ni zbrana/deljena; app je coarse-only, surovih koordinat ne hrani); approximate location = **Collected
  (H3 v Supabase) + Shared (Open-Meteo centroid) + Optional + App functionality**. Glej `docs/legal/play-data-safety.md` v1.1.
  - precise location = **NOT collected / NOT shared** (gotcha: odznači jo na SEZNAMU vrst, ne v dialogu — prazen dialog Play ne shrani)
  - crash logs + diagnostics = **Shared (Sentry)** + Required
  - ostalo = Collected / Optional · encrypted in transit = Yes
  - privacy URL = `https://tendask.com/privacy` · **deletion URL = `https://tendask.com/delete-account`**
    (Google je 404 blokiral pregled; stran v izdelavi v `tendask_web`, brief = `tendask_web/tmp/delete-account-brief.md`)
- [x] **Ads**: No · **Government**: No · **Financial features**: None · **Health**: No
- [x] **Advertising ID**: No (preverjeno: `AD_ID` ni v merged manifestu, brez oglaševalskih dep)

## Objava

- [x] **Spremembe poslane v pregled (2026-06-20)** — status »v pregledu«. Predtem rešena 2 blocker-ja:
  (1) feedback email typo `info@tehdask.com` → `info@tendask.com`; (2) deletion URL 404 → kaže na `/delete-account`.
  - Opomba: zaprti-test pregled je krajši; 14-dnevni števec je ločen.
- [x] Managed publishing — **OFF** (auto-publish ob odobritvi)

## Po objavi / gate-i do produkcije

- [x] **🔑 Play App Signing SHA-1 → OAuth client (REŠENO 2026-06-10).** Registriran nov Android OAuth client
      (`app.tendask` + Play App Signing SHA-1 `FB:1A:01:25:B9:06:BA:30:52:8D:A9:AC:B3:55:B8:B1:44:50:21:51`)
      v Google Cloud. Brez kode/builda. **On-device potrjeno: Google login na Play-buildu dela.**
      (Upload-key SHA-1 `62:CF:…:2C:F9` je bil že registriran 2026-06-09 — za sideload.)
      Klik-pot do SHA-1: Zaščiteno z Google Play → razširi »Zaščita Trgovine Play« → »Upravljanje podpisovanja aplikacij z Google Play«.
- [x] **Zaprti test: ≥12 testerjev × 14 dni — IZPOLNJENO** (obvezen gate za nove osebne račune).
      Vabila prek `tester-invite.md` + Mailmeteor; zadnji aktiven build v tiru = **vc13**.
      Opomba: interni test nima časovne zahteve; 14-dnevni števec teče šele v ZAPRTEM testu z ≥12 vključenimi testerji.
- [~] **Prijava za produkcijski dostop ODDANA — V PREGLEDU** (opaženo 2026-07-13; Play javlja »Prejeli smo vašo
      prijavo … pregled običajno do 7 dni, občasno dlje«; splošna razpoložljivost = »Neaktivno«).
      **Med pregledom: zaprtega testa NE ustavljaj** in ne nalagaj novih, na Play neverificiranih funkcij —
      pregledovalci app testirajo prek zaprtega tira (zato je vc14 zadržan).
- [ ] Po odobritvi: naloži **vc14** (sredstva/recepti + pridelek; prod migracije `0014`–`0016` so že gor)
      → nato objava v produkcijo.
- Opomba: stran **»Zaščiteno z Googlom Play«** (Play Integrity API 0/7, Zaščita fakturiranja 0/4) = **neobvezno**,
  ni pogoj za objavo. Integrity bi pomenil novo dep izven `tech-stack.md §1`; fakturiranje postane relevantno
  šele ob premiumu.

## Preverjanje razvijalca + posodobitve pravil (2026-07)

**Android Developer Verification** (posnetek 2026-07-17): paket **`app.tendask` = »Registrirana« ✅**
(1 ključ, posodobljeno 10. jun. 2026). Od **septembra 2026** morajo preverjeni razvijalci registrirati vsa
imena paketov, sicer aplikacija ne bo namestljiva na »potrjenih« Android napravah v izbranih regijah (velja
tudi za sideload izven Play). Google: »99 % aplikacij registriranih samodejno« — Tendask je med njimi.
- [x] Zavihek **Imena paketov** — `app.tendask` registrirana.
- [ ] 👤 **Preveri zavihek »Identiteta«** v tem razdelku Play Console (razvijalska identiteta za verifikacijo —
      ločen korak od registracije paketa; posnetek ga ne pokaže). Račun-identiteta je sicer že odobrena
      (2026-06-10), a to je nov program — potrdi, da je zelen.

**Policy update email (2026-07, »≥30 dni za skladnost«).** Triaža za Tendask:
- **N/A** (ne zadeva): anonimni/naključni klepet (Tendask nima klepeta); SMS/Call Log `READ_CALL_LOG`
  (ne uporablja); Personal Loans / EWA; third-party **AI** User Data (Tendask »motor« je pravilni, **ne AI**);
  registracija za distribucijo **izven** Play (Tendask je Play-only; debug sideload = razvoj, ne distribucija).
- **Že urejeno**: Content rating — app **je ocenjena** (Everyone/PEGI3), »brez neocenjenih« ne velja;
  precise/approximate **location** disclosure — Data Safety že po FR-8 (coarse-only + H3, `play-data-safety.md`
  v1.1) → ob priložnosti primerjaj z novim Googlovim vodilom.
- [ ] 👤 **API level do 31. 8. 2026** (letna target-API zahteva) — zadnji build je bil **SDK 36** in je prestal
      Play preverbe (`targetSdk = flutter.targetSdkVersion`); **potrdi ob naslednjem buildu**, da še ustreza.
- Neobvezno: Google je izdal open-source »Android skill« za pregled skladnosti s Play pravili v IDE/CLI.

## Najdeni bugi med testom — vsi razrešeni na `main` ✅

Podrobnosti + smer popravka: [`../bugreport.md`](../bugreport.md).

- [x] **BUG-001** — Riverpod `gardenLocation` dispose med loadingom (razrešen 2026-06-08, keepAlive)
- [x] **BUG-002** — po prijavi vedno vpraša za lokacijo (razrešen 2026-06-10, FR-8 routing)
- [x] **BUG-003** — gostov »Odjava« tiho briše nesinhronizirane podatke (razrešen 2026-06-10)
- [x] **BUG-004** — navigator key assertion ob tapu opravila iz zgodovine rastline (razrešen 2026-06-18, top-level `task-view`)
- [~] On-device dimni test na release `vc5`: **prijava (e-koda + Google) ✅ dela (2026-06-20)**; GDPR izvoz ✅ potrjen (schema_version 9, samo H3 celice, brez surovih koordinat); ostane ponovitev BUG-004 + vreme/opomnik/offline
- [ ] Prijava za **produkcijski dostop** → objava globalno (vse države)

## Odloženo (🤖)

- [ ] Sentry debug symbols upload — **N/A za MVP** (pure-Dart sentry, stacktrace berljiv); glej `sentry-symbols.md`

## Povezan projekt

- `../../../tendask_web/` — predstavitvena stran + e-pošta na `tendask.com` / `tendask.app` (ločena seja).
  Privacy je tam že (`tendask.com/privacy`). **V IZDELAVI: namenska `/delete-account` stran** (brief
  `tendask_web/tmp/delete-account-brief.md`) — nujno za Data Safety deletion URL; Google je brez nje 404-blokiral pregled.
