# Tendask — Roadmap / Task list (MVP)

> **Status:** živ dokument · zadnja posodobitev 2026-06-04
> **Namen:** edini vir resnice za "kaj delamo naprej". PM + Flutter dev + tester pogled.
> **Bere ga AI agent (Claude Code) IN človek.** Sledi mu korak za korakom.
>
> Povezano: [`tech-stack.md`](tech-stack.md) (potrjen sklad + §6 struktura, §9 vrstni red),
> [`koncept.md`](koncept.md) (§7.9 entiteta opravilo, §7.14 podatkovni model),
> [`opravila-in-rastline.md`](opravila-in-rastline.md) (vir za seed), `wireframes/` (~27 zaslonov),
> [`povratne-informacije.md`](povratne-informacije.md) (opažanja testerjev/uporabnikov + analiza/odločitve, runde T1–).

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
| **M11** | *(po MVP / V2)* Pametni motor + FCM + percentili | glej `pametni-motor.md` | `[~]` |

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
- [x] **9.4 — Android release.** Keystore (👤), podpisan release build, `--dart-define` produkcijski ključi. release build podpisan z upload keystorom (`build.gradle.kts` bere `key.properties`, fallback na debug za dev). AAB potrjen (CN=Gorazd Veselič). *Commit:* `chore: Android release konfiguracija` (`2a8e72b`)
- [x] **9.6 — Razširitev kataloga rastlin (PRED RELEASOM, pred 9.5).** ~34 → **128 vrst** čez **12 kategorij** (lawn, fruit_tree, berries, vegetable, herbs, perennial, shrub, climber, bulb, conifer, hedge, houseplant). Metoda (z uporabnikom): **kuracija (SL/EN/DE ljudska imena, pogovorna) + GBIF preverba znanstvenih imen** (match API — vsa veljavna) + **Wikidata navzkrižna preverba SL imen** (batch SPARQL — potrdila imena; popravljen `hibiscus`→`sirski oslez`). Povezava rastlina→opravila prek **kategorije** (razširjena `categoryMatrix`, 93 vrstic). Vir: `lib/data/seed/catalog_seed.dart` → `tool/gen_catalog_sql.dart` → `supabase/seed/catalog.sql`. **Reseed (pre-release okno):** oblak posodobljen prek `apply_catalog.py` (128 plant, 93 matrika; počiščene osirotele `ornamental`/`container` matrika vrstice); naprava pull-a ob zagonu + bundlan seed (offline prvi zagon) = 128. Brez podvojenih id-jev, 151/151 testov, analyze čist. **On-device potrjeno: vseh 128 vrst prisotnih (pull + bundlan offline seed za prvi zagon brez signala).** *Commit:* `feat: razširjen katalog rastlin (128 vrst, GBIF/Wikidata preverba)`
- [x] **9.7 — GDPR: izvoz podatkov + izbris računa.** Dva placeholderja v Nastavitvah (`export_data`, `delete_account`) sta zdaj »coming soon«; pred internim testom naredi dejansko. **Izvoz:** zberi vse uporabnikove drift vrstice (profile, area, user_plant, task + task_subject/reminder/note/task_supply) → JSON datoteka → `share`/shrani; brez koordinat (samo H3 celice). **Izbris računa:** potrditveni dialog (`showConfirmDialog destructive`) → Supabase brisanje računa (`ON DELETE CASCADE` počisti oblak) → lokalni `clearUserData` → nazaj na onboarding. Anon gost: lokalni izvoz + lokalni clear (ni oblačnega računa). *Commit:* `feat: GDPR izvoz + izbris računa`. **Opomba:** enote (°C/°F) namerno opuščene — MVP je metričen (SL/EU trg); »Območja« povezava odstranjena iz Nastavitev (podvojena z Vrt zavihkom).
- [~] **9.5 — 👤 Play interni test.** Naloži na Play Console interni track. **Predpogoj: 9.6 (poln katalog).** **Priprava ✅ (2026-06-09):** podpisan AAB zgrajen+verjeven (CN=Gorazd Veselič); politika zasebnosti SL/EN/DE objavljena (`https://tendask.com/privacy`); Data Safety mapirano; go-live plan + store listing (**EN default**, SL+DE prevoda) + content rating + grafika (icon-512, feature-graphic) v `docs/go-live/`. **Play razvijalski račun ustvarjen** (osebni, »Tendask«, `exogenus@gmail.com`) — **čaka Googlovo preverjanje identitete** (blokira create-app). Ostane 👤: konzolni koraki po odobritvi + posnetki zaslona; odloženo Sentry debug symbols upload.
- [x] **9.9 — Odpornost vremena na izpad/počasen Open-Meteo.** Sproženo z reprodukcije: ob izpadu Open-Meteo (502 + odzivi 40+ s — preverjeno na napravi) je dashboard ostal s prazno kartico, loader pa ni povedal, kaj dela. (1) `kWeatherStaleTtl` 2 h → **48 h** (`config.dart`): odpiranje naslednje jutro pokaže včerajšnji posnetek namesto prazne kartice; čez 48 h pošteno »ni na voljo« (napovedni pas bi bil sicer večinoma pretekli dnevi). (2) `CurrentWeatherCard` doda tih žig **»Osveženo ob X«** (nov i18n `weather.updated_at`), a le ko je posnetek star (> `kWeatherCacheTtl`); svež ostane čist. (3) Med osveževanjem se star posnetek ne skrije za spinner — prek `weather.value` (riverpod 3.x ohrani prejšnjo vrednost ob reload), spinner le ob **prvem** nalaganju; loader dobi besedilo **»Nalagam vreme…«** (`weather.loading`). (4) Dashboard uporabi nov **lažji** zahtevek `OpenMeteoClient.fetchCurrent()` (samo trenutni pogoji + 3-dnevna napoved, brez `hourly` soil/precip in `et0` — najtežja dela payloada; `capture(full: false)`); težki tri-pasni posnetek (§7.10 detajl opravila) ostane poln prek `fetch()`. analyze čist; vremenski testi 17/17 (posodobljen stale prag 49 h, dodan »dan star posnetek offline«). *Commit:* `feat(weather): odpornost dashboarda na izpad Open-Meteo`
- [x] **9.8 — UI polish + začasni izklop sredstev.** Manjši UX popravki pred releasom (z uporabnikom, wireframe-driven): izklop debug pasu; jezikovni `SegmentedButton` brez kljukice (popravek preloma dolgih endonimov); **Domov** — opravila kažejo rastlino-subjekt (🪴, kot zaslon Opravila) + zamujena opravila v **strnjenem rdečem pasu**, ki se ob kliku razširi v seznam na mestu (prej zamujena na Domov niso bila prikazana); **prenova zaslona Lokacija** — iz Nastavitev (push) back + samodejno shranjevanje + toast brez spodnjega gumba, iz onboardinga (go) gumb »Nadaljuj«; statusni pas (nastavljeno/ni) + gumb **»Odstrani lokacijo«** s potrditvijo (`clearGardenLocation` počisti koordinate + H3 celice → vreme pade na privzeto območje); **Vrt** — obrnjena hierarhija (območje = naslov skupine, rastline = kartice pod njim, prej je bilo območje bolj zamaknjeno kot rastline). **Sredstva (supplies) začasno skrita** prek nove konstante `kSuppliesEnabled=false` (`core/config.dart`): preskočen korak »Sredstva« v čarovniku + skrita sekcija »Vrt/zaloge« v Nastavitvah; koda ostane za kasnejšo vključitev. Novi wireframi `16b-location`, `01b-home-overdue-{collapsed,expanded}`, `vrt_v5`. analyze čist, 157/157. *Commiti:* `chore(i18n): ključi za lokacijo in zamujena opravila`, `feat(location): status, brisanje in kontekstni gumb`, `feat(home): rastlina ob opravilu + pas zamujenih`, `refactor(garden): hierarhija območje kot naslov, rastline kartice`, `chore(ui): debug pas, jezikovni gumb, skrij sredstva (kSuppliesEnabled)`, `docs(wireframes): lokacija, zamujena, vrt (v5)`

---

## M10 — *(po MVP)* iOS mejnik

> Zahteva macOS + Xcode ali oblačni build (Codemagic / GitHub macOS runner) + Apple Developer (99 $/leto).
> iOS dovoljenja (lokacija, obvestila), ikone/splash, podpisovanje, App Store metapodatki, TestFlight.

---

## M11 — *(po MVP / V2)* Pametni motor + FCM + percentili

