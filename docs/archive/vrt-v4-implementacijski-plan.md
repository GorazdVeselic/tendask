# Vrt v4 — implementacijski plan (rastlino-prvi tok dodajanja/urejanja/premikanja)

> Status: **potrjen, pripravljen za implementacijo**. Datum: 2026-06-07.
> Vir dizajna: `docs/wireframes/*_v4.html` (galerija → skupina »🪴 Vrt — rastlino-prvi (v4)«).
> Koncept: `docs/koncept.md` §7.14 (model) + §7.15 (subjekt = rastlina ALI območje).
> Ta dokument je **samozadosten** — nova seja lahko začne brez dodatnih vprašanj.

---

## 0. Cilj v eni povedi

Predelati obstoječi vrtni tok tako, da je **dodajanje rastline = en zaslon z instant-dodajanjem** (tap = takoj shranjeno), **območje povsod postransko**, ter dodati **urejanje, premikanje med območji in prvi-zagon** — vse skladno z obstoječo kodo, brez spremembe sheme, brez nove odvisnosti.

## 1. Trdne invariante (NE kršiti)

1. **Brez spremembe sheme.** Model `user_plant(area_id nullable single FK)` + `area(type enum)` že podpira vse. **Brez** drift/Supabase migracije, **brez** build_runner za bazo.
2. **Brez nove odvisnosti** (pravilo `tech-stack.md §1`). Swipe = vgrajen `Dismissible`. Recent = drift query.
3. **Repo skrije drift.** Nobenega `Companion`/`Value` v podpisih widgetov; drift ostane v `data/`. UI bere prek Riverpod providerjev.
4. **Offline-first, RLS, brez koordinat, brez skrivnosti.** Vsi zapisi prek repo z `userId` iz `authServiceProvider`. Po vsakem `await` v widgetu `if (!mounted) return;` pred `context`.
5. **Obrazci = poln zaslon + `SaveBar`** (kot `note_form`/`area_form`). **Edina izjema:** izbirnik območja (move) je `showModalBottomSheet` (izbira, ne obrazec).
6. **Komponentni katalog se ponovno uporablja:** `SectionLabel`, `FieldLabel`, `EmptyState`, `SaveBar`, `SheetHandle`, `DestructiveButton`, `showConfirmDialog`, `catalogLabel`, `core/date_format.dart`, barve prek `Theme.of(context).colorScheme`. **Brez hardcode hex, brez golih nizov** (vse prek `t.*`).
7. **i18n:** novi ključi v sl/en/de, nato `dart run slang`. Slovenščina samo v `t.*` vrednostih, koda angleška.

## 2. Potrjene odločitve (iz pogovora)

| Tema | Odločitev |
|---|---|
| Obrazci urejanja | **Poln zaslon** + `SaveBar` (ne sheet) |
| Swipe Premakni/Odstrani | **Vgrajen `Dismissible`** (brez paketa) |
| »Pogosto« v dodajanju | **Nazadnje uporabljeno** (drift query, omejena) |
| FAB | Razširi obstoječi shell-FAB na `/areas` (akcija = `plant-add`) |
| Move izbirnik | `showModalBottomSheet`, single-select, **pure selection** (vrne izbiro, klicalec zapiše) |
| Izbira ob ＋ (router) | **Ukinjena** — FAB gre naravnost na rastline; območje = tih vstop |

---

## 3. Trenutni inventar (z referencami)

**Routes** (`lib/app/router/app_router.dart`):
- `/plant-picker` → `PlantPickerScreen` (vrne `PlantPick = ({String? plantId, String? customName})`). Klicalci: `area_form` (briše se), `plant_edit` (briše se), `note_form_screen.dart:107`, … → **po migraciji ostane samo `note_form`**.
- `/plant-new` (`name: plant-new`) → `PlantEditScreen()` add-mode. Klicalca: `areas_screen` (add-menu), `subject_step.dart:58` (vrne `List<String>`).
- `/plant/:id` → `PlantDetailScreen`.
- `/plant/:id/edit` → `PlantEditScreen(userPlantId)` edit-mode.
- `/area-new` → `AreaFormScreen()` add (vrne `String areaId`). Klicalci: `areas_screen`, `plant_edit:206`, `subject_step.dart:68`.
- `/areas/:id/edit` → `AreaFormScreen(areaId)` edit. Klicalec: `area_detail`.
- Shell: `/areas` → `AreasScreen` z otrokom `:id` → `AreaDetailScreen`.

