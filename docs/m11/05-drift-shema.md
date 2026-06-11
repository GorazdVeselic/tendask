# Poglavje 5 — Drift spremembe (lokalna SQLite)

> Drift mora zrcaliti Supabase (CLAUDE.md §Sync). Vse spremembe so **additive** →
> `schemaVersion` +1 in `onUpgrade` z `m.addColumn` / `m.createTable`. Po spremembi:
> `dart run build_runner build --delete-conflicting-outputs`.
> **Gotcha:** `app_database.dart` mora importati vse nove enum-e/tabele, sicer part-of
> `*.g.dart` javi »Type not found« (ujame šele `flutter test`).

## 5.1 `profile` — novi stolpci

```dart
// lib/core/database/tables/user_tables.dart — Profiles (dopolnitev)
class Profiles extends Table {
  // ... obstoječe ...
  // IANA timezone (e.g. 'Europe/Ljubljana'); set on device, used server-side.
  TextColumn get timezone => text().nullable()();
  // Coarse public climate bucket (e.g. 'e1_t5') — the ONLY climate data synced
  // into public aggregates.
  TextColumn get climateBucket => text().nullable()();
  // Rich owner-only climate profile (JSON, see docs/m11/07) — never aggregated.
  TextColumn get climateProfile => text().nullable()();
  // FCM push token (MVP: last device wins). Cleared on sign-out.
  TextColumn get fcmToken => text().nullable()();
  DateTimeColumn get fcmTokenUpdatedAt => dateTime().nullable()();
}
```
- **Migracija:** additive (`m.addColumn` ×5).
- **Bere/piše:** `LocationRepository` (timezone + climate ob nastavitvi lokacije, gl. 07),
  `FcmTokenService` (token, gl. 06), `SyncPushService`/`SyncPullService` (obstoječi vzorec —
  dopolni `remote_mappers.dart`).

## 5.2 `task` — nov stolpec `agg_context`

```dart
class Tasks extends Table {
  // ... obstoječe ...
  // Frozen aggregation buckets snapshot ({h3_r7,h3_r6,h3_r5,climate_bucket}),
  // stamped on completion like the weather snapshot; never overwritten.
  TextColumn get aggContext => text().nullable()();
}
```
- **Migracija:** additive.
- **Piše:** `TasksRepository` — ob prehodu `status → done` (ista koda kot vremenski posnetek;
  vrednosti iz `profile` v drift). Ob `↩ Na čaka` se posnetek NE briše (zamrznjen je za
  zgodovinsko semantiko; ponovni `done` ga prepiše z aktualnim).
- **Bere:** samo strežniški cron (klient ga ne prikazuje).

## 5.3 `suggestion` (nova, sinhronizirana) + `suggestion_log` (nova, pull-only zrcalo)

```dart
// lib/core/database/tables/user_tables.dart
class Suggestions extends Table {
  @override
  String get tableName => 'suggestion';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get ruleId => text()();                       // 'R1'..'R7'
  TextColumn get plantTaskRuleId => text().nullable()();
  TextColumn get taskTypeId => text().references(TaskTypes, #id)();
  TextColumn get userPlantId => text().nullable().references(UserPlants, #id)();
  TextColumn get areaId => text().nullable().references(Areas, #id)();
  TextColumn get subjectKey => text()();
  TextColumn get messageKey => text()();
  // JSON params for the i18n template; client only interpolates, never computes.
  TextColumn get messageParams => text().withDefault(const Constant('{}'))();
  RealColumn get score => real()();
  TextColumn get status =>
      textEnum<SuggestionStatus>().withDefault(const Constant('new'))();
  // 'season' | 'forever' — meaningful only with status='dismissed' (docs/m11/03 §Akcije).
  TextColumn get dismissScope =>
      text().withDefault(const Constant('season'))();
  TextColumn get plannedTaskId => text().nullable()();
  DateTimeColumn get validUntil => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(kSyncSynced))();   // server-authored: synced by default

  @override
  Set<Column> get primaryKey => {id};
}

// lib/core/suggestion_status.dart
// POZOR: 'new' je Dart rezervirana beseda, DB vrednost pa MORA biti 'new' (zrcalo
// Supabase) — drift textEnum ne zna remap-ati. ODLOČITEV: navaden TextColumn `status`
// + top-level konstante (vzorec kot sync_status), brez textEnum za to polje:
// kSuggestionNew='new', kSuggestionPlanned='planned', kSuggestionDismissed='dismissed',
// kSuggestionLogged='logged', kSuggestionExpired='expired';
// kDismissScopeSeason='season', kDismissScopeForever='forever'.

class SuggestionLogs extends Table {
  @override
  String get tableName => 'suggestion_log';

  TextColumn get userId => text()();
  TextColumn get ruleId => text()();
  TextColumn get subjectKey => text()();
  DateTimeColumn get lastSuggestedAt => dateTime().nullable()();
  DateTimeColumn get dismissedUntil => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  // Pull-only mirror: no syncStatus column — the client NEVER pushes this table.

  @override
  Set<Column> get primaryKey => {userId, ruleId, subjectKey};
}
```
- **Migracija:** `m.createTable` ×2.
- **Sync registracija:**
  - `suggestion`: pull (standardni inkrementalni `updated_at`) **+ push** — a push pošilja
    SAMO vrstice, ki jih je klient spremenil (status Načrtuj/Opusti → `sync_status=pending`).
    Privzeti `sync_status` je `synced` (strežnik je avtor) → pull ne ustvarja pending šuma.
  - `suggestion_log`: SAMO pull (dodaj v `sync_pull_service`, NE v `sync_push_service`).
