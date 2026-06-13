# Tendask — Play Console: stanje objave

> Sledenje konkretnim korakom v Google Play Console. Zadnja posodobitev: **2026-06-13**.
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
- `1.0.0+4` (vc4) — **zgrajen 2026-06-13 za ZAPRTI test**, iz veje `main` (M0–M9; brez M11/FCM/pametnega motorja).
  AAB: `build/app/outputs/bundle/release/app-release.aab` (66,5 MB, upload-key podpisan, dart-defines = živi Supabase).
  Naslednji versionCode mora biti `+5` ali več.

## Interni test

- [x] AAB naložen na **interni test** (izdaja `1.0.0 – interni test`, versionCode 1)
  - 11,7 MB install · SDK 36 · API 24+ · 16 KB page support ✅ · multi-ABI · Play App Signing ON
  - Stanje: **Aktivno · Ni pregledano** (»app.tendask (unreviewed)«)

## Zaprti test (gate za produkcijo)

- [x] **AAB `1.0.0+4` zgrajen** iz `main` (2026-06-13) — čaka 👤 upload v Closed testing track
- [ ] 👤 Upload `app-release.aab` (vc4) → Closed testing → Create new release → rollout
- [ ] Dodaj **≥12 testerjev** (e-poštni seznam) + namesti prek opt-in povezave
- [ ] Preveri release build na napravi — posebej **prijava** (e-koda + Google)
- [ ] 14-dnevni števec teče šele z ≥12 vključenimi testerji

## Store presence

- [x] **Main store listing (EN)** shranjen
  - Ime + kratek + polni opis (iz `store-listing.md`)
  - Ikona 512 (`assets/icon-512.png`) + feature graphic (`assets/feature-graphic-1024x500.png`)
  - 6 telefonskih posnetkov (`assets/screenshots/play/01..06`)
  - Tablet/Chromebook posnetki: **preskočeno** (neobvezno za MVP)
- [x] **Store settings**: kategorija **Lifestyle**, kontakt `gorazd@spletnakoda.si`, web `tendask.netlify.app`, oznake (do 5)
- [ ] **Prevodi listinga: SL + DE** (Manage translations; besedila v `store-listing.md`)

## App content (vse KONČANO ✅)

- [x] **App access**: Ne (brez prijave — gostovski način; preverjeno `auth_service`/`login_screen._continueAsGuest`)
- [x] **Content rating (IARC)**: vse No → **Everyone / PEGI 3 / USK 0**
- [x] **Target audience**: 16-17 + 18+ · appealing-to-children = No
- [x] **Data safety**: 7 tipov (approx+precise location, email, user IDs, crash logs, diagnostics, other UGC)
  - precise location = Collected + **Shared (Open-Meteo)** + Ephemeral
  - crash logs + diagnostics = **Shared (Sentry)** + Required
  - ostalo = Collected / Optional · encrypted in transit = Yes
  - deletion URL + privacy URL = `https://tendask.netlify.app/`
- [x] **Ads**: No · **Government**: No · **Financial features**: None · **Health**: No
- [x] **Advertising ID**: No (preverjeno: `AD_ID` ni v merged manifestu, brez oglaševalskih dep)

## Objava

- [ ] Spremembe poslane v pregled (čaka pred-submisijska »hitra preverjanja«; gumb se odklene po njih)
  - Opomba: ta minutna preverjanja ≠ 14-dnevni zaprti test.
- [ ] Managed publishing — trenutno **OFF** (auto-publish ob odobritvi)

## Po objavi / gate-i do produkcije

- [x] **🔑 Play App Signing SHA-1 → OAuth client (REŠENO 2026-06-10).** Registriran nov Android OAuth client
      (`app.tendask` + Play App Signing SHA-1 `FB:1A:01:25:B9:06:BA:30:52:8D:A9:AC:B3:55:B8:B1:44:50:21:51`)
      v Google Cloud. Brez kode/builda. **On-device potrjeno: Google login na Play-buildu dela.**
      (Upload-key SHA-1 `62:CF:…:2C:F9` je bil že registriran 2026-06-09 — za sideload.)
      Klik-pot do SHA-1: Zaščiteno z Google Play → razširi »Zaščita Trgovine Play« → »Upravljanje podpisovanja aplikacij z Google Play«.
- [ ] **Zaprti test: ≥12 testerjev × 14 dni** (obvezen gate za nove osebne račune pred produkcijo)
      — zbrati testerje. **Vabilo pripravljeno:** `tester-invite.md` (SL/EN) + `assets/tester-preview.png`.
      Opomba: interni test nima časovne zahteve; 14-dnevni števec teče šele v ZAPRTEM testu z ≥12 vključenimi testerji.

## Najdeni bugi med testom (popraviti PRED zaprtim testom)

Podrobnosti + smer popravka: [`../bugreport.md`](../bugreport.md).

- [ ] **BUG-002** — po prijavi (in logout→login) app vedno vpraša za lokacijo (brezpogojni `go('/location')`)
- [ ] **BUG-003** — gost ima »Odjava« + logout tiho briše nesinhronizirane podatke (možna izguba podatkov)
- [ ] Prijava za **produkcijski dostop** → objava globalno (vse države)

## Odloženo (🤖)

- [ ] Sentry debug symbols upload — **N/A za MVP** (pure-Dart sentry, stacktrace berljiv); glej `sentry-symbols.md`

## Povezan projekt

- `../../../tendask_web/` — predstavitvena stran + e-pošta na `tendask.com` / `tendask.app` (ločena seja).
  Tja bo kasneje smiselno preseliti politiko zasebnosti + dodati namensko stran za izbris računa
  (`/delete-account`) in posodobiti deletion URL v Data Safety.