> ⭐ **POLNA PRED-IMPLEMENTACIJSKA SPECIFIKACIJA: [`docs/m11/`](m11/README.md)** (2026-06-11) —
> agronomska pravila (61, z viri), signalni sloj, formalna pravila R1–R7, točen SQL (0005/0006),
> drift zrcalo, FCM, klimatski profil, Flutter arhitektura. **Delovni tasklist s koraki
> M11.1–M11.21 + DoD: [`docs/m11/09-koraki.md`](m11/09-koraki.md)** — koraki se odkljukavajo tam.
>
> Plast B: dnevni paketni pregled (cron/Edge Function) + FCM push, kurirana pravila (brez AI),
> vodenje proti gnjavljenju (cooldown, vremenske straže, dedup, frekvenčna kapica). Glej
> [`pametni-motor.md`](pametni-motor.md) + `koncept.md` §7.13. V2: percentili okolice (`activity_agg`, §8).
> Razširitev kataloga rastlin 35 → 100–200 (Wikidata/GBIF) je **premaknjena na PRED-RELEASE → glej 9.6** (mora biti pred internim testom; ne čaka na M11).
>
> **Agregacija okolice — celovit statistični + podatkovni model: [`skupnost-agregacija.md`](skupnost-agregacija.md)**
> (vsa odprta vprašanja razrešena 2026-06-08; povzetek v `koncept.md §8`).
> Wireframe (klikabilni flow): [`wireframes/community-flow_v3.html`](wireframes/community-flow_v3.html) — 2-zaslonski IA + tease za ne-premium.
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
- **FR-3 — Zatikanja (performance).** ✅ **Zaprto (2026-06-11).** Glavni opaženi izvor —
  »občutek zmrznitve« na plant-add (katalog ~128 vrst grajen kot `Column` naenkrat + rebuild ob vsakem
  toggle; `recentPlantsProvider` `AsyncLoading` flicker) — odpravljen v `8c1cd05` (lazy `SliverList` +
  snapshot pogostih v `initState`); na napravi zatikanja ni več zaznati. Namenski profiling pass se ni
  zgodil, a širših zatikanj ni opaziti → zapiramo. **Če se spet pojavi:** profiliraj (DevTools timeline),
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
- **FR-5 — Ponavljanje opravil.** ✅ **Implementirano 2026-06-30 na `feat/fr5-recurrence`** (pushano,
  PR čaka; gl. dnevnik). MVP obseg = **materializiraj-naslednjo-instanco-ob-dokončanju**: ob ✓ se v isti
  transakciji ustvari naslednja instanca (sidro = načrtovani datum). UI v koraku »Kdaj«: Dnevno/Tedensko/
  Po meri + neobvezno **število ponovitev** (= `remaining`, min 1) + živ »Naslednje: <datum>« + validacija
  (prazno blokira »Naprej«). Model `Recurrence{everyDays, remaining}` v `task.recurrence` + nova
  `task.series_id` (drift v11 + Supabase `0013`, additive). Značka serije, »Ustavi ponavljanje« v ⋯,
  revert blokiran na dokončani ponavljajoči (D1). Polna spec: [`recurrence.md`](feature-requests/recurrence.md).
  **Namerno izven obsega:** serijsko urejanje / izjeme / mesečno-RRULE / sprava z motorjem (M11) —
  `series_id` to kasneje omogoči. **TODO ob prod releasu:** `supabase db push` za `0013` na prod PRED FR-5 buildom.
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
- **FR-8 — Lokacija prek centroida `h3_r7` namesto surovih koordinat.** ✅ **Implementirano
  2026-06-18 na `feat/fr8-h3-centroid`** (gl. dnevnik). Vreme + routing bereta centroid celice;
  `device_location` tabela odstranjena (drift v9); dovoljenje COARSE-only; pravni/Play/i18n osnutki
  usklajeni. Ostane 👤: Play Data Safety obrazec + redeploy privacy v1.1. Spodaj prvotna spec. Surove GPS koordinate danes živijo
  device-local (`device_location`) samo zato, da vreme in post-sign-in usmerjanje dobita točko — ampak
  r7 celica ima rob ~1,2 km (centroid ≤ ~1,4 km od vrta), kar je **pod ločljivostjo Open-Meteo mreže**
  (1–11 km), in ClimateService (M11.3) centroid že uporablja. Sprememba: (1) vreme (dashboard +
  zamrznjen posnetek ob ✓) bere `cellToLatLng(profile.h3_r7)`; (2) usmerjanje po prijavi preverja
  `profile.h3_r7` namesto device-local koordinat → **lokacijski zaslon po odjavi/prijavi izgine**
  (uporabnikova pritožba); (3) `device_location` shramba postane odveč; (4) izbira lokacije lahko dela
  s coarse dovoljenjem ali samo ročnim pinom. Pomislek: nadmorska višina v razgibanem terenu (centroid
  na pobočju → ~1–2 °C odmik). **OBVEZNI spremljevalni del — dokumentacija in pravni vidiki, ker se
  spremeni, kateri podatek zapusti napravo (ne več točne koordinate, samo centroid celice):**
  `koncept.md` (lokacija/zasebnost, sklep BUG-002) + `tech-stack.md` §2; **pravno:** politika zasebnosti
  (`docs/legal/privacy-policy.md` + `.html` — SL/EN/DE, opis kaj se pošlje Open-Meteo) → ponovna objava
  na spletni strani (`tendask.com`, Cloudflare Pages); **Play Data Safety**
  (`docs/legal/play-data-safety.md` + 👤 obrazec v konzoli: precise location → approximate, »Shared
  z Open-Meteo« opis); **v aplikaciji:** besedila na lokacijskem zaslonu/onboardingu in priming/privacy
  mikrocopy (i18n sl/en/de), ki obljubljajo ravnanje z lokacijo. Brez teh uskladitev se sprememba NE
  shipa — deklaracije morajo ustrezati dejanskemu vedenju.
- **FR-9 — Privzeto območje »Vrt« (nov `AreaType.garden`, auto-seed).** ✅ **Implementirano
  2026-06-16 na `feat/vrt-area` (gl. dnevnik). Migracija `0010` (CHECK z `garden`) APLICIRANA na
  živi DB 2026-06-16 prek poolerja (preverjeno: `area_type_check` zdaj vsebuje `garden`); ledger
  vnos za 0010 pride ob merge brancha (SQL idempotenten). **On-device verificirano** (SM A536B,
  debug): seed ustvaril »Vrt« (type=garden, user=local, pending), flag postavljen, app brez crasha
  (logcat čist). ZAKLJUČENO; preostane le push brancha + PR.**
  Odstopanji od načrta: (a) seeded flag NI v profile (synced),
  ampak v lokalnih prefs (`local_flags`) — synced stolpec bi zahteval migracijo profila na deljenem
  živem Supabase; lokalni flag se temu izogne (cena: multi-device re-seed edge, MVP enouporabniško
  sprejemljivo). (b) **Opomba (4) spodaj je bila NAPAČNA: `area.type` IMA `area_type_check`** (0001),
  ki ni vključeval `garden` → seedani »Vrt« bi ob pushu sprožil 23514 in fail-fast push bi zaklenil
  cel sync. Popravljeno z migracijo `0010_area_type_add_garden.sql` (drop+add CHECK z `garden`,
  expand-safe, idempotentno; oštevilčeno 0010, ker živi DB že ima 0005–0009 iz M11). **Sekvenca:
  migracijo `0010` aplicirati na živi DB PRED kakršnim koli FR-9 buildom, ki sinhronizira.** »Vrt« = primarna
  v-tla vsajena celota ob hiši (kot majhna njiva) — najpogostejša oblika sajenja; **različen od
  grede** (`bed` = dvignjene grede / manjši otočki). `AreaType` (`lawn/hedge/bed/tree/ornamental/
  other`) **nima** `garden` → opravila »za cel vrt« nimajo kam. Sprememba: (1) `enum AreaType {
  garden, lawn, hedge, bed, tree, ornamental, other }` — `garden` **PRVI** (UI vrstni red izhaja
  iz `AreaType.values`; drift `textEnum` shranjuje **ime**, zato je reorder varen in **brez
  migracije**); (2) i18n labela Vrt/Garden/Garten + ikona v `area_type_display.dart`; (3)
  **auto-seed** privzeti »Vrt« za vsakega uporabnika ob prvem zagonu + **backfill obstoječim** ob
  naslednjem zagonu (idempotentno, vzorec `seed_service`); **izbrisljiv** (kdor ima le grede/trato,
  ga odstrani); (4) Supabase `area.type` **nima CHECK** omejitve → nova vrednost varna (tolerantni
  parser obeh strani); (5) M11: `garden` postane veljaven engine subjekt (additive). **Prizadeti:**
  `AreaType`, area seed/service, `areas_screen`/`area_form_screen`/`area_type_display`, area picker
  v task entry, i18n sl/en/de. **DoD:** nov uporabnik vidi »Vrt« prvi v seznamu+pickerju; obstoječ
  dobi backfill; izbris deluje; sync round-trip; analyze+testi zeleni.
- **FR-10 — Motor (V2): rastline z menjavo/prekinitvami (kolobarjenje, premiki).** 📝 **Designerska
  opomba, NI NUJNO, V2/motor (M11).** Kako pravila/opomniki ravnajo, ko je rastlina eno leto na
  vrtu/gredi, drugo ne, potem morda spet (kolobarjenje), ali ko jo premakneš med gredami.
  Podvprašanja: **(a) kontinuiteta zgodovine** — če `user_plant` soft-deletaš in naslednje leto
  spet dodaš, je nova vrstica = izgubljen ritem/obletnica (R2/R3)? Morda rabi stabilen subjekt-ključ
  čez sezone. **(b) Mirovanje pravil** — eligibility že preskoči neobstoječ subjekt (straža 5a), a
  obletnica naslednje leto se ne sproži, ker ni žive vrstice. **(c) Premik med gredami** = sprememba
  area FK (ne nov subjekt) — ritem naj se ohrani. **Detajl design** spada v
  `docs/m11/10-odprta-vprasanja.md` ob nadaljevanju M11; lasten branch ob obravnavi.
- **FR-11 — Varnost prijave (OTP/email hardening).** ✅ **Implementirano 2026-06-16 na
  `feat/auth-hardening`** (gl. dnevnik; čaka pregled + push). Odstopanje: rate-limit (#5) =
  60 s resend cooldown (UX sloj); urne kapice ostajajo server-side (Supabase). Spec (po vrsti): **(1) format
  validacija** e-pošte (regex + osnovna pravila); **(2) tipkarska zaznava domene** (did-you-mean:
  `gmal.com`→`gmail.com`, `gmail.con`→`gmail.com`); **(3) DNS check** prek DNS-over-HTTPS (npr.
  `dns.google/resolve`): **MX → fallback A/AAAA** (RFC 5321 §5.1; CNAME se pri A-poizvedbi sledi
  sam), **block samo** ob NXDOMAIN / brez MX in A/AAAA, **fail-OPEN ob napaki poizvedbe** (nikoli
  blokiraj zaradi DoH izpada/timeouta — le ob definitivnem negativnem); razkrije le **domeno** (ne
  celega naslova); **(4) 60 s cooldown** med pošiljanji (zrcali Supabase server-side ~60 s + urne
  kapice — uporabnik ne trči v strežniško napako); **(5) rate limit / omejitev poskusov** (UX sloj
  nad Supabase enforcementom). **Omejitev:** DNS potrdi domeno, **ne nabiralnika** (napačen lokalni
  del ujame šele OTP). **Prizadeti:** `AuthService.sendEmailOtp` + prijava/onboarding UI + i18n
  napake sl/en/de; morda omemba DoH v privacy policy. **DoD:** napačen format/neobstoječa domena
  zavrnjena (s fail-open na DNS napako), did-you-mean predlog deluje, cooldown odštevalnik, brez
  regresije obstoječega OTP toka.
- **FR-12 — Oznaka kraja pri vremenu (reverzno geokodiranje centroida).** ✅ **Implementirano
  2026-06-18 na `feat/fr12-place-label`** (gl. dnevnik). **Vir = OSM/Nominatim reverse** (odločitev
  uporabnika; Open-Meteo Geocoding je samo naprej). Oznaka na vremenski kartici Domov; klic le ob
  spremembi `h3_r7`, oznaka cacheana lokalno (offline pokaže zadnjo znano za isto celico). Nov tretji
  ponudnik → privacy v1.2 + Play Data Safety usklajena. Spodaj prvotna spec. Ob vremenu (in po želji
  ob izbiri lokacije) pokaži **ime najbližjega kraja/vasi** — reverzno geokodiran centroid
  `cellToLatLng(profile.h3_r7)`. **Zakaj:** po FR-8 lokacija nima oznake (le H3 celica); uporabnik ne
  vidi, za kateri kraj je vreme. **Izvedba:** (1) reverzni geo-vir — Open-Meteo Geocoding je **samo
  naprej** (ime→koord), zato rabi **nov vir** (Nominatim/OSM ali offline seznam SI/EU krajev);
  **odprto vprašanje + glavna odločitev.** (2) **Cache oznake lokalno** (recompute le ob spremembi
  `h3_r7`), da ne ugibamo vsakič in delamo offline. (3) majhna oznaka kraja na vremenski kartici.
  **Zasebnost:** OK — pošljemo le centroid (~1 km, že tako gre Open-Meteo), rezultat je groba oznaka,
  ne koordinate. **OBVEZNO če dodamo nov vir:** posodobi privacy policy + Play Data Safety (nov
  tretji ponudnik). **Prizadeti:** weather feature (data+presentation), location screen, i18n,
  morda pravni dokumenti. **DoD:** vremenska kartica pokaže ime kraja; offline pokaže zadnjo
  znano oznako; brez novih shranjenih koordinat.
- **FR-13 — Indikator okolja (STAGING/OFFLINE) v aplikaciji.** ✅ **Implementirano 2026-06-28.**
  Hitro vizualno ločiti, kam je build povezan (prod Play vs. lokalni staging Docker). Kotni `Banner`
  prek `MaterialApp.builder`, viden samo ko `kEnvLabel != 'production'` → prod/Play nikoli ne pokaže.
  Polna spec: [`docs/feature-requests/env-banner.md`](feature-requests/env-banner.md).
- **FR-14 — Analitika & metrike (interna BI + javne statistike).** Predlog (2026-06-22, ni implementiran),
  čaka odločitev o obsegu. Trenutna shema je odlična za sync, šibka za analitiko (gostje nevidni; LWW
  upsert = brez zgodovine dogodkov). Priporočen razrez dveh tirov: (A) vedenjska analitika (installi,
  DAU/retencija, funnel, tudi gostje) prek Firebase Analytics / PostHog — brez dotika sync sheme; (B)
  domenske/javne statistike prek Supabase event log. Polna spec:
  [`docs/feature-requests/analytics.md`](feature-requests/analytics.md).
- **FR-15 — Obvestilo o nadgradnji v aplikaciji (in-app update).** Predlog (2026-06-26, ni implementiran),
  čaka odločitev o obsegu. Dva neodvisna mehanizma: (A) Google Play In-App Updates prek paketa
  `in_app_update ^4.2.5` (flexible flow, samo Android, native UX, nič lastne infra) — **NOVA dependency
  izven `tech-stack.md §1` → najprej potrdi + pin + posodobi §1**; (B) lasten Supabase `min_supported_version`
  gate (cross-platform/iOS »force update«, dodan kasneje ob M10). Lokalno netestabilno (rabi Play track).
  Polna spec: [`docs/feature-requests/in-app-update.md`](feature-requests/in-app-update.md).
- **FR-16 — Re-engagement opomnik za neaktivne uporabnike.** ✅ **Implementirano 2026-06-29 na `main`**
  (commit `d29fd9d`). **Lokalni dead-man's-switch = MVP** (doseže tudi neaktivirane/goste, brez M11/FCM,
  privacy-first); FCM/R8 ostane kot kasnejši dodatek za prijavljene. Mehanizem: namesto enega znova-
  zakoličenega opomnika zakoličimo **fiksno verigo dveh** (dan +7, dan +28 = decay 7 → +21 → tišina); vsak
  dotik (cold start / zapis task ali note / app resume) prekliče oba in ju zakoliči naprej — aktiven
  uporabnik ju nikoli ne vidi. Tako so anti-spam guardraili (kapica 1×/7 dni, decay, reset ob aktivnosti)
  zadoščeni **brez stanja v bazi**. A/B segment (`task.count==0` → »začni dnevnik« vs lapsed) izbran ob
  zakoličenju. Ločen kanal `journal_nudge` + rezervirani **negativni** notif ID-ji (`reminder_coordinator`
  ju izloča iz cancel-sweepa na obeh mestih); 17:00 = izven tihih ur po konstrukciji; collision-shift mimo
  dneva s task-reminderjem; ločen toggle v zaslonu 22 (privzeto on). Polna spec:
  [`docs/feature-requests/re-engagement-nudge.md`](feature-requests/re-engagement-nudge.md).
