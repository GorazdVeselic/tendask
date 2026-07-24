# M11 — poravnava v `main` (flag-dark landing)

- **Status:** načrt (ni izvedeno)
- **Datum:** 2026-07-23
- **Kontekst:** `feat/m11-smart-engine` je zaostal za `main` (**125 commitov main naprej, 46 M11 naprej**; razšla sta se 2026-06-19). Cilj: M11 poravnati v `main` **ugasnjen za flagom**, da neha zastarati, a uporabnik ne vidi ničesar do namernega vklopa (§ FR-20 §10.2 — M11 debitira zaklenjen kot Plus, brez grandfatheringa).
- **Povezave:** [`09-koraki.md`](09-koraki.md) (M11 tasklist), [`08-flutter-arhitektura.md`](08-flutter-arhitektura.md), [`../feature-requests/tendask-plus-licensing.md`](../feature-requests/tendask-plus-licensing.md) (FR-20 §10.2, §12), [`../deploy-runbook.md`](../deploy-runbook.md) (migracijski ledger)

---

## 0. Ključna ugotovitev: M11 NIMA gating flaga

M11 je zgrajen **»prižgan«** — `home_screen.dart` vstavi `SuggestionBand(...)` **brezpogojno**, v `config.dart` obstaja le `kSuppliesEnabled = false`, ne `kSuggestionsEnabled`. Če M11 zmergaš takšen, se **takoj prižge**.

Zato je »flag-dark landing« **zavesten korak**, ne avtomatika (glej §3).

Razmejitev, kaj pomeni »dark« na kateri plasti:

| Plast | Kako ostane dark |
|---|---|
| **UI** (band na Domov, `/suggestions`, gumb v nastavitvah) | **klientski flag** `kSuggestionsEnabled=false` (dodati) |
| **FCM init** (`main.dart`, `app.dart`) | isti flag — preskoči registracijo tokena |
| **Edge funkcija `smart-engine` + cron** | **ne deployaš / ne omogočiš** — ni flag, je izbira deploya |
| **Shema** (drift tabele, migracije 0006–0010) | **aplicira se** — additive/nullable, varno; prisotna a neuporabljena = točno flag-dark model |

---

## 1. Konfliktna slika (iz dejanske diff analize)

130 datotek / ~28,5k vrstic. **~85 % je additive in pristane čisto.** Bolečina je koncentrirana.

### 1a. Popolnoma additive — main se jih ni dotaknil (merge čist)
`lib/features/suggestions/**` (cel nov feature), `lib/core/location/climate_*`, `core/notifications/fcm_handler.dart`, `core/sync/profile_write_guard.dart`, `features/notifications/application/fcm_token_service.dart`, `lib/data/seed/plant_task_rules_seed.dart` (1127 vrstic), `lib/core/widgets/day_header.dart`, celoten `supabase/functions/smart-engine/**`, migracije `0006`–`0010`, večina `test/**`, `tool/gen_rules_sql.dart`, `tool/gen_push_i18n.dart`.

### 1b. Prekrivanje (24 datotek), a večina je šum

| Tip | Datoteke | Kako rešiš |
|---|---|---|
| **Generirane — NE mergaj** | `core/database/app_database.g.dart` (16968 vrstic), `i18n/translations*.g.dart` ×4, `location/*.freezed.dart` + `*.g.dart`, `weather_service.g.dart`, `sync_coordinator.g.dart`, `profile_providers.g.dart`, `location_repository.g.dart` | zbriši + `dart run build_runner build --delete-conflicting-outputs` |
| **i18n JSON** | `i18n/{sl,en,de}.i18n.json` (M11 +351 vrstic vsak) | additiven merge ključev → `dart run slang` |
| **Ročni, večinoma additive** | `app/app.dart`, `app/router/app_router.dart`, `core/config.dart`, `core/database/tables/user_tables.dart`, `core/notifications/notification_service.dart`, `core/sync/remote_mappers.dart`, `features/tasks/data/tasks_repository.dart`, `features/settings/presentation/settings_screen.dart`, `features/settings/data/profile_repository.dart`, `main.dart` | ročno, konflikti majhni |
| **Prava bolečina — main razrezal** | `features/home/presentation/home_screen.dart`, `features/journal/presentation/journal_screen.dart`, `features/tasks/presentation/entry/entry_screen.dart`, `features/notifications/presentation/notification_settings_screen.dart` | **na novo vgradi** M11 integracijo na main strukturo (7 zaslonov je bilo razrezanih v čiste funkcije), **ne** merge-resolve |

