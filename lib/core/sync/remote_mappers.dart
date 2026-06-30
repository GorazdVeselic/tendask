import 'dart:convert';

import 'package:drift/drift.dart';

import '../area_type.dart';
import '../database/app_database.dart';
import '../task_status.dart';
import 'sync_status.dart';

/// Maps a drift data class to the Postgres row shape the push upsert sends.
/// Pure (no I/O) so the push payload is unit-testable without Supabase.
///
/// Three things drift's own toJson() gets wrong for the cloud and we fix here:
///   * keys are camelCase in drift, snake_case in Postgres;
///   * DateTime serializes to an int in drift, timestamptz wants ISO-8601 UTC;
///   * jsonb columns are stored as JSON strings locally — Postgres wants the
///     decoded object, not a quoted string.
/// `sync_status` is deliberately never sent (local-only column).

String _ts(DateTime d) => d.toUtc().toIso8601String();

Object? _jsonb(String? s) => s == null ? null : jsonDecode(s);

Map<String, dynamic> profileToRemote(Profile r) => {
  'user_id': r.userId,
  'h3_r7': r.h3R7,
  'h3_r6': r.h3R6,
  'h3_r5': r.h3R5,
  'lang': r.lang,
  'notification_settings': _jsonb(r.notificationSettings),
  'default_garden_seeded': r.defaultGardenSeeded,
  'updated_at': _ts(r.updatedAt),
};