- **FR-17 — Haptični odziv ob ključnih akcijah.** ✅ **Implementirano 2026-06-28 na
  `feat/fr17-haptics`.** Nov `core/haptics.dart` (`AppHaptics.taskCompleted/saved/destructiveConfirmed`)
  centralizira preslikavo jakosti; sproži se, **ko se dejanje dejansko zgodi** (ne ob tapu): ✓ opravljeno
  (`lightImpact`, vse 4 točke — swipe/seznam-meni/detajl-gumb/detajl-meni), uspešno shranjen obrazec
  (`mediumImpact`, na success-poti entry + area/plant/note), potrjen izbris/clear (`heavyImpact`, en
  chokepoint v `showConfirmDialog`, ki pokrije VSE potrditve — v `lib/` je en sam `AlertDialog`). Brez
  nove dependency/sheme/i18n; `HapticFeedback` je sistemski (brez `VIBRATE` dovoljenja), OS-onemogočena
  vibracija = no-op. Testi: jakostna preslikava (3) + branža `showConfirmDialog` (3). Polna spec:
  [`docs/feature-requests/haptics.md`](feature-requests/haptics.md).
- **FR-18 — Več lokacij / vrtov (kandidat za premium »Tendask+«).** 💡 **Ideja/želja (2026-06-29,
  neraziskano do spec ravni).** Več vrtov na uporabnika, vsak s svojim vremenom/rastlinami; možen
  plačljiv dodatek. Večji poseg — trenutna arhitektura je »1 uporabnik = 1 lokacija« (lokacija =
  lastnost profila, koncept §7.7). Srečni vzvod: `area` je že N-na-uporabnika → verjetno dovolj nova
  `garden` tabela + `area.garden_id`. Groba ocena ~2–3 tedne (+1 IAP). Polna želja:
  [`docs/feature-requests/multi-location.md`](feature-requests/multi-location.md).
- **FR-19 — Lunin koledar (biodinamični koren / list / cvet / plod).** 📝 **Spec (2026-07-21).** Delovno
  ime »**Tendask biodinamični lunin koledar**« (in-app kratko »Lunin koledar«). Iz tester-feedbacka T10
  (delo »po luni«). Pristop **A = lasten izračun** (siderični položaj Lune → element → del rastline),
  **brez kopiranja Thuninega koledarja** (pravno kot »Lunine bukve« Kmečki glas — dejstva + tradicija
  prosta, njen izdelek/znamka ne). **Jedro = uveljavljena načela; znamka Tendask = UX/planiranje**, ne
  izmišljena pravila. **Nič sheme/synca/mreže/lokacije** — element je čista funkcija datuma. **Večdnevni
  pogled naprej = jedro** (namenski zaslon, planiranje); + kontekstne oznake (Domov/detajl/»Kdaj«);
  akcijske integracije = pol-avto opravilo iz koledarja, obratni iskalnik »naslednji dober dan za X«,
  personalizacija po vrtu, opt-in obvestila. **Zdaj vse free** (billing še ni); premium meja (planer +
  avto-opravilo + obvestila) = zapis namere za kasnejšo monetizacijo. Ni launch-gating (app v produkciji)
  — »kasneje« = prioritizacija. Polni spec:
  [`docs/feature-requests/biodynamic-calendar.md`](feature-requests/biodynamic-calendar.md).
- **FR-20 — Tendask + (premium): licenciranje, plačila in skladnost s Play.** 📝 **Spec / dogovorjena smer
  (2026-07-22).** Nadomešča prvotno predpostavko »premium = Play Billing«. **Pot = »consumption-only«**
  (Netflix model): nakup **na spletni strani**, v aplikaciji samo **odkupna koda** → **0 % provizije Play**.
  Politika to izrecno dovoli (»access content paid for somewhere else«), a **v aplikaciji ne sme biti nobenega
  poziva k nakupu, cene ali URL-ja** — to je edina rdeča črta (velja tudi za push obvestila in i18n nize).
  **Plačila prek merchant of record** (Polar ali Paddle, ~5 % + 0,50 $), **ne Stripe** — normirani s.p. je
  obdavčen po **prihodkih**, zato je pri MoR prihodek neto in provizija dejansko zniža osnovo (+ MoR prevzame
  DDV/OSS, račune, chargebacke). **Licenca:** koda (ne ujemanje po e-pošti — anonimni/Google računi se
  razhajajo), enkratna unovčitev prek atomarnega `update ... where redeemed_by is null`, vezana na `auth.uid()`;
  unovčitev **zahteva prijavljen račun**. **Offline:** podpisan token (`sub` + `plus_until`), javni ključ
  bundlan → aplikacija preverja **lokalno**; strežnik je »urad, ki izda dokument«, ne vratar; token pride
  zraven v **obstoječem pull syncu** (nič novega omrežnega dela); grace 7–14 dni prišteje **strežnik**.
  `plus_until`/`plus_token` sta strežniško lastna (column-level revoke + izpuščena iz push payloada).
  ⚠️ **Play Console: `App access` se mora spremeniti** (Googlu je treba dati testno kodo/račun s Plus).
  ⚠️ Preverjanje podpisa = **nova dependency izven `tech-stack.md §1`**. Alternativa (pot B, če ni konverzije):
  Googlov external payments program (od 30. 6. 2026, ZDA/UK/EGP) = gumb v aplikaciji dovoljen, a ~10 % service
  fee + geo-pogojevanje; **arhitektura licenc je enaka**, zato ni izgubljenega dela. **Prvi nosilec = FR-19**
  (lunin koledar: mena free, element-dan + planer + akcije = Plus); koledar se najprej zgradi **v celoti free**,
  gating je zadnji korak. **Delitev dela:** FR-20 = licence/plačila/Play skladnost, FR-19 §11.2–11.4 = UI
  Tendask+ zaslona in vstopne točke. **Obseg paketa (§10):** *Plus se gradi iz novega in neizdanega, nikoli
  iz izdanega* — izjema le razširitev zmogljivosti. **Opomniki ostajajo trajno free** (preverjeno in zavrnjeno
  2026-07-22: so obljuba iz listinga, so zanka zadrževanja, nosi jih FR-16); monetizira se sme le nov sloj nad
  njimi (vremensko pogojen opomnik, opomnik po fazi Lune). **Najmočnejši kandidat = M11 pametni motor** —
  zgrajen na `feat/m11-smart-engine`, a **nikoli izdan**, torej nihče nič ne izgubi; ima pa ponavljajoč se
  strošek → argument za letno in proti neomejeni doživljenjski. Trajno free: jedro, sredstva/recepti/pridelek/teme
  (v listingu), GDPR izvoz/izbris, mena Lune. **Grandfathering:** kdor je koledar uporabljal pred vklopom zidu,
  ga obdrži trajno. **Cenovni model:** mesečna **zavrnjena** (fiksna provizija 0,50 $ vzame 47 % pri 1,99 €;
  prelom pri 7 mesecih; pri letni ~9,90 € mesečna sploh ne more obstati) → **ponudba = dva izdelka: letno
  (naročnina, »odpoveš kadarkoli, leto ti ostane«) + doživljenjsko**; **številke še niso zapečene**; sidro =
  tiskane Lunine bukve 9,90 €. Zavrnjena tudi **plačana testna doba** (vsak izdelek nosi svoj ključ → dvojno
  lepljenje kode; nadomestek = 14-dnevno vračilo + brezplačni sloj + `granted` kode) in **ločena »letna brez
  obnovitve«** (= naročnina, ki jo takoj odpoveš). **Arhitektura s Polarjem:** Polar = blagajna in poštar
  (denar, DDV, račun, generiranje kode, e-pošta, portal, omejitev naprav prek `activate`); licenco vodiš ti
  v Supabase. **Koda = kdo si, webhook = do kdaj velja** — koda sama ne ve za obnovitev. **NE nastavljaj TTL
  na Polarjevem ključu** (dve uri se razideta); `plus_until` je edina resnica. **Invarianta:** nakupni dogodki
  `plus_until` samo podaljšajo (`max(now, obstoječi)`) — webhooki prihajajo izven vrstnega reda; to zastonj
  reši nadgradnjo, dvojni nakup in nakup pred iztekom. **Lastne kode ostanejo** za Play pregled, grandfathering
  in darila (te tečejo **od unovčitve**, Polarjeve **od nakupa**). **Spletna stran ostane statična** (§4.5):
  `/plus` v treh jezikih + nav postavka + sekcija na landingu + footer na Polarjev portal; **fiksnih stroškov
  0 €**; popraviti je treba hero značko »brezplačno«. **Ponudnik — priporočilo Polar** (§4.3; tveganje mladega
  podjetja ublaženo, ker je menjava prepis webhooka in ne selitev podatkov; prodaja potrošnikom, zato Paddlova
  davčna globina odpade), **Paddle rezerva**, če Stripe Express za s.p. ne steče ali če Polar ne pošilja
  opomnika pred obnovitvijo. **Popravek:** License Keys prihranijo le e-pošto in »izgubil sem kodo« — lastno
  generiranje kod rabiš tako ali tako. **Predpogoj go-live:** Stripe Express (izplačilna cev, ne blagajna;
  ročna izplačila). **Testiranje:** Polar sandbox ↔ obstoječi staging (ngrok ni potreben, tunel je javen);
  letne obnovitve se ne da počakati → kratek testni izdelek ali ročni webhook. **Darila = lastna `granted`
  koda** (0 €, brez kartice, teče od unovčitve), ne 100 % kupon. **Play pregled = `kind='review'` koda:**
  večkratna s kapico, vsaka unovčitev da 30 dni, vklopiš ob oddaji in prekličeš po odobritvi; `App access`
  gre z »Ne« na »Da«. **Odprto:** konkretne cene, potrditev ponudnika, ali paket starta z eno funkcijo.
  Polni spec:
  [`docs/feature-requests/tendask-plus-licensing.md`](feature-requests/tendask-plus-licensing.md).