**Repo** (`features/plants/data/user_plants_repository.dart`): `watchByArea(areaId)` (order by **id** — popraviti), `watchAll`, `byArea`, `byId`, `watchById`, `create(...)`, `createForArea`(mrtvo), `syncForArea`(mrtvo), `update(id, areaId, personalAlias)`, `softDelete`. `PlantSpec` v `plant_spec.dart` (mrtvo po migraciji).

**Repo** (`features/areas/data/areas_repository.dart`): `watchAll`, `watchById`, `byId`, `create`, `update`, `softDelete` (**ima orphan bug — popraviti**).

**Providers:** `plants_providers.dart` (`userPlantsByAreaProvider`, `userPlantByIdProvider`, `userPlantsMapProvider`, `userPlantsRepositoryProvider`), `areas_providers.dart` (`areasListProvider`, `areasMapProvider`, `areaByIdProvider`, `latestTaskPerAreaProvider`, `areaHistoryProvider`).

**Tasks** (za zgodovino, NE spreminjamo): `tasks_repository.watchByArea/watchByPlant/watchLatestPerArea`, `tasksByPlantProvider`.

---

## 4. Datoteke: dodaj / spremeni / odstrani

### NOVE
- `features/plants/presentation/garden_plant_add_screen.dart` — `GardenPlantAddScreen` (instant multi-add).
- `features/plants/presentation/widgets/area_pick_sheet.dart` — `showAreaPickSheet(...)` (generičen single-select izbirnik območja; uporabljen za move IN za »Kam dodajam«).

### SPREMENJENE
- `app/router/app_router.dart` — `plant-new` → `plant-add` (nov zaslon + extra args).
- `app/router/main_shell.dart` — FAB tudi na `/areas`.
- `features/areas/presentation/areas_screen.dart` — empty-state, tih »＋ Novo območje«, swipe; brez add-menu.
- `features/areas/presentation/area_form_screen.dart` — brez rastlinske sekcije; izbris + reparent opomba.
- `features/areas/presentation/area_detail_screen.dart` — sekcija »Rastline« + »＋ Dodaj rastlino«.
- `features/areas/data/areas_repository.dart` — `softDelete` reparenta rastline (transakcija).
- `features/plants/presentation/plant_detail_screen.dart` — območje = tappable pill → move sheet.
- `features/plants/presentation/plant_edit_screen.dart` — **samo edit**; brez multi-area/picker.
- `features/plants/data/user_plants_repository.dart` — odstrani `syncForArea`/`createForArea`; popravi `watchByArea` ordering; dodaj `recentPlantIds`.
- `features/plants/application/plants_providers.dart` — dodaj `recentPlantsProvider`.
- `features/tasks/presentation/entry/steps/subject_step.dart` — `plant-new` → `plant-add` (subjectMode).
- `core/config.dart` — `kRecentPlantsLimit`.
- i18n `sl/en/de.i18n.json` — dodani/odstranjeni ključi.

### ODSTRANJENE (cele datoteke)
- `features/plants/data/plant_spec.dart` (in vsi importi nanj).

---

## 5. Detajli po komponentah

### 5.1 `GardenPlantAddScreen` (wireframe `plant-add_v4`) — glavni zaslon

**Konstruktor / args** (prek go_router `extra`):
```dart
class PlantAddArgs {
  const PlantAddArgs({this.areaId, this.subjectMode = false});
  final String? areaId;     // predizpolni cilj (vstop iz area-detail)
  final bool subjectMode;   // skrije »Kam dodajam« (vstop iz task subject-step)
}
```
`ConsumerStatefulWidget`. Stanje: `String _query=''`, `String _category='all'`, `bool _searchExpanded=false`, `String? _targetAreaId` (init iz args.areaId), `final List<String> _createdIds=[]`.

