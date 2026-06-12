import 'package:drift/drift.dart';

class TaskTypes extends Table {
  @override
  String get tableName => 'task_type';

  TextColumn get id => text()();
  // JSON: {"sl": "...", "en": "...", "de": "..."}
  TextColumn get labels => text()();
  TextColumn get icon => text()();
  TextColumn get category => text()();
  BoolColumn get requiresSubject =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get weatherSensitive =>
      boolean().withDefault(const Constant(false))();
  // True for types that draw from stock (fertilizing, treatment) — drives the
  // conditional "supplies" step in the entry flow.
  BoolColumn get consumesSupplies =>
      boolean().withDefault(const Constant(false))();
  // Days between repetitions; null = no default cadence
  IntColumn get defaultCadence => integer().nullable()();
  // Seasonal types get a time-percentile curve (V2); non-seasonal only feed+frequency.
  BoolColumn get seasonal => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Plants extends Table {
  @override
  String get tableName => 'plant';

  TextColumn get id => text()();
  // JSON: {"sl": "...", "en": "...", "de": "..."}
  TextColumn get labels => text()();
  TextColumn get scientificName => text().nullable()();
  TextColumn get category => text()();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlantSynonyms extends Table {
  @override
  String get tableName => 'plant_synonym';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get plantId => text().references(Plants, #id)();
  TextColumn get lang => text()();
  // Normalized (lowercase, trimmed) for fuzzy matching
  TextColumn get textNorm => text()();
}

class PlantTaskRules extends Table {
  @override
  String get tableName => 'plant_task_rule';

  // '<ref_id>.<task>[.<qualifier>]' slug, add-only (catalog id contract)
  TextColumn get id => text()();
  TextColumn get scope => text()(); // 'plant' | 'category'
  // plant.id or plant category slug, per scope
  TextColumn get refId => text()();
  TextColumn get taskTypeId => text().references(TaskTypes, #id)();
  // 'month_window' | 'frost_offset' | 'growth_stage' | 'cadence_only'
  TextColumn get timingAnchor => text()();
  // JSON, shape per anchor — docs/m11/01 §0
  TextColumn get window => text()();
  // Human-readable; machine logic reads only window
  TextColumn get cadence => text().nullable()();
  BoolColumn get frostGate => boolean().withDefault(const Constant(false))();
  // Comma-joined guard codes (docs/m11/02 §G); null = none
  TextColumn get weatherGuard => text().nullable()();
  // Citation — mandatory audit trail
  TextColumn get sourceRef => text()();
  TextColumn get confidence => text()(); // 'high' | 'medium'
  TextColumn get messageKey => text()(); // i18n key under suggestions.*

  @override
  Set<Column> get primaryKey => {id};
}

class CategoryTaskTypes extends Table {
  @override
  String get tableName => 'category_task_type';

  TextColumn get category => text()();
  TextColumn get taskTypeId => text().references(TaskTypes, #id)();

  @override
  Set<Column> get primaryKey => {category, taskTypeId};
}
