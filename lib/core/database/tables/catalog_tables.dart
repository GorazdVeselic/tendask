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
  // Days between repetitions; null = no default cadence
  IntColumn get defaultCadence => integer().nullable()();

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

class CategoryTaskTypes extends Table {
  @override
  String get tableName => 'category_task_type';

  TextColumn get category => text()();
  TextColumn get taskTypeId => text().references(TaskTypes, #id)();

  @override
  Set<Column> get primaryKey => {category, taskTypeId};
}