**Layout (od zgoraj):**
1. `AppBar`: leading `Icons.close` → `context.pop(_createdIds)`; title `t.plants.add_title`; centerTitle.
2. **Kategorije** — `Wrap`/horizontalni `ChoiceChip` (ista lista `_categories` kot v `plant_picker_screen.dart:17`).
3. **»Pogosto«** (`SectionLabel(t.plants.frequent)`) — chipi iz `recentPlantsProvider`; tap = instant-add (glej spodaj). Skrij sekcijo, če prazno.
4. **»Iz baze«** vrstica naslova: `Row(spaceBetween)` z `SectionLabel(t.plants.from_catalog)` levo + `IconButton(Icons.search)` desno, ki preklopi `_searchExpanded`. Ko `_searchExpanded`: pod naslovom `TextField` (autofocus) → `setState _query`.
5. **Seznam zadetkov** — `Card` z vrsticami (`_CatalogRow` kot v picker-ju, a **tap = instant-add**, ne pop). Filtriraj: `plantMatchesQuery` + kategorija (kot `plant_picker_screen.dart:63`). Že-dodane vrste označi z ✓ (preveri `_createdIds` → plantId).
6. **»Ne najdeš?«** — `_CustomEntry` (kot picker): tap = instant-add custom (`customName: query`).
7. **»Kam dodajam« (neobvezno)** — skrij če `subjectMode`. `SectionLabel(t.plants.add_to_label)` + vrstica »📍 {ime ali Brez območja}« → `showAreaPickSheet` (choose-mode); ob izbiri: `setState _targetAreaId`, **in re-parentaj vse `_createdIds`** na novo območje (loop `repo.update(id, areaId:_targetAreaId)` — majhen N).

**Sticky footer** (kot `plant-add_v4` addbar): če `_createdIds.isNotEmpty` → vrstica »`t.plants.added_count(n)` + imena + `t.plants.undo`« nato `FilledButton(t.plants.done)` → `context.pop(_createdIds)`.

**Instant-add semantika:**
```dart
Future<void> _add({String? plantId, String? customName}) async {
  final id = await ref.read(userPlantsRepositoryProvider).create(
    userId: ref.read(authServiceProvider).userId,
    areaId: _targetAreaId, plantId: plantId, customName: customName,
  );
  if (!mounted) return;
  setState(() => _createdIds.add(id));
}
```
- **Undo** = `softDelete(_createdIds.removeLast())`.
- **Pop pogodba:** `close` IN `Končano` poženeta `pop(_createdIds)`. Vrstice so že persistirane (to je bistvo instant-add). Za garden vstop je to želeno; za `subjectMode` se vrnjeni id-ji auto-izberejo v task subjektih.
- **Duplikati dovoljeni** (dve sadiki paradižnika = dve vrstici). ✓ pomeni »vsaj enkrat dodano«.

### 5.2 `showAreaPickSheet` (wireframe `plant-move_v4`) — generičen izbirnik območja

```dart
/// Pure selection. Returns null on cancel; otherwise a record whose areaId is
/// null for "Brez območja" or a real area id. Writes NOTHING — caller persists.
typedef AreaPick = ({String? areaId});

Future<AreaPick?> showAreaPickSheet(
  BuildContext context,
  WidgetRef ref, {
  required String title,        // "Premakni „Jablana“" ali "Izberi območje"
  String? currentAreaId,
}) { ... showModalBottomSheet ... }
```
Vsebina: `SheetHandle`, naslov, podnaslov (`t.area_pick.note`), single-select `RadioListTile`/vrstice:
- »Brez območja« (`area_pick.none`) → vrne `(areaId: null)`.
- vsako območje iz `ref.watch(areasListProvider)` (RLS-omejen → ni tujih); trenutno označeno z `area_pick.current`.
- »＋ Novo območje«: `final newId = await context.pushNamed<String>('area-new');` → če `!=null` zapri sheet z `(areaId: newId)`.
Izbira vrstice → `Navigator.pop(ctx, (areaId: id))`.

**Klicalci in zapis (klicalec persistira):**
- plant-detail pill / plant-edit polje / list-swipe Premakni:
  ```dart
  final pick = await showAreaPickSheet(context, ref, title: ..., currentAreaId: plant.areaId);
  if (pick == null || !context.mounted) return;
  await ref.read(userPlantsRepositoryProvider).update(id: plant.id, areaId: pick.areaId, personalAlias: plant.personalAlias);
  ```
  > ⚠️ `update` prepiše tudi `personalAlias`; pri move VEDNO podaj obstoječi alias, da ga ne zbrišeš.
- plant-add »Kam dodajam«: ne zapiše takoj v eno vrstico, ampak nastavi `_targetAreaId` + re-parenta `_createdIds`.

