import 'dart:convert';

import '../database/app_database.dart';

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
