# T11 — Količina pridelka ob pobiranju (yield)

> **Status:** spec + UI/UX · 2026-06-30 · branch `feat/t11-harvest-yield`
> **Vir zahteve:** `docs/povratne-informacije.md` → Runda 2, T11.
> **Obseg (potrjeno z lastnikom):** **zajem + osnovni povzetek**. Vnos **povsod, kjer
> opravilo postane `done`** (presko­čljivo). Enota = **fiksen enum**.
> Grafi/analitika med leti = **V2** (ločen FR), tukaj zunaj obsega.

---

## 1. Cilj in vrednost

Vrtnar ob pobiranju zabeleži **koliko** je pobral (količina + enota). Skupaj z že
zamrznjenim vremenskim posnetkom ob `done` (§7.10) to pretvori dnevnik iz seznama
opravil v **podatkovno orodje**: »koliko paradižnika letos vs. lani«. MVP zajame
podatek; primerjave čez leta so V2.

Načela (CLAUDE.md): offline-first (vnos brez signala), zasebnost (nič novih
osebnih podatkov), additive shema (stari APK-ji preživijo), brez over-engineeringa.

## 2. Domenski model

Yield je **lastnost opravila pobiranja**, ne zaloge. `task_supply` modelira
**porabo** (vhod) in je trenutno skrit (`kSuppliesEnabled = false`) — zato yield
**ni** task_supply, ampak **dve dodatni polji na `task`**:

| polje | tip | opis |
|---|---|---|
| `yield_amount` | `double?` (drift `RealColumn.nullable`, PG `double precision`) | količina; `> 0` |
| `yield_unit` | `String?` (drift `TextColumn.nullable`, PG `text`) | `YieldUnit.name` |

**Invarianta both-or-neither:** obe polji sta hkrati postavljeni ali hkrati `null`.
Normalizira jih **repozitorij** (eno mesto), DB-level CHECK na Supabase je varovalka.

**Enote** (`YieldUnit`, `lib/features/tasks/yield_unit.dart`):
`kg`, `dag`, `g`, `pieces`, `l`, `bunch`. Shranjeno kot `.name`. **Tolerantni
parse** (`yieldUnitFromName`): neznana/`null` vrednost → `null` (stari APK ob pull
novega `yield_unit` ne crasha — mirror pravila tolerantnega parserja). Privzeta
enota v vnosu = `kg`.

**Kateri tipi opravil:** samo tip kategorije `harvest` (trenutno en sam katalog
tip `harvest` 🧺). Detekcija: `isHarvestType(TaskType?)` → `type?.category ==
'harvest'`. Mehko, brez blokiranja drugih tipov.

## 3. Shema, migracije, sync

- **Drift:** dodaj `yieldAmount`/`yieldUnit` v `Tasks`. `schemaVersion 11 → 12`,
  `onUpgrade … if (from < 12) addColumn × 2`. Brez drift-level CHECK (sicer bi se
  sveža `createAll` baza in migrirana baza razhajali; invarianto drži repo + PG).
- **Supabase `0014_task_yield.sql`:** additive `add column if not exists` × 2 +
  `CHECK (yield_amount is null or yield_amount > 0)` +
  `CHECK ((yield_amount is null) = (yield_unit is null))`. Grant ni potreben
  (table-level grant na `task` že pokriva nove stolpce). RLS nespremenjen.
- **Sync mapperji** (`remote_mappers.dart`): `taskToRemote` doda `yield_amount`,
  `yield_unit`; `taskFromRemote` ju bere tolerantno (manjka → `null`; neznan
  `yield_unit` string se shrani kot je → faithful round-trip, prikaz parse-a
  tolerantno). LWW po `updated_at` velja enako.
- **GDPR izvoz** dobi polji samodejno (`toJson()` čez `task`).

## 4. Repozitorij (`TasksRepository`)

Trije zapisovalni vhodi (vsi normalizirajo both-or-neither + `updatedAt` +
`syncStatus = pending`):

- `create(… , double? yieldAmount, YieldUnit? yieldUnit)` — čarovnik beleži
  **pretekel/opravljen** harvest s pridelkom.
- `complete(id, {double? yieldAmount, YieldUnit? yieldUnit})` — ob zaključku
  čakajočega harvesta. Brez yielda → stolpca pusti pri miru (`Value.absent`).
  Ponavljajoč harvest: yield na **tej** instanci, naslednja instanca brez yielda.
