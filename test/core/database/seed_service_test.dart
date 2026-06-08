import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/seed_service.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/data/seed/catalog_seed.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  // ---------------------------------------------------------------------------
  // SeedService
  // ---------------------------------------------------------------------------
  group('SeedService', () {
    test('seeds expected row counts', () async {
      await SeedService(db).runIfNeeded();

      final taskTypeCount = await db.select(db.taskTypes).get();
      final plantCount = await db.select(db.plants).get();
      final matrixCount = await db.select(db.categoryTaskTypes).get();

      expect(taskTypeCount.length, CatalogSeed.taskTypes.length);
      expect(plantCount.length, CatalogSeed.plants.length);
      expect(matrixCount.length, CatalogSeed.categoryMatrix.length);
    });

    test('is idempotent — second run does not duplicate rows', () async {
      final service = SeedService(db);
      await service.runIfNeeded();
      await service.runIfNeeded();

      final count = await db.select(db.taskTypes).get();
      expect(count.length, CatalogSeed.taskTypes.length);
    });

    test('mow task type has correct fields', () async {
      await SeedService(db).runIfNeeded();

      final mow = await (db.select(
        db.taskTypes,
      )..where((t) => t.id.equals('mow'))).getSingle();

      expect(mow.requiresSubject, false);
      expect(mow.weatherSensitive, true);
      expect(mow.defaultCadence, 7);
      expect(mow.category, 'lawn_care');
    });
  });

  // ---------------------------------------------------------------------------
  // Area CRUD
  // ---------------------------------------------------------------------------
  group('Area CRUD', () {
    const areaId = '11111111-1111-1111-1111-111111111111';
    final now = DateTime.utc(2026, 6, 2);

    test('insert and read back', () async {
      await db
          .into(db.areas)
          .insert(
            AreasCompanion.insert(
              id: areaId,
              userId: 'user-1',
              name: 'Trata',
              type: const Value(AreaType.lawn),
              updatedAt: now,
            ),
          );

      final area = await (db.select(
        db.areas,
      )..where((a) => a.id.equals(areaId))).getSingle();

      expect(area.name, 'Trata');
      expect(area.type, AreaType.lawn);
      expect(area.deleted, false);
      expect(area.syncStatus, 'pending');
    });

    test('update name', () async {
      await db
          .into(db.areas)
          .insert(
            AreasCompanion.insert(
              id: areaId,
              userId: 'user-1',
              name: 'Trata',
              type: const Value(AreaType.lawn),
              updatedAt: now,
            ),
          );

      await (db.update(db.areas)..where((a) => a.id.equals(areaId))).write(
        AreasCompanion(
          name: const Value('Sprednja trata'),
          updatedAt: Value(now),
        ),
      );

      final area = await (db.select(
        db.areas,
      )..where((a) => a.id.equals(areaId))).getSingle();

      expect(area.name, 'Sprednja trata');
    });

    test('soft delete sets deleted=true', () async {
      await db
          .into(db.areas)
          .insert(
            AreasCompanion.insert(
              id: areaId,
              userId: 'user-1',
              name: 'Trata',
              type: const Value(AreaType.lawn),
              updatedAt: now,
            ),
          );

      await (db.update(db.areas)..where((a) => a.id.equals(areaId))).write(
        AreasCompanion(deleted: const Value(true), updatedAt: Value(now)),
      );

      final area = await (db.select(
        db.areas,
      )..where((a) => a.id.equals(areaId))).getSingle();

      expect(area.deleted, true);
    });
  });

  // ---------------------------------------------------------------------------
  // Task CRUD
  // ---------------------------------------------------------------------------
  group('Task CRUD', () {
    const areaId = '22222222-2222-2222-2222-222222222222';
    const taskId = '33333333-3333-3333-3333-333333333333';
    final now = DateTime.utc(2026, 6, 2);

    setUp(() async {
      await SeedService(db).runIfNeeded();
      await db
          .into(db.areas)
          .insert(
            AreasCompanion.insert(
              id: areaId,
              userId: 'user-1',
              name: 'Vrt',
              type: const Value(AreaType.bed),
              updatedAt: now,
            ),
          );
    });

    test('insert and read back', () async {
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: taskId,
              userId: 'user-1',
              taskTypeId: 'mow',
              date: now,
              updatedAt: now,
            ),
          );

      final task = await (db.select(
        db.tasks,
      )..where((t) => t.id.equals(taskId))).getSingle();

      expect(task.status, TaskStatus.waiting);
      expect(task.deleted, false);
      expect(task.syncStatus, 'pending');
    });

    test('update status to done', () async {
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: taskId,
              userId: 'user-1',
              taskTypeId: 'mow',
              date: now,
              updatedAt: now,
            ),
          );

      await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          status: const Value(TaskStatus.done),
          updatedAt: Value(now),
        ),
      );

      final task = await (db.select(
        db.tasks,
      )..where((t) => t.id.equals(taskId))).getSingle();

      expect(task.status, TaskStatus.done);
    });

    test('soft delete sets deleted=true', () async {
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: taskId,
              userId: 'user-1',
              taskTypeId: 'mow',
              date: now,
              updatedAt: now,
            ),
          );

      await (db.update(db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(deleted: const Value(true), updatedAt: Value(now)),
      );

      final task = await (db.select(
        db.tasks,
      )..where((t) => t.id.equals(taskId))).getSingle();

      expect(task.deleted, true);
    });
  });
}