- **FR-21 — Rastlinsko znanje / obogaten katalog (»Vodič«).** 💡 **Ideja / osnutek (2026-07-22).** Iz
  konkurenčne analize **posadi.si** (zavihek »Znanje« = strukturirane razlage rastlin = njihova glavna
  prednost) in sorodnega **T5**. Danes je naš katalog (128 vrst) tanek (ime + kategorija); ideja = ob kliku
  na rastlino **strukturiran opis** (pridelava, lokacija, čas sajenja, razmik, zalivanje, kolobar, sosedje,
  škodljivci, spravilo, nasveti). **AI/LLM** naredi obseg (128 × ~12 sekcij × sl/en/de) izvedljiv, **a je le
  pospešek za osnutek, ne avtoritativni vir** — agronomska halucinacija (napačen čas/razmik, ameriške cone)
  uniči pridelek in zaupanje; zato **LLM osnutek → navzkrižna preverba trdih podatkov / strokovni pregled →
  seed**, in **enkratno v katalog, ne runtime** (offline-first). **Arhitektura = obstoječi katalog**
  (additive shema, oblak vir resnice + pull, bundlan offline fallback, typed model, i18n). **Free/premium
  (priporočeno = opcija B):** osnovni opis **free** (paritet s posadi.si, ki to daje zastonj), poglobljeni
  **»Tendask vodič« = Tendask+** (veže se na FR-19 + M11). Pravno: kuriran LLM tekst = lastna vsebina, **ne**
  prepisujemo posadi.si; slike lastne ali Wikimedia z licenco/pripisom. Polni spec:
  [`docs/feature-requests/plant-knowledge-catalog.md`](feature-requests/plant-knowledge-catalog.md).
- **Monetizacija — plačljive storitve (premium / naročnina).** 💡 **Namera (2026-06-30): »slej ko prej«.**
  Najverjetnejši nosilec = premium naročnina (kandidat: FR-18 več vrtov/lokacij). **Konkretna izvedba je zdaj
  specificirana v FR-20 (zunanja licenca, ne Play Billing) — spodnje velja le, če bi se kdaj vrnila na Play
  Billing.** Google Play **service fee od 10 %** na prvi $1M/leto (od 30. 6. 2026, ZDA/EGP/UK), zdaj **LOČEN od
  billing fee** (5 %, samo za Play Billing) → neto računaj po `(cena − service fee − billing fee)`, ne samo −10 %.
  Naročnine = isto 10 %. Vredno preveriti **Apps Experience program** (znižane provizije za kakovostne ne-igre).
  **Tehnično:** IAP/naročnina = nov package izven `tech-stack.md §1` (`in_app_purchase`/RevenueCat) → najprej
  uskladi sklad; payout/Merchant + davčni setup v Play Console; premium **gating offline-first** (entitlement
  cache v drift, da plačnik dela brez signala). Glej spomin `tendask-monetization-planned`.

## Dnevnik napredka

> Agent tu dopisuje zaključene korake (datum · korak · commit hash). Najnovejše zgoraj.

- 2026-07-15 — **Matrika postavitve + refaktor entry korakov + on-device dimni test (`main`, pushano).**
  **(A) Matrika postavitve `test/layout/` (`850eb7b`).** Novo orodje proti tihim UI prelomom: vsak zaslon
  se izriše čez **viewport × locale × text-scale** (3 širine 320/360/411 × sl/en/de × 1.0/1.3 = 234
  kombinacij, 13 zaslonov) in lovi overflow + odrezan tekst. Bila je nedelujoča iz prekinjene seje (vseh
  234 »did not complete«); dokončana. **4 sistemski defekti harnessa:** (1) `File.readAsBytes()` (async) v
  `testWidgets` visi za vedno — ponarejen async zone ne izvede pravih `dart:io` future-jev → `readAsBytesSync()`;
  (2) `*StepBody` rabijo `Material` prednika → `home: Scaffold(body:)`; (3) task-detail bere
  `GoRouter.of(context)` v `build` → vbrizgan inerten `InheritedGoRouter`; (4) več izjem v enem frame-u
  pride agregirano kot »Multiple exceptions« → izčrpaj vse v zanki + loči `overflow:`/`error:`.
  **Ključno — detektor clipa je imel lažne pozitive:** `getMinIntrinsicWidth` pretirava za prosto-ovijajoč
  tekst (empirično potrjeno: deljena nem. beseda se na napravi ovije v 2 vrstici, ne odreže; Flutter razlomi
  tudi predolgo besedo). Pravilo: **prosto-ovijajoč tekst (`softWrap && maxLines==null`) se NIKOLI ne
  odreže**; odreže se le vrstično omejen → nov detektor preskoči prosto-ovijajoče, flag na `didExceedMaxLines`
  ali enovrstični `getMaxIntrinsicWidth > box`. To je **82 fantomskih prelomov zvedlo na 9 pravih**.
  **En pravi bug (`c29879c`):** appearance palete kartice so pri text×1.3 prekoračile (+12px), ker je
  `GridView.count childAspectRatio` zaklenil višino → `mainAxisExtent` izpeljan iz dejanskih text metrik.
  Matrika 234/234; on-device potrjeno (screenshot pri scale 1.3, brez overflowa).
  **(B) Pregled vseh velikih zaslonov + refaktor 4 entry/journal korakov (`9e14966`+`1527e77`+`d355125`+`829575d`).**
  Explore agent klasificiral vseh 15 datotek >250 vrstic (večina deklarativnih/že-vzorčenih — pusti).
  Izločena netestabilna logika (vsak svoj commit+testi; testi **778 → 820**): `subject_step` 412→369 →
  **`subject_picker.dart`** (filter/particija T3 relevance/dedup lastnih vrst/kategorije, po vzorcu
  `plant_picker_view`, 12 testov); `reminder_step` 495→461 → **`reminder_draft.dart`** (`ReminderDraft`:
  effectiveOffset/isDayBased/toSpec/canAdd dedup + `reminderOffsetTaken`, 15 testov); `type_step` 255→233 →
  **`type_ordering.dart`** (`sortTaskTypesByUsage` tie-break seed + `ensureSelectedVisible`, 7 testov);
  `note_form` 364→347 → **`note_date.dart`** (`noteDateOption`/`noteSelectedDate` z injiciranim `now`, 8 testov).
  `tasks_screen` je bil ŽE razrezan v 2. krogu — ne rabi nič.
  **(C) On-device dimni test entry flowa (staging debug, gost) — vse zeleno.** Vseh 5 korakov (vrsta→predmet→
  kdaj→opomnik→pregled→shrani) brez izjem v logcatu; potrjen `ReminderDraft` edit sheet (»Ob dogodku že
  dodano« dedup, živ preview, dodaj → 2 opomnika), »Naslednje: 22.7.« preview, in **opomnik se je dejansko
  sprožil** (cela veriga razpored→dostava, ne le UI). `tool/smoke.md` posodobljen (podroben entry scenarij +
  opomnik/exact-alarm + izbris + deploy USB-drop gotcha). **Nauka:** (1) za on-device VEDNO `tmp/steps.txt` +
  fiksni `& ./tool/adb_run.ps1` (allowlistan), NE `adb_ui.ps1` z različnimi argumenti (vsak = nov poziv);
  (2) USB pade sredi `deploy.bat` (2×/seja) → `flutter run` izstopi a build ni nameščen; robustneje
  `flutter build apk --debug --dart-define-from-file=dart_defines.staging.json` → `adb install -r`.