Map<String, dynamic> areaToRemote(Area r) => {
  'id': r.id,
  'user_id': r.userId,
  'name': r.name,
  'type': r.type.name,
  'protected': r.protected,
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

Map<String, dynamic> userPlantToRemote(UserPlant r) => {
  'id': r.id,
  'user_id': r.userId,
  'area_id': r.areaId,
  'plant_id': r.plantId,
  'custom_name': r.customName,
  'personal_alias': r.personalAlias,
  'is_custom': r.isCustom,
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

Map<String, dynamic> taskToRemote(Task r) => {
  'id': r.id,
  'user_id': r.userId,
  'task_type_id': r.taskTypeId,
  'date': _ts(r.date),
  'status': r.status.name,
  'note': r.note,
  'weather': _jsonb(r.weather),
  'recurrence': _jsonb(r.recurrence),
  'series_id': r.seriesId,
  'yield_amount': r.yieldAmount,
  'yield_unit': r.yieldUnit,
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

Map<String, dynamic> taskSubjectToRemote(TaskSubject r) => {
  'id': r.id,
  'task_id': r.taskId,
  'user_plant_id': r.userPlantId,
  'area_id': r.areaId,
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

Map<String, dynamic> taskReminderToRemote(TaskReminder r) => {
  'id': r.id,
  'task_id': r.taskId,
  'offset': r.offset,
  'reminder_time': r.reminderTime,
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

Map<String, dynamic> noteToRemote(Note r) => {
  'id': r.id,
  'user_id': r.userId,
  'area_id': r.areaId,
  'user_plant_id': r.userPlantId,
  'date': _ts(r.date),
  'text': r.content,
  'weather': _jsonb(r.weather),
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

Map<String, dynamic> supplyToRemote(Supply r) => {
  'id': r.id,
  'user_id': r.userId,
  'name': r.name,
  'unit': r.unit,
  'quantity': r.quantity,
  'low_threshold': r.lowThreshold,
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

Map<String, dynamic> recipeToRemote(Recipe r) => {
  'id': r.id,
  'user_id': r.userId,
  'name': r.name,
  'equipment': r.equipment,
  'items': _jsonb(r.items),
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

Map<String, dynamic> taskSupplyToRemote(TaskSupply r) => {
  'id': r.id,
  'task_id': r.taskId,
  'supply_id': r.supplyId,
  'amount': r.amount,
  'applied': r.applied,
  'updated_at': _ts(r.updatedAt),
  'deleted': r.deleted,
};

// ── Remote → drift (pull) ───────────────────────────────────────────────────
//
// Maps a Postgres row (decoded JSON from supabase) to a drift Companion stamped
// `synced` (it came from the cloud). Pure so the parse is unit-testable. Mirror
// of the *ToRemote maps above, plus the inverse conversions:
//   * ISO-8601 timestamptz string → DateTime;
//   * jsonb (decoded to a Map/List by supabase) → JSON string for the TEXT cell;
//   * enum string → enum, tolerantly (unknown value falls back to the default).
// Tolerant by design: unknown keys are ignored, missing optionals default.

DateTime _dt(Object? v) => DateTime.parse(v as String);

String? _text(Object? v) {
  if (v == null) return null;
  if (v is String) return v; // already JSON text — don't double-encode
  return jsonEncode(v);
}

double? _double(Object? v) => (v as num?)?.toDouble();

AreaType _areaType(Object? v) => AreaType.values.firstWhere(
  (e) => e.name == v,
  orElse: () => AreaType.other,
);

TaskStatus _taskStatus(Object? v) => TaskStatus.values.firstWhere(
  (e) => e.name == v,
  orElse: () => TaskStatus.waiting,
);

ProfilesCompanion profileFromRemote(Map<String, dynamic> r) =>
    ProfilesCompanion(
      userId: Value(r['user_id'] as String),
      h3R7: Value(r['h3_r7'] as String?),
      h3R6: Value(r['h3_r6'] as String?),
      h3R5: Value(r['h3_r5'] as String?),
      lang: Value(r['lang'] as String?),
      notificationSettings: Value(_text(r['notification_settings'])),
      defaultGardenSeeded: Value(r['default_garden_seeded'] as bool? ?? false),
      updatedAt: Value(_dt(r['updated_at'])),
      syncStatus: const Value(kSyncSynced),
    );

AreasCompanion areaFromRemote(Map<String, dynamic> r) => AreasCompanion(
  id: Value(r['id'] as String),
  userId: Value(r['user_id'] as String),
  name: Value(r['name'] as String),
  type: Value(_areaType(r['type'])),
  protected: Value(r['protected'] as bool? ?? false),
  updatedAt: Value(_dt(r['updated_at'])),
  deleted: Value(r['deleted'] as bool? ?? false),
  syncStatus: const Value(kSyncSynced),
);

UserPlantsCompanion userPlantFromRemote(Map<String, dynamic> r) =>
    UserPlantsCompanion(
      id: Value(r['id'] as String),
      userId: Value(r['user_id'] as String),
      areaId: Value(r['area_id'] as String?),
      plantId: Value(r['plant_id'] as String?),
      customName: Value(r['custom_name'] as String?),
      personalAlias: Value(r['personal_alias'] as String?),
      isCustom: Value(r['is_custom'] as bool? ?? false),
      updatedAt: Value(_dt(r['updated_at'])),
      deleted: Value(r['deleted'] as bool? ?? false),
      syncStatus: const Value(kSyncSynced),
    );

TasksCompanion taskFromRemote(Map<String, dynamic> r) => TasksCompanion(
  id: Value(r['id'] as String),
  userId: Value(r['user_id'] as String),
  taskTypeId: Value(r['task_type_id'] as String),
  date: Value(_dt(r['date'])),
  status: Value(_taskStatus(r['status'])),
  note: Value(r['note'] as String?),
  weather: Value(_text(r['weather'])),
  recurrence: Value(_text(r['recurrence'])),
  seriesId: Value(r['series_id'] as String?),
  // Unit stored as-is (tolerant): an unknown value round-trips; the display
  // layer parses it leniently. Amount is numeric → double, or null.
  yieldAmount: Value(_double(r['yield_amount'])),
  yieldUnit: Value(r['yield_unit'] as String?),
  updatedAt: Value(_dt(r['updated_at'])),
  deleted: Value(r['deleted'] as bool? ?? false),
  syncStatus: const Value(kSyncSynced),
);

TaskSubjectsCompanion taskSubjectFromRemote(Map<String, dynamic> r) =>
    TaskSubjectsCompanion(
      id: Value(r['id'] as String),
      taskId: Value(r['task_id'] as String),
      userPlantId: Value(r['user_plant_id'] as String?),
      areaId: Value(r['area_id'] as String?),
      updatedAt: Value(_dt(r['updated_at'])),
      deleted: Value(r['deleted'] as bool? ?? false),
      syncStatus: const Value(kSyncSynced),
    );

TaskRemindersCompanion taskReminderFromRemote(Map<String, dynamic> r) =>
    TaskRemindersCompanion(
      id: Value(r['id'] as String),
      taskId: Value(r['task_id'] as String),
      offset: Value((r['offset'] as num).toInt()),
      reminderTime: Value(r['reminder_time'] as String?),
      updatedAt: Value(_dt(r['updated_at'])),
      deleted: Value(r['deleted'] as bool? ?? false),
      syncStatus: const Value(kSyncSynced),
    );

NotesCompanion noteFromRemote(Map<String, dynamic> r) => NotesCompanion(
  id: Value(r['id'] as String),
  userId: Value(r['user_id'] as String),
  areaId: Value(r['area_id'] as String?),
  userPlantId: Value(r['user_plant_id'] as String?),
  date: Value(_dt(r['date'])),
  content: Value(r['text'] as String),
  weather: Value(_text(r['weather'])),
  updatedAt: Value(_dt(r['updated_at'])),
  deleted: Value(r['deleted'] as bool? ?? false),
  syncStatus: const Value(kSyncSynced),
);

SuppliesCompanion supplyFromRemote(Map<String, dynamic> r) => SuppliesCompanion(
  id: Value(r['id'] as String),
  userId: Value(r['user_id'] as String),
  name: Value(r['name'] as String),
  unit: Value(r['unit'] as String?),
  quantity: Value(_double(r['quantity']) ?? 0),
  lowThreshold: Value(_double(r['low_threshold'])),
  updatedAt: Value(_dt(r['updated_at'])),
  deleted: Value(r['deleted'] as bool? ?? false),
  syncStatus: const Value(kSyncSynced),
);

RecipesCompanion recipeFromRemote(Map<String, dynamic> r) => RecipesCompanion(
  id: Value(r['id'] as String),
  userId: Value(r['user_id'] as String),
  name: Value(r['name'] as String),
  equipment: Value(r['equipment'] as String?),
  items: Value(_text(r['items'])),
  updatedAt: Value(_dt(r['updated_at'])),
  deleted: Value(r['deleted'] as bool? ?? false),
  syncStatus: const Value(kSyncSynced),
);

TaskSuppliesCompanion taskSupplyFromRemote(Map<String, dynamic> r) =>
    TaskSuppliesCompanion(
      id: Value(r['id'] as String),
      taskId: Value(r['task_id'] as String),
      supplyId: Value(r['supply_id'] as String),
      amount: Value((r['amount'] as num).toDouble()),
      applied: Value(r['applied'] as bool? ?? false),
      updatedAt: Value(_dt(r['updated_at'])),
      deleted: Value(r['deleted'] as bool? ?? false),
      syncStatus: const Value(kSyncSynced),
    );

// ── Catalog: remote → drift (pull) ──────────────────────────────────────────
//
// Read-only catalog. No sync_status/updated_at/deleted — it is not per-user
// synced; the cloud is the source of truth and ids are stable slugs, so the
// upsert merges into any seeded rows. `labels` is jsonb (a Map from supabase) →
// stored as a JSON string, matching the on-device seed.

TaskTypesCompanion taskTypeFromRemote(Map<String, dynamic> r) =>
    TaskTypesCompanion(
      id: Value(r['id'] as String),
      labels: Value(_text(r['labels']) ?? '{}'),
      icon: Value(r['icon'] as String),
      category: Value(r['category'] as String),
      requiresSubject: Value(r['requires_subject'] as bool? ?? false),
      weatherSensitive: Value(r['weather_sensitive'] as bool? ?? false),
      consumesSupplies: Value(r['consumes_supplies'] as bool? ?? false),
      defaultCadence: Value((r['default_cadence'] as num?)?.toInt()),
    );

PlantsCompanion plantFromRemote(Map<String, dynamic> r) => PlantsCompanion(
  id: Value(r['id'] as String),
  labels: Value(_text(r['labels']) ?? '{}'),
  scientificName: Value(r['scientific_name'] as String?),
  category: Value(r['category'] as String),
  icon: Value(r['icon'] as String?),
);

CategoryTaskTypesCompanion categoryTaskTypeFromRemote(Map<String, dynamic> r) =>
    CategoryTaskTypesCompanion(
      category: Value(r['category'] as String),
      taskTypeId: Value(r['task_type_id'] as String),
    );