### 5.3 `PlantDetailScreen` (wireframe `plant-detail_v4`)
- `_Hero`: območje iz `sub` niza pretvori v **tappable `ActionChip`/pill**: »📍 {area.name} · {t.plant_detail.move}«; brez območja → »📍 {t.plant_detail.assign_area}«. Tap → `showAreaPickSheet` → zapiši (glej zgoraj). Ostalo (alias/ime, znanstveno ime, zgodovina) nespremenjeno.

### 5.4 `PlantEditScreen` (wireframe `plant-edit_v4`) — SAMO edit
- Odstrani: `_areaIds`, `_pickSpecies`, add-vejo v `_save` (`plant_edit_screen.dart:104–124`), `_LocationField` multi-način, import `plant_picker_screen`.
- Vrsta = **static** prikaz (ikona + label + znanstveno ime), brez »Spremeni«.
- Polja: alias (kot zdaj) · **Območje** (`FieldLabel(t.plant_edit.location_label)` + vrstica »📍 {ime/Brez} → Premakni« ki kliče `showAreaPickSheet`, rezultat shrani v lokalno `_editAreaId`) · kategorija (chipi, samo prikaz/izbira za lasten vnos) · `DestructiveButton(t.plant_edit.delete)`.
- `_save`: `repo.update(id, areaId:_editAreaId, personalAlias: aliasOrNull)`; `pop()`.

### 5.5 `AreaFormScreen` (wireframe `area-edit_v4`) — new + edit
- **Odstrani** `_PlantsSection` (200–279), `_addPlant`, `_plants`, `syncForArea` klic (`area_form_screen.dart:109–113`), importe `plant_picker_screen`/`plant_spec`.
- Ostane: ime + tip (`ChoiceChip` po `AreaType.values`) + info opomba (lokacija).
- **Dodaj** v edit-mode: `DestructiveButton(t.areas.action_delete)` → `showConfirmDialog` → `areasRepository.softDelete(id)` → `pop()`; pod njim `t.areas.delete_reparent_note`.
- `_save`: create vrne `areaId` (ohrani — `subject_step`/`area_pick` ga rabita); edit vrne `null`.

### 5.6 `AreaDetailScreen` (wireframe `area-detail_v4`)
- Med `_Hero` in »Zgodovina opravil« dodaj sekcijo **»Rastline«**:
  - `ref.watch(userPlantsByAreaProvider(id))` → seznam `_PlantRow` (isti widget/vzorec kot v `areas_screen`, vključ. swipe).
  - Na dnu kartice »＋ {t.areas.add_plant_here(area: area.name)}« → `context.pushNamed('plant-add', extra: PlantAddArgs(areaId: id))`.
- ⋯ action-sheet ostane (Uredi → `area-edit`; Izbriši → `softDelete`).

### 5.7 `AreasScreen` (wireframe `vrt_v4` + `vrt-empty_v4`)
- Odstrani `_showAddMenu` (18–48) in appbar `IconButton(add)`.
- **Empty-state** (ko `areas.isEmpty && unassigned.isEmpty`): lokalni centriran blok (NE `EmptyState` komponenta — ta je za list-empty en niz): ikona 🌱 + `t.areas.empty_title` + `t.areas.empty_body` + `FilledButton(t.areas.empty_cta_plant)`→`plant-add` + `OutlinedButton(t.areas.empty_cta_area)`→`area-new`.
- **`_PlantRow`** → ovij v `Dismissible`:
  - `key: ValueKey(plant.id)`.
  - `background` (startToEnd, zelen, `Icons.swap_horiz` + `t.areas.swipe_move`); `secondaryBackground` (endToStart, `colorScheme.error`, `Icons.delete` + `t.areas.swipe_remove`).
  - `confirmDismiss`: če `DismissDirection.startToEnd` → odpri `showAreaPickSheet` + zapiši, vrni `false` (vrstica ostane). Če `endToStart` → `showConfirmDialog(... destructive)`, ob potrditvi `softDelete(plant.id)` in vrni `true`.
- **Dno seznama**: za zadnjo sekcijo dodaj črtkan element »＋ {t.areas.new_area_inline}« → `pushNamed('area-new')`.
- Razvrstitev rastlin pod območjem: po `watchByArea` (popravljen order — glej 6.1).