- `setYield(id, {required double? amount, required YieldUnit? unit})` —
  dodaj/uredi/**počisti** (`null,null`) na detajlu opravila.

`updateTask` yielda **ne** spreminja (Companion brez teh polj → ohrani obstoječe);
urejanje yielda gre prek detajla, ne čez čarovnik-edit.

**Povzetek (pura funkcija, `yield_summary.dart`):** `summarizeYield(records)` →
skupne vsote **po enoti** (kg in kom se ne seštevata) + razčlenitev **po letih**
(padajoče). Vir = opravila rastline (`tasksByPlantProvider`), filtrirana po
`yield_amount != null` — brez nove poizvedbe.

## 5. UI / UX — vsi koraki in CTA

### 5.1 Skupni `YieldSheet` (bottom sheet, en sam za vse vstopne točke)
`showYieldSheet(context, {initial, allowSkip, allowRemove}) → YieldSheetResult?`
- `SheetHandle` + naslov.
- **Polje količine** — `TextField`, numerična tipkovnica, sprejme `.` in `,`
  (parse `> 0`), hint `npr. 2,5`.
- **Enote** — `Wrap` `ChoiceChip`-ov (kg · dag · g · kom · l · šop). Privzeto `kg`
  (ali `initial.unit`).
- **CTA:** `Shrani` (`FilledButton`, 48 h, onemogočen dokler količina ni veljavna)
  → `YieldSaved(draft)`. `Preskoči` (`TextButton`, ko `allowSkip`) → `null`.
  `Odstrani pridelek` (`DestructiveButton`, ko `allowRemove`) → `YieldCleared`.
  Zapiranje (tap zunaj) → `null`.

### 5.2 Zaključek čakajočega harvesta (`✓`) — presko­čljivo
Vse poti zaključka tečejo skozi `completeTask()`. Če je opravilo harvest →
**najprej** `YieldSheet` (`allowSkip`), nato `repo.complete(...)`:
- **Shrani** → zaključi s pridelkom. **Preskoči / zapri** → zaključi brez.
- Velja za: swipe `✓` in `⋯` sheet v seznamu, `✓` na detajlu (gumb + `⋯`).
- Ne-harvest opravila: nespremenjeno (brez sheeta).

### 5.3 Čarovnik (create) — pretekel harvest
V koraku **Pregled** se za `harvest` + `status == done` (samo create, ne edit)
pokaže vrstica **Pridelek**: tap odpre `YieldSheet`; vrednost se shrani v stanje
čarovnika in gre v `repo.create(...)`. Prihodnji (waiting) harvest: brez vrstice
(pridelek dobi ob zaključku).

### 5.4 Detajl opravila — sekcija »Pridelek«
Samo za `harvest` + `done`:
- ima yield → kartica z vrednostjo (`2,5 kg`) + tap = uredi (`YieldSheet`,
  `allowRemove`).
- nima yielda → CTA **»Dodaj pridelek«** (npr. opravljeno offline) → `setYield`.

### 5.5 Detajl rastline — povzetek + zgodovina
- Nova sekcija **»Pridelek«** (samo če `summary` ni prazen): skupne vsote po enoti
  + razčlenitev po letih.
- Vrstica zgodovine harvesta z yieldom prikaže količino (`🧺 … · 2,5 kg`).

### 5.6 Dnevnik, Domov, mesečni koledar
Skupni `taskYieldChip(task, t)` helper prikaže »🧺 2,5 kg« v podnaslovu pri
opravljenem harvestu → enako v dnevniku (`TaskEntryTile` + mesečni koledar) in v
seznamu »Nedavno« na Domov (`_TaskTile`). Zaključek prek `TaskSwipe` (swipe ✓ v
seznamu, Domov in dnevniku) gre skozi `completeTask(harvest:)` — isti sheet.

### Stil
Barve/tekst le prek teme; nizi prek `t.harvest.*` (en/sl/de; slang `dart run
slang`). Enote: sl `kg/dag/g/kom/l/šop`, en `kg/dag/g/pcs/l/bunch`,
de `kg/dag/g/Stk./l/Bund`. Brez hardcode hex/nizov.

## 6. Robni primeri

- **Offline:** vnos dela (drift), push počaka. Vreme se lahko ne zajame — yield se
  vseeno shrani (neodvisen od vremena).
- **Skip / dismiss** ob `✓` → opravilo se vseeno zaključi (yield neobvezen).
- **0 ali prazno** → `Shrani` onemogočen; ni zapisa (count 0 ni »pridelek«).
- **Mešane enote pri rastlini** → povzetek po enoti (ne seštevamo kg + kom).
- **Stari APK** pull-a `yield_*`: tolerantni parser → neznana enota = brez prikaza
  enote, količina ostane; nikoli crash.
- **Edit harvesta v čarovniku** ne povozi yielda (managira ga detajl).

## 7. Testi

- **Unit:** `yield_unit` (tolerantni parse), `yield_summary` (vsote/po letih/prazno),
  repo (`create`/`complete`/`setYield`/clear/recurring), `remote_mappers`
  (round-trip + tolerantnost), migracija v11→v12 (stolpca obstajata, version 12).
- **Widget:** `YieldSheet` (vnos+enota→`YieldSaved`; Preskoči→`null`;
  Odstrani→`YieldCleared`; `Shrani` onemogočen pri neveljavnem vnosu).
- `flutter analyze` čist + cel `flutter test` zelen.

## 8. Datoteke

**Novo:** `lib/features/tasks/yield_unit.dart`, `.../harvest.dart`,
`.../yield_summary.dart`, `.../presentation/yield_sheet.dart`,
`.../presentation/yield_format.dart`, `supabase/migrations/0014_task_yield.sql`,
testi.
**Spremenjeno:** `core/database/tables/user_tables.dart`,
`core/database/app_database.dart`, `core/sync/remote_mappers.dart`,
`features/tasks/data/tasks_repository.dart`,
`features/tasks/presentation/{task_actions,review_step,entry_screen,task_detail_screen}.dart`,
`features/tasks/presentation/widgets/task_entry_tile.dart`,
`features/plants/presentation/plant_detail_screen.dart`,
`features/tasks/presentation/tasks_screen.dart`, i18n `en/sl/de`.
