import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/sync/remote_mappers.dart';
import 'package:tendask/core/sync/sync_status.dart';
import 'package:tendask/core/task_status.dart';

void main() {
  final t0 = DateTime.utc(2026, 6, 5, 10);

  test('areaToRemote: snake_case keys, enum.name, no sync_status', () {
    final map = areaToRemote(Area(
      id: 'a1',
      userId: 'u1',
      name: 'Bed',
      type: AreaType.bed,
      protected: true,
      updatedAt: t0,
      deleted: false,
      syncStatus: kSyncPending,
    ));
    expect(map, {
      'id': 'a1',
      'user_id': 'u1',
      'name': 'Bed',
      'type': 'bed',
      'protected': true,
      'updated_at': '2026-06-05T10:00:00.000Z',
      'deleted': false,
    });
    expect(map.containsKey('sync_status'), isFalse);
  });

  test('taskToRemote: jsonb decoded, status.name, UTC timestamps', () {
    final map = taskToRemote(Task(
      id: 't1',
      userId: 'u1',
      taskTypeId: 'water',
      date: t0,
      status: TaskStatus.done,
      note: 'hi',
      weather: '{"tempC":5,"code":61}',
      recurrence: null,
      updatedAt: t0,
      deleted: false,
      syncStatus: kSyncSynced,
    ));
    expect(map['status'], 'done');
    expect(map['date'], '2026-06-05T10:00:00.000Z');
    // jsonb column stored as a JSON string locally → decoded object for Postgres.
    expect(map['weather'], {'tempC': 5, 'code': 61});
    expect(map['recurrence'], isNull);
    expect(map.containsKey('sync_status'), isFalse);
  });

  test('taskToRemote: local DateTime is normalized to UTC', () {
    // A non-UTC instant must still serialize as the same absolute time in Z.
    final local = DateTime.utc(2026, 6, 5, 8).toLocal();
    final map = taskToRemote(Task(
      id: 't1',
      userId: 'u1',
      taskTypeId: 'water',
      date: local,
      status: TaskStatus.waiting,
      updatedAt: local,
      deleted: false,
      syncStatus: kSyncPending,
    ));
    expect(map['date'], '2026-06-05T08:00:00.000Z');
  });

  test('profileToRemote: no deleted column, nullable cells pass through', () {
    final map = profileToRemote(Profile(
      userId: 'u1',
      h3R7: 'abc',
      h3R6: null,
      h3R5: null,
      lang: 'sl',
      updatedAt: t0,
      syncStatus: kSyncPending,
    ));
    expect(map, {
      'user_id': 'u1',
      'h3_r7': 'abc',
      'h3_r6': null,
      'h3_r5': null,
      'lang': 'sl',
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(map.containsKey('deleted'), isFalse);
  });

  test('noteToRemote: content maps to the "text" column', () {
    final map = noteToRemote(Note(
      id: 'n1',
      userId: 'u1',
      areaId: null,
      userPlantId: null,
      date: t0,
      content: 'first frost',
      weather: null,
      updatedAt: t0,
      deleted: false,
      syncStatus: kSyncPending,
    ));
    expect(map['text'], 'first frost');
    expect(map.containsKey('content'), isFalse);
  });

  test('taskReminderToRemote: offset key, nullable reminder_time', () {
    final map = taskReminderToRemote(TaskReminder(
      id: 'r1',
      taskId: 't1',
      offset: 120,
      reminderTime: null,
      updatedAt: t0,
      deleted: false,
      syncStatus: kSyncPending,
    ));
    expect(map['offset'], 120);
    expect(map['reminder_time'], isNull);
    expect(map['task_id'], 't1');
  });

  test('supplyToRemote: nullable low_threshold and double quantity', () {
    final map = supplyToRemote(Supply(
      id: 's1',
      userId: 'u1',
      name: 'Compost',
      unit: 'kg',
      quantity: 12.5,
      lowThreshold: null,
      updatedAt: t0,
      deleted: false,
      syncStatus: kSyncPending,
    ));
    expect(map['quantity'], 12.5);
    expect(map['low_threshold'], isNull);
  });

  // ── Remote → drift (pull) ─────────────────────────────────────────────────

  test('areaFromRemote: parses ISO + enum, stamps synced', () {
    final c = areaFromRemote({
      'id': 'a1',
      'user_id': 'u1',
      'name': 'Bed',
      'type': 'bed',
      'protected': true,
      'updated_at': '2026-06-05T10:00:00.000Z',
      'deleted': false,
    });
    expect(c.id.value, 'a1');
    expect(c.type.value, AreaType.bed);
    expect(c.protected.value, isTrue);
    expect(c.updatedAt.value.isAtSameMomentAs(t0), isTrue);
    expect(c.syncStatus.value, kSyncSynced);
  });

  test('areaFromRemote: unknown enum falls back to the default (tolerant)', () {
    final c = areaFromRemote({
      'id': 'a1',
      'user_id': 'u1',
      'name': 'X',
      'type': 'patio', // not a known AreaType
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(c.type.value, AreaType.other);
    expect(c.protected.value, isFalse); // missing optional → default
  });

  test('taskFromRemote: jsonb object re-encoded to text, status parsed', () {
    final c = taskFromRemote({
      'id': 't1',
      'user_id': 'u1',
      'task_type_id': 'water',
      'date': '2026-06-05T10:00:00.000Z',
      'status': 'done',
      'note': null,
      // supabase decodes jsonb to a Map → store as a JSON string in drift.
      'weather': {'tempC': 5, 'code': 61},
      'recurrence': null,
      'updated_at': '2026-06-05T10:00:00.000Z',
      'deleted': false,
    });
    expect(c.status.value, TaskStatus.done);
    expect(c.weather.value, jsonEncode({'tempC': 5, 'code': 61}));
    expect(c.recurrence.value, isNull);
  });

  test('taskFromRemote: unknown status falls back to waiting', () {
    final c = taskFromRemote({
      'id': 't1',
      'user_id': 'u1',
      'task_type_id': 'water',
      'date': '2026-06-05T10:00:00.000Z',
      'status': 'archived',
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(c.status.value, TaskStatus.waiting);
  });

  test('noteFromRemote: the "text" column maps back to content', () {
    final c = noteFromRemote({
      'id': 'n1',
      'user_id': 'u1',
      'date': '2026-06-05T10:00:00.000Z',
      'text': 'first frost',
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(c.content.value, 'first frost');
  });

  test('supplyFromRemote: numeric quantity to double, null threshold', () {
    final c = supplyFromRemote({
      'id': 's1',
      'user_id': 'u1',
      'name': 'Compost',
      'quantity': 12, // int from JSON → double
      'low_threshold': null,
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(c.quantity.value, 12.0);
    expect(c.lowThreshold.value, isNull);
  });

  // ── Catalog: remote → drift (pull) ────────────────────────────────────────

  test('taskTypeFromRemote: jsonb labels to text, bools, null cadence', () {
    final c = taskTypeFromRemote({
      'id': 'water',
      'labels': {'sl': 'Zalivanje', 'en': 'Watering', 'de': 'Gießen'},
      'icon': '💧',
      'category': 'care',
      'requires_subject': true,
      'weather_sensitive': true,
      'consumes_supplies': false,
      'default_cadence': null,
    });
    expect(c.id.value, 'water');
    expect(c.labels.value, jsonEncode({'sl': 'Zalivanje', 'en': 'Watering', 'de': 'Gießen'}));
    expect(c.requiresSubject.value, isTrue);
    expect(c.defaultCadence.value, isNull);
  });

  test('plantFromRemote: labels + nullable scientific_name/icon', () {
    final c = plantFromRemote({
      'id': 'tomato',
      'labels': {'sl': 'Paradižnik'},
      'scientific_name': 'Solanum lycopersicum',
      'category': 'vegetable',
      'icon': null,
    });
    expect(c.id.value, 'tomato');
    expect(c.scientificName.value, 'Solanum lycopersicum');
    expect(c.icon.value, isNull);
  });

  test('categoryTaskTypeFromRemote: category + task_type_id', () {
    final c = categoryTaskTypeFromRemote(
        {'category': 'vegetable', 'task_type_id': 'water'});
    expect(c.category.value, 'vegetable');
    expect(c.taskTypeId.value, 'water');
  });
}