- 2026-07-14 — **Refaktor presentation plasti, 2. krog: zadnje tri velike datoteke (`main`, pushano,
  `efbf761`+`b3364fd`+`ad65de5`).** Zaprte vse tri postavke »nedotaknjeno« iz prejšnjega vnosa.
  Vedenje **nespremenjeno**; testi **493 → 544 (+51)**, `analyze` čist.
  Razrezano: `tasks_screen` 404→133, `when_step` 483→210, `journal_screen` 369→146,
  `month_calendar_view` 316→152.
  **`tasks/presentation/task_day_groups.dart` — grupiranje opravil po dnevih je zdaj na ENEM mestu.**
  Prej sta obstajali dve skoraj enaki pravili z **za dan zgrešeno mejo**: dashboard (`bucketPendingTasks`,
  `!day.isAfter(today+7)`) je opravilo čez natanko 7 dni štel med prihajajoča, seznam
  (`day.isBefore(today+7)`) pa ga je pokazal pod »Kasneje«. **Poenoteno na vključujočo mejo** (kot pravi
  komentar pri `kUpcomingWindowDays`) → 👤 potrjeno; edina namerna sprememba vedenja v tem krogu.
  `home_buckets` zdaj kliče `taskDayGroup`; `overdueDays` se je preselil sem (bil je podvojen inline v
  `_StatusBadge`). Poleg tega `buildTaskListItems` (sealed `TaskListItem` — konec `List<Object>` + casta)
  in `taskGroupLabel`/`taskStatusText`.
  **`entry/steps/when_rules.dart` — validacija ponavljanja, ki gejta gumb »Naprej«.** Živela je zapletena
  s `TextEditingController`-ji v stanju widgeta, zato so bile veje dosegljive le prek `WidgetTester`-ja in
  netestirane: interval `0` (polje `digitsOnly` ga **spusti**, pravilo `<1` ga zavrne), prevelika številka
  (`int.tryParse` → null), smet za **skritim** poljem (mode custom→weekly, odklopljena kapica) — ta ne sme
  blokirati. Zdaj čista `evaluateRecurrence(mode, intervalText, limited, countText)` → `(rule, valid,
  intervalInvalid, countInvalid, everyDays)`; widget samo riše (`entry/widgets/recurrence_picker.dart`).
  Tudi `whenPreset`/`dateForPreset` (preset je bil izračunan v getterju z `DateTime.now()`), `_withDay` je
  podvajal `combineDateAndTime`, `_Labelled` je bil lokalna kopija skupnega `FieldLabel` (razmik pod
  oznako se s tem spremeni za 1 px — 👤 potrjeno).
  **`journal/presentation/journal_timeline.dart` + `month_grid.dart`:** `journalEntries` (združi + filtrira
  + sortira), `groupEntriesByDay`, `journalEmptyMessage`, `journalDayLabel`, ter `tasksOnDay`,
  `taskCountsInMonth`, `preselectedDay` (`monthCells` preseljen sem). **Naslova dneva v dnevniku namenoma
  NISEM poenotil z `relativeDayLabel` z Domov:** obrazec opombe dovoli datum v prihodnosti, in tam se
  pravili razideta (dnevnik pokaže datum, `relativeDayLabel` bi rekel »danes«) → poenotenje bi tiho
  spremenilo vedenje. Trikrat ponovljeni `startOfDay(a) == startOfDay(b)` je dobil ime (`isSameDay` v
  `core/date_format`).
  **On-device dimni test (prod release APK):** seznam (sekcija DANES + značka), čarovnik korak »Kdaj« →
  tedensko → »Naslednje: 21. 7. 2026«, zaključek ponavljajočega opravila → naslednja ponovitev (dan+7)
  **pod TA TEDEN** (potrjena poravnana meja), dnevnik (skupina »Danes«), filter Opombe (»Ni opomb.«),
  mesečni koledar (»2 opravili ta mesec«, izbran današnji dan), prehod na tuj mesec (brez izbranega dneva).
  **Orodje: `tool/adb_run.ps1` + `tool/smoke.md`** — cel scenarij v **enem** zagonu, koraki v `tmp/steps.txt`
  so **napisi** (`taptext`), ne koordinate. Nauk: iz orodja `PowerShell` **ne zaganjaj ugnezdenega
  `powershell -File …`** — Claude Code takega ukaza ne validira in vpraša za dovoljenje pri *vsakem* tapu;
  poženi skript neposredno (`./tool/adb_run.ps1`).

- 2026-07-14 — **Refaktor presentation plasti: logika iz widgetov v čiste funkcije (`main`, pushano,
  `c39e70b`…`87df323`, 8 commitov).** Vedenje **nespremenjeno** (refaktor, ne redesign); merilo uspeha ni
  število vrstic, ampak **novo pokrita logika: 399 → 493 testov (+94)**, `analyze` čist.
  **Sedem zaslonov razrezanih:** `task_detail_screen` 913→170, `entry_screen` 708→501,
  `garden_plant_add_screen` 619→337, `home_screen` 578→175, `location_screen` 550→275,
  `appearance_screen` 523→103, `areas_screen` 424→196 (⏳ postavka iz prejšnjega vnosa zaprta).
  **Izluščeno (vsako s testi, ki prej niso bili mogoči):** `areas/presentation/garden_items.dart`
  (vrstni red vrta: brez-območja → tipi po `AreaType.values`; `areaSubtitle`),
  `tasks/presentation/task_detail_labels.dart` (oznake sredstev/opomnikov/statusa; sredstva zdaj prek
  obstoječega `formatSupplyQuantity`, ne ročno prepisanega `roundToDouble`), `core/date_format`
  `combineDateAndTime` (prestavitev opravila ohrani uro), `entry/entry_flow.dart` (`activeSteps`,
  `nextStep`/`previousStep`, `canLeaveStep`), `entry/entry_defaults.dart` (`nextFullHour`,
  `statusFromDate`, `shouldSeedReminder` — 4-pogojni guard je bil dobesedno prepisan dvakrat),
  **`entry/entry_save_spec.dart` (`resolveSave`) — najpomembnejše: pravila, ki knjižijo zalogo in brišejo
  pridelek (`keepSupplies` ob nenaloženem katalogu, `typeRecordsYield` ob menjavi tipa stran od harvesta),
  so bila doslej netestirana znotraj `_save()`**; `plants/presentation/plant_picker_view.dart`
  (`filterCatalog`, `splitByRelevance`, `pickerMembers` — sken »kaj je že v ciljnem območju« je bil
  podvojen v `build` in `_memberFor`), `home/presentation/home_buckets.dart` (koši danes/zamujeno/
  prihajajoče **po koledarskem dnevu, ne 24h oknu** — »včeraj ob 22:00« je zjutraj zamujeno),
  `auth/presentation/location_labels.dart`, `settings/presentation/palette_labels.dart`.
  **Plasti zaprte (`b602c1b`):** `accountRepositoryProvider` je živel v `data/` → preseljen v
  `settings/application/account_providers.dart`; `PlantMoveResult`/`ReminderSpec`/`TaskSubjectSpec` niso
  drift tipi, ampak besednjak repo API-ja → v koren feature-ja (`tasks/task_specs.dart`,
  `plants/plant_move_result.dart`, repozitorija ju re-exportata). **V `presentation/` ni več nobenega
  uvoza `data/…_repository.dart`**; edina zavestna izjema je `task_actions.dart` (akcijska plast, imenuje
  `TasksRepository` v podpisu). **On-device dimni test (staging release APK, čista namestitev, gost):**
  lokacija (iskanje »Kranj« → status z imenom kraja), Domov (ura vs. »Danes«), Vrt (BREZ OBMOČJA → VRT),
  dodajanje rastline, čarovnik (privzeta polna ura, opomnik zasejan, korak Sredstva preskočen), detajl
  opravila (**`⋯` meni, ki zdaj bere repo skozi `Consumer`** — podvoji/opravljeno delujeta), Videz
  (preklop palete + ponastavitev) — **brez izjem v logcatu**. Novo orodje: `tool/adb_ui.ps1` (tap/vnos +
  `uiautomator dump` + izpis napisov z `bounds` v enem ukazu). **Nedotaknjeno (kandidati za naslednjič):**
  `entry/steps/when_step.dart` (483, validacija ponavljanja), `tasks_screen.dart` (404, časovni koši),
  `journal_screen.dart` + `month_calendar_view.dart` (grupiranje po dnevih, verjetno podvojeno).

- 2026-07-14 — **vc14 pripravljen: prod migracije + on-device verifikacija sredstev + 3 UI popravki
  (`main`, pushano, `478d7c9`).** (1) **Migracije `0014`+`0015`+`0016` aplicirane na PROD**
  (`supabase db push --linked`) in verificirane z read-only sondo — **ledger IN dejanska shema**
  (`tmp/probe_0014_0016.py`). Prod je bil pri `0013`; manjkale so **tri** (ne dve, kot je trdil dnevnik —
  tudi `0014` task yield). Živi vc13 na Play je bil ves čas varen, ker je zgrajen **pred** supplies/yield
  commiti (`kSuppliesEnabled=false`, brez yield stolpcev; preverjeno s `git show <commit>:core/config.dart`).
  (2) **On-device verifikacija zavihka Vrt** (release APK proti prod) — segmenti, kontekstni FAB
  (Rastlina/Sredstvo/Recept), prazna stanja in grupiranje po kategorijah delujejo; našla je **3 napake**,
  vse popravljene in on-device potrjene: **`adc8631` `fix(theme)`** — tema je izbranemu čipu barvala le
  *ozadje* (`chipTheme.selectedColor = primaryContainer`), M3 pa besedilo izbranega čipa jemlje iz
  `onSecondaryContainer`, ki ga shema ni nastavila → ostal je M3 baseline in se bral kot **onemogočen**;
  fix = `secondaryContainer`/`onSecondaryContainer` v `_scheme()` → popravi **vseh 10 mest s čipi** naenkrat.
  **`c0ebdf4` `fix(i18n)`** — sl kategorija sredstev »Tretiva« → **»Škropiva«** (»tretiva« ni slovenska beseda).
  **`63e5985` `fix(areas)`** — območje brez opravil je v podnaslovu ponavljalo svoj **tip**, ki ga sekcijska
  oznaka že pove (»VRT / Vrt / Vrt«) → podnaslov zdaj pade nazaj na **število rastlin** (`plant_count(n)`
  slang plural + `no_plants`; podatek je že v `plantsByArea`, brez nove poizvedbe). `analyze` čist,
  **399 testov** (+1 widget). (3) **E2E potrjeno proti ŽIVEMU PRODU** (vnos prek aplikacije + read-only sonda):
  `supply.category` ✅, `task.yield_amount = 2.0 kg` ✅ (`0014`), recept z dvema sredstvoma ✅
  (postavke so **JSONB v `recipe.items`**, ločene tabele `recipe_item` NI), in ključno — **negativna zaloga
  `−450` gre skozi** (`task_supply.applied=true`, opravilo `done`, `supply_quantity_check` odstranjen) =
  `0016` dela; pred njo bi `23514` na `supply` **zaklenil cel sync** (supply se pusha pred task).
  (4) **AAB `1.0.0+14` zgrajen, a NAMERNO ZADRŽAN** — Google pregleduje prijavo za produkcijski dostop
  in pregledovalci testirajo prek zaprtega tira; sredstva so v vc13 izklopljena, torej bi šla nova
  funkcija pred pregledovalce brez testerskega cikla. Upload po Googlovi odločitvi.
  ⏳ Odprto: razdelitev `areas_screen.dart` (>300 vrstic).

- 2026-07-01 — **Sredstva UX + preselitev v zavihek Vrt (`main`, merge `93d9d3a`).** (1) **UX koraka
  Sredstva pri opravilu** (commit `c4ab4a5`): keyboard-safe `add_supply_to_task_sheet` (drseč seznam +
  pripeta spodnja vrstica Količina[enota]+Dodaj nad tipkovnico prek `viewInsetsOf`), izbira = toggle
  (ponoven tap odznači) z močnejšo oznako (primaryContainer + krepko + `check_circle`), zaloga+»malo«
  v vrsticah, iskanje ko >8; progress bar v vnosu izloči »Pregled« iz pik. (2) **Preselitev zalog/receptov
  iz Nastavitev v zavihek Vrt** (commit `7591611`): en `SegmentedButton [Območja | Sredstva | Recepti]`
  (kot Dnevnik), telo se zamenja v istem zaslonu; samostojni `/supplies` zaslon **upokojen**, telesi
  ekstrahirani v `supplies/presentation/widgets/supply_list_views.dart`. **Enoten kontekstni razširjeni
  FAB** (Rastlina/Sredstvo/Recept) — preseljen iz `main_shell` v `areas_screen`, da pozna segment
  (prej je na Zaloge/Recepti napačno dodal rastlino); območje ostane tih spodnji gumb; urejanje/izbris
  prek tap vrstice (ševron namig). (3) **Izčrpen 5-agentni pregled + popravki:** harmonizirana
  terminologija sredstev (**sl → »Sredstva«**, **de → »Mittel«**; »zaloga/Bestand/stock« ostane le za
  stanje), skupni `formatSupplyQuantity` namesto 4 kopij, odstranjeni osiroteli i18n ključi `settings.*`.
  Koncept §Zaloge + wireframe `08-supplies.html` posodobljena. `analyze` čist, **398 testov** zeleno.
  **NEPUSHANO.** ⏳ on-device verifikacija napisov (USB je padel); PROD migraciji **0015+0016 še ne**
  deployani (pred prod releasom `supabase db push`). Odprto: razdelitev `areas_screen.dart` (424 vrstic >300).

