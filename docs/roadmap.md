# Tendask — Roadmap / Task list (MVP)

> **Status:** živ dokument · zadnja posodobitev 2026-06-04
> **Namen:** edini vir resnice za "kaj delamo naprej". PM + Flutter dev + tester pogled.
> **Bere ga AI agent (Claude Code) IN človek.** Sledi mu korak za korakom.
>
> Povezano: [`tech-stack.md`](tech-stack.md) (potrjen sklad + §6 struktura, §9 vrstni red),
> [`koncept.md`](koncept.md) (§7.9 entiteta opravilo, §7.14 podatkovni model),
> [`opravila-in-rastline.md`](opravila-in-rastline.md) (vir za seed), `wireframes/` (~27 zaslonov).

---

## Potrjene odločitve za ta roadmap (2026-06-02)

1. **Android-first.** Razvoj + test na Androidu (USB debug). Koda ostane iOS-kompatibilna;
   iOS build/test = ločen kasnejši mejnik (macOS ali oblačni build) pred beto.
2. **Local-first UI.** Vrstni red: skeleton → drift+seed → **jedro UI nad lokalno bazo (offline)**
   → Supabase → sync → auth → obvestila. (Ne spreminja potrjenega sklada, le vrstni red iz §9.)
3. **Seed iz obstoječega osnutka.** ~22 tipov opravil + ~35 rastlin zdaj; razširitev na 100–200
   (Wikidata/GBIF) je **pred-release korak — glej 9.6** (mora pred internim testom).
4. **Pragmatično testiranje.** Unit testi za logiko (drift/sync/vreme/pravila) + widget testi
   ključnih zaslonov + ročna preverba na napravi ob mejniku. Brez e2e zaenkrat.

---

## Delovni dogovor (KAKO delamo)

- **En korak = en commit.** Koraki so namenoma majhni in samostojno preverljivi.
- **Pred vsakim nadaljevanjem agent VPRAŠA:** "naj ta korak označim kot zaključen in ga commitam?"
  → šele po potrditvi commit in prehod na naslednji korak.
