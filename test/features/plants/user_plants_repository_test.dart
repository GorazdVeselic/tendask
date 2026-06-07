import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/sync/sync_status.dart';
import 'package:tendask/features/plants/data/user_plants_repository.dart';
import 'package:tendask/features/plants/presentation/plant_display.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late UserPlantsRepository repo;

  const userId = 'user-1';
  const areaId = 'area-1';
  final t0 = DateTime.utc(2026, 6, 2, 8);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UserPlantsRepository(db, clock: _FakeClock(t0));
    await db.into(db.areas).insert(AreasCompanion.insert(
          id: areaId,
          userId: userId,
          name: 'Vrt',
          type: const Value(AreaType.bed),
          updatedAt: t0,
        ));
  });

  tearDown(() async => db.close());

  group('createForArea', () {
    test('catalog plant: isCustom=false, plantId set', () async {
      final id = await repo.createForArea(
          userId: userId, areaId: areaId, plantId: 'tomato');
      final rows = await repo.byArea(areaId);
      expect(rows, hasLength(1));
      expect(rows.single.id, id);
      expect(rows.single.plantId, 'tomato');
      expect(rows.single.isCustom, false);
    });

    test('custom entry: isCustom=true, customName set, plantId null', () async {
      await repo.createForArea(
          userId: userId, areaId: areaId, customName: 'Babičina sorta');
      final rows = await repo.byArea(areaId);
      expect(rows.single.isCustom, true);
      expect(rows.single.customName, 'Babičina sorta');
      expect(rows.single.plantId, isNull);
    });
  });

  group('recentPlantIds', () {
    test('distinct species, newest first, excludes custom + deleted + limit',
        () async {
      final t1 = t0.add(const Duration(minutes: 1));
      final t2 = t0.add(const Duration(minutes: 2));
      final repo1 = UserPlantsRepository(db, clock: _FakeClock(t1));
      final repo2 = UserPlantsRepository(db, clock: _FakeClock(t2));

      await repo.create(userId: userId, areaId: areaId, plantId: 'apple');
      await repo1.create(userId: userId, areaId: areaId, plantId: 'pear');
      // Duplicate 'apple', now the newest use of that species.
      await repo2.create(userId: userId, areaId: areaId, plantId: 'apple');
      // Custom entry (no plantId) is excluded.
      await repo.create(userId: userId, areaId: areaId, customName: 'Babica');
      // Deleted row is excluded.
      final delId =
          await repo.create(userId: userId, areaId: areaId, plantId: 'plum');
      await repo.softDelete(delId);

      expect(await repo.recentPlantIds(), ['apple', 'pear']);
      expect(await repo.recentPlantIds(limit: 1), ['apple']);
    });
  });

  group('update', () {
    test('changes area, keeps the passed alias, marks pending', () async {
      final id = await repo.create(
          userId: userId,
          areaId: areaId,
          plantId: 'apple',
          personalAlias: 'Stara');
      await (db.update(db.userPlants)..where((p) => p.id.equals(id)))
          .write(const UserPlantsCompanion(syncStatus: Value(kSyncSynced)));

      await repo.update(id: id, areaId: null, personalAlias: 'Stara');

      final row = await repo.byId(id);
      expect(row!.areaId, isNull);
      expect(row.personalAlias, 'Stara');
      expect(row.syncStatus, kSyncPending);
    });
  });

  group('moveToArea', () {
    const area2 = 'area-2';

    Future<void> insertArea2() => db.into(db.areas).insert(AreasCompanion.insert(
          id: area2,
          userId: userId,
          name: 'Greda',
          type: const Value(AreaType.bed),
          updatedAt: t0,
        ));

    test('moves into an area without that species', () async {
      await insertArea2();
      final id = await repo.create(
          userId: userId, areaId: areaId, plantId: 'apple');

      final res = await repo.moveToArea(id: id, areaId: area2);

      expect(res, PlantMoveResult.moved);
      expect((await repo.byId(id))!.areaId, area2);
    });

    test('blocks a move into an area that already has the species', () async {
      await insertArea2();
      await repo.create(userId: userId, areaId: area2, plantId: 'apple');
      final movingId = await repo.create(
          userId: userId, areaId: areaId, plantId: 'apple');

      final res = await repo.moveToArea(id: movingId, areaId: area2);

      expect(res, PlantMoveResult.duplicate);
      expect((await repo.byId(movingId))!.areaId, areaId);
    });

    test('a deleted instance in the target does not block', () async {
      await insertArea2();
      final delId = await repo.create(
          userId: userId, areaId: area2, plantId: 'apple');
      await repo.softDelete(delId);
      final id = await repo.create(
          userId: userId, areaId: areaId, plantId: 'apple');

      final res = await repo.moveToArea(id: id, areaId: area2);

      expect(res, PlantMoveResult.moved);
      expect((await repo.byId(id))!.areaId, area2);
    });

    test('custom plants (no plantId) never collide', () async {
      await insertArea2();
      await repo.create(userId: userId, areaId: area2, customName: 'Babica');
      final id = await repo.create(
          userId: userId, areaId: areaId, customName: 'Babica');

      final res = await repo.moveToArea(id: id, areaId: area2);

      expect(res, PlantMoveResult.moved);
    });
  });

  group('plantMatchesQuery', () {
    const tomato = Plant(
      id: 'tomato',
      labels: '{"sl":"paradižnik","en":"tomato","de":"Tomate"}',
      scientificName: 'Solanum lycopersicum',
      category: 'vegetable',
      icon: '🍅',
    );

    test('empty query matches', () {
      expect(plantMatchesQuery(tomato, ''), true);
    });

    test('matches Slovenian prefix', () {
      expect(plantMatchesQuery(tomato, 'parad'), true);
    });

    test('matches English and German', () {
      expect(plantMatchesQuery(tomato, 'tomat'), true);
      expect(plantMatchesQuery(tomato, 'toma'), true);
    });

    test('matches scientific name (case-insensitive)', () {
      expect(plantMatchesQuery(tomato, 'solanum'), true);
    });

    test('does not match unrelated query', () {
      expect(plantMatchesQuery(tomato, 'jablana'), false);
    });
  });
}
