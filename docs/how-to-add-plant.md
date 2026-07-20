# Kako dodati rastlino v katalog

> **Status:** ŽIV DOKUMENT · operativna navodila
> **Vir resnice za vsebino:** `docs/opravila-in-rastline.md` (kategorije, opravila)
> **Pravila:** `CLAUDE.md` → »Sync, čas in shema«, »Katalog«

Katalog rastlin ima **en sam vir resnice**: `lib/data/seed/catalog_seed.dart`
(`CatalogSeed.plants`). Imena (`sl`/`en`/`de`) so **vgrajena v seed**, **ne** v slang/i18n —
slang se dotakneš **samo** ob uvedbi nove kategorije (chip label).

## Tok do naprave (zakaj sta potrebna seed + oblak)

- **Nove namestitve offline** → `SeedService.runIfNeeded()` napolni drift iz bundlanega
  seeda, a **samo če je tabela prazna** — obstoječim napravam novih vrstic **ne** doda.
- **Obstoječe naprave** → `CatalogSyncService.pull()` naredi **poln pull** celotnega
  kataloga iz oblaka (ni inkrementalno; katalog nima `updated_at`). Nove vrstice pridejo
  ob naslednjem catalog syncu — **zato je nujno aplicirati `catalog.sql` na oblak.**
- **Oblak** se (re)materializira iz seeda prek `tool/gen_catalog_sql.dart` →
  `supabase/seed/catalog.sql` → `supabase/seed/apply_catalog.py`.

## Checklist — vsaka rastlina

1. **`lib/data/seed/catalog_seed.dart`** → dodaj `PlantSeed(...)` v `CatalogSeed.plants`,
   v ustrezno kategorijsko sekcijo:
   - `id` — stabilen slug (`snake_case`, angleško). **Add-only — NIKOLI preimenuj/izbriši**
     (`user_plant.plant_id` kaže nanj; preimenovanje osiroti FK).
   - `sl`, `en`, `de` — imena (mala začetnica, kot ostala v katalogu).
   - `icon` — emoji (osnutek; finalno oblikovanje kasneje).
   - `category` — ena od obstoječih (gl. spodaj) ali nova (gl. razdelek »Nova kategorija«).
   - `scientificName` — latinsko ime (priporočeno; pomaga pri V2 širjenju iz Wikidata/GBIF).
2. **Regeneriraj oblačni SQL:** `dart run tool/gen_catalog_sql.dart` → prepiše
   `supabase/seed/catalog.sql`.
3. **Testi:** `flutter test` — `catalog_sql_parity_test` pade, če pozabiš korak 2;
   `seed_service_test` bere dolžine dinamično (count-a ti ni treba ažurirati).
4. **Apliciraj na oblak** — sicer obstoječe naprave nove rastline ne dobijo. Upsert je
   idempotenten (`on conflict do update`), aditiven in ga je varno pognati večkrat.
   - **Produkcija:** `python supabase/seed/apply_catalog.py` (ref in pooler sta trdo zapisana
     v skripti; geslo iz `.env`). Izpiše števce — preveri, da je `plant=` pričakovan.
   - **Staging:** skripta staging varante **nima**. Postavitev teče v WSL, Postgres pa ni v
     tunelu, zato gre prek containerja (brez gesla, `docker exec` kot superuser):
     ```bash
     wsl -e bash -lc "cat /mnt/c/Users/Uporabnik/StudioProjects/tendask/supabase/seed/catalog.sql \
       | docker exec -i supabase-db psql -v ON_ERROR_STOP=1 -U postgres -d postgres"
     ```
     Staging mora teči (`tendask start`). Zadnje vrstice `INSERT 0 0` so normalne —
     to so `category_task_type` vrstice z `on conflict do nothing`.

## Kdaj rastlina pride do uporabnika

**Nova izdaja aplikacije NI potrebna** — gre za podatke, ne kodo; dobijo jih tudi naprave na
starejšem buildu. `CatalogSyncService.pull()` naredi **poln** pull kataloga in se sproži:

- **ob vsakem zagonu aplikacije** — `SyncCoordinator.start()` z `includeCatalog: true`;
- **ob vrnitvi povezave** — prehod offline → online.

Periodični sync kataloga namenoma **ne** vleče (redko se spreminja). Deluje tudi za **goste**
(katalog je javno berljiv, seja ni potrebna). Brez povezave se ne zgodi nič — bundlan seed polni
samo **prazno** tabelo, zato obstoječim napravam novih vrstic ne doda; od tod nujnost koraka 4.

## Obstoječe kategorije (brez dodatnega dela)

`fruit_tree`, `citrus`, `berries`, `vegetable`, `herbs`, `perennial`, `shrub`, `climber`,
`bulb`, `conifer`, `hedge`, `houseplant`, `lawn`.

Če rastlina pripada eni od teh, **ne rabiš nič drugega** — skupina opravil
(`categoryMatrix`) in chip filter že obstajata. Coarse fold za chip izbirnik:
`perennial/shrub/climber/bulb/conifer/hedge → ornamental`, `citrus → fruit_tree`,
ostale se preslikajo same vase (`lib/core/plant_category.dart`).

## Nova kategorija (dodatno delo)

Potrebno samo, če rastline ne moreš smiselno uvrstiti v obstoječo skupino opravil.

5. **`CatalogSeed.categoryMatrix`** (`catalog_seed.dart`) → dodaj pare
   `('<kategorija>', '<task_type_id>')` = katera opravila veljajo za to skupino.
   Veljavni `task_type_id`-ji so v `CatalogSeed.taskTypes`.
6. **`lib/core/plant_category.dart`**:
   - `coarsePlantCategory()` → zloži novo kategorijo v obstoječ coarse bucket
     (npr. `'citrus' => 'fruit_tree'`) — **ali** dodaj nov bucket v `kPlantCategories`.
   - Če nov bucket → tudi `plantCategoryLabel()`.
7. **Slang (samo ob novem coarse bucketu):** dodaj ključ `plants.cat_<ime>` v
   `lib/i18n/{sl,en,de}.i18n.json`, nato `dart run slang`.

> Zlaganje v obstoječ coarse bucket (kot `citrus → fruit_tree`) se izogne koraku 7 in
> ohrani kratke chipe — priporočeno, kadar je smiselno.

## Česa NE rabiš

- **i18n za imena rastlin** — so v seedu, ne v slang.
- **`plant_synonym`** — tabela obstaja v shemi, a se iz seeda **ne** polni; sinonimov ne
  dodajaš (in se trenutno ne indeksirajo za iskanje po imenu).
- **drift migracije** — katalog tabele se ne spreminjajo ob dodajanju vrstic.

## Opomba: pametni motor (M11)

Na branchu `feat/m11-smart-engine` obstaja sloj **pravil predlogov** (`suggestion`), ki
referencira `plant_id`. Nove rastline tam **nimajo** pravil (predlogov), dokler jih ročno
ne dodaš v rules seed — to je ločen, neobvezen korak na tem branchu.