- 2026-06-30 — **Beleženje sredstev v celoti (`feat/supplies-tracking`, worktree `../tendask-supplies`).**
  Tri faze: (1) **ponovni vklop** `kSuppliesEnabled=true` (korak v čarovniku + sekcija Nastavitve) +
  manjkajoč **izbris zaloge** v edit sheetu (`DestructiveButton`) — commit `392e707`. (2) **Kategorije**:
  nov enum `core/supply_category.dart` (Gnojila/Tretiva/Oprema/Drugo) + `Supply.category` (drift **v13**
  + Supabase **`0015`** additive, default `'other'` + CHECK), `remote_mappers` push+toleranten pull,
  edit sheet izbira + grupiranje na zaslonu 08 (`SectionLabel`) — commit `38dc1a1`. (3) **Recepti**:
  `recipe_item.dart` (ročni model + tolerantni parse/encode kot `Recurrence`), `RecipesRepository` +
  providerji (recipe tabela je bila že ožičena v sync), zavihek Zaloge|Recepti na zaslonu 08,
  `recipe_edit_sheet` + `recipe_picker_sheet`, gumb »Uporabi recept« v koraku Sredstva (predizpolni).
  Wireframe `08b-recipes.html` + posodobljen `08-supplies.html`/`index.html`, koncept §213/§7.16.
  **3 neodvisni agentski pregledi + hardening:** (a) `.when(error:)` na seznamih, `try/catch` ob
  shranjevanju, recept na izbrisano sredstvo (placeholder + picker filtrira); (b) **neviden odpis
  zaloge** ob menjavi tipa na ne-trošeč → gating v `entry_screen._save` (`keepSupplies`, varno ob
  neznane tipu); (c) **BLOKER: pre-poraba → negativna zaloga → Supabase CHECK zavrne push → fail-fast
  zaustavi cel sync.** Odločitev (uporabnik): dovoli deficit — migracija **`0016`** spusti
  `supply_quantity_check`; shrani točno (revert simetrija), UI clampa prikaz na `max(0,qty)` + »malo«.
  analyze čist · **357 testov** (dodani: recept→odpis, pre-poraba→negativa+revert, prazni-specs
  reconcile, kategorija default/pull-toleranca). **Preštevilčeno zaradi main-ovega `0014_task_yield`
  (drift v12): najini migraciji sta `0015`/`0016`, drift **v13** (v12 rezerviran za task_yield ob
  merge).** ⏳ **`db push` migracij `0015`+`0016` na prod** (ločen deploy korak) + merge main. Ročna
  on-device: menjava tipa ne odpiše; realna v12→v13 nadgradnja.
- 2026-06-30 — **FR-5: ponavljanje opravil (`feat/fr5-recurrence`, commita `06bab04` feat + `feebfed`
  fix-ui; pushano, PR čaka).** Materializiraj-naslednjo-ob-dokončanju. Nov `data/recurrence.dart`
  (`Recurrence{everyDays, remaining}` + tolerantni `tryParse`/`encode`/`next` + čisti DST-varni
  `nextOccurrenceDate`); nova nullable `task.series_id` (drift **v11** + Supabase **`0013`**, additive;
  `0013` apliciran na **staging**, prod čaka). `complete()` rodi otroka v isti transakciji (deduje
  subjekte/opomnike/series_id), `updateTask` ureja recurrence, `stopRecurrence`, `duplicate` strip,
  revert blokada (D1). UI: picker v `when_step` (Dnevno/Tedensko/Po meri + št. ponovitev=`remaining` min 1
  + »Naslednje: <datum>« + validacija blokira »Naprej«), `RecurringBadge`, vrstica na Pregledu/detajlu,
  »Ustavi ponavljanje« v ⋯, toast prek `showTopToast`. **Semantika (potrjeno z uporabnikom): »ponovitve«
  = `remaining` neposredno (1 = trenutni + 1 = skupaj 2), NE »skupaj«.** **Nauki:** (a) `ValueKey(recurrence)`
  na stateful pickerju ga ob vsakem emitu uniči/poustvari → zbris polja je skakal na »Dnevno« (odpravljeno
  brez key); (b) `SegmentedButton` privzeto kaže ✓ na izbranem → krade širino, besedilo prebija → povsod
  `showSelectedIcon: false`; (c) `×` enota je izgledala kot gumb za brisanje → »krat«. Review: 4-dimenzijski
  multi-agentni + adversarna verifikacija; vse potrjene najdbe popravljene (revert-gate `status==done`,
  `updateTask` null-check, 4× `!`→lokali, magic width→const, observability log). analyze čist · **345 testov**.
- 2026-06-29 — **FR-16: re-engagement opomnik za neaktivne uporabnike (`main`, commit `d29fd9d`).**
  Lokalni dead-man's-switch: nova čista funkcija `journal_nudge_schedule.dart` (`journalNudgeFireTimes`,
  testabilna) + `JournalNudgeCoordinator` (vzorec `_running`/`_dirty` + debounce kot reminder_coordinator).
  **Ključni vpogled — decay brez fire-callbackov:** namesto enega znova-zakoličenega opomnika zakoličimo
  fiksno **verigo dveh** (`kJournalNudgeDayOffsets=[7,28]` ob 17:00); vsak dotik (start/zapis task ali
  note/`AppLifecycleListener.onResume`) prekliče oba in ju zakoliči naprej → aktiven uporabnik ju nikoli
  ne vidi, tih dobi dva in nato mir = guardraili (kapica 1×/7d, decay 7→+21→stop, reset) brez stanja v
  bazi. Ločen kanal `journal_nudge` (inexact, brez exact-alarm dovoljenja) + rezervirani **negativni**
  ID-ji `[-201,-202]` (reminder hash je vedno ≥0 → brez trka). **Tester-najdba (kritična):**
  `reminder_coordinator` je na **dveh** mestih (orphan-sweep + master-off veja) klical cancel čez *vse*
  pending ID-je → bi pobrisal nudge, oba coordinatorja pa poslušata `db.profiles` → race; popravljeno z
  izločitvijo `kJournalNudgeNotificationIds` na obeh mestih. + defensivni past-time guard (debug-skrajšava/
  DST). A/B segment prek nove `TasksRepository.totalCount()`. i18n en/sl/de (`journal_nudge.*` +
  `notif_settings.type_journal_nudge`). Code review + neodvisen security review (privacy-by-design potrjen:
  generična kopija, nič PII na lock screenu). Testi (+12): čista funkcija (9) + settings round-trip/opt-out
  (3). analyze čist, 289/289. ⏳ Preostane: on-device verifikacija (negativni ID-ji + sproženje/preklic;
  predlog: začasni skrajšani offset).
- 2026-06-28 — **FR-17: haptični odziv ob ključnih akcijah (`feat/fr17-haptics`).** Nov
  `lib/core/haptics.dart` z `AppHaptics` (3 statične metode = `light`/`medium`/`heavy`), edina točka
  preslikave jakosti in bodočega stikala. Načelo: haptika se sproži, **ko se dejanje zgodi**, ne ob tapu
  — zato je `mediumImpact` na uspešni save-poti vsakega obrazca (entry `_save`, area/plant/note), ne v
  skupnem `SaveBar` (ki ne ve za uspeh in bi utripnil ob neuspeli validaciji ali `PlantMoveResult.duplicate`).
  `lightImpact` na vseh 4 complete-točkah (swipe prek skupnega `TaskSwipe`, seznam-meni, detajl-gumb,
  detajl-meni). `heavyImpact` v `showConfirmDialog` ob `destructive && potrjeno` — en chokepoint pokrije
  vse izbrise/clear/odjavo (preverjeno: v `lib/` je en sam `AlertDialog`). Brez nove dependency/sheme/
  i18n; `HapticFeedback` (vgrajen) ne rabi `VIBRATE` dovoljenja, OS-onemogočena vibracija = no-op.
  Testi (+6): jakostna preslikava prek mock platform kanala (3) + branža `showConfirmDialog` confirm/
  cancel/non-destructive (3). analyze čist, 274/274.
- 2026-06-28 — **FR-13: indikator okolja STAGING/OFFLINE (`feat/fr13-env-banner`).** Dev-only kotni
  `Banner` prek `MaterialApp.router` `builder` (`_envBanner` v `lib/app/app.dart`): na ne-produkcijskih
  buildih izriše `STAGING` (oranžen) / `OFFLINE` (siv), na produkciji vrne otroka brez ovoja → tester
  na Play nikoli ne vidi traku. Ponovno uporabi obstoječ `kEnvLabel` (`core/config.dart`); brez nove
  dependency, sheme, i18n ali testov (niz dev-only). `Colors.orange/grey` = upravičena dev-only izjema
  od »barve prek teme«. analyze čist.
- 2026-06-28 — **FR backlog oštevilčen do FR-16 + FR-14/15/16 zapisani.** Trije samostojni
  feature-request dokumenti dobili številko (analitika=FR-14, in-app update=FR-15, re-engagement=FR-16);
  zapisano v glavah `.md` + backlogu. `in-app-update.md` prej neuvožen, zdaj sledjen (commit `485a620`).
- 2026-06-24 — **Opozorilo »opomniki bodo tihi« + verifikacija 0011 + FR-13 (na `main`).** (1) Nov
  reaktivni banner `ReminderSoundBanner` (`core/notifications/reminder_audio.dart` + Android EventChannel/
  BroadcastReceiver) opozori, ko obvestila ne bodo zvenela (glasnost obvestil 0 ali tih profil). **Diagnoza
  pri uporabniku:** »ni zvoka« = `STREAM_NOTIFICATION` glasnost na 0 (Samsung ima ločen drsnik), **NE bug** —
  kanal (HIGH+zvok), točni alarm in vibracija delujejo (potrjeno prek `adb dumpsys audio/alarm/notification`).
  Gumb »Vklopi zvok« dvigne glasnost (`ADJUST_RAISE`) + pokaže sistemski drsnik; banner izgine **takoj**
  (live stream prek `VOLUME_CHANGED`/`RINGER_MODE_CHANGED`). Topla amber paleta (`AppColors.warnSoft`) za
  vidnost na temni temi. Tri površine: nastavitve opomnikov, priming sheet, korak opomnika ob vnosu opravila.
  analyze čist, `compileDebugKotlin` ✅, testi 232 + 10 novih. (2) Migracija `0011` (created_at/
  server_inserted_at) verificirana na **PROD + staging** (ledger + dejanski stolpci 14/14). (3) **FR-13**
  (indikator okolja) napisan kot feature request (`docs/feature-requests/env-banner.md`), ni implementiran.