### 5.8 `main_shell.dart` (FAB doslednost)
```dart
final showFab = location == '/home' || location == '/tasks' || location == '/areas';
...
onPressed: () => context.pushNamed(location == '/areas' ? 'plant-add' : 'task-new'),
```
Isti `centerFloat`, `Icons.add` — vizualno enak FAB čez zavihke.

---

## 6. Repo & query spremembe (točne)

### 6.1 `user_plants_repository.dart`
- **Odstrani** `createForArea` (63–77) in `syncForArea` (81–106).
- `watchByArea`: `orderBy id` → `orderBy([(p) => OrderingTerm.desc(p.updatedAt)])`.
- **Dodaj** (en optimalen query, group-by + agregat, brez full-scan):
```dart
/// Distinct catalog species the user has used, newest first — for "Frequent".
Future<List<String>> recentPlantIds({int limit = kRecentPlantsLimit}) async {
  final pid = _db.userPlants.plantId;
  final maxUpd = _db.userPlants.updatedAt.max();
  final q = _db.selectOnly(_db.userPlants)
    ..addColumns([pid, maxUpd])
    ..where(_db.userPlants.deleted.equals(false) & pid.isNotNull())
    ..groupBy([pid])
    ..orderBy([OrderingTerm.desc(maxUpd)])
    ..limit(limit);
  final rows = await q.get();
  return [for (final r in rows) r.read(pid)!];
}
```

### 6.2 `areas_repository.dart` — orphan-bug fix (🔴 obvezno)
```dart
Future<void> softDelete(String id) async {
  await _db.transaction(() async {
    // Re-parent plants to "no area" so they resurface under "Brez območja"
    // instead of pointing at a deleted area (otherwise they vanish from the UI).
    await (_db.update(_db.userPlants)..where((p) => p.areaId.equals(id))).write(
      UserPlantsCompanion(
        areaId: const Value(null),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
    await (_db.update(_db.areas)..where((a) => a.id.equals(id))).write(
      AreasCompanion(
        deleted: const Value(true),
        updatedAt: Value(_clock.now()),
        syncStatus: const Value(kSyncPending),
      ),
    );
  });
}
```
> Potreben import `user_tables`/`UserPlantsCompanion` je že na voljo prek `app_database.dart`. `AreasRepository` že drži `_clock`/`_uuid`.

### 6.3 `plants_providers.dart`
```dart
// Recent species ids for the "Frequent" row on the add screen.
final recentPlantsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  // Re-fetch when the plant set changes so freshly added species bubble up.
  ref.watch(userPlantsMapProvider);
  return ref.watch(userPlantsRepositoryProvider).recentPlantIds();
});
```

### 6.4 `core/config.dart`
```dart
/// Max species shown in the "Frequent" row of the plant-add screen.
const int kRecentPlantsLimit = 8;
```

---

## 7. Router diff (`app_router.dart`)

```dart
// PREJ:
GoRoute(path: '/plant-new', name: 'plant-new',
  builder: (c, s) => const PlantEditScreen()),

// POTEM:
GoRoute(path: '/plant-add', name: 'plant-add',
  builder: (c, s) {
    final a = s.extra is PlantAddArgs ? s.extra as PlantAddArgs : const PlantAddArgs();
    return GardenPlantAddScreen(args: a);
  }),
```
- `/plant/:id/edit`, `/area-new`, `/areas/:id/edit`, `/plant-picker` ostanejo.
- Import: zamenjaj `plant_edit_screen` add-uporabo z `garden_plant_add_screen` (plant-edit še vedno uvožen za `/plant/:id/edit`).
- **Klicalci `plant-new` → `plant-add`:** `subject_step.dart:58` (`extra: const PlantAddArgs(subjectMode: true)`), `area_detail` (`extra: PlantAddArgs(areaId: id)`), shell-FAB (brez extra).

---

## 8. i18n ključi (sl / en / de) — nato `dart run slang`