- **Bere:** `SuggestionRepository.watchActive()` (pas Domov). **Piše:** `SuggestionRepository`
  (`markPlanned`/`dismiss` → status + `updated_at` + `sync_status=pending`).
- **Gost (brez računa):** motor teče samo strežniško → gost predlogov nima (pas se ne pokaže).
  To je sprejeta MVP omejitev — dokumentirana v Settings copy (»predlogi zahtevajo račun«).

## 5.4 `plant_task_rule` (nova, katalog — seed ob zagonu + redki pull)

```dart
// lib/core/database/tables/catalog_tables.dart
class PlantTaskRules extends Table {
  @override
  String get tableName => 'plant_task_rule';

  TextColumn get id => text()();
  TextColumn get scope => text()();                        // 'plant' | 'category'
  TextColumn get refId => text()();
  TextColumn get taskTypeId => text().references(TaskTypes, #id)();
  TextColumn get timingAnchor => text()();
  TextColumn get window => text()();                       // JSON per anchor
  TextColumn get cadence => text().nullable()();
  BoolColumn get frostGate => boolean().withDefault(const Constant(false))();
  TextColumn get weatherGuard => text().nullable()();
  TextColumn get sourceRef => text()();
  TextColumn get confidence => text()();                   // 'high' | 'medium'
  TextColumn get messageKey => text()();

  @override
  Set<Column> get primaryKey => {id};
}
```
- **Migracija:** `m.createTable` + seed v `seed_service.dart` (bundlan
  `lib/data/seed/plant_task_rules_seed.dart` — isti offline-first vzorec kot katalog rastlin).
- **Sync:** dodaj v `catalog_sync_service.dart` (pull ob zagonu/reconnect — oblak je vir resnice).
- **Bere (MVP):** nihče kritičen — motor teče strežniško. Lokalna kopija je za prihodnje UI
  namige (»okno obreza: tedni 6–11«) na detajlu rastline; vključimo jo zdaj, ker je strošek
  minimalen, dvojni seed kasneje pa drag.

## 5.5 `task_type.seasonal` (katalog, nov stolpec)

```dart
class TaskTypes extends Table {
  // ... obstoječe ...
  // Seasonal types get a time-percentile curve (V2); non-seasonal only feed+frequency.
  BoolColumn get seasonal => boolean().withDefault(const Constant(true))();
}
```
- **Migracija:** additive; seed posodobi `catalog_seed.dart` (`seasonal: false` za
  `water`, `weed`, `stake`, `repot`).

## 5.6 V2 dnevni cache okolice (nova, lokalna — brez sync stolpcev)

```dart
// lib/features/community/data/ — drift tabela (lokalni dnevni cache rezine agregata,
// skupnost-agregacija.md §12.4; vzorec kot weather cache)
class CommunityCaches extends Table {
  @override
  String get tableName => 'community_cache';

  // Cache key: '<metric>|<resolution>|<bucket_key>|<task_type_id>|<plant_id>'
  TextColumn get key => text()();
  TextColumn get payload => text()();                      // JSON slice
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
```
- **Migracija:** `m.createTable` (šele v koraku M11.19).
- **Bere/piše:** `CommunityRepository` (gl. 08 §8.3). Ob odjavi se počisti kot ostale tabele.

## 5.7 Povzetek migracije

| Sprememba | Vrsta | Korak |
|---|---|---|
| `profile` +5 stolpcev | addColumn | M11.2 |
| `task.agg_context` | addColumn | M11.2 |
| `task_type.seasonal` | addColumn + seed | M11.2 |
| `suggestion`, `suggestion_log` | createTable | M11.2 |
| `plant_task_rule` | createTable + seed | M11.4 |
| `community_cache` | createTable | M11.19 |

`schemaVersion`: en bump na korak, ki spreminja shemo (M11.2 → +1, M11.4 → +1, M11.19 → +1);
`onUpgrade` stopničasto (`from < N`) po obstoječem vzorcu v `app_database.dart`.