- 2026-06-16 — **M11.16 (V2 agregati) + zaklep grantov + push i18n fix + pregled M11.**
  **(1) M11.16 — V2 agregatne tabele + nočni cron** (migracija `0008`): štiri tabele
  (`activity_recent/season/frequency`, `bucket_population`), `eligible_user` matview (anti-junk
  X/N/M), `agg_event` pogled (COALESCE `task.agg_context` ali trenutni profil → H3/koš),
  `agg_refresh_all()` (security definer, prazen `search_path`) + `pg_cron` (`30 2 * * *`), RLS
  k-anonimnost (`distinct_users >= k_privacy()`), grant SELECT-only za anon/authenticated. Teče
  tiho brez UI — zgodovina dokončanj se kopiči že od M11.2. *Commit:* `feat(db): V2 agregatne
  tabele + nočni cron`. **(2) Zaklep grantov** (`0009`): dokončan namen 0007 — eksplicitni
  granti na vseh klient-dostopnih M11 tabelah (reproducibilna migracija; živa baza je skrivala
  manjkajoč grant). *Commit:* `fix(db): zakleni grante na M11 tabelah`. **(3) push i18n fix**
  (M11.12 dokončanje): `_shared/push_i18n.ts` je imel prazen `kTitles {}` (generator ni bil
  pognan po M11.13) → vsak push je padel na generičen fallback namesto lokaliziranega naslova
  predloga. Regenerirano prek `tool/gen_push_i18n.dart` (201 naslovov, 67×sl/en/de); vseh 63
  oddanih `messageKey` se razreši; Deno 96/96, deployano na živ Supabase. *Commit:* `fix(engine):
  regeneriraj push_i18n naslove`. **(4) Pregled M11** (5 vzporednih agentov po fazah A–E):
  potrjeno ujemanje dokumentacije in kode za M11.1–M11.16; M11.17–21 (ostanek faze E)
  neimplementirano kot načrtovano (R6 v motorju je le forward-ref). Edina najdena vrzel = prazen
  push i18n (popravljen zgoraj).
- 2026-06-16 — **M11.14 follow-up — »Načrtuj« odpre obrazec + nav crash fix (on-device).**
  Med živo preverbo razkrita dva problema: **(1) UX** — »Načrtuj« je tiho ustvaril opravilo s
  predlaganim datumom brez izbire termina in brez vidne potrditve; zdaj odpre čarovnik Novo
  opravilo, predizpolnjen (tip/rastlina/predlagani datum), odprt na koraku »Kdaj«; šele
  **shranjeno** opravilo označi predlog `planned` (preklic ga pusti na pasu). `EntryScreen`
  dobi `initialTaskTypeId/Plant/Area` in vrne id nastalega opravila prek `context.pop(taskId)`;
  koncept §0.5 posodobljen. **(2) Crash** — tap na vnos v »Pretekli predlogi« je sprožil
  navigator `keyReservation` assertion (rdeč zaslon): zaslon živi NAD shell-om, zato push
  gnezdene `/tasks/:id` (task-detail) podvoji shell page key. Dodana top-level sestra
  `/task/:id` (`task-view`); zgodovina + plant-detail (oba zunaj shell-a) jo uporabljata,
  in-shell klicalci ostanejo na `task-detail`. Oba band Plan testa predelana (router stub),
  history test na `task-view`. analyze čist, 241/241. *Commit:* `feat(suggestions): »Načrtuj«
  odpre predizpolnjen obrazec + fix nav crash`
- 2026-06-15 — **M11.14 — E2E veriga paradižnika potrjena na napravi + poliranje.** Cel krog
  §0.1 v živo (SM A536B, dev `exogenus@gmail.com`): `start_seedlings` done (−16 dni) → ročni
  engine invoke → **R7 emitira `prick_out`** (score 2, okno +14..21) → predlog se pull-a na pas
  na Domov → **FCM push prispe** (kanal `suggestions`) → Načrtuj → waiting opravilo → ponovni tek
  **NE podvoji** (dedup-planned straža + cooldown). **GLAVNA NAJDBA:** skrivnost
  `FCM_SERVICE_ACCOUNT_JSON` **nikoli ni bila nastavljena** na deployani funkciji (`secrets list`
  je pokazal le privzete) → push je tiho padal (per-user error, batch se nadaljuje). Provisionirano
  iz Firebase service-accounta (projekt `tendask-app`). **Robustnost (popravek):** push ovit v
  `try/catch` — `fcmProjectId()` throw (manjkajoča skrivnost) je prej obšel `.catch` in zrušil
  uporabnikov tek **po** emitu (engine_run se ni zapisal); zdaj FCM napaka graciozno preskoči push,
  tek se dokonča in token **ne** ponulli (krivda = naša konfiguracija, ne mrtva naprava). **Error
  sink:** `_shared/report.ts` (`reportError`, `evt:"engine_error"`, stage) čez 6 mest v
  index.ts/weather.ts — eno mesto za Sentry DSN, queryable v log drainu. **UI popravek:** modalni
  sheet-i predloga (⋯ akcije + »že opravljeno« datum) dobili `useRootNavigator:true` — prej je
  centrirani FAB shell-a prekrival sheet. Deno 96/96, app rebuild+install na napravo. **Parkirano
  (must-do):** slovenska sklanjatev `{subject}` v sporočilih (npr. »Od setve paradižnik« → rabi
  rodilnik »paradižnika«; robustno le z nominativ-oznako čez vseh ~61 sporočil); TENDASK-6
  RenderFlex (nereproduciran). **Test-nauk** (v `docs/m11/e2e-runbook.local.md`): prihodnje-datiran
  `updated_at` v ročnih reset PATCH-ih pokvari `last_pulled_at` watermark naprave → realni `now()`
  emiti se ne pull-ajo (le testni artefakt; motor v produkciji vedno `now()`).
  *Commit:* `fix(suggestions): modalni sheet nad FAB (useRootNavigator)`,
  `feat(engine): FCM robustnost + strukturiran error sink (M11.14 e2e)`
- 2026-06-15 — **M11.15 — celovita test suite motorja v CI.** GitHub Actions ima zdaj dva joba:
  obstoječi `ci` (Flutter: pub get → slang → build_runner → analyze → test) + nov `engine`
  (`denoland/setup-deno@v2` → `deno test supabase/functions/`). 96 Deno testov (signali, pravila
  R1–R5+R7, straže a–h + §G kode, cevovod/dedup/rank/determinizem, housekeeping 2a–2e, vreme) +
  Flutter testi predlogov (repo/band/history/text/i18n) in klime tečejo na CI. Pokritost potrjena:
  vsak implementiran R + vsaka straža ima ≥1 test (R6 = Faza E, le forward-ref). README v
  `supabase/functions/` dokumentira lokalni zagon + opozorilo, da `deno check` z root-a pade zaradi
  import-mapa v `smart-engine/deno.json` (config discovery, ne tipska napaka — tipe preverja
  `deno test`). Lokalno: 96/96 Deno zelenih. *Commit:* `test(engine): celovita test suite motorja v CI`
- 2026-06-15 — **M11.13 + M11.13b — pas predlogov na Domov + zaslon Pretekli predlogi.**
  **M11.13:** `SuggestionRepository` (`watchActive` z LEFT join na rastline/območja + filter
  `status='new'`/valid/ne-deleted; `dismiss`/`markPlanned`/`markLogged`) + providerji;
  `SuggestionBand` + kartica na Domov (max 3 po score), gumba Načrtuj/Opusti, ⋯ akcijski sheet
  (»Že opravljeno« z mini-sheetom datuma → DONE task + `agg_context`; »Ne predlagaj več« =
  dismiss forever; »Te rastline nimam več« = confirm + soft-delete subjekta), deep-link
  highlight; i18n katalog `suggestions.*` (en/sl/de — 67 naslovov + akcije + disclaimer); widget
  + repo testi. *Commiti:* `feat(suggestions): repozitorij + providerji predlogov`, `feat(i18n):
  katalog sporočil predlogov`, `feat(home): pas pametnih predlogov z Načrtuj/Opusti`.
  **M11.13b:** zaslon Pretekli predlogi (`watchHistory`, terminalni statusi s čipi, tap planned
  → opravilo prek `task-view`, vstop ⋯ + Nastavitve, retencija 365 d v housekeepu); wireframe
  `23-suggestion-history.html` (skica pred zaslonom); widget testi. *Commit:* `feat(suggestions):
  zaslon preteklih predlogov z odzivi uporabnika`.
- 2026-06-18 — **FR-12: oznaka kraja pri vremenu (`feat/fr12-place-label`).** Vremenska kartica Domov
  zdaj pokaže ime najbližjega kraja (📍), reverzno geokodirano iz centroida celice `h3_r7`. Vir =
  **OSM/Nominatim reverse** (uporabnikova izbira; Open-Meteo geocoding je samo naprej). Koda (core/
  location): `ReverseGeocodingClient` (tanek Dio klient + `pickPlaceName` izbira village/town/city iz
  `address`; User-Agent po Nominatim usage policy), `PlaceLabelRepository` (cache v `local_flags`, ključ
  `{cell,label,lang}`), `placeLabel(lang)` provider (cache-hit brez mreže / fetch+cache / offline →
  zadnja znana oznaka **le za isto celico**, da premaknjen vrt ne kaže napačnega kraja); klic le ob
  spremembi celice ali jezika. UI: `_PlaceHeader` (Icons.place_outlined, muted) na vrhu
  `CurrentWeatherCard`; brez lokacije ni oznake (generično vreme). Testi: `pickPlaceName` parse +
  cache repo + provider (hit/miss/offline/no-name) — **219/219 zelenih, analyze čist**. Pravno: nov
  tretji ponudnik → privacy-policy `.md`+`.html` v1.2 (SL/EN/DE), play-data-safety v1.2 (approximate
  location ostane Shared, doda se prejemnik OSM/Nominatim). **Ostane 👤:** redeploy privacy v1.2 na
  tendask.com; on-device verifikacija (nastavi lokacijo → oznaka kraja na kartici). Pomislek glede
  skale (parkiran): javni Nominatim ima usage policy (1 req/s, brez bulk) — nizko-volumski klic +
  cache je znotraj politike; ob rasti volumna pot LocationIQ/self-host.