**Dodaj:**
```
plants.add_title         = "Dodaj rastline" / "Add plants" / "Pflanzen hinzufügen"
plants.added_count(n)    = "Dodano ({n})" / "Added ({n})" / "Hinzugefügt ({n})"
plants.done              = "Končano" / "Done" / "Fertig"
plants.undo              = "Razveljavi" / "Undo" / "Rückgängig"
plants.frequent          = "Pogosto" / "Frequent" / "Häufig"
plants.add_to_label      = "Kam dodajam" / "Add to" / "Hinzufügen zu"

area_pick.move_title(name) = "Premakni „{name}“" / "Move „{name}“" / "„{name}“ verschieben"
area_pick.choose_title   = "Izberi območje" / "Choose area" / "Bereich wählen"
area_pick.none           = "Brez območja" / "No area" / "Kein Bereich"
area_pick.current        = "trenutno" / "current" / "aktuell"
area_pick.new_area       = "Novo območje" / "New area" / "Neuer Bereich"
area_pick.note           = "Rastlina je lahko v enem območju (ali brez). Zgodovina opravil ostane." / EN / DE

areas.plants_section     = "Rastline" / "Plants" / "Pflanzen"
areas.add_plant_here(area) = "Dodaj rastlino v {area}" / "Add plant to {area}" / "Pflanze zu {area} hinzufügen"
areas.new_area_inline    = "Novo območje" / "New area" / "Neuer Bereich"
areas.delete_reparent_note = "Rastline iz tega območja se premaknejo v „Brez območja“ (ne izbrišejo se)." / EN / DE
areas.empty_title        = "Tvoj vrt je še prazen" / "Your garden is empty" / "Dein Garten ist leer"
areas.empty_body         = "Dodaj rastline, ki jih imaš. Območja (grede, trate) so neobvezna." / EN / DE
areas.empty_cta_plant    = "Dodaj rastline" / "Add plants" / "Pflanzen hinzufügen"
areas.empty_cta_area     = "Dodaj območje" / "Add area" / "Bereich hinzufügen"
areas.swipe_move         = "Premakni" / "Move" / "Verschieben"
areas.swipe_remove       = "Odstrani" / "Remove" / "Entfernen"

plant_detail.move        = "premakni" / "move" / "verschieben"
plant_detail.assign_area = "Dodeli območje" / "Assign area" / "Bereich zuweisen"
plant_edit.location_label = "Območje" / "Area" / "Bereich"
plant_edit.move          = "Premakni" / "Move" / "Verschieben"
```
**Odstrani** (osirotelo po migraciji): `areas.form_plants`, `areas.form_plants_add`, `areas.form_plants_note`, `areas.plants_empty`, `areas.plant_remove`, `plants.field_add`, `plants.field_empty`, `plant_edit.locations`, `plant_edit.locations_hint`, `plant_edit.locations_note`, `plant_edit.new_area`, `plant_edit.species_choose`, `plant_edit.species_change`.
> Pred odstranitvijo zaženi `grep -rn "<key>" lib/` da potrdiš 0 rab. `plant_edit.species` (label) **ostane**.

---

## 9. Mrtva koda — eksplicitni seznam za izbris (0 ostankov)

- `plant_spec.dart` (cela datoteka) + vsi importi.
- `UserPlantsRepository.syncForArea`, `createForArea`.
- `AreasScreen._showAddMenu`.
- `AreaFormScreen._PlantsSection`, `_addPlant`, polje `_plants`, importi `plant_picker_screen`/`plant_spec`.
- `PlantEditScreen`: `_areaIds`, `_pickSpecies`, add-veja `_save`, `_LocationField` (multi/new-area), import `plant_picker_screen` + `area-new` push.
- pripadajoči i18n ključi (§8).
**Sprejem:** `flutter analyze` = 0 opozoril (brez `unused_*`, brez `dead_code`).

---

## 10. Varnost / produkcijska varnost (checklist)

- [ ] Vsi zapisi prek repo; `userId` iz `authServiceProvider`, nikoli iz UI/extra.
- [ ] Območja v izbirnikih iz `areasListProvider` (RLS lastnik) → ni dodelitve tujega območja.
- [ ] `move` ne zbriše aliasa (vedno podaj obstoječega).
- [ ] `softDelete(area)` atomarno reparenta (transakcija) — ni osirotelih rastlin, ni odvisnosti od `ON DELETE CASCADE`.
- [ ] `mounted`/`context.mounted` po vsakem `await` pred `context`.
- [ ] Brez `Map<String,dynamic>` v widgetih (prek `userPlantLabel`/`userPlantIcon`/`catalogLabel`).
- [ ] Brez koordinat, brez skrivnosti, brez novega network klica.
- [ ] Brez spremembe sheme → stari APK varno pull-a (tolerantni parser nedotaknjen).
- [ ] Queriji omejeni: instant-add O(1) insert, move O(1) update, recent = 1 group-by+limit, iskanje in-memory nad katalogom.

