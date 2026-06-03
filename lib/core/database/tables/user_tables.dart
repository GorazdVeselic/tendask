import 'package:drift/drift.dart';

import '../../area_type.dart';
import '../../task_status.dart';
import 'catalog_tables.dart';

/// Sync-ready pattern: every user row has id (UUID, device-generated),
/// updated_at (for LWW pull), deleted (soft delete), sync_status (local only).

class Profiles extends Table {
  @override
  String get tableName => 'profile';

  TextColumn get userId => text()();
  TextColumn get h3R7 => text().nullable()();
  TextColumn get h3R6 => text().nullable()();
  TextColumn get h3R5 => text().nullable()();
  TextColumn get lang => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {userId};
}

class Areas extends Table {
  @override
  String get tableName => 'area';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  // lawn, hedge, bed, tree, ornamental, other
  TextColumn get type =>
      textEnum<AreaType>().withDefault(const Constant('other'))();
  // True for greenhouse/indoor — excluded from weather guards (§7.7)
  BoolColumn get protected =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserPlants extends Table {
  @override
  String get tableName => 'user_plant';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  // Nullable: a plant may have no named area (e.g. a pot on the terrace).
  TextColumn get areaId => text().nullable().references(Areas, #id)();
  // Null when is_custom = true (no catalog match)
  TextColumn get plantId =>
      text().nullable().references(Plants, #id)();
  TextColumn get customName => text().nullable()();
  TextColumn get personalAlias => text().nullable()();
  BoolColumn get isCustom =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  @override
  String get tableName => 'task';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  // Subjects (plants/areas) live in TaskSubjects — task is M:N with subjects.
  TextColumn get taskTypeId => text().references(TaskTypes, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status =>
      textEnum<TaskStatus>().withDefault(const Constant('waiting'))();
  TextColumn get note => text().nullable()();
  // Frozen weather snapshot (JSON); set on completion, never overwritten
  TextColumn get weather => text().nullable()();
  // JSON recurrence rule; null = one-off
  TextColumn get recurrence => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// M:N link between a task and its subjects (a plant OR an area-as-subject).
/// One row per subject; CHECK guarantees at least one of the two FKs is set.
class TaskSubjects extends Table {
  @override
  String get tableName => 'task_subject';

  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  // Subject = plant (user_plant_id) OR area-as-subject (area_id); never neither.
  TextColumn get userPlantId =>
      text().nullable().references(UserPlants, #id)();
  TextColumn get areaId => text().nullable().references(Areas, #id)();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK (user_plant_id IS NOT NULL OR area_id IS NOT NULL)',
      ];
}

class TaskReminders extends Table {
  @override
  String get tableName => 'task_reminder';

  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  // Minutes before task date; 0 = at event time
  IntColumn get offset => integer()();
  // HH:mm time of day for the notification (nullable = use task time)
  TextColumn get reminderTime => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Notes extends Table {
  @override
  String get tableName => 'note';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get areaId => text().nullable().references(Areas, #id)();
  TextColumn get userPlantId =>
      text().nullable().references(UserPlants, #id)();
  DateTimeColumn get date => dateTime()();
  // 'text' is a drift builder method — use named() to keep the SQL column name
  TextColumn get content => text().named('text')();
  // Weather snapshot at time of note (JSON)
  TextColumn get weather => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Supplies extends Table {
  @override
  String get tableName => 'supply';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  // kg, l, piece, etc.
  TextColumn get unit => text().nullable()();
  RealColumn get quantity =>
      real().withDefault(const Constant(0.0))();
  // Warn when quantity drops below this; null = no threshold
  RealColumn get lowThreshold => real().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Recipes extends Table {
  @override
  String get tableName => 'recipe';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  // Equipment the recipe is calibrated for (e.g. "16L sprayer")
  TextColumn get equipment => text().nullable()();
  // JSON: [{supply_id, amount, unit}]
  TextColumn get items => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class TaskSupplies extends Table {
  @override
  String get tableName => 'task_supply';

  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get supplyId => text().references(Supplies, #id)();
  RealColumn get amount => real()();
  // True once this consumption was booked into supply.quantity (task done) —
  // guards against double deduction / double return.
  BoolColumn get applied => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
