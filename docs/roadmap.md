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
   (Wikidata/GBIF) = ločen ne-blokirajoč tir kasneje.
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
| **M5** | Supabase zaledje | Projekt + shema + RLS | `[ ]` |
| **M6** | Sync servis | Ročni push/pull, LWW, povezljivost | `[ ]` |
| **M7** | Auth + H3 | Anonimno + linkanje + lokacija/H3 na napravi | `[ ]` |
| **M8** | Lokalna obvestila (plast A) | Opomniki + deep-link + zasloni 19–22 | `[ ]` |
| **M9** | Polish + monitoring + Android release | Sentry, ikona/splash, neskladja, Play test | `[ ]` |
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
- [ ] **5.3 — RLS politike.** Uporabniške tabele `user_id = auth.uid()`; katalog javno-bralni; CASCADE ob izbrisu računa. *Commit:* `feat: RLS politike`
- [ ] **5.4 — Preverba.** Ročni insert/select prek client proti testnemu uporabniku. *DoD:* RLS prepreči tuje vrstice.

---

## M6 — Sync servis (ročni push/pull)

**Cilj:** drift ↔ Supabase, LWW po `updated_at`, brez razreševanja konfliktov (MVP enouporabniški). §2 tech-stack.

- [ ] **6.1 — Povezljivost + infra.** `connectivity_plus`; `sync_status` označevanje ob zapisih. *Commit:* `feat: connectivity + sync_status infra`
- [ ] **6.2 — Push.** `pending` vrstice → `upsert` v Supabase (FK vrstni red: area→user_plant→task→…) → `synced`. *Commit:* `feat: sync push`
- [ ] **6.3 — Pull.** `updated_at > last_pulled_at` → upsert v drift; `deleted=true` → odstrani lokalno. *Commit:* `feat: sync pull`
- [ ] **6.4 — Sprožilci + LWW.** Ob zagonu/povezavi/periodično; LWW po `updated_at`. *Commit:* `feat: sync sprožilci + LWW`
- [ ] **6.5 — Testi M6.** Unit (LWW logika, vrstni red) + integracijski proti testnemu projektu. *Commit:* `test: sync`

---

## M7 — Auth + H3 na napravi

**Cilj:** anonimno "brez računa" → kasneje linkanje; lokacija → H3 celice (brez koordinat). §3, §5 tech-stack.

- [ ] **7.1 — Anonimno.** `signInAnonymously()`; po prijavi prvi pull; ob odjavi clear lokalne baze. *Commit:* `feat: anonimna prijava + pull/clear`
- [ ] **7.2 — Onboarding + prijava (13, 15/15b-d, 16).** Zasloni + flow. *Commit:* `feat: onboarding + prijava`
- [ ] **7.3 — Linkanje identitete.** `linkIdentity` (Apple/Google/email OTP); opozorilo izguba podatkov (anonimno). *Commit:* `feat: linkIdentity + opozorilo`
- [ ] **7.4 — H3 na napravi.** `h3_flutter`: iz GPS → res-7, izpelji res-6/5; shrani **samo celice** v `profile`. *Commit:* `feat: H3 celice na napravi (zasebnost)`
- [ ] **7.5 — Testi M7.** *Commit:* `test: auth + H3`

---

## M8 — Lokalna obvestila (plast A)

**Cilj:** deterministični opomniki opravil, delujejo offline; deep-link na Detajl. §4 tech-stack. Zasloni 19–22.

- [ ] **8.1 — Setup.** `flutter_local_notifications` + `timezone`. *Commit:* `feat: lokalna obvestila setup`
- [ ] **8.2 — Razporejanje.** Po `task_reminder(offset, time)`; več opomnikov na opravilo; časovni pasovi. *Commit:* `feat: razporejanje opomnikov`
- [ ] **8.3 — Deep-link.** Tap → `go_router` na Detajl (17). *Commit:* `feat: deep-link obvestilo → detajl`
- [ ] **8.4 — Zasloni 19/20/21/22.** Dodaj obvestilo (19), videz (20), priming dovoljenje (21, pred sistemskim pozivom), nastavitve (22: tihe ure, kapica, opt-in). *Commit:* `feat: zasloni obvestil (19–22)`
- [ ] **8.5 — Testi M8.** *Commit:* `test: opomniki`

---

## M9 — Polish + monitoring + Android release

**Cilj:** MVP pripravljen za interni Android test.

- [ ] **9.1 — Sentry.** `sentry_flutter` init (dev DSN prek dart-define). *Commit:* `feat: Sentry monitoring`
- [ ] **9.2 — Ikona + splash (00).** Iz `docs/brand/assets/`. *Commit:* `chore: app ikona + splash`
- [ ] **9.3 — Pregled neskladij.** UI vs wireframi; i18n popolnost (sl/en/de); dostopnost; vsi nizi prevedeni. *Commit:* `fix: neskladja UI/wireframi + i18n`
- [ ] **9.4 — Android release.** Keystore (👤), podpisan release build, `--dart-define` produkcijski ključi. *Commit:* `chore: Android release konfiguracija`
- [ ] **9.5 — 👤 Play interni test.** Naloži na Play Console interni track.

---

## M10 — *(po MVP)* iOS mejnik

> Zahteva macOS + Xcode ali oblačni build (Codemagic / GitHub macOS runner) + Apple Developer (99 $/leto).
> iOS dovoljenja (lokacija, obvestila), ikone/splash, podpisovanje, App Store metapodatki, TestFlight.

---

## M11 — *(po MVP / V2)* Pametni motor + FCM + percentili

> Plast B: dnevni paketni pregled (cron/Edge Function) + FCM push, 3–4 kurirana pravila (brez AI),
> vodenje proti gnjavljenju (cooldown, vremenske straže, dedup, frekvenčna kapica). Glej
> [`pametni-motor.md`](pametni-motor.md) + `koncept.md` §7.13. V2: percentili okolice (`activity_agg`, §8).
> Vzporedni ne-blokirajoč tir: **razširitev kataloga rastlin 35 → 100–200** (Wikidata/GBIF) + preverba prevodov.

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
- **FR-3 — Zatikanja (performance).** Med ročno preverbo M3.7 opažena rahla zatikanja pri
  navigaciji/scrollu. Kasneje: profiliraj (DevTools timeline), poišči nepotrebne rebuilde
  (`const`, ozki `watch`/`select`), preveri drift stream rebuilde. Najprej izmeri, šele nato optimiziraj.
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

## Dnevnik napredka

> Agent tu dopisuje zaključene korake (datum · korak · commit hash). Najnovejše zgoraj.

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