---

## 11. Testi (`test/`)

Najprej `grep -rn "syncForArea\|PlantSpec\|_PlantsSection\|plant-new" test/` → posodobi/odstrani prizadete.

Dodaj:
- **Unit** `areas_repository_test.dart`: `softDelete` → rastline dobijo `areaId == null`, `syncStatus == pending`, območje `deleted`. (FakeClock)
- **Unit** `user_plants_repository_test.dart`: `recentPlantIds` vrne distinct po `updatedAt desc`, spoštuje `limit`, ignorira deleted/custom(null plantId); `update` spremeni `areaId` + `pending` + ohrani alias.
- **Widget** `garden_plant_add_test.dart`: tap katalog vrstice → nastane vrstica (mock repo) + `pop` vrne id-je; undo prekliče zadnjo.
- **Widget** `area_pick_sheet_test.dart`: izbira vrne `(areaId:)`; »Brez območja« vrne `(areaId: null)`.
- **Widget** `areas_screen_test.dart`: empty-state pokaže oba gumba; swipe-Odstrani po potrditvi pokliče `softDelete`.

---

## 12. Vrstni red (en korak = en commit; pred vsakim commitom vprašaj)

1. **`refactor(repo): vrt v4 temelji`** — `areas_repository.softDelete` reparent-fix; odstrani `syncForArea`/`createForArea`/`plant_spec.dart`; `watchByArea` ordering; `recentPlantIds` + `recentPlantsProvider`; `kRecentPlantsLimit`. (analyze bo začasno rdeč pri klicalcih — pokrije korak 5.)
2. **`feat(plants): area-pick sheet + premik`** — `area_pick_sheet.dart`; integracija v `plant_detail` (pill).
3. **`feat(plants): zaslon za dodajanje rastlin (v4)`** — `garden_plant_add_screen.dart` + `PlantAddArgs`; route `plant-add`; preusmeri `subject_step` (subjectMode).
4. **`refactor(plants): plant-edit le še urejanje`** — odstrani add/multi-area/picker; območje prek area-pick.
5. **`refactor(areas): obrazec brez rastlin + detajl z rastlinami`** — `area_form` (brez `_PlantsSection`, + izbris/reparent opomba); `area_detail` (sekcija Rastline + dodaj rastlino).
6. **`feat(areas): Vrt FAB + empty-state + novo območje + swipe`** — `areas_screen` + `main_shell` FAB.
7. **`chore(i18n): vrt v4 ključi`** — dodaj/odstrani ključe + `dart run slang`.
8. **`test: vrt v4`** — testi iz §11; **`flutter analyze` čist**, `flutter test` zelen, on-device preverba (`! deploy.bat hot`, SM A536B).
9. *(neobvezno)* **`docs: koncept §7.15 + fokus-rastlina vrt v4`** — uskladi besedilo z v4 (FAB=rastline, area_id single-select premik, brez routerja, area-form ne ureja rastlin).

---

## 13. Ukazi

```bash
dart run slang                                   # po spremembi i18n
flutter analyze                                  # mora biti čist
flutter test                                     # če lock: ubij viseče flutter_tester/dart
! deploy.bat hot                                 # on-device (SM A536B)
# shema se NE spreminja → build_runner NI potreben; providerji so manual
```

---

## 14. Definicija dokončanosti (DoD)

- [ ] Vsi koraki §12 (1–8) commitani; analyze čist; testi zeleni.
- [ ] Dodajanje rastline = 1 zaslon, tap = takoj; več naenkrat; iskanje skrito za 🔍; »Kam dodajam« na dnu.
- [ ] Premik med območji deluje iz detajla, urejanja, swipe; alias se ohrani.
- [ ] Brisanje območja preseli rastline v »Brez območja« (preverjeno z unit testom + na napravi).
- [ ] Vrt FAB → rastline; tih »Novo območje«; empty-state z dvema gumboma.
- [ ] Območje-obrazec ne ureja več rastlin; detajl območja jih našteje.
- [ ] 0 mrtve kode/ključev; UI dosleden (komponentni katalog, theme, i18n).

## 15. Odprta vprašanja

Nobenih — vse odločitve potrjene (§2). Če se med implementacijo pojavi nova dilema, ustavi in vprašaj (delovni dogovor).