- 2026-06-18 — **FR-8: lokacija prek centroida `h3_r7` (`feat/fr8-h3-centroid`).** Surove koordinate
  se ne hranijo več (niti device-local); vreme + post-sign-in routing bereta **centroid celice**
  `cellToLatLng(profile.h3_r7)`. Štirje code commiti: (1) `cellCentroid` helper + k-prefiks res
  konstante (`h3_cells.dart`, uporablja `cellToGeo` — ne `cellToLatLng`, h3_common 0.7.0 API); (2)
  koordinatno-prosti `LocationRepository` + centroid `gardenLocation` provider, ki bere **eno
  profilno vrstico brez userId filtra** (lokalna baza ima vedno eno — izogne se ne-reaktivnemu
  `authServiceProvider.userId`); (3) routing počaka na **prvi pull** (5 s timeout + fallback na
  lokalno celico), ker `clearUserData` ob odjavi izbriše profil → `start()` zdaj vrne future
  (BUG-002 fix); (4) drop `device_location` (drift v8→v9, v6 createTable → raw SQL), `ACCESS_FINE_LOCATION`
  odstranjen (COARSE zadošča). Testi: h3_cells (fake H3 — FFI se ne naloži v host testu), location_repo,
  post_sign_in_navigation (5 scenarijev), migration v8→v9; **203/203 zelenih, analyze čist.** Plus
  doc/pravno (commit 5): privacy-policy `.md`+`.html` v1.1 (SL/EN/DE — koordinate se ne shranijo,
  Open-Meteo dobi centroid), play-data-safety v1.1 (precise→ni zbran, approximate→Shared), koncept
  §7.7/§7.10, tech-stack §5, play-console-status. **Ostane 👤:** Play Data Safety obrazec + redeploy
  privacy v1.1 na netlify; on-device verifikacija (odjava→prijava ne pokaže lokacije).
- 2026-06-16 — **FR-11: varnost prijave / OTP hardening (`feat/auth-hardening`).** Dva commita
  (`9e54e4e`, `afbc4dd`). **Pure logika** (`features/auth/data/`): `email_validation.dart` =
  format check (pragmatičen regex + RFC 5321 dolžinske meje) + `suggestEmailFix` did-you-mean prek
  Damerau-Levenshtein (transpozicija = 1 → ujame `gmial`/`hotmial`) nad kuriranim seznamom domen
  (vključno SI: siol.net/telemach.net/t-2.net/amis.net); prag 1, ali 2 za domene ≥9 znakov.
  `email_domain_checker.dart` = DoH (`dns.google/resolve`) z injektiranim resolverjem (testabilno),
  MX→A/AAAA fallback (RFC 5321 implicitni MX), **fail-open** — `DomainVerdict.missing` LE ob NXDOMAIN
  ali NOERROR-brez-MX/A/AAAA, vse nejasno = `unknown`; pošlje le domeno (ne local dela). **Zaslon**
  (`email_login_screen`): neveljaven format → napaka+predlog; typo → »Ste mislili …?« gate (tap
  popravi, 2. poskus z istim potrdi); pred sendom DNS gate (blokira le `missing`); po sendu 60 s
  resend cooldown (`Timer.periodic`, počiščen v dispose). Konstanti `kOtpResendCooldown`/
  `kDnsCheckTimeout` v `config.dart`; i18n sl/en/de. **Testi:** 16 unit (validacija+checker) + 4
  widget (format/typo/domain-block/cooldown); analyze čist, 186/186. **Odprto:** privacy policy
  omemba DoH (domena→dns.google) ob bodoči objavi; opcijsko persistentne urne kapice (zdaj server-side).
- 2026-06-16 — **FR-9: privzeto območje »Vrt« (`feat/vrt-area`).** Nov `AreaType.garden`, postavljen
  **prvi** v enumu (UI vrstni red = vrstni red deklaracije; reorder varen brez migracije, ker drift
  `textEnum` shranjuje ime in `remote_mappers` bere tolerantno po imenu). Ikona 🌻 + labela; i18n
  `type_garden` + `default_garden_name` (Vrt/Garden/Garten) v sl/en/de. **Auto-seed** privzetega
  »Vrta« ob zagonu prek novega `GardenSeedService` (`features/areas/data/`): območje + enkratni flag
  atomarno v transakciji (rollback ob napaki → ni dvojnega seeda); hook v `main.dart` po nastavitvi
  jezika, pred syncom, ovit v `try/catch` (seed ni esencialen za boot). **Seeded flag v lokalnih
  prefs** (`local_flags`, vzorec `onboardingSeen`), NE »if missing« → **izbris drži**. Odstopanje od
  načrta (flag v profile/synced) zaradi deljenega živega Supabase + vzporednih M11 migracij — gl.
  FR-9 backlog opombo. Picker vrstni red: `watchAll()` zdaj sortira po `(AreaType.index, name)` —
  garden prvi povsod (ne le v seznamu, tudi task-entry picker), v vseh jezikih (prej po imenu →
  »Vrt« v sl proti koncu). Testi: seed enkrat / ne po izbrisu + widget »garden prvi« + watchAll
  vrstni red; 165/165 zeleni, analyze čist. **Večagentni code+security pregled je odkril BLOCKER:**
  živi Supabase `area_type_check` (0001) ni vključeval `garden` → seedani »Vrt« bi ob pushu sprožil
  23514 in fail-fast push bi zaklenil cel sync prijavljenega uporabnika. Popravljeno z migracijo
  `0010_area_type_add_garden.sql` (živi ledger ima 0005–0009 iz M11, zato 0010). **Aplicirano na
  živi DB 2026-06-16** prek poolerja (`db push` blokiran zaradi branch divergence — remote ima
  0005–0009, ki jih ta branch nima kot datoteke; direkten SQL kot `apply_catalog.py`; preverjeno z
  `pg_get_constraintdef`). **On-device verificirano** (SM A536B, debug): seed ustvaril »Vrt«
  (type=garden, user=local, pending), flag `default_garden_seeded=true`, app brez crasha (logcat
  čist). Tudi **varnostni popravek:** `android/app/google-services.json` dodan v `.gitignore`
  (vsebuje projektne ključe; ni bil sledjen ne v zgodovini, a tudi ne ignoriran → zdaj ignoriran).
  *Commiti:* `feat(areas): dodaj AreaType.garden...` (`e6c80cc`) + `feat(areas): auto-seed
  privzetega »Vrt« območja...` (`316f5b2`) + `fix(areas): picker uredi po AreaType...` (`5241d64`) +
  `fix(db): razširi area_type_check...` (`bd41913`) + roadmap (`0e04815`, `99738d6`).
- 2026-06-09 — **i18n: `base_locale` sl → en (privzeti/fallback + Play default).** App že sledi
  jeziku telefona (`useDeviceLocale`), a je za **nepodprte** jezike padel nazaj na slovenščino. Zdaj
  `slang.yaml base_locale: en` → fallback = **angleščina** (univerzalno); SI/DE naprave še vedno
  dobijo svoj jezik, le tujci ne dobijo več slovenščine. Posledično je **default jezik Play listinga
  = angleščina**, SL+DE = prevoda. **sl ostaja jezik ciljnega trga + vir wireframov** (vsebinsko
  izhodišče, ne tehnični base). slang regen (`dart run slang`); testi že eksplicitno postavljajo
  `AppLocale.sl`, zato niso prizadeti. Posodobljeni: `slang.yaml`, `CLAUDE.md` (i18n razdelek),
  `docs/go-live/*` (EN default). *Commit:* `chore(i18n): base_locale en (default/fallback) + go-live EN default`
- 2026-06-09 — **9.5 priprava: politika zasebnosti + Data Safety + go-live materiali.** Politika
  zasebnosti (SL/EN/DE, `docs/legal/privacy-policy.md` + `.html`) **objavljena na
  `https://tendask.com/privacy`** (Cloudflare Pages); Data Safety mapiranje (`docs/legal/play-data-safety.md`,
  ključ: precise location = Collected+Shared(Open-Meteo)+Ephemeral); svež podpisan AAB zgrajen+verjeven
  (CN=Gorazd Veselič); go-live plan + store listing + content rating + grafika (icon-512,
  feature-graphic 1024×500) v `docs/go-live/`. Play razvijalski račun ustvarjen (osebni, »Tendask«) —
  čaka preverjanje identitete. *Commiti:* `docs: politika zasebnosti … + Play Data Safety` (`1268676`),
  `docs: go-live plan + store listing … + grafika` (`c5e87cf`)
- 2026-06-09 — **FIX: aplikacija obtiči na splash (release).** Sentry je javil
  `PlatformException(invalid_icon: ic_stat_notify could not be found)` iz `NotificationService.init`
  → `initialPayload()`, kar je **await-ano** v `_bootstrap` PRED `runApp()` → native splash obvisi za vedno.
  **Dva ločena popravka:** (1) **odporen bootstrap** — `initialPayload()` + `reminderCoordinator.start()` v
  `try/catch`; obvestila niso esencialna za zagon, zato napaka (ikona/timezone/plugin) ne sme več preprečiti
  `runApp` (degradira gracefully, poroča v Sentry). (2) **PNG ikona obvestila** — status-bar ikona je bil
  **vektor** (`ic_stat_notify.xml`); `flutter_local_notifications` ikono razreši prek
  `getResources().getIdentifier(...,"drawable",...)`, kar pri vektorjih v določenih build konfiguracijah vrne
  0 → `invalid_icon`. Zamenjano z belo silhueto brand znaka (`logomark-white.svg`) renderiran v 5 density
  bucketov (`drawable-mdpi`…`xxxhdpi`, 24→96 px prek sharp); vektor zbrisan. **On-device potrjeno (release
  APK, SM RZCT70XGC5P): app gre čez splash naravnost na Domov, brez `invalid_icon`.** **Stranski nauk
  (release login):** Google sign-in na release buildu zahteva, da je upload-key SHA-1
  (`62:CF:B4:…:2C:F9`) registriran kot dodaten **Android OAuth client** (`app.tendask`) v Google Cloud — en
  client = en package+SHA-1, zato nov client poleg debug; koda/`serverClientId` (Web client) se NE spremeni.
  Play kasneje rabi še Play App Signing SHA-1. *Commit:* `fix: app obtiči na splash – odporen notification bootstrap + PNG ikona`
- 2026-06-09 — **9.7 — GDPR: izvoz podatkov + izbris računa.** **Izvoz:** `AppDatabase.exportUserData()`
  zbere vse uporabnikove tabele (profile/area/user_plant/task + task_subject/reminder/note/supply/recipe/
  task_supply) v JSON-serializabilen `Map`; **izpusti `device_location`** (surove koordinate nikoli ne
  zapustijo naprave — le H3 celice iz profila) + interni `sync_status`. `AccountRepository.writeExportFile()`
  zapiše JSON v začasno datoteko; Nastavitve odprejo sistemski share sheet prek **`share_plus ^13.1.0`**
  (nov paket, tech-stack §1; `share_plus 12` je v konfliktu z `package_info_plus 10` na `win32` → 13.1).
  **Izbris računa:** `showConfirmDialog(destructive)` → `AuthService.deleteAccount()` (RPC `delete_account`
  → `signOut`) + `clearUserData()` → onboarding; gost = samo lokalni izbris (ni oblačnega računa). Migracija
  **`0004_delete_account.sql`** — `SECURITY DEFINER` RPC briše le `auth.uid()` (cascade iz `0002` počisti
  oblak), `grant execute` samo `authenticated`, `search_path` prazen (klient nima service-role ključa, zato
  RPC namesto admin API). **Aplicirano prek `supabase db push`.** Odstranjen mrtev `settings.coming_soon`.
  +2 testa (izvoz vključi uporabnika; nikoli ne razkrije koordinat). analyze čist, 159/159. **On-device
  preverba (share sheet + izbris) = naslednjič.** *Commit:* `feat: GDPR izvoz + izbris računa`
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
