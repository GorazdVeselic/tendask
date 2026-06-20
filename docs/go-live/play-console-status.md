# Tendask — Play Console: stanje objave

> Sledenje konkretnim korakom v Google Play Console. Zadnja posodobitev: **2026-06-20**.
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
  Bump `pubspec +4 → +5`: commit `8410106`. To je aktualni zaprti build.

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
- [ ] **Zaprti test: ≥12 testerjev × 14 dni** (obvezen gate za nove osebne račune pred produkcijo)
      — zbrati testerje. **Vabilo pripravljeno:** `tester-invite.md` (SL/EN) + `assets/tester-preview.png`.
      Opomba: interni test nima časovne zahteve; 14-dnevni števec teče šele v ZAPRTEM testu z ≥12 vključenimi testerji.

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
