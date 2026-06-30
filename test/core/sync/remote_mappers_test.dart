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
    final map = areaToRemote(
      Area(
        id: 'a1',
        userId: 'u1',
        name: 'Bed',
        type: AreaType.bed,
        protected: true,
        updatedAt: t0,
        deleted: false,
        syncStatus: kSyncPending,
      ),
    );
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
    final map = taskToRemote(
      Task(
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
      ),
    );
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
    final map = taskToRemote(
      Task(
        id: 't1',
        userId: 'u1',
        taskTypeId: 'water',
        date: local,
        status: TaskStatus.waiting,
        updatedAt: local,
        deleted: false,
        syncStatus: kSyncPending,
      ),
    );
    expect(map['date'], '2026-06-05T08:00:00.000Z');
  });

  test('profileToRemote: no deleted column, nullable cells pass through', () {
    final map = profileToRemote(
      Profile(
        userId: 'u1',
        h3R7: 'abc',
        h3R6: null,
        h3R5: null,
        lang: 'sl',
        defaultGardenSeeded: false,
        updatedAt: t0,
        syncStatus: kSyncPending,
      ),
    );
    expect(map, {
      'user_id': 'u1',
      'h3_r7': 'abc',
      'h3_r6': null,
      'h3_r5': null,
      'lang': 'sl',
      'notification_settings': null,
      'default_garden_seeded': false,
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(map.containsKey('deleted'), isFalse);
  });

  test('profile notification_settings: jsonb round-trips through text', () {
    const json = '{"task_reminders":false,"default_offset":60}';
    final map = profileToRemote(
      Profile(
        userId: 'u1',
        h3R7: null,
        h3R6: null,
        h3R5: null,
        lang: null,
        notificationSettings: json,
        defaultGardenSeeded: false,
        updatedAt: t0,
        syncStatus: kSyncPending,
      ),
    );
    // Local JSON text → decoded object for Postgres jsonb.
    expect(map['notification_settings'], {
      'task_reminders': false,
      'default_offset': 60,
    });

    // Postgres returns a Map → stored back as JSON text in drift.
    final c = profileFromRemote({
      'user_id': 'u1',
      'notification_settings': {'task_reminders': false, 'default_offset': 60},
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(
      c.notificationSettings.value,
      jsonEncode({'task_reminders': false, 'default_offset': 60}),
    );
  });

  test('noteToRemote: content maps to the "text" column', () {
    final map = noteToRemote(
      Note(
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
      ),
    );
    expect(map['text'], 'first frost');
    expect(map.containsKey('content'), isFalse);
  });

  test('taskReminderToRemote: offset key, nullable reminder_time', () {
    final map = taskReminderToRemote(
      TaskReminder(
        id: 'r1',
        taskId: 't1',
        offset: 120,
        reminderTime: null,
        updatedAt: t0,
        deleted: false,
        syncStatus: kSyncPending,
      ),
    );
    expect(map['offset'], 120);
    expect(map['reminder_time'], isNull);
    expect(map['task_id'], 't1');
  });

  test('supplyToRemote: nullable low_threshold and double quantity', () {
    final map = supplyToRemote(
      Supply(
        id: 's1',
        userId: 'u1',
        name: 'Compost',
        unit: 'kg',
        quantity: 12.5,
        lowThreshold: null,
        updatedAt: t0,
        deleted: false,
        syncStatus: kSyncPending,
      ),
    );
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
    expect(
      c.labels.value,
      jsonEncode({'sl': 'Zalivanje', 'en': 'Watering', 'de': 'Gießen'}),
    );
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
    final c = categoryTaskTypeFromRemote({
      'category': 'vegetable',
      'task_type_id': 'water',
    });
    expect(c.category.value, 'vegetable');
    expect(c.taskTypeId.value, 'water');
  });

  // ── Remaining entities: round-trip + tolerance ────────────────────────────

  test('userPlant round-trips and defaults missing optionals', () {
    final map = userPlantToRemote(
      UserPlant(
        id: 'up1',
        userId: 'u1',
        areaId: 'a1',
        plantId: 'tomato',
        customName: null,
        personalAlias: 'Big Red',
        isCustom: false,
        updatedAt: t0,
        deleted: false,
        syncStatus: kSyncPending,
      ),
    );
    expect(map['area_id'], 'a1');
    expect(map['plant_id'], 'tomato');
    expect(map['personal_alias'], 'Big Red');
    expect(map['custom_name'], isNull);
    expect(map.containsKey('sync_status'), isFalse);

    // Minimal remote row: missing optionals fall back to defaults, no throw.
    final c = userPlantFromRemote({
      'id': 'up1',
      'user_id': 'u1',
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(c.id.value, 'up1');
    expect(c.areaId.value, isNull);
    expect(c.plantId.value, isNull);
    expect(c.isCustom.value, isFalse);
    expect(c.deleted.value, isFalse);
    expect(c.syncStatus.value, kSyncSynced);
  });

  test('taskSubject round-trips with nullable plant/area links', () {
    final map = taskSubjectToRemote(
      TaskSubject(
        id: 'ts1',
        taskId: 't1',
        userPlantId: 'up1',
        areaId: null,
        updatedAt: t0,
        deleted: false,
        syncStatus: kSyncPending,
      ),
    );
    expect(map['user_plant_id'], 'up1');
    expect(map['area_id'], isNull);

    final c = taskSubjectFromRemote({
      'id': 'ts1',
      'task_id': 't1',
      'user_plant_id': null,
      'area_id': 'a1',
      'updated_at': '2026-06-05T10:00:00.000Z',
      'deleted': true,
    });
    expect(c.areaId.value, 'a1');
    expect(c.userPlantId.value, isNull);
    // deleted=true maps through so the tombstone syncs.
    expect(c.deleted.value, isTrue);
  });

  test('taskReminderFromRemote: numeric offset to int, deleted maps through', () {
    final c = taskReminderFromRemote({
      'id': 'r1',
      'task_id': 't1',
      'offset': 120, // int from JSON
      'reminder_time': '08:30',
      'updated_at': '2026-06-05T10:00:00.000Z',
      'deleted': true,
    });
    expect(c.offset.value, 120);
    expect(c.reminderTime.value, '08:30');
    expect(c.deleted.value, isTrue);
    expect(c.syncStatus.value, kSyncSynced);
  });

  test('recipe: items jsonb round-trips, nullable equipment', () {
    const items = '[{"supply_id":"s1","amount":2}]';
    final map = recipeToRemote(
      Recipe(
        id: 'rec1',
        userId: 'u1',
        name: 'Tomato feed',
        equipment: null,
        items: items,
        updatedAt: t0,
        deleted: false,
        syncStatus: kSyncPending,
      ),
    );
    // Local JSON text → decoded list for Postgres jsonb.
    expect(map['items'], [
      {'supply_id': 's1', 'amount': 2},
    ]);
    expect(map['equipment'], isNull);

    final c = recipeFromRemote({
      'id': 'rec1',
      'user_id': 'u1',
      'name': 'Tomato feed',
      'items': [
        {'supply_id': 's1', 'amount': 2},
      ],
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(c.items.value, jsonEncode(jsonDecode(items)));
    expect(c.equipment.value, isNull);
    expect(c.deleted.value, isFalse);
  });

  test('taskSupply: double amount, applied defaults to false', () {
    final map = taskSupplyToRemote(
      TaskSupply(
        id: 'tsup1',
        taskId: 't1',
        supplyId: 's1',
        amount: 2.5,
        applied: true,
        updatedAt: t0,
        deleted: false,
        syncStatus: kSyncPending,
      ),
    );
    expect(map['amount'], 2.5);
    expect(map['applied'], isTrue);

    final c = taskSupplyFromRemote({
      'id': 'tsup1',
      'task_id': 't1',
      'supply_id': 's1',
      'amount': 3, // int from JSON → double
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(c.amount.value, 3.0);
    expect(c.applied.value, isFalse); // missing optional → default
  });

  test('profileFromRemote: full row parses; minimal row defaults', () {
    final full = profileFromRemote({
      'user_id': 'u1',
      'h3_r7': 'r7',
      'h3_r6': 'r6',
      'h3_r5': 'r5',
      'lang': 'de',
      'notification_settings': {'task_reminders': true},
      'default_garden_seeded': true,
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(full.h3R7.value, 'r7');
    expect(full.lang.value, 'de');
    expect(full.defaultGardenSeeded.value, isTrue);

    final minimal = profileFromRemote({
      'user_id': 'u1',
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(minimal.h3R7.value, isNull);
    expect(minimal.lang.value, isNull);
    expect(minimal.notificationSettings.value, isNull);
    expect(minimal.defaultGardenSeeded.value, isFalse);
  });

  test('parsers ignore unknown/extra keys without throwing (tolerant)', () {
    final c = taskFromRemote({
      'id': 't1',
      'user_id': 'u1',
      'task_type_id': 'water',
      'date': '2026-06-05T10:00:00.000Z',
      'status': 'waiting',
      'updated_at': '2026-06-05T10:00:00.000Z',
      'future_column': 'ignored', // unknown field from a newer schema
      'another': {'nested': true},
    });
    expect(c.id.value, 't1');
    expect(c.taskTypeId.value, 'water');
  });

  test('taskToRemote: includes harvest yield (T11)', () {
    final map = taskToRemote(
      Task(
        id: 't1',
        userId: 'u1',
        taskTypeId: 'harvest',
        date: t0,
        status: TaskStatus.done,
        updatedAt: t0,
        deleted: false,
        syncStatus: kSyncPending,
        yieldAmount: 2.5,
        yieldUnit: 'kg',
      ),
    );
    expect(map['yield_amount'], 2.5);
    expect(map['yield_unit'], 'kg');
  });

  test('taskFromRemote: yield parsed; unknown unit kept verbatim (tolerant)', () {
    final c = taskFromRemote({
      'id': 't1',
      'user_id': 'u1',
      'task_type_id': 'harvest',
      'date': '2026-06-05T10:00:00.000Z',
      'status': 'done',
      'updated_at': '2026-06-05T10:00:00.000Z',
      'yield_amount': 3, // int from JSON → double
      'yield_unit': 'tonnes', // unknown to this app version
    });
    expect(c.yieldAmount.value, 3.0);
    // Stored as-is so it round-trips; the display layer parses it leniently.
    expect(c.yieldUnit.value, 'tonnes');
  });

  test('taskFromRemote: missing yield columns default to null', () {
    final c = taskFromRemote({
      'id': 't2',
      'user_id': 'u1',
      'task_type_id': 'harvest',
      'date': '2026-06-05T10:00:00.000Z',
      'status': 'waiting',
      'updated_at': '2026-06-05T10:00:00.000Z',
    });
    expect(c.yieldAmount.value, isNull);
    expect(c.yieldUnit.value, isNull);
  });
}