- **Commit sporočila** = [Conventional Commits](https://www.conventionalcommits.org):
  `feat:`, `fix:`, `chore:`, `test:`, `docs:`, `refactor:`. Slovenski opis. Agent doda `Co-Authored-By`.
- **Veja:** za zdaj delamo na `main` (solo, majhni commiti). Ko bo smiselno (npr. pred ultrareview),
  lahko preklopimo na vejo-na-mejnik + PR.
- **Definicija končanega (DoD)** velja za vsak korak: koda prevede, `flutter analyze` čist,
  testi (kjer obstajajo) zeleni, in (kjer relevantno) ročno preverjeno na napravi.
- **Po vsaki spremembi modela/zaslona:** posodobi ustrezni `koncept.md` / wireframe, če odstopa (konvencija §10 tech-stack).
- **Legenda statusa:** `[ ]` odprto · `[~]` v teku · `[x]` zaključeno (+commit hash).

---

## Pregled mejnikov

| # | Mejnik | Cilj | Stanje |
|---|--------|------|:------:|
| **M0** | Temelj projekta | Skeleton: mape, tema, router, i18n, CI | `[x]` |
| **M1** | Lokalna baza + seed | drift sheme + katalog/uporabnik tabele + seed | `[x]` |
| **M2** | Jedro opravil (offline) | Vnos/pregled/urejanje opravil nad drift | `[x]` |
| **M3** | Območja · rastline · zaloge · opombe | Preostali offline zasloni | `[x]` |
| **M4** | Vreme (Open-Meteo) | Vremenski posnetek na opravilo | `[x]` |
| **M5** | Supabase zaledje | Projekt + shema + RLS | `[x]` |
| **M6** | Sync servis | Ročni push/pull, LWW, povezljivost | `[x]` |
| **M7** | Auth + H3 | Anonimno + linkanje + lokacija/H3 na napravi | `[x]` |
| **M8** | Lokalna obvestila (plast A) | Opomniki + deep-link + zasloni 19–22 | `[x]` |
| **M9** | Polish + monitoring + Android release | Sentry, ikona/splash, neskladja, Play test | `[~]` |
| **M10** | *(po MVP)* iOS mejnik | macOS/oblačni build + iOS specifike | `[ ]` |
| **M11** | *(po MVP / V2)* Pametni motor + FCM + percentili | glej `pametni-motor.md` | `[ ]` |

> Zgodnji mejniki (M0–M2) so razčlenjeni na podrobne korake. Kasnejši mejniki dobijo
> podroben razrez korakov, ko do njih pridemo (da se izognemo prezgodnjemu načrtovanju).

---

## M0 — Temelj projekta (skeleton)

**Cilj:** prazna a pravilno strukturirana Flutter aplikacija, ki se zažene z brand temo,
2-zavihkovo navigacijo in i18n; CI varuje vsak commit.

- [x] **0.1 — Struktura map (§6 tech-stack).** Ustvari `lib/{app,core,i18n,features/*,data/seed}`
  po feature-first; minimalni `main.dart` z `MaterialApp` (placeholder). *DoD:* zažene se prazen zaslon.
  *Commit:* `chore: feature-first struktura map + minimalni main`
- [x] **0.2 — Riverpod temelj.** Dodaj `flutter_riverpod`, `riverpod_annotation`, dev `riverpod_generator`+
  `build_runner`; ovij app v `ProviderScope`; en demo provider + `build_runner` teče. *DoD:* code-gen uspe.
  *Commit:* `feat: Riverpod + code-gen temelj`
- [x] **0.3 — Brand tema.** `ColorScheme` (primarna zelena `#2e7d32`, sekundarna medena `#E0A82E`),
  Plus Jakarta Sans (google_fonts ali bundlan), light + dark. *DoD:* zasloni uporabljajo temo, ne hardcode barv.
  *Commit:* `feat: brand tema (zelena/medena, Plus Jakarta Sans, light+dark)`
- [x] **0.4 — Routing (go_router).** Shell z 2 zavihkoma **Dnevnik (📅)** + **Opravila (☑️)** + osrednji
  **FAB ＋** (placeholder). Imenovane poti za prihodnje zaslone. *DoD:* preklop med zavihkoma dela.
  *Commit:* `feat: go_router shell + 2 zavihka + FAB`
- [x] **0.5 — i18n (slang).** Nastavi `slang` sl/en/de + nekaj ključev (naslovi zavihkov, FAB);
  zamenjaj vse vidne nize s `t.*`. *DoD:* preklop jezika zamenja besedilo; brez hardcode nizov.
  *Commit:* `feat: i18n slang (sl/en/de) + osnovni ključi`
- [x] **0.6 — CI + README.** GitHub Actions: `flutter analyze` + `flutter test` ob push/PR;
  posodobi `README.md` (zagon, build, struktura). *DoD:* CI zelen na GitHubu.
  *Commit:* `ci: GitHub Actions (analyze + test) + README`

---

## M1 — Lokalna baza (drift) + seed

**Cilj:** lokalna SQLite baza = offline vir resnice; katalog napolnjen iz seed-a ob prvem zagonu.
Reference: `koncept.md` §7.14 (tabele), `opravila-in-rastline.md` (seed vsebina).

- [x] **1.1 — drift temelj.** Dodaj `drift`, `sqlite3_flutter_libs`, dev `drift_dev`; `AppDatabase`
  (prazna) + odpiranje povezave + Riverpod provider baze. *DoD:* baza se ustvari/odpre ob zagonu.
  *Commit:* `feat: drift AppDatabase temelj`
- [x] **1.2 — Katalog tabele.** `task_type`, `plant`, `plant_synonym`, `category_task_type`
  (`labels` kot JSON `{sl,en,de}`, ikona, kategorija, `requires_subject`, `weather_sensitive`,
  `default_cadence`). *DoD:* migracija ustvari tabele; code-gen čist.
  *Commit:* `feat: drift katalog tabele (task_type, plant, sinonimi, matrika)`
- [x] **1.3 — Uporabniške tabele.** `profile, area, user_plant, task, task_reminder, note, supply,
  recipe, task_supply` — vsaka uporabniška vrstica z `id` (UUID), `updated_at`, `deleted`,
  `sync_status` (lokalno). FK po §7.14. *DoD:* migracija + code-gen čist.
  *Commit:* `feat: drift uporabniške tabele (sync-ready: uuid/updated_at/deleted/sync_status)`
- [x] **1.4 — Seed podatki (Dart/JSON).** Pretvori tipe opravil + matriko kategorija↔tip + vzorčne
  rastline iz `opravila-in-rastline.md` v strukturiran seed (asset JSON ali Dart konstante).
  *DoD:* seed datoteka obstaja, ujema se s katalogom v dokumentu.
  *Commit:* `feat: seed podatki katalog (tipi opravil + matrika + vzorčne rastline)`
- [x] **1.5 — Seed servis.** Ob prvem zagonu (prazna baza) napolni katalog iz seed-a; idempotentno.
  *DoD:* po zagonu so katalog tabele napolnjene; ponoven zagon ne podvaja.
  *Commit:* `feat: seed servis (napolni katalog ob prvem zagonu)`
- [x] **1.6 — Testi M1.** Unit: seed naloži pričakovano št. vrstic; osnovne CRUD poizvedbe nad
  `task`/`area`. *DoD:* testi zeleni.
  *Commit:* `test: seed + osnovne drift poizvedbe`

---

## M2 — Jedro opravil (offline)

**Cilj:** najpomembnejši flow — uporabnik lahko zabeleži/načrtuje, pregleda, uredi opravilo,
vse lokalno. Zasloni: 01 Domov, 02 Hiter vnos, 07 Novo opravilo, 03 Dnevnik, 06 Opravila, 17/17b Detajl.
Entiteta = `koncept.md` §7.9. Vzorec: `data/` (drift repo) → `application/` (Riverpod) → `presentation/`.

- [x] **2.1 — Tasks repo + providerji.** `TasksRepository` nad drift (list, byId, create, update,
  complete, softDelete, duplicate, +1 dan) + Riverpod providerji. *DoD:* unit testi repo metod zeleni.
  *Commit:* `feat: tasks repozitorij + Riverpod providerji`
- [x] **2.2 — Domov (01) + FAB → Hiter vnos.** Osnovni Domov; FAB odpre Hiter vnos (02). *DoD:* navigacija dela.
  *Commit:* `feat: zaslon Domov (01) + FAB pot`
- [x] **2.3 — Hiter vnos (02).** Hiter vnos opravila (tip + območje/rastlina, privzeto status=opravljeno,
  datum=danes) → shrani v drift; "Napredno ›" → 07. *DoD:* vnos se prikaže v Dnevniku.
  *Commit:* `feat: Hiter vnos (02)`
- [x] **2.4 — Novo opravilo (07).** Poln obrazec: tip, območje, rastlina? (pogojno po `requires_subject`),
  datum, status, opomba, sredstva, (opomnik/ponavljanje placeholder). *DoD:* ustvari + uredi opravilo.
  *Commit:* `feat: Novo opravilo (07) obrazec`
- [x] **2.5 — Dnevnik (03).** Opravljena opravila + opombe pomešano po datumu; filter Vse/Opravila/Opombe.
  *DoD:* prikaže ustvarjena opravila; filter dela.
  *Commit:* `feat: Dnevnik (03) z filtrom`
- [x] **2.6 — Opravila (06).** Čakajoča + zapadla; akcije ✓ Opravljeno · +1 dan · Uredi · Podvoji · Izbriši.
  *DoD:* akcije posodobijo drift + UI.
  *Commit:* `feat: seznam Opravila (06) + akcije`
- [x] **2.7 — Detajl opravila (17/17b).** Bralni pogled, dve stanji (čaka / opravljeno), gumb Uredi → 07,
  ⋯ akcijska plošča (14). Vremenski pasovi = placeholder do M4. *DoD:* oba stanja se prikažeta pravilno.
  *Commit:* `feat: Detajl opravila (17/17b) bralni pogled`
- [x] **2.8 — Testi M2.** Widget testi: Hiter vnos shrani; Opravila akcija ✓ premakne v Dnevnik.
  Ročna preverba na napravi. *DoD:* testi zeleni + ročno potrjeno.
  *Commit:* `test: widget testi jedra opravil`

---

## M3 — Območja · rastline · zaloge · opombe (offline)

**Cilj:** zaokroži offline funkcionalnost. Zasloni 04/05/09 (območja), 10 (izbirnik rastlin),
08 (zaloge), 18 (opomba), 11 (mesečni koledar), 12 (nastavitve/profil).

- [x] **3.1 — Območja (04, 05, 09).** Repo + providerji + zasloni (seznam, detajl, dodaj/uredi). *Commit:* `feat: območja (04/05/09)`
- [x] **3.2 — Izbirnik rastlin (10) + user_plant.** Iskanje po katalogu (labels+sinonimi), lasten vnos + alias. *Commit:* `feat: izbirnik rastlin (10) + user_plant`
- [x] **3.3 — Zaloge (08) + odpis.** `supply` + `task_supply` (odpis ob opravilu, transakcija). *Commit:* `feat: zaloge (08) + odpis na opravilo`
- [x] **3.4 — Opombe (18).** Samostojna opomba → v vrtni dnevnik; vstop iz Hitrega vnosa. *Commit:* `feat: opombe (18)`
- [x] **3.5 — Mesečni koledar (11).** Tap na dan → dodaj opravilo. *Commit:* `feat: mesečni koledar (11)`
- [x] **3.6 — Nastavitve/profil (12).** Jezik, (placeholder lokacija/obvestila). *Commit:* `feat: nastavitve/profil (12)`
- [x] **3.7 — Testi M3.** Widget + ročna preverba. *Commit:* `test: M3 zasloni`

---

## M4 — Vreme (Open-Meteo)

**Cilj:** vremenski posnetek na opravilu/opombi (3 pasovi po §7.10); zamrznjen ob "opravljeno".

- [x] **4.1 — dio client + Open-Meteo model.** `dio` + tanek client + `freezed`/`json_serializable` model. *Commit:* `feat: Open-Meteo client (dio)`
- [x] **4.2 — Vremenski posnetek.** Ob izvedbi posname (temp/veter/vlaga/padavine/temp.tal/ET₀), shrani `weather jsonb`; 24–48 h nazaj + napoved. *Commit:* `feat: vremenski posnetek na opravilo`
- [x] **4.3 — Prikaz (Domov, Detajl 17/17b).** 3-pasovni prikaz; zamrznjen dejanski posnetek na opravljeno. *Commit:* `feat: prikaz vremenskih pasov`
- [x] **4.4 — Testi M4.** Unit: client z mock odgovori; serializacija. *Commit:* `test: Open-Meteo client`

---

## M5 — Supabase zaledje

**Cilj:** oblačna shema, ki zrcali drift; RLS za zasebnost. (Ročni koraki uporabnika označeni 👤.)

- [x] **5.1 — 👤 Projekt + ključi.** Uporabnik ustvari Supabase projekt; `url`+`anonKey` prek `--dart-define`; `supabase_flutter` init. *Commit:* `feat: Supabase client init (dart-define)` (`0741a69`)
- [x] **5.2 — SQL migracije.** Iste tabele kot drift + indeksi (`updated_at`, `user_id`). *Commit:* `feat: Supabase shema (migracije)` (`bb72aec`)
- [x] **5.3 — RLS politike.** Uporabniške tabele `user_id = auth.uid()`; katalog javno-bralni; CASCADE ob izbrisu računa. *Commit:* `feat: RLS politike` (`8df4131`)
- [x] **5.4 — Preverba.** Ročni insert/select prek client proti testnemu uporabniku. *DoD:* RLS prepreči tuje vrstice. ✅ (PASS: A=1, B=0)

---

## M6 — Sync servis (ročni push/pull)

**Cilj:** drift ↔ Supabase, LWW po `updated_at`, brez razreševanja konfliktov (MVP enouporabniški). §2 tech-stack.

- [x] **6.1 — Povezljivost + infra.** `connectivity_plus`; `sync_status` označevanje ob zapisih. Razrezan na **6.1a** (povezljivost + konstante) + **6.1b** (anonimna seja + currentUserId).
  - [x] **6.1a — Povezljivost + sync_status konstante.** *Commit:* `feat: connectivity_plus + sync_status konstante` (`9bc57f9`)
  - [x] **6.1b — Anonimna seja + currentUserId (sync auth infra).** *Commit:* `feat: anonimna seja + currentUserId`
- [x] **6.2.0 — Katalog v oblak (vir resnice).** Generator iz Dart seed → `supabase/seed/catalog.sql` (idempotenten upsert), apliciran prek pooler; FK na katalog zdaj zadovoljen za push. **Odločitev (z uporabnikom):** oblak = vir resnice kataloga, naprave pull (6.3); bundlan seed = pred-release TODO. *Commit:* `feat: katalog v oblak (seed vir resnice)`
- [x] **6.2 — Push.** `pending` vrstice → `upsert` v Supabase (FK vrstni red: area→user_plant→task→…) → `synced`. *Commit:* `feat: sync push`
- [x] **6.3 — Pull.** `updated_at >= last_pulled_at` → upsert v drift; `deleted=true` → soft-delete lokalno. Razrezan na **6.3a** (user tabele) + **6.3b** (katalog pull + reaktiven provider).
  - [x] **6.3a — User-table pull.** Reverse mapperji (remote→drift Companion, `synced`), `SyncPullService` (inkluzivni kurzor + idempotenten upsert, LWW po `updated_at` prek `DoUpdate(where:)`, tombstone=soft-delete, FK red, child brez user_id filtra=RLS), `SyncCursors` tabela (v5), push guard (izključi `user_id='local'`). *Commit:* `feat: sync pull (user tabele)`
  - [x] **6.3b — Katalog pull + reaktivnost.** `CatalogSyncService` (full-pull, upsert po slug; category=insert-or-ignore); `catalog_provider` → StreamProvider (pull reaktivno osveži UI); SeedService **ostane** (offline fallback). Generator refaktoriran (`buildCatalogSql()` čista fn) + parnost test (committan `catalog.sql` == regeneriran) + id-kanoničnost test. *Commit:* `feat: katalog pull + reaktiven provider`
- [x] **6.4 — Sprožilci + LWW.** Ob zagonu/povezavi/periodično; LWW po `updated_at` (že v 6.3). `SyncService` orkestrator (seja+claim→push→pull→katalog; re-entrancy guard; izolirane faze; katalog le ob zagonu/reconnectu) + `SyncCoordinator` (3 sprožilci prek `onlineStatusProvider` + `Timer.periodic`). *Commit:* `feat: sync sprožilci + LWW`
- [x] **6.5 — Testi M6.** Unit (LWW + vrstni red) so že pokriti v 6.2–6.4; dodan **integracijski round-trip** (`sync_roundtrip_test.dart`): `_FakeCloud` služi push upsert + pull fetch nad eno shrambo → cikel teče skozi realne `*ToRemote`/`*FromRemote` mapperje (2 drift bazi = 2 napravi); pokriva fidelity, jsonb/enum, LWW med napravama, tombstone. Živa integracija proti testnemu projektu = on-device preverba (6.4). *Commit:* `test: sync`

---

## M7 — Auth + H3 na napravi

**Cilj:** anonimno "brez računa" → kasneje linkanje; lokacija → H3 celice (oblak) + lokalne koordinate (za vreme, ne zapustijo naprave). §3, §5 tech-stack. Zasloni 13, 15/15b-d, 16.

**Razrešene odločitve (2026-06-05, z uporabnikom):**
1. **GPS:** `geolocator` (1 nov paket, §1) za GPS; vpisan kraj → lat/lon prek **Open-Meteo Geocoding API** (brez ključa, obstoječi dio — brez paketa).
2. **OAuth:** **e-pošta OTP** (Supabase native, 0 paketov) + **Google native** (`google_sign_in` + `signInWithIdToken`, 1 nov paket + 👤 Google Cloud OAuth client). **Apple odložen na M10** (rabi iOS/macOS + Apple Developer) → gumb na Androidu **skrit**.
3. **Koordinate vs zasebnost:** lat/lon shranjen **lokalno-only** (ne-sync drift tabela, push jo izpusti) → vreme bere pravo lokacijo; **samo H3 celice** gredo v `profile` → oblak. CLAUDE.md "ne shrani koordinat" = "ne zapustijo naprave" (skladno wireframe 16).
4. **Obseg:** polno — lokacija ob onboardingu **nahrani vreme** (zamenja `kDefaultLatitude`) + H3 za V2.
5. **Izbris računa (GDPR):** **odložen na M9** (polish); M7 ima samo odjavo + clear lokalne baze.

> **Nova paketa izven §1:** `geolocator`, `google_sign_in` — ob izvedbi posodobi `tech-stack.md §1+§3`.

**Vrstni red:** data plast (lokacija+H3) → UI zasloni → linkanje → lifecycle → testi.

- [x] **7.1 — Lokacija + H3 na napravi (data plast).**
  - [x] **7.1a — Viri lokacije.** `geolocator`+`h3_flutter` v pubspec (+§1); Android dovoljenja (`ACCESS_FINE/COARSE_LOCATION`); `LocationService` (GPS→lat/lon, graceful zavrnitev); Open-Meteo Geocoding client (kraj→lat/lon, obstoječi dio). *Commit:* `feat: lokacijski viri (geolocator + Open-Meteo geocoding)`
  - [x] **7.1b — H3 + lokalna shramba.** lat/lon→res-7→izpelji res-6/5; H3 v `profile` (sync→oblak), lat/lon v **novo local-only tabelo** (push izpusti) — migracija v6; `LocationRepository` + provider. *Commit:* `feat: H3 celice + lokalna shramba koordinat`
  - [x] **7.1c — Vreme uporabi pravo lokacijo.** `weather_service`/`tasks_providers` berejo shranjeno lokacijo (fallback `kDefault*`). *Commit:* `feat: vreme uporabi shranjeno lokacijo`
- [x] **7.2 — Onboarding intro (15/15b/15c/15d).** 4-slide `PageView` + indikator; "Preskoči ›"/"Začni 🌿" → login; first-run gating (lokalni flag, samo prvič). *Commit:* `feat: onboarding intro (15)`
- [x] **7.3 — Prijava + lokacija zaslona (13, 16).**
  - [x] **7.3a — Login zaslon (13).** UI: Apple (skrit — M10), Google, e-pošta, "Preizkusi brez računa"; flow routing. *Commit:* `feat: prijava zaslon (13)`
  - [x] **7.3b — E-pošta OTP.** `signInWithOtp`→vnos kode→`verifyOTP` (Supabase native). *Commit:* `feat: e-pošta OTP prijava`
  - [x] **7.3c — Lokacija zaslon (16).** Gumb GPS + vnos kraja → 7.1 servis → home. *Commit:* `feat: lokacija zaslon (16)`
- [x] **7.4 — Google prijava (native).** `google_sign_in ^7.2.0`+`signInWithIdToken` → prijava; nato `start()` (claim+push+pull, ohrani gost-podatke=merge — **brez** `linkIdentity`/anon). AuthService.signInWithGoogle, gumb v login_screen, `kGoogleServerClientId` prek dart-define. **ON-DEVICE ✅:** Google prijava dela, isti email → povezan z obstoječim računom (brez dvojnika), gost-task claim+push (`fertilize`) + računov pull (`mow`/`Trata`) = merge. 👤 Google Cloud Web+Android OAuth (debug SHA-1 `D0:44:…:28:55`) + Supabase Google enabled. *Commit:* `feat: Google prijava`
- [x] **7.5 — Auth lifecycle.**
  - [x] **7.5a — Eager prvi pull** po prijavi/linku (ne čakaj periodičnega). Pokrito prek `syncCoordinator.start()` ob verify (link+signin) → takojšen cikel (push→pull). Dodatno **push-ob-shranjevanju** (debounce 2 s prek `db.tableUpdates`) → spremembe v oblaku v sekundah, ne čez periodični tick.
  - [x] **7.5c — Gost = lokalno (odstrani anon).** Brez `signInAnonymously` (kopičili so se anon računi pred izbiro prijave); gost = drift pod `kLocalUserId`, oblak šele ob prijavi (`claimLocalRows`+push → merge). Email ena pot (`sendEmailOtp`/`verifyEmailOtp`), `link`/updateUser/switch-warn odstranjeni. *(združeno v naslednji commit)*
  - [x] **7.5b — Odjava + reset/clear + email dve poti.** Odjava (potrditev → signOut + `clearUserData` + nova anon → onboarding); **flush push pred clear** (prepreči izgubo nepush-anih podatkov, offline→prekini); »Prijava« (signInWithOtp, preklop računa, clear+pull) vs »Poveži račun« (updateUser, ohrani podatke) + opozorilo gostu. GDPR izbris računa = M9. *Commit:* (združeno) `feat: lokacija (16) + odjava/email poti + fix izguba podatkov`
- [x] **7.6 — Testi M7.** Unit: geocoding parser (tolerantnost, blank=no-call), `clearUserData` (keepFlags, katalog ostane), `claimLocalRows` (že M6 + updated_at invarianta), `flushPush` (bool veje), **privacy: `device_location` se NIKOLI ne push-a** (koordinate ne zapustijo naprave, CLAUDE.md §2). **Device-verified (ne auto):** H3 izpeljava (FFI — `871e1390…` v oblaku), email/Google prijava + claim-merge, onboarding/login/lokacija flow (ročno on-device to sejo). Widget testi auth flowov odloženi (težak mock Supabase/google_sign_in/geolocator, nizek ROI). *Commit:* `test: M7 (geocoding, clearUserData, privacy device_location)`

---

## M8 — Lokalna obvestila (plast A)

**Cilj:** deterministični opomniki opravil, delujejo offline; deep-link na Detajl. §4 tech-stack. Zasloni 19–22.

- [x] **8.1 — Setup.** `flutter_local_notifications` + `timezone` + `flutter_timezone`; core-library desugaring, dovoljenja (`POST_NOTIFICATIONS`/`RECEIVE_BOOT_COMPLETED`/`SCHEDULE_EXACT_ALARM`) + **vsi 3 plugin receiverji** (Scheduled/ActionBroadcast/Boot — plugin jih NE deklarira sam), začasna eco ikona; `NotificationService` (init+tz+dovoljenje+exact). On-device potrjeno (takoj + razporejeno; zaprt app + ugasnjen zaslon). *Commit:* `feat: lokalna obvestila setup`
- [x] **8.2 — Razporejanje.** `reminder_schedule.dart` (čista `reminderFireTime`: dnevni offset+ura → dan-X ob uri, sicer taskDate−offset; stabilen 31-bit `reminderNotificationId` iz UUID). `ReminderCoordinator` (keepAlive): reconcile razporedi prihodnje opomnike čakajočih opravil + prekliče osirotele (le pending, ne prikazanih), reaktivno na `tableUpdates([tasks, taskReminders])` + debounce + ob zagonu. `NotificationService.scheduleAt/cancel/pendingIds` (payload=task id za 8.3). i18n `notifications.today/tomorrow`. On-device potrjeno (»1h prej« sproži). **Odloženo:** ime kanala še hardcoded SL + `Clock` v coordinatorju `const SystemClock()` (trigger-time je čista, testirana fn) — uredi v 8.4/8.5. *Commit:* `feat: razporejanje opomnikov`
- [x] **8.3 — Deep-link.** Tap obvestila → Detajl (17). `NotificationService` oddaja tapnjen task id prek `taps` streama (live) + `initialPayload()` (cold start prek `getNotificationAppLaunchDetails`); servis ločen od routerja (core/ ne kliče features/). `TendaskApp`→`ConsumerStatefulWidget` posluša `taps`→`goNamed('task-detail')`; `main` razreši cold-start v `initialLocation /tasks/:id`. *Commit:* `feat: deep-link obvestilo na detajl`
- [x] **8.4 — Zasloni 19/21/22 (+ prikaz na 17).** Detajl (17) kaže dejanske opomnike (`watchRemindersForTask`→`remindersForTaskProvider`, oznake prek `reminderLabel`). **Dovoljenja (21)** ✅ (`cb2efe7`): kontekstualni gate ob dodajanju (POST_NOTIFICATIONS + točni alarmi prek `canScheduleExactAlarms`/`openExactAlarmSettings`; brez duplikatov v izbirniku). **Dodaj obvestilo (19)** ✅ pokrit z reminder edit sheet. **Nastavitve (22)** ✅: vrste (opomniki aktivni; vreme/okolica disabled do FCM), privzeti zamik (ožičen v prefill), tihe ure + kapica (store-only za FCM-namige, NE vplivajo na eksplicitne opomnike — odločitev: skladno s konceptom), status točnih alarmov. Master stikalo gate-a `ReminderCoordinator`. Nastavitve v **`profile.notification_settings` jsonb** (LWW sync, sledijo uporabniku), drift v7→v8 + Supabase `0003`. **Videz/predogled (20)** ✅: statičen mockup zaklenjenega zaslona (3 vrste obvestil), dosegljiv iz 22. *Commit:* `feat: prikaz opomnikov na detajlu opravila (17)`, `feat: nastavitve obvestil (zaslon 22) + sync v profile`, `feat: predogled videza obvestil (zaslon 20)`
- [x] **8.5 — Testi M8 + čiščenje.** Odstranjen debug smoke-test gumb (Nastavitve) + `showNow`/`scheduleIn`/`ensureExactAlarms` iz servisa. Testi: `reminder_schedule` (6), `NotificationSettings` JSON tolerantnost (3), profile jsonb round-trip, `ProfileRepository` nastavitve + invarianta ne-clobber (3) → 151/151. On-device: exact alarmi na Samsung A53 brez battery-exemption, recents-swipe potrjen. *Commit:* `chore: odstrani debug smoke-test + testi nastavitev (8.5)`

---

## M9 — Polish + monitoring + Android release

**Cilj:** MVP pripravljen za interni Android test.

- [x] **9.1 — Sentry.** **Čisti Dart `sentry ^9.21.0`** (NE `sentry_flutter`): 8.x se ne prevede na svežem Android skladu (Kotlin 2.3.20/AGP 9 — sentry 8.x trdo kodira `compileSdk 34` + `languageVersion 1.6`), 9.x pa poriše `jni 1.0.0→0.14.1` in zlomi `h3_flutter`. Pure Dart paket nima native modula → se vedno prevede. `main.dart`: gate na DSN (prazen → off, offline-first kot Supabase); ko je DSN, `Sentry.init` + `runZonedGuarded(_bootstrap, …)` (async napake) + ročno `FlutterError.onError` in `PlatformDispatcher.onError` → captureException. `environment` `production`/`development` po `kReleaseMode`. DSN `kSentryDsn` prek `--dart-define`. Pipeline preverjen (dogodek v Sentry → Issues, projekt `tendask`). On-device: app se zažene brez crasha (release crash-capture = naslednjič). *Commit:* `feat: Sentry monitoring`, `fix: Sentry pure-Dart paket`
- [x] **9.2 — Ikona + splash (00).** Iz `docs/brand/assets/`. SVG→PNG prek node `sharp` (`tmp/icongen`, scratch) → `assets/icon/{icon-1024,foreground}.png` + `assets/splash/splash-logo.png`. `flutter_launcher_icons ^0.14.4` (android+ios, adaptive bg `#2e7d32` + transparent foreground, `remove_alpha_ios`) + `flutter_native_splash ^2.4.8` (color `#2e7d32` + bel logomark, android_12 blok) — konfig v `flutter_launcher_icons.yaml` + `flutter_native_splash.yaml`. Generirano za Android (mipmap + adaptive + splash drawable + styles v31) in iOS (AppIcon + LaunchImage, pripravljeno za M10). **Flutter splash zaslon** (`features/splash/`, zaslon 00): ker Android 12+ native splash kaže le ikono brez teksta, kratek in-app splash (zeleni radial gradient + logo + „Tendask" + verzija prek `package_info_plus`) na `/splash?next=…` → po `kSplashMinDuration` (1,2 s) routа na home/onboarding/deep-link. On-device potrjeno (ikona, native + Flutter splash z imenom+verzijo). *Commit:* `chore: app ikona + splash`
- [x] **9.3 — Pregled neskladij.** Pregled vseh ~22 zaslonov vs wireframi (5 vzporednih agentskih pregledov) + programski i18n del. **i18n pariteta sl/en/de čista** (380 ključev), brez hardcoded prevajalnih nizov. **Bucket A (popravljeno, `fix: neskladja UI/wireframi + i18n`):** tiho požiranje napake (home + task_detail → `common.load_error`), mrtev iskalni gumb (Dnevnik), lokalne kopije → skupni `SectionLabel` (3×), hardcoded `Colors.black` → `colorScheme.shadow`, `SheetHandle` v reminder sheetu, ročni datum → `formatDm()`, podvojena datumska vrstica, gost emoji → `Icons.person`, 2 mrtva i18n ključa. **Bucket B (produktne odločitve):** *implementirano* — swipe na Opravilih (desno=opravljeno/levo=+1 dan; skupni `SwipeActionBackground`), opomnik »Po meri« (število+enota), pre-permission priming zaslon (21). *Odloženo + wireframe uskladi* — Ponavljanje (= FR-5), Zaloge grupiranje po kategoriji (rabi shemo — `Supply` nima `category`), Vrt filter chipi, opomnik »Predogled« vrstica, community »V2« značka. **Lažna alarma (zavrnjena):** Vrt FAB (obstaja v `main_shell`), plant_row swipe barva (`primaryContainer` je brand zelena). analyze čist, 157/157 testov. *Commit:* `fix: neskladja UI/wireframi + i18n`, `feat(tasks): swipe akcije`, `feat(reminders): opomnik po meri`, `feat(notifications): priming zaslon`, `docs: uskladi wireframe (M9.3 odložene postavke)`
- [ ] **9.4 — Android release.** Keystore (👤), podpisan release build, `--dart-define` produkcijski ključi. *Commit:* `chore: Android release konfiguracija`
- [x] **9.6 — Razširitev kataloga rastlin (PRED RELEASOM, pred 9.5).** ~34 → **128 vrst** čez **12 kategorij** (lawn, fruit_tree, berries, vegetable, herbs, perennial, shrub, climber, bulb, conifer, hedge, houseplant). Metoda (z uporabnikom): **kuracija (SL/EN/DE ljudska imena, pogovorna) + GBIF preverba znanstvenih imen** (match API — vsa veljavna) + **Wikidata navzkrižna preverba SL imen** (batch SPARQL — potrdila imena; popravljen `hibiscus`→`sirski oslez`). Povezava rastlina→opravila prek **kategorije** (razširjena `categoryMatrix`, 93 vrstic). Vir: `lib/data/seed/catalog_seed.dart` → `tool/gen_catalog_sql.dart` → `supabase/seed/catalog.sql`. **Reseed (pre-release okno):** oblak posodobljen prek `apply_catalog.py` (128 plant, 93 matrika; počiščene osirotele `ornamental`/`container` matrika vrstice); naprava pull-a ob zagonu + bundlan seed (offline prvi zagon) = 128. Brez podvojenih id-jev, 151/151 testov, analyze čist. **On-device potrjeno: vseh 128 vrst prisotnih (pull + bundlan offline seed za prvi zagon brez signala).** *Commit:* `feat: razširjen katalog rastlin (128 vrst, GBIF/Wikidata preverba)`
- [ ] **9.7 — GDPR: izvoz podatkov + izbris računa.** Dva placeholderja v Nastavitvah (`export_data`, `delete_account`) sta zdaj »coming soon«; pred internim testom naredi dejansko. **Izvoz:** zberi vse uporabnikove drift vrstice (profile, area, user_plant, task + task_subject/reminder/note/task_supply) → JSON datoteka → `share`/shrani; brez koordinat (samo H3 celice). **Izbris računa:** potrditveni dialog (`showConfirmDialog destructive`) → Supabase brisanje računa (`ON DELETE CASCADE` počisti oblak) → lokalni `clearUserData` → nazaj na onboarding. Anon gost: lokalni izvoz + lokalni clear (ni oblačnega računa). *Commit:* `feat: GDPR izvoz + izbris računa`. **Opomba:** enote (°C/°F) namerno opuščene — MVP je metričen (SL/EU trg); »Območja« povezava odstranjena iz Nastavitev (podvojena z Vrt zavihkom).
- [ ] **9.5 — 👤 Play interni test.** Naloži na Play Console interni track. **Predpogoj: 9.6 (poln katalog).**
- [x] **9.8 — UI polish + začasni izklop sredstev.** Manjši UX popravki pred releasom (z uporabnikom, wireframe-driven): izklop debug pasu; jezikovni `SegmentedButton` brez kljukice (popravek preloma dolgih endonimov); **Domov** — opravila kažejo rastlino-subjekt (🪴, kot zaslon Opravila) + zamujena opravila v **strnjenem rdečem pasu**, ki se ob kliku razširi v seznam na mestu (prej zamujena na Domov niso bila prikazana); **prenova zaslona Lokacija** — iz Nastavitev (push) back + samodejno shranjevanje + toast brez spodnjega gumba, iz onboardinga (go) gumb »Nadaljuj«; statusni pas (nastavljeno/ni) + gumb **»Odstrani lokacijo«** s potrditvijo (`clearGardenLocation` počisti koordinate + H3 celice → vreme pade na privzeto območje); **Vrt** — obrnjena hierarhija (območje = naslov skupine, rastline = kartice pod njim, prej je bilo območje bolj zamaknjeno kot rastline). **Sredstva (supplies) začasno skrita** prek nove konstante `kSuppliesEnabled=false` (`core/config.dart`): preskočen korak »Sredstva« v čarovniku + skrita sekcija »Vrt/zaloge« v Nastavitvah; koda ostane za kasnejšo vključitev. Novi wireframi `16b-location`, `01b-home-overdue-{collapsed,expanded}`, `vrt_v5`. analyze čist, 157/157. *Commiti:* `chore(i18n): ključi za lokacijo in zamujena opravila`, `feat(location): status, brisanje in kontekstni gumb`, `feat(home): rastlina ob opravilu + pas zamujenih`, `refactor(garden): hierarhija območje kot naslov, rastline kartice`, `chore(ui): debug pas, jezikovni gumb, skrij sredstva (kSuppliesEnabled)`, `docs(wireframes): lokacija, zamujena, vrt (v5)`

---

## M10 — *(po MVP)* iOS mejnik

> Zahteva macOS + Xcode ali oblačni build (Codemagic / GitHub macOS runner) + Apple Developer (99 $/leto).
> iOS dovoljenja (lokacija, obvestila), ikone/splash, podpisovanje, App Store metapodatki, TestFlight.

---

## M11 — *(po MVP / V2)* Pametni motor + FCM + percentili

> Plast B: dnevni paketni pregled (cron/Edge Function) + FCM push, 3–4 kurirana pravila (brez AI),
> vodenje proti gnjavljenju (cooldown, vremenske straže, dedup, frekvenčna kapica). Glej
> [`pametni-motor.md`](pametni-motor.md) + `koncept.md` §7.13. V2: percentili okolice (`activity_agg`, §8).
> Razširitev kataloga rastlin 35 → 100–200 (Wikidata/GBIF) je **premaknjena na PRED-RELEASE → glej 9.6** (mora biti pred internim testom; ne čaka na M11).
>
> **Agregacija okolice — celovit statistični + podatkovni model: [`skupnost-agregacija.md`](skupnost-agregacija.md)**
> (vsa odprta vprašanja razrešena 2026-06-08; povzetek v `koncept.md §8`).
> - **Zgodnji temelj (poceni, kandidat za PRED-V2, da kopiči zgodovino):** nova polja
>   `profile.climate_bucket` + `climate_profile` (jsonb, owner-only) + `timezone`, `task.agg_context`
>   (jsonb posnetek veder ob `done`), `task_type.seasonal`; on-device izpeljava klime (Open-Meteo
>   normals) + sync; tabele `activity_recent/season/frequency` + `pg_cron` (nočno, inkrementalno) +
>   javno-bralna RLS (`K_privacy=5`). Teče tiho, brez UI.
> - **V2 pogledi (odkleni ob gostoti):** feed + časovni percentil + frekvenca; fallback
>   res-7→6→5→climate→globalno; opt-in obvestila okolice (§7.12 vrsta 3). Anti-junk: zrelostni filter
>   (X/N/M) + `distinct_users` + drseče okno + izločen `is_custom`; prikaz številke ob `K_reliab=30`.
> - **V2.5+:** ocena primernosti opravila (raje implicitni signal kot zvezdice).

---

## Backlog (feature requests)

> Zabeleženo med razvojem; ni vezano na trenutni mejnik. Implementira se kot ločen korak po dogovoru.

- **FR-1 — Grid tipov opravil: razširi/skrij + sort po pogostosti.** ✅ **Implementirano 2026-06-04.**
  Sort po pogostosti + razširi/skrij sta narejena (`type_step`); del »ekstrahiraj skupni `TaskTypeGrid`
  (podvojen v 02/07)« je odpadel — po stepperju je grid samo še en klicalec. Grid (~26 tipov) v Hitrem
  vnosu (02) in obrazcu (07) privzeto pokaže le ~6 (2–3 vrstice) + gumb **Razširi** (prikaže vse) /
  **Skrij** (nazaj na 6). Bonus: sortiranje po pogostosti uporabe **per user** — izvedljivo brez nove
  sheme prek `SELECT task_type_id, COUNT(*) FROM task WHERE deleted=0 GROUP BY task_type_id ORDER BY 2 DESC`
  (najpogostejši v zgornjih 6). Najprej ekstrahiraj skupni `TaskTypeGrid` widget (zdaj podvojen v 02/07).
- **FR-3 — Zatikanja (performance).** 🔄 **Glavni opaženi izvor odpravljen (2026-06-07), ostalo opazovano.**
  Med ročno preverbo M3.7 opažena rahla zatikanja pri navigaciji/scrollu. Najbolj opazen izvor —
  »občutek zmrznitve« na plant-add (katalog ~128 vrst grajen kot `Column` naenkrat + rebuild ob vsakem
  toggle; `recentPlantsProvider` `AsyncLoading` flicker) — odpravljen v `8c1cd05` (lazy `SliverList` +
  snapshot pogostih v `initState`); na napravi zatikanja ni več zaznati. **Namenski profiling pass se ni
  zgodil** — širša zatikanja niso izmerjena. Pusti odprto: če se spet pojavi, profiliraj (DevTools timeline),
  poišči nepotrebne rebuilde (`const`, ozki `watch`/`select`), preveri drift stream rebuilde. Najprej izmeri.
- **FR-2 — Dodaj območje iz obrazca opravila.** ✅ **Implementirano (potrjeno 2026-06-04).** Vsi trije
  »ustvari sproti« vzorci so v stepperju: subject_step »+ Dodaj območje« (`area-new` → `area_form` vrne nov
  `areaId` prek `pop` → auto-select) in »+ Dodaj rastlino« (`plant-new`), supplies_step »pick_new«
  (`showSupplyEditSheet` → auto-select). Reaktivna osvežitev: `areasMapProvider`/`userPlantsMapProvider`/
  `suppliesListProvider` so StreamProvider nad drift `watchAll()`, zato se nov element takoj prikaže.
  Prazen vrt ni dead-end (gumbi so vidni tudi brez vnosov). Originalni predlog: ponudi inline povezavo
  **"+ Dodaj območje"** → odpre obrazec → vrne z izbranim (+ isti vzorec za rastlino/sredstvo).
- **FR-4 — Navigacija po dnevih na časovnici Dnevnika.** ✗ **Umaknjeno (2026-06-04).** Prototip dnevnega
  traku (skok na dan) je bil implementiran in po pregledu na napravi **zavrnjen** — dodal je vizualni šum
  brez prave vrednosti. Navigacijo po datumih že pokrivata kronološka časovnica (s skupinami po dnevih) in
  mesečni pogled. Ne implementiramo, dokler ne bo jasne potrebe in boljšega dizajna.
- **FR-5 — Ponavljanje opravil (nice-to-have).** Korak »Kdaj« v vnosu predvideva izbiro ponavljanja
  (Enkratno / Tedensko / Sezonsko; `task.recurrence` JSON, polje že obstaja). MVP ga **namenoma izpušča**:
  dejanska logika (generiranje naslednjih instanc, urejanje serije, izjeme) ni trivialna in ni nujna za
  beleženje. Kasneje: definiraj pravilo ponavljanja + generator + UI za serijo. Do takrat je vsako opravilo enkratno.
- **FR-6 — »Ponovi zadnje« (hitrost ponavljajočega beleženja).** ✅ **Implementirano 2026-06-04.** Vrt pogosto pomeni isto opravilo na
  istih subjektih večkrat (zalivam paradižnik vsak večer). Predlog: na koraku 1 (Tip) stepperja na vrhu
  kartica »↻ Ponovi zadnje — 💧 Zalivanje · Paradižnik …«; tap predizpolni tip + subjekte + sredstva +
  opombo iz zadnjega ustvarjenega opravila, datum/uro resetira na zdaj (status izpeljan iz datuma) in
  skoči naravnost na Pregled. Vir = zadnji task iz baze (`watchAll()` že obstaja), offline-OK, brez novega
  state managementa. Odprto pri implementaciji: ali pristati na Pregledu ali na koraku Subjekti (subjekti se
  najpogosteje spremenijo). NE predizpolnjevati koraka 1 z zadnjim tipom (ubije auto-advance). Premišljeno
  med UX validacijo stepperja 2026-06-04, odloženo na po-MVP.
- **FR-7 — Vreme: deduplikacija + okno ±1 dan.** 📝 **Odločeno na papirju 2026-06-06, neimplementirano.**
  Polna specifikacija: [`vreme-shranjevanje.md`](vreme-shranjevanje.md). Vreme je danes denormaliziran JSON
  blob na vsakem tasku (~600 B × 3,6 M opravil/leto pri 10k uporabnikih ≈ ~2,1 GB/leto, večinoma podvojeno).
  Model: vreme = `f(h3_r7, dan)` → **hibrid**: (A) trenutni pogoji ob kliku ✓ = kompakten frozen blob na
  tasku (urno, zaseben); (B) dnevni povzetki dan −1/0/+1 = skupna `weather_observation(h3_r7, dan)`
  (`weather_code`, `temp_max`, `temp_min`, `precipitation_sum`, javno-bralna kot katalog). Dan +1 = najprej
  napoved → samozdravljenje v dejansko (lazy ob branju, vezano na celico; cron backstop V2). Zasebnost: cron
  uporabi centroid celice (`cellToLatLng`), ne koordinat. **Faznost:** MVP = lokalni hibrid + kompaktiranje
  blob-a; shared cloud `weather_observation` + cross-user dedup + cron = V2 (skala). Posledica: posodobi
  `koncept.md` §7.9/§7.10 (frozen → hibrid) ob implementaciji. Opozorilo: Open-Meteo pri 10k = komercialna raba.

## Dnevnik napredka

> Agent tu dopisuje zaključene korake (datum · korak · commit hash). Najnovejše zgoraj.

- 2026-06-08 — **9.8 — UI polish + začasni izklop sredstev.** Z uporabnikom prek HTML wireframov:
  debug pas off; jezikovni gumb brez kljukice (popravek preloma); Domov — rastlina-subjekt ob opravilih
  + razširljiv rdeč pas zamujenih (prej se zamujena na Domov niso prikazala); prenova **Lokacije**
  (Nastavitve = back + auto-save + toast brez gumba, onboarding = »Nadaljuj«, statusni pas nastavljeno/ni,
  gumb »Odstrani lokacijo« → `clearGardenLocation` počisti koordinate + H3 → privzeto vreme); **Vrt**
  obrnjena hierarhija (območje = naslov skupine, rastline = kartice pod njim). **Sredstva začasno skrita**
  prek `kSuppliesEnabled=false` (korak v čarovniku + sekcija v Nastavitvah; koda ostane). Novi wireframi
  `16b-location`, `01b-home-overdue-{collapsed,expanded}`, `vrt_v5` (stare predloge pobrisane). Dokumentacija
  usklajena (koncept §7.7/§7.8/§7.10/§7.15, fokus-rastlina §10.2, tech-stack §6, NEXT-SESSION, galerija
  index.html). analyze čist, 157/157. *Commiti:* `chore(i18n): ključi za lokacijo in zamujena opravila`,
  `feat(location): status, brisanje in kontekstni gumb`, `feat(home): rastlina ob opravilu + pas zamujenih`,
  `refactor(garden): hierarhija območje kot naslov, rastline kartice`, `chore(ui): debug pas, jezikovni gumb,
  skrij sredstva (kSuppliesEnabled)`, `docs(wireframes): lokacija, zamujena, vrt (v5)`, `docs: uskladi dokumentacijo`
- 2026-06-08 — **9.3 — Pregled neskladij UI/wireframi + i18n.** 5 vzporednih agentskih pregledov ~22
  zaslonov + programski i18n pregled (pariteta sl/en/de čista, brez hardcoded nizov, 2 mrtva ključa).
  Bucket A popravljen (tiho požiranje napake, komponentni katalog, hardcoded barve, SheetHandle, datum
  helper, mrtvi ključi). Bucket B z uporabnikom: implementirani swipe na Opravilih, opomnik »Po meri«,
  pre-permission priming zaslon (21); odloženi (wireframe označen po-MVP) Ponavljanje/FR-5, Zaloge
  grupiranje (rabi `Supply.category`), Vrt filter. Dva lažna alarma zavrnjena po verifikaciji (Vrt FAB
  obstaja v `main_shell`; plant_row swipe barva je brand zelena). analyze čist, 157/157.
  *Commiti:* `fix: neskladja UI/wireframi + i18n`, `feat(tasks): swipe`, `feat(reminders): po meri`,
  `feat(notifications): priming`, `docs: uskladi wireframe`.
- 2026-06-08 — **BUG-001** (`gardenLocation` StateError) razrešen prek `keepAlive` (`16c77f8`); čaka on-device.
- 2026-06-07 — **9.6 — Razširitev kataloga rastlin (~34 → 128).** 12 kategorij (dodane perennial,
  shrub, climber, bulb, conifer, hedge, houseplant; opuščeni nerabljeni ornamental/container). Metoda
  (z uporabnikom): kuracija SL/EN/DE pogovornih imen + **GBIF** preverba znanstvenih imen (vsa veljavna;
  flagi le hibridni × / hortikulturni sinonimi / GBIF quirk pri samostojnih rodovih) + **Wikidata** batch
  SPARQL navzkrižna preverba SL imen (potrdila pogovorna imena; edini popravek `hibiscus`→`sirski oslez`).
  Dodanih 19 pogosto manjkajočih (pelargonija, lešnik, sončnica, zelena, blitva, motovilec, rukola,
  brstični ohrovt, melisa, pehtran, kamilica, kaki, aronija, perunika, šmarnica, rododendron, magnolija,
  tisa, aloja). `categoryMatrix` razširjena (93 vrstic; +`sow` za trajnice/cvetlice). Pipeline:
  `catalog_seed.dart`→`gen_catalog_sql.dart`→`catalog.sql`; oblak reseedan prek `apply_catalog.py` (počiščene
  osirotele matrika vrstice). Brez podvojenih id-jev, 151/151, analyze čist. **On-device potrjeno: vseh
  128 vrst prisotnih (pull + bundlan offline seed).** *Commit:* `feat: razširjen katalog rastlin (128 vrst, GBIF/Wikidata preverba)`
- 2026-06-07 — **9.2 — Ikona + splash (zaslon 00).** SVG (vir resnice `docs/brand/assets/`) → PNG prek node
  `sharp` v `tmp/icongen` (scratch, gitignored): `app-icon.svg`→`assets/icon/icon-1024.png` (gradient + mark),
  `app-icon-foreground.svg`→`assets/icon/foreground.png` (transparent, 66% safe zone), `logomark.svg`→
  `assets/splash/splash-logo.png` (bel šesterokotnik + zelen list). `flutter_launcher_icons ^0.14.4` (dev):
  android+ios, **adaptive icon** bg `#2e7d32` + transparent foreground, `remove_alpha_ios`, `min_sdk 21` →
  generiral mipmape, `mipmap-anydpi-v26` adaptive, `colors.xml`, iOS AppIcon set. `flutter_native_splash ^2.4.8`
  (dev): `color #2e7d32` + centriran logomark + `android_12` blok (sistemski splash API) → splash drawable +
  `values-v31`/`values-night-v31` styles + iOS LaunchImage. Konfig ločen (`flutter_launcher_icons.yaml`,
  `flutter_native_splash.yaml`) da ne zatrpa pubspec. Vir-PNG-ji vizualno preverjeni (gradient/mark/transparentnost
  pravilni; bel šesterokotnik je na beli predogled nasloni neviden = pričakovano, na zeleni podlagi viden). iOS
  generiran vnaprej (pripravljeno za M10). On-device videz (home ikona + boot splash) = ob naslednji napravi.
  analyze čist, testi nedotaknjeni (151/151). *Commit:* `chore: app ikona + splash`
- 2026-06-07 — **9.1 — Sentry monitoring → M9 začet.** `sentry_flutter ^8.14.2` (potrjen sklad §1, free dev
  tier). `main.dart`: bootstrap ekstrahiran v `_bootstrap()` + ovit v `SentryFlutter.init(appRunner:)` (zajame
  tudi startup napake, ne le runtime). Gate na DSN (prazen → Sentry off, app boota normalno — isti offline-first
  vzorec kot Supabase init; Sentry brez signala buffer-a). `options.environment` = `production` v release / `development`
  sicer (loči dev šum); brez performance tracinga + brez PII (zasebnost, baterija). `kSentryDsn` prek `--dart-define`
  (`SENTRY_DSN` v gitignored `dart_defines.json`; placeholder v `dart_defines.example.json`). DSN/pipeline preverjen
  prek začasnega `tmp/sentry_smoke.dart` (čisti `package:sentry`, brez naprave) → testni dogodek dostavljen v Sentry →
  Issues (projekt preimenovan v `tendask`). On-device crash-capture odložen na naslednjo priklopljeno napravo (app
  integracija je trivialna + analyze-čista). analyze čist, 151/151. *Commit:* `feat: Sentry monitoring`
- 2026-06-06 — **8.4 zaslon 20 + 8.5 čiščenje/testi → M8 ZAKLJUČEN.** **Zaslon 20** (`feat: predogled videza
  obvestil (zaslon 20)`): statičen mockup zaklenjenega zaslona (gradient `AppColors.green900/green`, ura, 3 kartice
  opomnik/vreme/okolica z barvnimi tagi), dosegljiv iz nastavitev 22; i18n `notif_preview.*`. **8.5** (`chore:
  odstrani debug smoke-test + testi nastavitev (8.5)`): odstranjen M8.1 smoke-test (gumb v nastavitvah +
  `showNow`/`scheduleIn`/`ensureExactAlarms` v servisu); +3 testi `ProfileRepository` nastavitev (privzetki,
  insert+pending, invarianta nastavitve↔lang se ne povozita). 151/151, analyze čist. On-device: recents-swipe na
  Samsung A53 potrjen (exact alarmi brez battery-exemption). **M8 (lokalna obvestila, plast A) zaključen.**
- 2026-06-06 — **8.4 nastavitve obvestil (zaslon 22) + prikaz na detajlu + sync.** Detajl (17): vrstica opomnik
  kaže dejanske opomnike (`watchRemindersForTask`→`remindersForTaskProvider`, oznake prek `reminderLabel`).
  Zaslon 22 (`notification_settings_screen`): vrste (opomniki aktivni; vreme/okolica disabled do FCM), privzeti
  zamik (segmented {0,60,1440}, ožičen v prefill reminder sheeta), tihe ure + kapica (store-only — odločitev z
  uporabnikom: NE vplivajo na eksplicitne opomnike, skladno s konceptom §"Vodenje proti motečnosti"; tihe ure
  semantika A), status točnih alarmov. **Master stikalo** gate-a `ReminderCoordinator` (izklop prekliče
  razporejene; watcha `profiles`). **Sync**: nastavitve premaknjene iz device-local `local_flag` v
  **`profile.notification_settings` jsonb** (LWW, `claimLocalRows` že pokriva profile → sledijo uporabniku);
  `NotificationSettings` (core/notifications) + toJson/fromJson tolerantno; drift **v7→v8** (additive addColumn) +
  Supabase **`0003`** (`alter table profile add column ... jsonb`, db push aplicirano). +4 testi (jsonb round-trip,
  JSON tolerantnost). On-device potrjeno (migracija, zaslon, master toggle, prefill, persist). analyze čist,
  148/148. *Commit:* `feat: prikaz opomnikov na detajlu opravila (17)`, `feat: nastavitve obvestil (zaslon 22) + sync v profile`
- 2026-06-06 — **8.3 deep-link + dovoljenja + zvonček + fix.** **8.3** (`41f9792`): tap obvestila → Detajl (17);
  `NotificationService` oddaja tapnjen task id prek `taps` streama (live) + `initialPayload()` (cold start), ločen od
  routerja; `TendaskApp`→ConsumerStatefulWidget posluša→`goNamed('task-detail')`, `main` razreši cold-start v
  `initialLocation`. **Dovoljenja+brez duplikatov** (`cb2efe7`, del 8.4): kontekstualni gate ob dodajanju opomnika
  (POST_NOTIFICATIONS + točni alarmi prek `canScheduleExactAlarms`/`openExactAlarmSettings`); v izbirniku že dodani
  zamiki onemogočeni. **Zvonček** (`8ecefe6`): Domov+Opravila kažeta ikono obvestila pri opravilih z opomnikom
  (`watchTaskIdsWithReminders`→`taskIdsWithRemindersProvider`). **Fix** (`e79344b`): reconcile drži autoDispose
  label-mape žive prek `ref.listen` (prej »disposed during loading« → padel). **Nauk: SCHEDULE_EXACT_ALARM na
  Android 14+ ni privzet — svež deploy ga ponastavi → `exact_alarms_not_permitted`.** On-device potrjeno razporejanje
  + gate; deep-link/zvonček še ne. analyze čist, 144/144.
- 2026-06-06 — **8.2 — Razporejanje opomnikov.** Čista `reminderFireTime` (dnevni offset+ura → dan-X ob uri; sicer
  taskDate−offset) + stabilen 31-bit `reminderNotificationId` iz UUID (`reminder_schedule.dart`, 6 testov).
  `ReminderCoordinator` (keepAlive): reconcile razporedi prihodnje opomnike čakajočih opravil prek `scheduleAt`
  (payload=task id za 8.3) in prekliče osirotele (`pendingIds` − `desired`, le pending), re-entrancy guard +
  reaktivno na `tableUpdates([tasks, taskReminders])` + debounce (`kReminderDebounce`) + `start()` v `main`.
  Naslov=ikona+tip, telo=subjekt·datum (danes/jutri prek slang `notifications.*`). `tasksRepository.pendingTasks()`.
  **Odloženo:** ime kanala hardcoded SL + `Clock` v coordinatorju `const SystemClock()` (trigger-time je čista fn) →
  8.4/8.5. On-device potrjeno (»1h prej« sproži). analyze čist, 142/142. Commit: `feat: razporejanje opomnikov`.
  Med sejo še `fix: soft-delete opravila kaskadira na otroke` (`52c195a`): `softDelete` zdaj soft-deleta tudi
  `task_subject`/`task_reminder`/`task_supply` (prej so v oblaku ostali `deleted=false` pod izbrisanim opravilom).
- 2026-06-06 — **8.1 — Lokalna obvestila (setup) → M8 začet.** Paketi `flutter_local_notifications ^21.0.0`,
  `timezone ^0.11.0`, `flutter_timezone ^5.1.0` (zadnji izven §1 — z dovoljenjem, §1 dopolnjen). Android: core-library
  desugaring (`desugar_jdk_libs:2.1.4`, rabi ga `zonedSchedule`); manifest dovoljenja `POST_NOTIFICATIONS` +
  `RECEIVE_BOOT_COMPLETED` + `SCHEDULE_EXACT_ALARM` + **vsi 3 plugin receiverji** (`ScheduledNotificationReceiver`,
  `ActionBroadcastReceiver`, `ScheduledNotificationBootReceiver`); začasna eco vector ikona (`ic_stat_notify`,
  prava v M9). `core/notifications/notification_service.dart`: tanek ovoj — `init()` (tz baza + lokalna IANA cona
  prek flutter_timezone + plugin init), `requestPermission()` (odložen na priming 21), `ensureExactAlarms()`,
  keepAlive provider; init fire-and-forget v `main.dart`. **Odločitvi (z uporabnikom):** (1) **točni alarmi**
  (`exactAllowWhileIdle`) — ne inexact (na Samsungu odloženi/nezanesljivi); (2) `flutter_timezone` za IANA cono.
  **DEVICE DEBUG SAGA (ključen nauk):** takojšnje obvestilo je delovalo, razporejeno NIKOLI — po diagnostiki
  (`exact:true`, `pending:1`, prava cona, brez napake) ni bil ne Doze ne koda, ampak **manjkajoč
  `ScheduledNotificationReceiver` v manifestu** (plugin receiverjev NE deklarira sam → AlarmManager se sproži, a
  nima kdo prikazati obvestila). Po dodajanju vseh 3 receiverjev: on-device potrjeno takoj + razporejeno, zaprt app,
  **ugasnjen zaslon** (Samsung A53, exact alarmi delujejo brez battery-exemption). Začasen kDebugMode smoke-test gumb
  v Nastavitvah (ostane skozi M8, odstrani v 8.5). flutter analyze čist, 135/135, debug APK gradi. docs: tech-stack §1.
  Commit: `feat: lokalna obvestila setup`.
- 2026-06-05 — **7.6 — Testi M7 → M7 ZAKLJUČEN.** Dodani unit testi (pure logika, CLAUDE.md pragmatika):
  `geocoding_client_test` (4: parsiranje, tolerantnost manjkajočih polj + int→double, prazna poizvedba brez
  network klica), `clear_user_data_test` (3: počisti uporabniške+device-local tabele, katalog ostane, keepFlags
  ohrani/počisti onboarding flag), privacy test v `sync_push_service_test` (**`device_location` se NIKOLI ne push-a**
  — koordinate ne zapustijo naprave, CLAUDE.md §2), `local_row_claim_test` dopolnjen (updated_at nedotaknjen ob
  claim). flushPush že pokrit (`573ee2c`). **H3 izpeljava + auth flowi + onboarding/login/lokacija = device-verified**
  to sejo (ne auto: FFI/Supabase/google_sign_in/geolocator mock = nizek ROI). flutter analyze čist, **135/135**.
  Commit: `test: M7 (geocoding, clearUserData, privacy device_location)`. **→ M7 (Auth + H3) ZAKLJUČEN.**
- 2026-06-05 — **7.4 — Google prijava (native), koda.** `google_sign_in ^7.2.0` (v7 API: `GoogleSignIn.instance.initialize(serverClientId:)`
  enkrat → `authenticate(scopeHint:)` → `account.authentication.idToken`). `AuthService.signInWithGoogle()` vrne `bool`
  (true=prijavljen, false=preklic prek `GoogleSignInException.canceled` → ni rdeče napake; sicer `AuthException`) →
  `supabase signInWithIdToken(provider: google, idToken)`. Po uspehu `start()` (claim+push+pull = merge gost-podatkov,
  enako kot email; **brez** linkIdentity/anon). `login_screen` → `ConsumerStatefulWidget`, Google gumb ožičen
  (loading spinner, gumbi disabled med prijavo). `kGoogleServerClientId` prek `--dart-define` (prazno → throw
  »not configured«, ostalo dela). i18n `auth.google_error`. tech-stack §1/§3. flutter analyze čist, **127/127**.
  **👤 Faze 1–4 narejene** (Google Cloud Web+Android OAuth client z debug SHA-1, Supabase Google enabled).
  **ON-DEVICE ✅ (debug build — debug SHA-1 registriran):** Google prijava uspela; isti email kot email-OTP →
  Supabase **povezal identiteti pod en račun** (`bad8ff62`, brez dvojnika); gost ustvaril task → Google prijava →
  claim+push (`fertilize` v oblaku) + pull računovih (`mow`/`Trata`) = **oba vidna (merge potrjen)**. **Opomba:** Google
  zahteva debug-podpisan build (release keystore = drug SHA-1, dodati pred Play). Commit: `feat: Google prijava`.
- 2026-06-05 — **7.5c — Gost = lokalno (odstrani anonimne seje).** **Odločitev (z uporabnikom):** anonimni `auth.users`
  so se kopičili še preden je uporabnik izbral način prijave (vsak zagon online + vsaka odjava + »Prijava« =
  ločen račun → sirote). Rešitev = **gost popolnoma lokalno** (drift pod `kLocalUserId`, **brez** `signInAnonymously`);
  oblak se vključi šele ob pravi prijavi (email/Google) → `claimLocalRows` posvoji gost-vrstice na nov uid + push →
  **prijava ohrani podatke (merge, ne reset)**. Ujema se z UI obljubo »brez računa = podatki lokalni«. Spremembe:
  `auth_service` brez `ensureAnonymousSession`/`signInAnonymously`; **email ena pot** `sendEmailOtp`/`verifyEmailOtp`
  (odstranjene `sendLinkOtp`/`verifyLinkOtp` = updateUser/emailChange + `sendSignInOtp`/`verifySignInOtp`);
  `sync_service.ensureSession` ne ustvarja več anon (le claim ob seji); `email_login`/`login` brez `link` veje +
  `switch_warn`/flush-pred-switch/`hasUserData` odstranjeni (prijava ne briše več); settings `_logout` brez ensureAnon
  (→ gost stanje; **flush le ob seji** — gost reset brez lažnega offline sporočila), gost tile → `/login`; router brez
  `?link=`. Branje ni filtrirano po `user_id` (`watchAll` le `deleted=false`)
  → gost-podatki ob prijavi ostanejo vidni brez utripa (claim teče v ozadju prek `start()`). **Poenostavi 7.4**
  (Google = `signInWithIdToken`+claim, ne `linkIdentity`). docs: tech-stack §3. **👤 Supabase:** izklopi Anonymous
  sign-ins + pobriši obstoječe anon userje. flutter analyze čist, **127/127**. Commit: *(združen s spodnjim)*.
- 2026-06-05 — **7.3c + 7.5a/b — Lokacija (16), odjava/reset, email dve poti + FIX izguba podatkov.**
  **Bug (diagnosticiran z dejstvi, `tmp/sync_verify.py`):** po logout→login z obstoječim emailom se podatki niso
  vrnili. Vzrok = **podatki nikoli push-ani v oblak** (push je bil le periodičen/ob-zagonu/reconnect; `clearUserData`
  ob odjavi/preklopu jih je izbrisal lokalno PRED push-em). Pull po loginu pravilno vrnil nič. **Popravek (2 dela):**
  (1) **varovalo** — `SyncService.flushPush()` (vrne `bool`, izpostavi napako za razliko od `sync()`); settings
  `_logout` flush-a PRED `clearUserData`, offline→snackbar+prekini (ne izbriše); email signin pot flush-a star račun
  pred clear + **opozori gosta** z lokalnimi podatki (naj uporabi »Poveži račun«) prek `showConfirmDialog`
  (`AppDatabase.hasUserData()`). (2) **push-ob-shranjevanju** — `SyncCoordinator` posluša `db.tableUpdates(...)` na
  sync tabelah + debounce `kPushDebounce=2s` → `push()` (direktno, brez claim → ni zanke); push je inkrementalen
  (samo `pending`). **7.3c:** `LocationScreen` (GPS prek `LocationService` + vnos kraja prek `GeocodingClient`) →
  `saveGardenLocation` (H3→profile, koordinate device-local); router `/location`; flow login/email-verify → `/location`,
  settings »Lokacija za vreme« → `push('/location')`. **Email dve poti:** `auth_service` `sendLinkOtp`/`verifyLinkOtp`
  (updateUser/emailChange, ohrani uid+podatke) vs `sendSignInOtp`/`verifySignInOtp` (signInWithOtp/email, preklop);
  `link` param skozi LoginScreen+EmailLoginScreen+router `?link=`. i18n location/email_login.switch_warn/settings.logout*
  sl/en/de. flutter analyze čist, **127/127 testov** (+4 flushPush). **ON-DEVICE ✅ (release, SM RZCT70XGC5P):** push-ob-
  shranjevanju (area »Trata«+task »mow« v oblaku v sekundah), logout→login z `exogenus@gmail.com` **vrne podatke**
  (isti uid `bad8ff62`, brez podvojitev — idempotenten pull). Commit: `feat: lokacija (16) + odjava/email poti + fix izguba podatkov`.
- 2026-06-05 — **7.3b — E-pošta OTP.** **Odločitev (tehnično enolična za ohranitev podatkov):** anonimni →
  e-pošta prek `updateUser(UserAttributes(email:))` + `verifyOTP(type: OtpType.emailChange)` — **ohrani isti
  `user.id`**, zato lokalni podatki (claim-ani na anon uid v M6) ostanejo (skladno wireframe 13). `signInWithOtp`/
  `OtpType.email` bi ustvaril NOVEGA userja (izguba) → ne uporabljen. `core/auth/auth_service.dart`:
  `sendEmailOtp(email)` (ensureAnonymousSession + updateUser) + `verifyEmailOtp(email, token)`; throwata
  `AuthException` če klient null (offline build). `features/auth/presentation/email_login_screen.dart`:
  dvostopenjski (email→koda), validacija, `digitsOnly`+maxLength 6, loading spinner na gumbu, error
  (`err_send`/`err_verify`), »Pošlji novo kodo«; po uspehu → `/home` (location 16 vrine 7.3c); mounted check po
  await, controllerji disposed. Router `/login-email`; login e-pošta gumb → `push('/login-email')`. i18n
  `email_login.*` sl/en/de (param `code_sent(email)`). flutter analyze čist, **123/123 testov**.
  **👤 Supabase TODO za on-device:** email auth provider ✅ že vklopljen; **email template »Confirm email
  change« mora vsebovati `{{ .Token }}`** (sprememba iz brez-email na email pošlje na ta template), sicer
  uporabnik prejme magic link namesto kode. Commit: `feat: e-pošta OTP prijava`.
- 2026-06-05 — **7.3b popravek (on-device).** Ob živi preverbi 3 odpravljene zadeve: (1) **OTP koda 8-mestna**
  (Supabase strežniška nastavitev), app je zahteval fiksno 6 → fleksibilno `code.length < 6` + `maxLength 10` +
  `counterText ''`; (2) **error handling pokaže pravo `AuthException.message`** (prej generično sporočilo je
  skrilo vzrok); (3) **vstopna točka za prijavo iz nastavitev** — profil tile »Gost« → `push('/login')` (gating
  sicer login skril po onboardingu; gost se zdaj prijavi/poveže kadarkoli — realna funkcija + omogoči test).
  i18n `sign_in_prompt` + posplošen `code_hint`/`err_code` (brez »6-mestno«). **👤 Supabase setup (z uporabnikom):**
  custom SMTP = Resend (sender `onboarding@resend.dev`; brez verificirane domene pošlje le na lastni Resend
  e-naslov — domena `tendask.com` = M9), template »Change email address« z `{{ .Token }}`. **ON-DEVICE ✅:**
  email OTP prijava uspela, e-pošta povezana z obstoječim anon `user.id` (podatki ohranjeni, vidno v Supabase
  users). Commit: `fix: e-pošta OTP popravki (dolžina kode, napake, vstop)`.
- 2026-06-05 — **Auth-aware profil v nastavitvah.** Profil tile v Nastavitvah je bil statičen (»Gost« tudi po
  prijavi). `AuthService.email` getter + `authStateChangesProvider` (StreamProvider nad Supabase
  `onAuthStateChange`); Settings watcha stream → rebuild ob prijavi/odjavi: prijavljen = prikaz e-pošte +
  `signed_in`, gost = poziv → `/login`. Odjava ostane 7.5b. i18n `signed_in`. flutter analyze čist, 123/123.
  Commit: `feat: auth-aware profil v nastavitvah`. **Naslednji: 7.3c (lokacija 16).**
- 2026-06-05 — **7.3a — Login zaslon (13).** `features/auth/presentation/login_screen.dart`: brand mark
  (Icons.eco v soft containerju), naslov + value-prop, gumbi Google (OutlinedButton) + e-pošta
  (FilledButton.icon accent), »Preizkusi brez računa« (underline TextButton), `guest_warning` (cs.error) +
  `legal` (muted). **Apple gumb le na iOS** (`Platform.isIOS` → M10, na Androidu skrit; `_DarkButton`).
  Router: dodana `/login` route; onboarding `_finish()` zdaj → `/login` (prej `/home`). Flow: 15→13→…→home.
  **Gumbi začasno:** Google + e-pošta → SnackBar `auth.coming_soon` (ožičita 7.3b OTP / 7.4 Google); »brez
  računa« → `/home` (anon seja že iz M6; location 16 se vrine 7.3c). i18n `auth.*` sl/en/de. flutter analyze
  čist, **123/123 testov**. Commit: `feat: prijava zaslon (13)`. **Naslednji: 7.3b (e-pošta OTP).**
- 2026-06-05 — **7.2 — Onboarding intro (15/15b/15c/15d) + jezikovni pregled i18n.** Drift **v7**: local-only
  `local_flag` (key/value) tabela za »seen-once« flage (`LocalFlags` v `tables/sync_tables.dart`, migracija
  `if (from < 7) createTable`). `core/local_prefs/local_prefs.dart`: `LocalPrefsRepository`
  (`onboardingSeen()`/`setOnboardingSeen()` prek key-value) + `localPrefsProvider` — razširljivo (notif
  priming 21, location). `features/onboarding/presentation/onboarding_screen.dart`: 4-slide `PageView`
  (Dobrodošel/Beleži/Opomniki+vreme/Okolica+badge »kmalu V2«), animiran `_Dots`, »Preskoči ›« (strani 0–2) +
  »Naprej«/»Začni 🌿«; brand `colorScheme`, Material ikone (brez `flutter_svg`); `PageController` disposed.
  i18n `onboarding.*` v sl/en/de. **Routing/gating:** `appRouter`→`createAppRouter({initialLocation})` +
  `/onboarding` route; `TendaskApp`→StatefulWidget (router enkraten); `main.dart` prebere `onboardingSeen`
  pred runApp → `initialLocation = seen ? '/home' : '/onboarding'`; po »Začni«/»Preskoči« → `setOnboardingSeen()`
  + `go('/home')` (login 13 se vrine v 7.3). **Gotcha:** slang ima ločen CLI (`dart run slang`), build_runner
  ga ne ujame. **Jezikovni pregled vseh i18n** (na zahtevo): SL onboarding kalki→knjižno (»vsa opravila«,
  »z nekaj dotiki«, »samodejno«, »Pozneje«, »podnebje«), poenoteni `»…«` narekovaji; **DE pomenska napaka**
  `log_body` »mit wenigen Tipps« (=nasveti!) → »Fingertipps«, `Zeitlinie`→`Zeitleiste`, `Prüfe es`→`Überprüfen`;
  EN `log_body` »weather saves itself«→»Weather is saved automatically«. **`entry.type_title` usklajen na
  nevtralno** (prej SL prihodnjik »Kaj boš naredil?« vs EN/DE preteklik): SL »Katero opravilo?« / EN »Which
  task?« / DE »Welche Aufgabe?«. flutter analyze čist, **123/123 testov**. On-device (prej): app teče brez
  crasha, vreme dela, migracija v6 OK. Commit: `feat: onboarding intro (15)`. **Naslednji: 7.3a (prijava 13).**
- 2026-06-05 — **7.1c — Vreme uporabi shranjeno lokacijo → 7.1 (data plast) ZAKLJUČEN.** En reaktiven vir
  lokacije namesto podvojenega »stored-or-default«: `gardenLocationProvider` (StreamProvider v
  `location_repository.dart`) bere `device_location` prek `watchGardenCoordinates()`, fallback na
  `kDefaultLatitude/Longitude` dokler onboarding ne nastavi lokacije; reaktiven (drift `.watch`, vzorec kot
  `catalog_provider`) → vreme se osveži ko uporabnik izbere lokacijo. `currentWeather` → async,
  `await ref.watch(gardenLocationProvider.future)`. `tasksRepository.weatherCapture` (posnetek ob izvedbi) →
  bere isti provider; **odstranjen TODO(gorazd, 2026-12-01)** o H3 centroidu (zdaj implementirano). `kDefault*`
  ostane le še fallback znotraj providerja; `config` import odstranjen iz `tasks_providers`. **Gotcha:** `part`
  direktiva mora pred deklaracije — `typedef GardenCoords` premaknjen za `part`. flutter analyze čist,
  **123/123 testov** (tasks/weather testi prek databaseProvider override → device_location prazna → fallback).
  Commit: `feat: vreme uporabi shranjeno lokacijo`. **Naslednji: 7.2 (onboarding intro 15/15b-d).**
- 2026-06-05 — **7.1b — H3 + lokalna shramba koordinat.** Drift shema **v6**: nova local-only tabela
  `device_location` (`tables/sync_tables.dart`, single-row `id=0`→upsert; lat/lon/updatedAt) registrirana
  v `app_database.dart` + migracija `if (from < 6) createTable(deviceLocations)`. **Push/pull seznama sta
  eksplicitna** (ročno naštete tabele) → nova tabela samodejno NI sinhronizirana = koordinate ne zapustijo
  naprave. `core/location/h3_cells.dart`: čista `deriveH3Cells(h3, lat, lon)` → `H3Cells` record (r7/r6/r5
  lowercase hex prek `geoToCell` + `cellToParent`; res-7 finest, res-6/5 starša za V2 roll-up) — testabilna
  ločeno od FFI/shrambe. `core/location/location_repository.dart`: `saveGardenLocation()` v transakciji —
  koordinate v `device_location` (insertOnConflictUpdate, local-only), izpeljane H3 celice upsert v `profile`
  (pending, brez clobbera `lang` — vzorec `ProfileRepository.setLang`); `gardenCoordinates()` za vreme (7.1c).
  `h3Provider` keepAlive (FFI `H3Factory().load()` enkrat) + `locationRepositoryProvider`. **Supabase:**
  `profile.h3_r7/r6/r5` že v migraciji `0001` → zrcalo, brez nove migracije; `device_location` ostane lokalno.
  flutter analyze čist, **123/123 testov** (nova tabela + schemaVersion bump nič ne zlomi; `forTesting`
  uporablja `createAll`). H3 native FFI = ročna preverba pri 7.3c; unit izpeljave = 7.6. Commit:
  `feat: H3 celice + lokalna shramba koordinat`. **Naslednji: 7.1c (vreme uporabi shranjeno lokacijo).**
- 2026-06-05 — **7.1a — Viri lokacije (M7 začet).** Najprej **podroben razrez M7** (zgoraj) +
  razrešene 4 odločitve z uporabnikom (GPS=`geolocator`+Open-Meteo geocoding; OAuth=e-pošta OTP +
  Google native, Apple→M10; koordinate=lokalno-only ne-sync + H3→oblak; obseg=polno, lokacija nahrani
  vreme). Dodana `geolocator ^14.0.2` + `h3_flutter ^0.7.1` (h3 že v §1; geolocator dopisan v §1).
  Android manifest: `ACCESS_COARSE/FINE_LOCATION` (koordinate ne zapustijo naprave — le H3 sync).
  `core/location/location_service.dart`: `LocationService.currentCoordinates()` prek geolocator,
  sealed `LocationResult` (`LocationCoords`/`LocationDenied{permanent}`/`LocationServiceDisabled`/
  `LocationUnavailable`) modelira permission stanja za zaslon 16; **medium accuracy** (H3 r7 ≈ 1 km,
  fini fix bi tratil baterijo). `core/location/geocoding_client.dart`: `GeocodingClient.search()`
  (Open-Meteo Geocoding, brez ključa, lasten dio z `kWeather*Timeout`), `GeoPlace` model; throwa
  `DioException` (transport plast kot weather client — caller degradira graceful). flutter analyze čist.
  Geolocator runtime poziv = ročna preverba pri 7.3c; geocoding parser test = 7.6. Commit:
  `feat: lokacijski viri (geolocator + Open-Meteo geocoding)`. **Naslednji: 7.1b (H3 + lokalna shramba).**
- 2026-06-05 — **6.5 — Testi M6 → M6 ZAKLJUČEN.** Unit del (LWW logika + FK vrstni red) je bil **že
  pokrit** v 6.2 (push: FK red, mark-synced, updated_at guard, fail-fast), 6.3a (pull: LWW obe smeri,
  tombstone, inkluzivni kurzor, child-RLS filter), 6.3b (katalog), 6.4 (orchestrator: vrstni red faz,
  gating, re-entrancy, izolacija). Prava vrzel = **integracijski round-trip**: push in pull sta bila
  testirana ločeno z ročno hranjenimi podatki na vsaki strani. `test/core/sync/sync_roundtrip_test.dart`:
  `_FakeCloud` služi **oba šiva hkrati** (`upsert`=push tarča, `fetch`=pull vir) nad eno `Map` shrambo →
  push-nato-pull teče skozi **realne `*ToRemote`+`*FromRemote` mapperje** (ujame asimetrijo, ki je per-service
  testi ne morejo). 2 in-memory drift bazi = 2 napravi prek enega oblaka. 4 testi: (1) area fidelity
  (ime/enum/protected, vir→synced); (2) task enum status + jsonb weather round-trip + sočasna area; (3) **LWW
  med napravama** (B uredi novejše → A-jev starejši synced povozi ob pull); (4) tombstone (B soft-delete →
  propagira kot lokalni soft-delete na A). **Odločitev o "integracijski proti testnemu projektu":** skladno
  `CLAUDE.md` (mock zunanje dep-e, brez e2e; CI nima Supabase ključev) avtomatizirani suite ostane
  fake-cloud; **živa integracija proti pravemu projektu = on-device preverba (6.4, opravljena)**. flutter
  analyze čist, **123/123 testov**. Commit: `test: sync`. **M6 ZAKLJUČEN → naslednji M7 (Auth + H3 na napravi).**
- 2026-06-05 — **6.4 — Sprožilci + LWW.** LWW je bil že uveljavljen v 6.3 (`DoUpdate(where:)` v pull); 6.4
  doda samo **žico sprožilcev** (`tech-stack §2`: zagon · povezava · periodično). `core/sync/sync_service.dart`:
  `SyncService.sync({includeCatalog})` = en cikel **seja(+claim) → push → pull → katalog**, z **re-entrancy
  guardom** (`_running` → prekrivajoči se sprožilci se ne izvajajo hkrati; tekoči cikel že pokrije delo) in
  **izolacijo faz** (`_phase()` ujame napako → `debugPrint`, ne blokira ostalih faz; offline je normalno stanje,
  vrstice ostanejo `pending` za naslednji sprožilec). Push/pull gated na `hasSession()`; **katalog teče tudi brez
  seje** (public-read), a **le ob `includeCatalog`** (zagon/reconnect) — periodični tick kataloga NE pulla (redki
  pull, baterija/podatki, §5). Odvisnosti prek **funkcijskih šivov** (`bool Function() hasSession`, `Future<void>
  Function() ensureSession/push/pull/catalog`; null šiv = offline build → faza skipped) kot obstoječi
  `RemoteUpsert`/`RemoteFetch` → orkestracija testabilna brez Supabase. `core/sync/sync_coordinator.dart`:
  keepAlive `SyncCoordinator` notifier — **reconnect** prek `ref.listen(onlineStatusProvider)` (fire le ob prehodu
  v online: `next.asData?.value==true && prev != true`), **periodično** `Timer.periodic(kSyncInterval)` (brez
  kataloga), `ref.onDispose` počisti timer; **zagon** prek `start()` (cikel z katalogom). `config.dart`:
  `kSyncInterval = 15 min`. `main.dart`: `_bootstrapSession` (prej le ensure+claim) **zamenjal**
  `coordinator.start()` — startup cikel zdaj poganja tudi push/pull/katalog; fire-and-forget, ne blokira first
  paint. +6 testov (`sync_service_test.dart`: vrstni red faz / gating brez seje (katalog vseeno) / `includeCatalog`
  gate / izolacija napake faze / re-entrancy skip+sprostitev / null-šivi). Mimogrede odstranjen neuporabljen
  `drift/drift.dart` import v `catalog_sync_service_test.dart`. flutter analyze čist, **119/119 testov**.
  Commit: `feat: sync sprožilci + LWW`.
  **On-device preverba ✅ (SM A536B / Android 16, debug build, headless — drift baza prek `run-as`, oblak
  prek pooler):** (1) startup→nova anon seja (`auth.users` 2→3); (2) **PUSH** lokalna area+task → oblak,
  `synced`; (3) **PULL** oblačno vstavljena area → lokalno `synced`; (4) inkrementalni kurzor (`sync_cursor`,
  ednina!) napreduje na `updated_at` zadnje pull vrstice; (5) katalog 26/34/57=oblak; (6) brez crasha čez več
  sync ciklov. **Naslednji: 6.5 (testi M6: integracijski proti testnemu projektu).**
- 2026-06-05 — **6.3b — Katalog pull + reaktivnost → 6.3 ZAKLJUČEN.** **Odločitev (z uporabnikom, popravek
  6.2.0 dnevnika):** SeedService **OSTANE** (bundlan offline fallback — prvi zagon na vrtu brez signala deluje;
  skladno `tech-stack.md §2` »bundled seed + redki pull«). Prejšnji »pull-only, umakni seed« plan **zavržen**
  (kršil offline-first #1). `core/sync/catalog_sync_service.dart`: `CatalogSyncService.pull()` — full-pull
  (katalog nima `updated_at`), upsert po **slug PK** → zlije s seedom (ne podvoji, ker so slug-i iz enega vira
  `catalog_seed.dart`); task_type/plant `DoUpdate`, category_task_type `insertOrIgnore` (le PK stolpci, zrcali
  oblačni `do nothing`); plant_synonym izpuščen (prazen v seedu+oblaku, identity-id bi se razhajal). 3 katalog
  reverse mapperji (jsonb labels→text). `RemoteSelectAll` typedef meja. `core/database/catalog_provider.dart`:
  FutureProvider → **StreamProvider** (drift `.watch()`) → pull reaktivno osveži vse zaslone; konzumenti berejo
  `AsyncValue` prek `.asData?.value` → transparentno (7 test override-ov Future→`Stream.value`). **Invarianta #4
  (generator-parnost) zdaj test, ne disciplina:** `tool/gen_catalog_sql.dart` refaktoriran v čisto
  `buildCatalogSql()`; `test/tool/catalog_sql_parity_test.dart` potrdi committan `catalog.sql` == regeneriran iz
  seeda (EOL-normaliziran) → oblak ⊇ vsak referenciran id (preprečuje push FK-fail). **Invarianta #2
  (id-kanoničnost):** test, da `Uuid().v4()` + repo `create()` dasta Postgres-kanonični lowercase v4 (push/pull
  bereta id verbatim → brez duplikata/orphana local↔cloud). **Pull trigger (startup/connectivity/periodic) =
  6.4.** flutter analyze čist, **113/113 testov**. Commit: `feat: katalog pull + reaktiven provider`.
  **Naslednji: 6.4 (sprožilci: push→pull+katalog ob zagonu/povezavi/periodično; LWW že v 6.3).**
- 2026-06-05 — **6.3a — User-table pull.** **Pred kodo zasnova z uporabnikom (id/UUID-pravilnost):** ločitev
  katalog-slug (deterministični, en vir) vs user-UUID (naprava) vs `user_id` (`local`→`auth.uid()` claim).
  7 invariant zapisanih; 6.3a uveljavi #5–#7. `core/database/tables/sync_tables.dart`: `SyncCursors` (globalni
  `last_pulled_at` high-watermark) + migracija **v4→v5** (additive `createTable`). `core/sync/remote_mappers.dart`:
  10 reverse mapperjev (remote Map → drift Companion, `synced`); inverzne pretvorbe ISO→DateTime, jsonb decoded→
  JSON-text (tolerantno tudi če je že String), enum **tolerantno** (neznano→default), num→double/int.
  `core/sync/sync_pull_service.dart`: `SyncPullService.pull()` + provider. **Invariante:** (7) **inkluzivni
  kurzor** `updated_at >= since` + idempotenten upsert po id (drift hrani updated_at v **sekundah** → strogi `>`
  bi izgubil robno vrstico); (6) **LWW po updated_at** prek `DoUpdate(where: old.updatedAt <= ts)` — novejši
  lokalni pending obstane, novejši oblak povozi. **Ujet+odpravljen bug med pisanjem testov:** prvotna `where`
  veja `| syncStatus==synced` bi pustila **starejši** oblak povoziti synced vrstico → LWW je **čisto časoven**,
  sync_status ne sodi vanj (novejši pending je že zaščiten z `old.updatedAt <= ts` = false). Tombstone
  (`deleted=true`) **zrcaljen kot lokalni soft-delete** (UI filtrira, brez FK-cascade reda lokalno); FK red
  parent→child; **child tabele brez `user_id` filtra** (RLS prek parent task — potrjeno v 0002); brez seje =
  no-op; kurzor napreduje na max(updated_at) le ob uspehu (fail → re-pull idempotenten). **Push guard #5**
  (`sync_push_service.dart`): owned tabele izključijo `user_id='local'` iz pusha (ni veljaven uuid → Postgres
  crash; claim jih prej prevzame; child prek parent). **Supabase meja injicirana** (`RemoteFetch` typedef) →
  testabilno brez Supabase. +13 testov (6 reverse mapper, 7 pull: insert+synced+kurzor / no-session / LWW obe
  smeri / tombstone / child-brez-filtra / inkrementalni kurzor). flutter analyze čist, **103/103 testov**.
  Commit: `feat: sync pull (user tabele)`. **Naslednji: 6.3b (katalog pull + reaktiven catalog_provider).**
- 2026-06-05 — **6.2 — Push (pending → upsert v Supabase).** `core/sync/remote_mappers.dart`: čiste funkcije
  drift vrstica → Postgres payload (10 tabel). Popravijo, kar drift `toJson()` za oblak naredi narobe:
  camelCase→snake_case, DateTime→ISO-8601 UTC (`.toUtc()`), jsonb stolpci (lokalno JSON string) → dekodiran
  objekt; `sync_status` se **nikoli** ne pošlje (lokalni stolpec). `core/sync/sync_push_service.dart`:
  `SyncPushService.push()` vzame vse `pending` → `upsert` → `synced`, v **FK-varnem vrstnem redu** (profile→
  area→supply→recipe→user_plant→task→note→task_subject→task_reminder→task_supply). **Fail-fast:** napaka pri
  tabeli ustavi ostale (FK-odvisne), pusti `pending` za naslednji sprožilec. **`updated_at` zaščita pri
  mark-synced:** vrstica, urejena med branjem in označevanjem (med mrežnim upsertom), ostane `pending` — sicer
  bi se novejša sprememba tiho izgubila iz synca. **Supabase meja injicirana** (`RemoteUpsert` typedef) →
  orkestracija testabilna brez Supabase; provider zapre pravi klient (`null` = offline build). **Caller pogodba
  (prepuščeno 6.4):** push zahteva sejo + že-claimane lokalne vrstice (sicer RLS zavrne) — servis sam le splakne
  `pending`. +12 testov (7 mapper: enum.name/jsonb decode/UTC/content→text/brez sync_status; 5 servis: FK red/
  samo pending/mark-synced/updated_at zaščita/fail-fast). flutter analyze čist, **90/90 testov**. Commit:
  `feat: sync push`. **Naslednji: 6.3 (pull: updated_at > last_pulled_at → upsert v drift; deleted → odstrani).**
- 2026-06-05 — **6.2.0 — Katalog v oblak (vir resnice).** **Odločitev (z uporabnikom, popravek smeri):** oblak
  Supabase = **vir resnice za katalog**, naprave ga **pull-ajo** (skladno §2 + dolgoročna vizija Supabase-kot-vir);
  FK na katalog **OSTANE** (ne odstranjujemo — kratkoviden tehnični dolg). Vrzel priznana: M5 je postavil FK, a
  ne koraka »seed katalog v oblak« → push bi padel na FK. `tool/gen_catalog_sql.dart` (Dart, en vir = `lib/data/
  seed/catalog_seed.dart`) generira `supabase/seed/catalog.sql` — **idempotenten** `on conflict do update`
  (task_type/plant) / `do nothing` (category_task_type); pravilno escapani jsonb labels, emoji, null cadence.
  `supabase/seed/apply_catalog.py` (pooler, postgres role obide RLS) aplicira + verificira. **V oblaku: 26
  task_type, 34 plant, 57 category_task_type** (idempotentnost potrjena — 2× zagon = isti count). Pravilo zapisano
  v `CLAUDE.md` (katalog vir resnice + **id-ji add-only, nikoli preimenuj** — sicer osiroti user_plant.plant_id/
  task.task_type_id; offline-bundle = pred-release TODO). **6.3 bo:** pull katalog+user, catalog_provider →
  reaktiven (zdaj FutureProvider, ne osveži po pull), umik lokalnega `SeedService` (pull-only), nato clean test na
  napravi. flutter analyze čist, **78/78 testov**. Commit: `feat:`. **Naslednji: 6.2 (push user → upsert).**
- 2026-06-04 — **6.1b — Anonimna seja + currentUserId (sync auth infra) → 6.1 ZAKLJUČEN.**
  `core/auth/auth_service.dart`: `AuthService` (`userId` = `auth.currentUser?.id ?? kLocalUserId` — bere živ
  klient; `hasSession`; `ensureAnonymousSession()` graceful) + `authServiceProvider` (null client = Supabase
  nekonfiguriran → offline build). `core/auth/local_row_claim.dart`: `claimLocalRows(db, uid)` posvoji vse
  `user_id='local'` vrstice v 7 owned tabelah (transakcija, raw-SQL zanka prek `TableInfo`, stream-aware),
  označi `pending`; no-op dokler ni seje (child tabele lastništvo prek task). `main.dart`: neblokirajoč
  `_bootstrapSession` (`unawaited`) — prijava + claim v ozadju (NE blokira first paint); `getLang` bere
  `authService.userId`. `ProfileRepository` sprejme `userId` (odstranjen hardcode `_localUserId`). Zamenjan
  hardcoded `'local'` → `ref.read(authServiceProvider).userId` v 6 presentation (entry/subject/area/note/
  plant/supply) + settings. +6 testov (claim: no-op/claims+pending/multi-table/selektivnost; auth null-fallback).
  **Ročna preverba na napravi (PASS, DB dokaz):** 2 anonimna userja v `auth.users` projekta jlmkk… (poizvedba
  `tmp/check_users.py` prek pooler). **Naučeno med preverbo (3 zanke):** (1) anonimne prijave morajo biti
  **omočene** v Supabase (Auth → Sign In/Providers → Anonymous = privzeto OFF); (2) `connectivity_plus` rabi
  **`ACCESS_NETWORK_STATE`** permission (dodan v main manifest); (3) `checkConnectivity()` na napravi traja
  **~1.6 s** (NE visi — prvotni sklep o visenju je bil prehiter logcat dump) → **online-gate odstranjen iz
  bootstrap**: prijava se ne veže na connectivity, `signInAnonymously` sam graceful pade offline (čistejši
  offline-first); `onlineStatusProvider` ostane za 6.4 (flush trigger); (4) Supabase Studio → Users ima
  **email-search filter**, ki skrije anonimne (brez e-pošte) — od tod lažni »ni userja«. flutter analyze čist,
  **78/78 testov**. Commit: `feat:`. **Naslednji: 6.2 (push: pending → upsert v Supabase, FK vrstni red).**
- 2026-06-04 — **6.1a — Povezljivost + sync_status konstante (M6 začet).** Dodan `connectivity_plus`
  `^6.1.0` (→ 6.1.5, major pinnan; predpisan v `tech-stack.md §2`). `core/sync/connectivity.dart`:
  `onlineStatusProvider` (`Stream<bool>`, `keepAlive`, ročni dedup stanja prek `await for` — brez
  nepotrebnih emisij); konzument pride v 6.4 (sprožilci). `core/sync/sync_status.dart`: konstanti
  `kSyncPending`/`kSyncSynced` — zamenjal magic-string `'pending'` čez 6 repozitorijev (tasks/areas/
  user_plants/notes/supplies/profile) + drift default v `user_tables.dart`. **Ugotovitev:** `sync_status`
  označevanje ob zapisih je bilo **že vgrajeno** (vsak update/softDelete postavi `pending`, insert pade na
  drift default) — 6.1 obseg se je tako skrčil na povezljivost + utrditev konstant. **Gotcha:** `kSyncPending`
  je bilo treba importati tudi v glavni `app_database.dart`, sicer `part`-generirani `*.g.dart` pade v CFE
  (`flutter test`), a NE v `flutter analyze` (isti vzorec kot enum-import gotcha v CLAUDE.md). Namerno
  nedotaknjeno: `'pending'` literal v raw-SQL migraciji v3 (zgodovinske migracije morajo ostati
  deterministične, neodvisne od trenutne konstante). flutter analyze čist, **72/72 testov**. Commit: `feat:`.
  **Odločitev na začetku M6 (z uporabnikom):** auth za sync = **`signInAnonymously` že v M6** (pravi
  `auth.uid()` za RLS; M7 doda le UI/linkanje) → 6.1b. **Naslednji: 6.1b (anonimna seja + currentUserId).**
- 2026-06-04 — **5.4 — uveljavitev + preverba → M5 ZAKLJUČEN.** Migraciji uveljavljeni v živo prek
  **Supabase CLI** (isti postopek kot hexatory): `supabase init` → `link --project-ref jlmkkeijmmnwkizutvkg`
  (Frankfurt; DB geslo prek `SUPABASE_DB_PASSWORD` env, ne v repo) → `db push` → **0001 + 0002 aplicirani
  brez napak** (to hkrati validira shemo+RLS na pravem Postgres 15). `config.toml` + `supabase/.gitignore`
  commitana (`0b848d3`); `.temp` (ref/pooler) gitignored. **RLS preverba** (`tmp/rls_verify.py`, psycopg prek
  pooler, vse v **eni transakciji → rollback**, nič ne ostane): testni auth user A vstavi območje →
  **A vidi 1, B (drug uid) vidi 0** = RLS prepreči tuje vrstice ✅; B bere katalog brez permission error.
  **DoD 5.4 izpolnjen.** Skrivnosti: DB geslo ostaja v lokalnem `.env` (gitignored), publishable+anon v
  `dart_defines.json` (gitignored). **M5 ZAKLJUČEN → naslednji M6 (sync servis: push/pull, LWW).**
- 2026-06-04 — **DB pregled 0001/0002 (2 neodvisna agenta) + utrjevanje.** Adversarni pregled sheme +
  RLS. **Agent RLS/varnost/indeksi: čisto** (RLS na vseh 14 tabelah, EXISTS izolacija pravilna, GDPR cascade
  poln, indeksi popolni — vsak runtime FK pokrit). **Agent shema-fidelity: 1 najdba** — `plant_synonym`
  UNIQUE, ki ga drift NIMA = divergenca → **odstranjen** (zrcali točno). Dodatno utrjeno: eksplicitni
  `GRANT`-i v 0002 (deterministični PostgREST dostop — RLS gata vrstice, grant gata tabelo), `task_supply.amount
  ≥ 0` CHECK, zabeležene namerne ne-dodaje (brez natural-key UNIQUE na M:N; brez id server defaulta = sync
  korektnost). Commit: `refactor:` (`5203eec`). Migracije pripravljene za uveljavitev (5.4).
- 2026-06-04 — **5.3 — RLS politike.** `supabase/migrations/0002_rls.sql` (uveljavi se takoj za 0001).
  **(1) Auth binding:** `user_id → auth.users(id) ON DELETE CASCADE` na 7 user tabelah (profile/area/
  user_plant/task/note/supply/recipe) = GDPR cascade root (child sledijo prek `task_id`). **(2) RLS vklop**
  na vseh 14 tabelah (brez politike = deny). **(3) Politike** (14): katalog (4) = javno-bralni `select to
  anon, authenticated using(true)`, brez pisanja (seed prek service role obide RLS); user tabele (7) =
  `for all to authenticated using/​with check (user_id = (select auth.uid()))`; child brez user_id (3:
  task_subject/reminder/supply) = lastništvo prek starševskega `task` z `EXISTS`. **Perf:** `auth.uid()`
  ovit v `(select auth.uid())` (initplan, ocenjen 1× na poizvedbo). **Anonimni** prijavljeni = vloga
  `authenticated` + veljaven `auth.uid()` → iste politike (CLAUDE.md); `anon` vloga le za katalog branje.
  Komentarji EN. flutter analyze/test nespremenjena (**72/72**). Commit: `feat:` (`8df4131`).
  **Naslednji: 5.4 — uveljavi 0001+0002 v Supabase SQL editor + ročna preverba (RLS prepreči tuje vrstice).**
- 2026-06-04 — **5.2 — Supabase shema (migracije).** `supabase/migrations/0001_schema.sql` +
  `supabase/README.md` — zrcalo drift tabel (`lib/core/database/tables/*`), vir tipov §7.14.
  **Katalog** (`task_type`/`plant`/`plant_synonym`/`category_task_type`): `id text` (slug), `labels jsonb`,
  brez sync stolpcev. **Uporabniške** (profile/area/user_plant/task/task_subject/task_reminder/note/supply/
  recipe/task_supply): `id`/`user_id` `uuid`, `weather`/`recurrence`/`items` `jsonb`, `date`/`updated_at`
  `timestamptz`, `deleted` bool, **`sync_status` IZPUŠČEN** (samo lokalni drift). **CHECK**: area.type∈enum,
  task.status∈enum, task_subject ≥1 FK, user_plant (plant_id∨is_custom), supply.quantity≥0. **FK cascade**:
  child (task_subject/reminder/supply) → `task_id ON DELETE CASCADE`; inter-user FK (area_id/user_plant_id/
  supply_id) cascade — pripravljeno za GDPR cascade prek `auth.users` (5.3). **Indeksi**: `(user_id,
  updated_at)` (pull) + `updated_at` na child + **vsak FK** (cascade/RLS EXISTS). **DB-review popravki**:
  dodani manjkajoči FK indeksi, poimenovani CHECK, `UNIQUE(plant_synonym)`, `updated_at default now()`;
  **namerno BREZ updated_at triggerja** (naprava = lastnik LWW ključa, trigger bi pokvaril pull vrstni red);
  `double precision` (ne numeric) = zrcali drift REAL. `suggestion_log`/`activity_agg` = V2/M11 (izpuščeno).
  Komentarji v SQL = angleški (CLAUDE.md: koda=EN). **RLS/auth FK = 5.3 → shema še NE izpostavljena.**
  Ni lokalnega Postgresa za izvedbo; sintakso validira Supabase SQL editor ob uveljavitvi (skupaj z 5.3).
  flutter analyze/test nespremenjena (**72/72**). Commit: `feat:` (`bb72aec`). **Naslednji: 5.3 (RLS).**
- 2026-06-04 — **5.1 — Supabase client init (M5 začet).** Dodan `supabase_flutter ^2.14.0` (tech-stack §1).
  `core/config.dart`: `kSupabaseUrl` + `kSupabasePublishableKey` (`String.fromEnvironment`, prazna → app
  dela offline). `main.dart`: `Supabase.initialize(url, publishableKey)` v bootstrapu **pogojno**
  (`if kSupabaseUrl.isNotEmpty`) → offline-first (zažene se tudi brez konfiguracije). Skrivnosti SAMO prek
  `--dart-define-from-file=dart_defines.json` (**gitignored**; tracked le `dart_defines.example.json`);
  `deploy.bat`/`dev.bat` datoteko poberejo, če obstaja. **Uporabljen `publishableKey`** (ne `anonKey` —
  opuščen v supabase_flutter 2.14; legacy JWT bi sprožil deprecation). **+ varnost:** najden netracken `.env`
  s Supabase geslom (ni bil v `.gitignore`) → dodan `.env` v `.gitignore` (datoteka neizbrisana). Potrjeno na
  napravi: app se normalno zažene (= `initialize` z ključi uspe). flutter analyze čist, **72/72 testov**.
  Commit: `feat:` (`0741a69`). **Naslednji: 5.2 (SQL migracije — zrcalo drift tabel).**
- 2026-06-04 — **Pregled prevodov + čiščenje.** Po vseh popravkih pregled i18n (`slang analyze --full`):
  struktura sl/en/de **popolna** (brez manjkajočih/odvečnih), brez `{}` interpolacije. Odstranjenih **14
  mrtvih ključev** (ostanki refaktoringov: `common.today_lower`, `task_detail.label_area/subjects/plant`,
  `subject_picker.*` razen title/choose, `entry.subject_area_hint/subject_empty`). Plural resolverji
  ekstrahirani v `i18n/plural_resolvers.dart` (klic iz main + `test/flutter_test_config.dart` → čist testni
  izpis); slang `lazy: false` (eager 3 locale, sicer `setPluralResolverSync(de)` pade na deferred loadingu v
  testih). analyze čist, **72/72 testov**. Commiti: `chore:` (mrtvi ključi), `refactor:` (resolver+bootstrap).
- 2026-06-04 — **Fix plural ključev + FR-4 umaknjen.** (1) **Plural:** `month_count`/`overdue_days` sta
  uporabljala `{n}` (ICU), ki ga slang ne interpolira → na zaslonu dobesedni »{n}«. Zamenjano z `$n`; sl dobi
  pravilne oblike (one/two/few/other), v `main.dart` registriran cardinal resolver za sl+de (slang nima
  vgrajenih). (2) **FR-4 umaknjen** — prototip dnevnega traku na časovnici zavrnjen kot vizualni šum (koda
  restored, backlog označen ✗). flutter analyze čist, **72/72 testov**. Commiti: `fix:` (plural), `docs:` ×2.
- 2026-06-04 — **FR-2 potrjen kot že implementiran (brez sprememb kode).** Pregled pokazal, da so vsi trije
  »ustvari sproti« vzorci že v stepperju: subject_step »+ Dodaj območje« (`area-new`→`area_form` vrne `areaId`
  prek `pop`→auto-select), »+ Dodaj rastlino« (`plant-new`), supplies_step »pick_new« (`showSupplyEditSheet`).
  Vsi providerji StreamProvider (drift `watchAll()`) → nov element se reaktivno prikaže. Oznaka »delno«
  (memory/roadmap) je bila zastarela; FR-2 označen kot implementiran. Commit `docs:`.
- 2026-06-04 — **Weather receiveTimeout 10s→20s + diagnoza Open-Meteo izpada** (po M4, pred M5).
  Vreme na Domov se v debug ni naložilo. Diagnoza prek `adb logcat` + `adb shell ping` + brskalnik na napravi:
  napake so **nihale** (`receive timeout` → `connection timeout` → brskalnik vrne **502 Bad Gateway**) — torej
  **zunanji izpad Open-Meteo** (5xx, server-side), NE aplikacija in NE uporabnikova mreža (ping 8.8.8.8 in
  api.open-meteo.com oba 0% loss; DNS OK). App pravilno gracefully degradira na »vreme ni na voljo«, brez crasha.
  Edini ukrep na naši strani: `receiveTimeout` 10s→20s + oba timeouta v `config.dart` (`kWeatherConnectTimeout`,
  `kWeatherReceiveTimeout`) — robustnost proti počasnemu prejemu obsežnega odgovora (hourly ~5 dni) v debug
  (non-AOT) in na počasnih mrežah; ne reši izpada Open-Meteo. flutter analyze čist, **72/72 testov**. Commit
  `fix:`. **Naslednji: M5 (Supabase zaledje).**
- 2026-06-04 — **FR-1 (grid tipov) + fix weather overflow + dev.bat** (po M4, pred M5).
  **(1) FR-1:** grid tipov na koraku 1 stepperja urejen po **pogostosti per user** (`watchTaskTypeUsage()` =
  COUNT po `task_type_id`, ne-izbrisani; ob izenačenju seed vrstni red) → najpogostejši na vrhu. Privzeto
  prikaže prvih `kTaskTypeGridCollapsed` (**9**, konfig. v `config.dart`) + gumb »Pokaži vse (N)«/»Pokaži manj«;
  izbrani tip vedno viden. `TypeStepBody` → `ConsumerStatefulWidget`. i18n `type_show_all(n)`/`type_show_less`
  (sl/en/de). +1 unit test. Del backloga »ekstrahiraj skupni `TaskTypeGrid` (02/07)« odpadel (en klicalec).
  Po UX odločitvi: brez avto-razširi ob scrollu (dvoumno, framework cleverness) — samo eksplicitni gumb.
  **(2) Fix weather overflow:** `CurrentWeatherCard` (Domov) je desno prelival (~8px) — srednji stolpec
  (temp+opis) ni bil omejen, `Spacer` padel na 0; zdaj stolpec v `Expanded` + opis `maxLines:1` z elipso.
  **(3) dev.bat:** dvoklik-prijazen razvojni zagon (debug + hot reload r/R; kliče `deploy.bat hot`).
  flutter analyze čist, **72/72 testov**. Commiti: `feat:` (FR-1), `fix:` (overflow), `chore:` (dev.bat).
  **Naslednji: M5 (Supabase zaledje).**
- 2026-06-04 — **FR-6 »Ponovi zadnje« + fix privzetega statusa + deploy.bat hot reload** (po M4, pred M5).
  **(1) FR-6:** kartica »↻ Ponovi zadnje« na koraku 1 (Tip) stepperja — predizpolni tip + subjekte +
  sredstva + opombo iz zadnjega opravila in skoči na Pregled; datum/ura ostane »zdaj« (status izpeljan),
  opomniki se NE kopirajo (vezani na konkreten načrtovan datum). Vir = najnovejše ne-izbrisano opravilo po
  `updated_at` (`watchLast()` + `lastTaskProvider`; `created_at` stolpca nimamo). Kartica skrita v edit-mode
  in ko ni opravil. +2 unit testa (`watchLast`). **(2) Fix:** privzeti status se zdaj izpelje iz **polnega
  datuma+ure** proti zdaj (`d.isAfter(now)`), ne le koledarskega dne — privzeti datum (danes ob naslednji
  polni uri) je v prihodnosti → privzeto **Čaka** (prej nedosledno »opravljeno«). i18n `when_status_note`
  posodobljen (sl/en/de). **(3) deploy.bat:** argument `hot`/`dev`/`debug` → debug build s hot reload (r/R);
  privzeto ostane release. flutter analyze čist, **71/71 testov**. Commiti: `feat:` (FR-6), `fix:` (status),
  `chore:` (deploy.bat). **Naslednji: M5 (Supabase zaledje).**
- 2026-06-04 — **Code-quality cleanup (po M4, brez funkcijskih sprememb)** — pregled M4 kode + odprava
  prop-drilling `theme`/`t` čez **vso presentation plast** (weather UI + `task_detail` + 13 zaslonov:
  home/tasks/journal/areas/plants/supplies/entry): pomožni widgeti zdaj berejo `Theme.of(context)`/`context.t`
  **lokalno** namesto prek konstruktorjev (CLAUDE.md pravilo); static helperji obdržijo `Translations` parameter
  (klicani z lokalno vrednostjo). Dodatno v weather UI: odstranjeni mrtvi `t` parametri, `WeatherForecastStrip`/
  `conditionLabel` → privatna, `OpenMeteoClient.fetch` brez neuporabljenih `pastDays`/`forecastDays` (YAGNI).
  Brez sprememb vedenja/postavitve/stilov; ~−85 vrstic šuma. analyze čist, **69/69 testov**. Commiti: `refactor:`
  ×4 (weather UI · task_detail · presentation plast). Doslednost s CLAUDE.md pred M5.
- 2026-06-04 — **M4 ZAKLJUČEN (vreme, Open-Meteo)** — **4.1** Open-Meteo client: paketi `dio`+`freezed`/
  `json_serializable` (tech-stack §1); tolerantni DTO `OpenMeteoResponse` (vsa polja optional, ne crasha ob
  delnem odgovoru); tanek transport client (en request → vsi 3 pasovi §7.10 + temp. tal + ET₀), vrže ob
  napaki. **4.2** Vremenski posnetek: domenski `WeatherSnapshot` (3 pasovi) + čisti `buildSnapshot` builder +
  `WeatherService` z omejenim retry/backoff (offline → null, graceful); zajem fire-and-forget ob prehodu v
  opravljeno (`complete` + `create`-done), shrani v `task.weather` SAMO če prazen (zamrznjen, nikoli prepisan).
  Repo agnostičen prek `WeatherCapture` typedef (composition, ne features→features). Privzeta lokacija v
  `core/config` (TODO M7 → H3-centroid; Dart nima `double.fromEnvironment` → String + parse). **4.3** Prikaz:
  `WeatherSnapshotCard` (detajl 17/17b, 3 pasovi) + `CurrentWeatherCard` (Domov, živ kontekst + napoved); WMO
  koda → stanje+emoji; `decodeWeatherSnapshot` tolerantni dekoder (`catch(_)` — TypeError ob legacy/corrupt
  JSON ne sme crashati UI); i18n `weather.*` sl/en/de, odstranjena mrtva placeholderja. **+ fix:** `INTERNET`
  permission v main manifestu (bil le v debug → release ni dosegel mreže; potreben tudi M5/M6 sync + Sentry) —
  **potrjeno na napravi (vreme dela)**. **+ 30-min cache** na Domov: `WeatherService.captureCached` (TTL prek
  `Clock`, graceful degrade na zadnji znan), `weatherService` provider → `keepAlive` (cache preživi obiske).
  **4.4** Testi M4: 14 novih (builder 3 pasovi + edge, (de)serializacija + decode tolerantnost, client prek
  dio fake-adapterja, service cache TTL/graceful prek `FakeClock`+stub). flutter analyze čist, **69/69 testov
  zelenih**. Odločitvi (UX uskladitev): vir lokacije = privzeta v config do M7; zajem le ob prehodu v opravljeno
  (live napoved za čaka izpuščena). **Naslednji: M5 (Supabase zaledje).**
- 2026-06-04 — **3.7 + M3 ZAKLJUČEN** — Po 3.6 je sledil **prefokus na vnos opravila** (ne nov mejnik, ampak
  večja prenova jedra M2/M3): (1) **Vnos = horizontalni stepper** (`features/tasks/presentation/entry/`) —
  6 pogojnih korakov (tip · subjekti multi-select · kdaj+ura+status · opomnik [če čaka] · sredstva [če tip
  troši] · pregled); nadomesti stari Hiter vnos + obrazec (oba IZBRISANA); edit odpre Pregled; `consumesSupplies`
  polje v katalogu (schemaVersion 4). (2) **UI polish**: tema (medel hint, error barve), poenoteni komponentni
  widgeti (SectionLabel/FieldLabel/DestructiveButton/EmptyState/TaskEntryTile) + komponentni katalog v CLAUDE.md.
  (3) **Nav reorganizacija**: vrstni red Domov · Opravila · Dnevnik · Vrt; FAB ＋ na Domov+Opravila (Dnevnik =
  bralni); vsak tab vedno odpre svoj root (`goBranch(initialLocation: true)`). (4) **Mesečni pregled — tap na dan**:
  izbere dan + izlista opravila + »Dodaj na ta dan« (today privzeto izbran, izbran dan rumen, today zelen border).
  (5) **Domov status**: ⏰/✓ ikone + popravek relativnega datuma (koledarski dnevi prek startOfDay). (6) **Detajl**:
  »Opravljeno/Načrtovano: datum« + Premakni = pravi date-picker (`repo.reschedule`). (7) 🔴 **KRITIČNI offline-first
  font fix**: `google_fonts` je font nalagal runtime prek omrežja (`fonts.gstatic.com`) → offline (vrt!) crash;
  Plus Jakarta Sans zdaj **bundlan** lokalno (`assets/fonts/`, `google_fonts` odstranjen) — **potrjeno na napravi
  offline**. Pravilo zapisano v CLAUDE.md (nič runtime fetcha sredstev). Počiščena mrtva koda + odvečni wireframi.
  **UX validacija stepperja** (2026-06-04): auto-advance koraka 1, pogojni koraki in opomba na Pregledu ocenjeni
  kot OK (brez sprememb); »ponovi zadnje« odložen v backlog (FR-6). M3 widget testi (mesečni koledar, opombe,
  rastline, zaloge, nastavitve, journal/tasks) + repo testi obstajajo, ročna preverba na napravi opravljena.
  flutter analyze čist, **55/55 testov zelenih**. **M3 zaključen → naslednji M4 (vreme, Open-Meteo).**
- 2026-06-02 — **3.6** — Nastavitve/profil (12): nova feature `settings/`; `ProfileRepository` (getLang/setLang nad drift `profile`, userId='local'/TODO M7, update-or-insert brez prepisa bodočih h3*) + `profileRepository` provider; `SettingsScreen` poln skeleton (Profil/Lokacija/Obvestila/Račun&podatki = placeholder → "Na voljo kmalu" snackbar; Jezik `SegmentedButton` sl/en/de z endonimi + Vrt vstopa = aktivna); jezik persistira prek `profile.lang` (main.dart bootstrap po seedu bere getLang → `setLocaleRaw`, offline-first brez novega paketa); Domov ⚙ → `settings`; router `/settings`; Vrt → Zaloge (`/supplies`, rešen odprt vstop M3.3) + Območja (`/areas`); `settings.*` i18n sl/en/de; unit testi ProfileRepository (null→set→update v isto vrstico). Odločitvi: profile.lang persistenca + poln skeleton z placeholderji. flutter analyze čist, 50/50 testov zelenih.
- 2026-06-02 — **3.5** — Mesečni koledar (11): `TasksRepository.watchAll` (vsa ne-deleted, vsa stanja) + `allTasksProvider`; `TaskFormScreen` +`initialDate` (router `task-new` bere `?date=ISO`, deep-link varno); nov `month_calendar_view` (mesečna navigacija ‹ › prek `MaterialLocalizations.formatMonthYear`, lokaliziran prvi dan tedna+narrowWeekdays, grid 7 stolpcev, do 3 enobarvne pike/dan, today obroba, štetje opravil, tap na dan → Novo opravilo s tem datumom); čista funkcija `monthCells(month, firstWeekday)` (testabilna); `journal_screen` `SegmentedButton` Časovnica/Mesec (filter bar le v časovnici); `journal.month_hint`+`month_count` (plural) i18n sl/en/de. Odločitve: tap→07 z datumom, koledar kaže vsa opravila, do 3 enobarvne pike (26 tipov ni mapljivih na 5 barv); setveni koledar = po-MVP (izpuščen). flutter analyze čist, 47/47 testov zelenih.
- 2026-06-02 — **3.4** — Opombe (18): `NotesRepository` (watchAll desc/byId/create/updateNote/softDelete; uuid+UTC+pending+Clock) + `notesProvider`; drift tabela `note` že obstaja (brez spremembe sheme); `PlantField` ekstrahiran v `plants/presentation/widgets/` (skupen task_form+note_form, odpravljen verbatim copy); `note_form_screen` (18) create/edit (Zapis textarea + Kdaj segmented + Območje neobvezno deselect + Rastlina prek PlantField ko je območje izbran), 🗑 v AppBar → confirm_dialog → softDelete; `sealed JournalEntry` (Task/Note) + `journal_screen` meša opombe+opravila po datumu (`switch` na sealed), ✍️ vnos tap→note-edit, filter Opombe oživljen; Hiter vnos (02) ✍️ kartica → `note-new`; router `/notes/new`+`/notes/:id/edit`; `notes` i18n sl/en/de. Odločitve: rastlina kot task_form (vezana na območje), edit prek forme + izbris v formi, brez inline "+ Novo". flutter analyze čist, 42/42 testov zelenih.
- 2026-06-02 — **3.3** — Zaloge (08) + odpis: `task_supply.applied` bool + migracija schemaVersion 1→2 (additive addColumn); `SuppliesRepository` (supply CRUD + odpis status-aware prek `applied`: `syncForTask`/`applyForTask`/`revertForTask`, straža proti dvojnemu odpisu); TasksRepository DI suppliesRepo, odpis vezan na prehod v done (complete→odpiše, revertToWaiting/softDelete→vrnejo, transakcije); `supply_edit_sheet` + `add_supply_to_task_sheet` bottom sheet-a; `supplies_screen` (08) bralni seznam z "malo" opozorilom (route `/supplies`, brez vstopa — vstop M3.6); task_form `_SupplyField` + `syncForTask(isDone)`; task_detail prikaz sredstev; `supplies` i18n sl/en/de (qty/custom_add slang param). Odločitvi: odpis SAMO ob opravljeno, brez Domov vstopa. Recepti/grupiranje/vstop = odloženo (manjkajo wireframi urejanja). flutter analyze čist, 36/36 testov zelenih.
- 2026-06-02 — **3.2** — Izbirnik rastlin (10) + user_plant: katalog `plantsList`/`plantsMap` v core; `UserPlantsRepository` (watchByArea/createForArea + `syncForArea` atomarna transakcija diff); `PlantSpec` vmesni tip; `plant_display` (label/icon + čista `plantMatchesQuery`); poln zaslon picker (iskanje labels sl/en/de+latinsko ime, kategorije, lasten zaseben vnos) vrne `PlantPick`; area_form buffer rastlin+syncForArea; task_form izbira user_plant+dodaj prek pickerja (reset ob menjavi območja); task_detail prikaže rastlino; `updateTask`+userPlantId; `/plant-picker` route; `plants` i18n sl/en/de (slang param `custom_add(q)` z `$q`). `plant_synonym` ostaja prazna (sinonimi=kasnejši tir). flutter analyze čist, 29/29 testov zelenih.
- 2026-06-02 — **3.1** — Območja (04/05/09): `AreaType` enum prek drift textEnum (Areas.type String→enum); `AreasRepository` (watchAll/byId/create/update/softDelete, UTC); tasks repo +`watchByArea`/`watchLatestPerArea`; `areas_providers` + `areasMapProvider` premaknjen iz catalog_provider (repo skrije drift — odpravljen M2 zdrs); zasloni seznam (grupiran po tipu, podnapis=zadnje opravilo)/detajl (hero+zgodovina+⋯)/obrazec; generičen `core/widgets/confirm_dialog`; 4. zavihek Območja (router+main_shell); `areas` i18n sl/en/de. flutter analyze čist, 19/19 testov zelenih. **M3 začet.**
- 2026-06-02 — **2.8** — widget testi: QuickLogScreen shrani opravilo v DB (tip + območje + Shrani); TasksScreen ⋯→Opravljeno kliče repo.complete; 19/19 zelenih; analyze čist. **M2 zaključen.**
- 2026-06-02 — **2.7** — TaskDetailScreen: hero blok + statusna pill (čaka/opravljeno), weather placeholder, details card (območje/rastlina/sredstva/opomnik/ponavljanje/opomba), action bar (primarna + 4 sekundarne, različno za oba stanja), ⋯ akcijski list; watchById + revertToWaiting v repo; taskByIdProvider family; router posodobljen; flutter analyze čist, 17/17 zelenih.
- 2026-06-02 — **2.5** — Dnevnik (03): JournalScreen z opravljenimi nalogami po datumskih skupinah (Danes/včeraj/datum); filter Vse/Opravila/Opombe (opombe = M3.4 placeholder); `journal.*` i18n sl/en/de; widget test posodobljen s provider overrides.
- 2026-06-02 — **2.4** — Novo opravilo (07): TaskFormScreen create+edit mod; tip (bottom sheet grid), datum+ura picker, status segmented, območje chips, rastlina (pogojno, M3.2 placeholder), sredstva/opomnik/ponavljanje placeholder; `task_form.*` i18n; `/tasks/new` + `/tasks/:id/edit` router.
- 2026-06-02 — **2.3** — Hiter vnos (02): tip opravila (grid), datum (Danes/Včeraj/Datum picker), območje (chips), opomba; validacija; shrani v drift; `quick_log.*` i18n sl/en/de.
- 2026-06-02 — **2.2** — Domov (01): HomeScreen z danes/nazadnje sekcijama iz drift; catalog/areas providerji; `nav.home`+`home.*`+`common.*` i18n; FAB odpre `/quick-log` (placeholder za 2.3); router `/home` kot prva veja + initialLocation.
- 2026-06-02 — **2.1** — Tasks repo + providerji: Clock interface za testabilno logiko časa; TasksRepository nad drift (create/complete/softDelete/postponeOneDay/duplicate/watch*); uuid za ID na napravi; pendingTasksProvider + completedTasksProvider; 7 unit testov.
- 2026-06-02 — **2.6** — seznam Opravila (06): TasksScreen s skupinami (zamuda/danes/jutri/ta teden/pozneje), statusni znački, akcijski list (✓/+1 dan/uredi/podvoji/izbriši + potrditev za brisanje), slang plural za `overdue_days`; widget_test posodobljen (pendingTasksProvider override + wildcard `_`); flutter analyze čist, 17/17 testov zelenih.

- 2026-06-02 — **1.6** — testi M1: 9 unit testov (seed šteje vrstice + idempotentnost + polja; Area CRUD ×3; Task CRUD ×3); AppDatabase.forTesting(super.executor); vsi testi zeleni (10/10).
- 2026-06-02 — **1.5** — SeedService: idempotenten, transakcija (task_type+plant → category_matrix), UncontrolledProviderScope v main; await LocaleSettings. flutter analyze čist, test zelen.
- 2026-06-02 — **1.4** — seed podatki: 26 tipov opravil (A.1–A.4) + 34 rastlin (C.1–C.6) + 58 vnosov category_matrix; Dart const; flutter analyze čist.
- 2026-06-02 — **1.3** — user tabele: profile, area, user_plant, task, task_reminder, note, supply, recipe, task_supply; sync-ready (uuid/updated_at/deleted/sync_status); area.protected; Notes.content→'text'; code-gen čist.
- 2026-06-02 — **1.2** — katalog tabele: `task_type`, `plant`, `plant_synonym`, `category_task_type`; `labels` JSON TEXT; `tableName` override za Supabase skladnost; code-gen čist.
- 2026-06-02 — **1.1** — drift temelj: `AppDatabase` (prazna) + `LazyDatabase`/`NativeDatabase` + `databaseProvider` (keepAlive); `path_provider`+`path` dodana; `*.g.dart` izključeni iz analize.
- 2026-06-02 — **pre-M1 fix** — route poti in imena v angleščini (`/journal`, `/tasks`); komentar v `main_shell.dart` popravljen. `flutter analyze` čist, test zelen.
- 2026-06-02 — **0.6** — CI (GitHub Actions: analyze + test + code-gen) + README posodobljen. **M0 zaključen.**
- 2026-06-02 — **0.5** — slang i18n sl/en/de; context.t v vseh widgetih; brez hardcode nizov; test zelen.
- 2026-06-02 — **0.4** — go_router StatefulShellRoute, 2 zavihka (Dnevnik/Opravila), FAB placeholder; test preklopa zelen.
- 2026-06-02 — **0.3** — brand tema (AppColors, AppTheme light+dark, Plus Jakarta Sans); flutter analyze čist.
- 2026-06-02 — **0.2** — Riverpod 3.x + code-gen temelj; ProviderScope, demo provider, build_runner čist.
- 2026-06-02 — **0.1** — feature-first struktura map + minimalni main + lint pravila; `flutter analyze` čist, test zelen.
- 2026-06-02 — Roadmap ustvarjen; M0 čaka na začetek.
