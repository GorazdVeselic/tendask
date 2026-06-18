# Tehnološki sklad — Tendask (POTRJENO)

> **Status:** potrjen implementacijski referenčni dokument · 2026-06-01
> **Namen:** kanonični vir za tehnološke odločitve. **To bere AI agent (Claude Code), ki piše kodo** —
> da kodira dosledno, po istih konvencijah. Koncept = `koncept.md` §7.11; ta datoteka = izvedbeni detajl.
>
> **Vodilno načelo izbire:** kodo piše AI agent, ne človek → izberi **najbolj mainstream, dobro
> dokumentirane, stabilne** tehnologije (AI ima največ primerov → najmanj napak). Brez eksotike.
> **Drugo načelo:** 0 € dodatnih stroškov v razvoju in MVP.

---

## 1. Zaklenjene odločitve (povzetek)

| Plast | Izbira | Paket(i) |
|-------|--------|----------|
| Platforma | **Flutter** (iOS + Android, en codebase) | — |
| Jezik | Dart (zadnji stabilni SDK) | — |
| **State management** | **Riverpod** (s code-gen) | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` |
| **Routing** | **go_router** (deep-link za obvestila) | `go_router` |
| **Lokalna baza (offline vir resnice)** | **drift** (SQLite) | `drift`, `sqlite3_flutter_libs`, `drift_dev` |
| **Sync** | **ročni push/pull** (brez zunanje storitve) | — (lastna koda) |
| Zaledje | **Supabase** (Postgres + Auth + RLS + Storage) | `supabase_flutter` |
| Prijava (Google native) | **google_sign_in** (idToken → `signInWithIdToken`, M7.4); e-pošta OTP = Supabase native | `google_sign_in` |
| Modeli/serializacija | **freezed + json_serializable** | `freezed`, `json_annotation`, `json_serializable` |
| i18n (SL/EN/DE) | **slang** (tip-varni ključi) | `slang`, `slang_flutter` |
| HTTP (Open-Meteo) | **dio** + tanek lasten client | `dio` |
| Vreme | **Open-Meteo** (brez ključa, brez stroška) | — |
| H3 (na napravi) | **h3_flutter** (FFI binding) | `h3_flutter` |
| Lokacija (GPS) | **geolocator** (M7); vpisan kraj → **Open-Meteo Geocoding** (brez ključa, dio) | `geolocator` |
| Lokalna obvestila (plast A) | **flutter_local_notifications** + tz (IANA cona prek `flutter_timezone`) | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Push (plast B) | **Firebase FCM** — **ODLOŽENO**, ne v prvem MVP | `firebase_messaging` (kasneje) |
| Crash/monitoring | **Sentry** (čisti Dart `sentry` — `sentry_flutter` 8.x se ne prevede na svežem Android skladu Kotlin 2.3/AGP 9, 9.x pa poriše `jni` navzdol in zlomi `h3_flutter`; zato Dart paket + ročna `FlutterError`/`PlatformDispatcher` integracija) | `sentry` |
| GDPR izvoz (deljenje datoteke) | **share_plus** (sistemski share sheet za izvoženo JSON datoteko, M9.7) | `share_plus` |
| Zunanje povezave (politika zasebnosti) | **url_launcher** (odpre javno politiko zasebnosti v brskalniku — prijava + Nastavitve, M9.5) | `url_launcher` |
| Analitika | **brez v MVP** (kasneje PostHog self-host, opcijsko) | — |
| CI/CD | **GitHub Actions** (lint + test + build) | — |

**Izrecno NE uporabljamo (zaenkrat):** PowerSync/ElectricSQL (zunanja storitev + strošek), Bloc
(več boilerplate kot Riverpod), Crashlytics (ker Firebase sicer odlagamo), tretje-osebne analitike.

---

## 2. Arhitektura offline + sync (najpomembnejši del)

**Načelo:** lokalna drift baza = **vir resnice za UI**; Supabase = vir resnice v oblaku.
UI vedno bere/piše v drift; sync teče v ozadju. Aplikacija deluje brez signala (vrt!).

### MVP poenostavitev
MVP je **enouporabniški, večinoma ena naprava** → sync je preprost, **brez zapletenega
razreševanja konfliktov**. Privzeto pravilo: **last-write-wins po `updated_at`**.

### Konvencije za sinhronizirane tabele
Vsaka uporabniška vrstica (`area`, `user_plant`, `task`, `task_reminder`, `note`, `supply`,
`recipe`, `task_supply`) ima:
- `id` = **UUID, generiran NA NAPRAVI** (da offline-ustvarjene vrstice takoj dobijo stabilen PK)
- `updated_at` (timestamptz) — za LWW in inkrementalni pull
- `deleted` (bool) — **soft delete** (da se izbris sinhronizira)
- lokalno (samo v drift, ne v Postgres): `sync_status` ∈ {`pending`, `synced`}

### Push (lokalno → oblak)
1. Vsak zapis/uredba/izbris v drift: označi vrstico `sync_status = pending`.
2. **Sync service** (sproži se ob: vrnitvi povezave · zagonu · periodično): vzame vse `pending`
   vrstice → `upsert` v Supabase → ob uspehu označi `synced`.
3. Vrstni red: spoštuj FK (najprej `area`, nato `user_plant`, nato `task`, …).

### Pull (oblak → lokalno)
1. Hrani `last_pulled_at` (po tabeli ali globalno).
2. Ob zagonu/periodično: `select * where user_id = auth.uid() and updated_at > last_pulled_at`.
3. `upsert` v drift; če `deleted = true`, odstrani lokalno. Posodobi `last_pulled_at`.

### Katalog (task_type, plant, plant_synonym, category_task_type)
- **Samo-branje, skupno.** Priložen kot **seed** v aplikaciji (bundled `seed` ob prvem zagonu),
  + redki periodični pull (katalog se skoraj ne spreminja). Glej §7.14 koncepta.

### Povezljivost
- `connectivity_plus` za zaznavo online/offline → proži flush čakalne vrste.

---

## 3. Auth (Supabase)

- Ponudniki: **Apple (M10) · Google native (`google_sign_in` → `signInWithIdToken`, serverClientId = Web OAuth client) · e-pošta OTP (Supabase native)**.
- **"Brez računa" = popolnoma lokalno** (drift pod `kLocalUserId`, **brez** Supabase seje — anon račun se NE ustvari, M7 odločitev 2026-06-05). Oblak se vključi šele ob prijavi: `claimLocalRows` posvoji gost-vrstice na nov `auth.uid()` + push → **prijava ohrani gost-podatke (merge)**. Razlog: anon računi so se sicer kopičili še pred izbiro načina prijave; lokalni gost se ujema z UI obljubo (»podatki se ob odstranitvi izgubijo«).
- RLS povsod: `user_id = auth.uid()` (prijavljen email/Google). Katalog = javno-bralni.
- Po prijavi: `claimLocalRows` + push + prvi **pull** (eager, prek `start()`); ob odjavi: `flushPush` → `signOut` → počisti lokalno bazo → gost stanje.
- Opozorilo "izguba podatkov" za gosta (skladno z wireframom 13).

---

## 4. Obvestila

### Plast A — opomniki opravil (MVP)
- **Lokalna** (`flutter_local_notifications`), deterministična, delujejo offline.
- Razporejanje po `task_reminder(offset, time)`; časovni pasovi prek `timezone`.
- Tap → deep-link (`go_router`) na Detajl opravila (17). Zasloni 19–22.
- iOS/Android dovoljenja: priming zaslon (21) **pred** sistemskim pozivom.

### Plast B — pametni predlogi (PO MVP)
- **Strežniško** (Supabase cron / Edge Function) + **FCM** push. Glej `pametni-motor.md`.
- **FCM se doda šele tu** → v prvem MVP Firebase ni potreben (manj setupa, 0 € dlje).

---

## 5. H3 na napravi (zasebnost)

- `h3_flutter`: iz GPS koordinat izračunaj **celico res-7**, izpelji res-6 in res-5.
- Shrani **samo celice** (`profile.h3_r7/r6/r5`), **nikoli surovih koordinat**.
- **FR-8 (2026-06-18):** koordinate se po izpeljavi celice **takoj zavržejo** — ne shranijo se niti
  device-local (tabela `device_location` odstranjena, drift v9). **Vreme** (dashboard + posnetek ob ✓)
  in usmerjanje po prijavi berejo **centroid celice** `cellToLatLng(profile.h3_r7)`, ne surove točke;
  dovoljenje je **COARSE-only** (r7 ~1,2 km zadošča). Open-Meteo torej dobi le približek, ne natančne lokacije.
- **Grob klimatski koš** (`profile.climate_bucket`, višina×temp. pas) prav tako izračunan na
  napravi (višina iz Open-Meteo `elevation`); shrani le pas, ne višine — fallback za V2 cold-start.
- V2 roll-up = navaden `GROUP BY` v Postgres (brez `h3-pg` razširitve). Glej §7.14.
- **V2 agregat** (`activity_agg`, koncept.md §8): **prva javno-bralna tabela** — piše jo samo
  `pg_cron` (service-role/SECURITY DEFINER), RLS `using (distinct_users ≥ K)`. Nova RLS kategorija
  poleg owner-only user-tabel in javno-bralnega kataloga.

---

## 6. Struktura projekta (feature-first)

```
lib/
  main.dart
  app/                  # MaterialApp, router, theme, lokalizacija
  core/                 # supabase client, drift db, sync service, dio, h3, rezultat/napake
  i18n/                 # slang (sl/en/de) generirano
  features/
    tasks/              # opravila: data (drift+remote) · application (riverpod) · presentation (zasloni)
    journal/            # dnevnik/opombe (03, 18)
    areas/              # območja (04, 05, 09)
    plants/             # izbirnik rastlin (10)
    supplies/           # zaloge (08)
    notifications/      # opomniki (19–22)
    auth/               # prijava/onboarding (13, 15, 16)
    home/               # domov (01), hiter vnos (02)
    weather/            # vreme (Open-Meteo) — posnetek + dashboard kartica
    splash/             # branded splash (00)
    onboarding/         # intro drsniki (15–15d)
  data/
    seed/               # seed iz opravila-in-rastline.md