### 1c. Posebna pozornost — shema in migracije
- `core/database/app_database.dart` (+46): **verzija drift sheme + nove tabele.** M11 je iz v9/v10 dobe; preveri, ali je `main` verzijo vmes premaknil → **re-sekvenca drift `schemaVersion` + migracijskih korakov.**
- Migracije `0006`–`0010` so bile aplicirane **out-of-band na prod**; ledger teče od `0011` (glej deploy-runbook). Znana točka usklajevanja, ne nova napaka.
- Pravilo: migracije **additive-only**, stari APK-ji ob pull-u ne crashajo.

---

## 2. Vrstni red poravnave

> **Merge `main` → `feat/m11-smart-engine` (NE rebase).** 46 commitov + deljena zgodovina + prejšnja izguba kode ob destruktivnem git posegu (M11.11) → rebase je prevelik riziko. Merge pokaže površino konfliktov enkrat.

1. **Predpriprava:** čist working tree, `flutter test` na M11 branchu zeleno (izhodišče). Zabeleži trenutni `schemaVersion` na obeh branchih.
2. **`git merge main`** v `feat/m11-smart-engine`.
3. **Generirane datoteke:** ob konfliktu `git checkout --theirs` (ali zbriši) → regeneriraj z `build_runner` + `slang`. Nikoli ročno.
4. **Additive ročne (1b vrstica 3):** razreši, večinoma le sprejmeš oba dela.
5. **4 razrezani zasloni (1c bolečina):** za vsakega odpri main verzijo, **na novo vstavi** M11 kos (band, deep-link highlight, FCM nastavitve) v novo strukturo čistih funkcij.
6. **Shema:** uskladi `schemaVersion` + migracijske korake; potrdi drift v-sekvenco.
7. **i18n:** merge JSON ključe → `dart run slang`.
8. **Dodaj flag (§3).**
9. `flutter analyze` čist + `flutter test` zelen.
10. **On-device dimni test:** app teče **z ugasnjenim flagom** — nič M11 UI, nobene regresije M8 opomnikov, migracija čez staro bazo OK.

---

## 3. Flag-dark: kaj konkretno oviti

Dodaj v `core/config.dart`:
```dart
const kSuggestionsEnabled = false;
```

Ovij vstopne točke (vse na `if (kSuggestionsEnabled)`):
- `features/home/presentation/home_screen.dart` — `SuggestionBand(...)` in `highlightSuggestionId` obravnava.
- `app/router/app_router.dart` — `/suggestions` (zgodovina) ruta.
- `features/settings/presentation/settings_screen.dart` — vstop v nastavitve motorja.
- `features/notifications/.../notification_settings_screen.dart` — M11 dodane vrstice.
- `main.dart` / `app/app.dart` — FCM init + `FcmTokenService` registracija (brez flaga se token registrira zaman).

> Vzorec kopiraj od obstoječega `kSuppliesEnabled` — isti idiom, isti nivo.

**Server dark = ne deployaj:** `smart-engine` edge funkcije ne deployaj, cron ne omogoči. Brez UI in brez cron-a nič ne potiska FCM potisnih sporočil, tudi če je token registriran.

---

## 4. DoD (Definition of Done)

- [ ] `feat/m11-smart-engine` vsebuje ves `main` (merge, ne rebase); brez konfliktnih markerjev.
- [ ] `flutter analyze` čist, `flutter test` zelen (M11 testi + main testi skupaj).
- [ ] `kSuggestionsEnabled=false` dodan; vse vstopne točke ovite; z ugasnjenim flagom **nič M11 UI ni vidno**.
- [ ] Drift `schemaVersion` usklajen; migracija čez obstoječo (main) bazo na napravi ne crasha.
- [ ] On-device: app teče kot navaden main build (nič suggestions), M8 opomniki brez regresije.
- [ ] `smart-engine` edge funkcija **NI** deployana; cron **NI** omogočen (dark na strežniku).
- [ ] Merge v `main` (kratkoživ branch — od tod M11 riva z main in ne zastara več).

**Prižig (kasneje, ne v tej poravnavi):** `kSuggestionsEnabled=true` + deploy edge/cron + gate kot Plus (FR-20 §10.2, §12) — hkrati s FR-19 bogatim delom, en dogodek.

---

*Načrt zapisan 2026-07-23. Poravnavo se izvede kot 2. korak v zaporedju FR-19 → M11 → FR-20 (glej FR-20 §12 in pogovor.)*