```
Vsak feature: `data/` (repozitorij: drift + supabase) → `application/` (Riverpod providerji) →
`presentation/` (zasloni/gradniki). Zasloni se ujemajo z wireframi `docs/wireframes/`.

---

## 7. Skrivnosti / okolje

- Supabase `url` + `anonKey` prek `--dart-define` (ne v gitu). `.env` ni v repo.
- Brez storitvenih ključev v aplikaciji (anon key + RLS = dovolj).
- Open-Meteo: brez ključa.

---

## 8. Stroški (MVP = 0 €)

| Storitev | Plan | Strošek |
|----------|------|---------|
| Supabase | Free | 0 € (Pro ~25 $/mes šele ob objavi/prometu) |
| Open-Meteo | Free, brez ključa | 0 € |
| FCM | — (odloženo) | 0 € |
| Sentry | Free (dev) | 0 € |
| GitHub Actions | Free | 0 € |
| Apple Developer | — (šele ob objavi v App Store) | 99 $/leto kasneje |
| Google Play | — (šele ob objavi) | 25 $ enkratno kasneje |

---

## 9. Vrstni red postavitve (za AI agenta)

1. **Flutter skeleton** — projekt, mape (§6), tema, `go_router`, slang (sl/en/de) z nekaj ključi.
2. **drift baza** — tabele po §7.14 (z `id uuid`, `updated_at`, `deleted`, `sync_status`).
3. **Seed** — uvozi tipe opravil + matriko + vzorčne rastline iz `opravila-in-rastline.md`.
4. **Supabase** — projekt, migracije (iste tabele), RLS politike, Auth ponudniki.
5. **Sync service** — push/pull (§2) + `connectivity_plus`.
6. **Auth flow** — anonimno + linkanje, prvi pull/clear (zasloni 13/15/16).
7. **Jedro UI** — Domov (01), Hiter vnos (02), Novo opravilo (07), Dnevnik (03), Opravila.
8. **Vreme** — Open-Meteo client (dio), vremenski posnetek na opravilo.
9. **Obvestila plast A** — `flutter_local_notifications`, zasloni 19–22.
10. **H3 na napravi** — ob nastavitvi lokacije (profil).
11. **Sentry + CI** (GitHub Actions: lint/test/build).
12. *(Po MVP)* FCM + pametni motor (plast B) — glej `pametni-motor.md`.

---

## 10. Konvencije za AI agenta (da koda ostane dosledna)

- **Nespremenljivi modeli** (freezed); UI bere iz Riverpod providerjev, nikoli direktno iz Supabase v gradniku.
- **Repozitorij vzorec**: feature `data/` skrije, ali gre za drift ali remote; aplikacijska plast ne ve.
- **UI vedno piše v drift**, nikoli direktno v Supabase (sync poskrbi za oblak).
- Vsi i18n teksti prek slang (`t.tasks.title`), nikoli "hardcoded" nizov; jeziki sl/en/de.
- UUID-je generiraj na napravi (`uuid` paket) pred vstavljanjem.
- Časi: hrani UTC, prikaži lokalno.
- Vsak nov zaslon se ujema z ustreznim wireframom; če odstopa, najprej posodobi wireframe + koncept.
