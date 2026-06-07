import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/sync/sync_status.dart';
import 'package:tendask/features/areas/data/areas_repository.dart';
import 'package:tendask/features/plants/data/user_plants_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late AreasRepository areas;
  late UserPlantsRepository plants;

  const userId = 'user-1';
  final t0 = DateTime.utc(2026, 6, 2, 8);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    areas = AreasRepository(db, clock: _FakeClock(t0));
    plants = UserPlantsRepository(db, clock: _FakeClock(t0));
  });

  tearDown(() async => db.close());

  test('softDelete re-parents the area plants to "no area" and tombstones it',
      () async {
    final areaId =
        await areas.create(userId: userId, name: 'Sadovnjak', type: AreaType.tree);
    final plantId =
        await plants.create(userId: userId, areaId: areaId, plantId: 'apple');
    // Mark the plant synced so we can prove softDelete flips it back to pending.
    await (db.update(db.userPlants)..where((p) => p.id.equals(plantId)))
        .write(const UserPlantsCompanion(syncStatus: Value(kSyncSynced)));

    await areas.softDelete(areaId);

    final area = await areas.byId(areaId);
    expect(area!.deleted, isTrue);

    final plant = await plants.byId(plantId);
    expect(plant!.areaId, isNull, reason: 'plant must not point at a deleted area');
    expect(plant.deleted, isFalse, reason: 'the plant itself is not deleted');
    expect(plant.syncStatus, kSyncPending, reason: 're-parent must sync');

    // The area drops out of the list; the plant resurfaces as unassigned.
    expect(await areas.watchAll().first, isEmpty);
    final unassigned = (await plants.watchAll().first)
        .where((p) => p.areaId == null)
        .toList();
    expect(unassigned.map((p) => p.id), contains(plantId));
  });

  test('softDelete leaves plants in OTHER areas untouched', () async {
    final a1 = await areas.create(userId: userId, name: 'A1', type: AreaType.bed);
    final a2 = await areas.create(userId: userId, name: 'A2', type: AreaType.bed);
    final keep =
        await plants.create(userId: userId, areaId: a2, plantId: 'pear');

    await areas.softDelete(a1);

    final plant = await plants.byId(keep);
    expect(plant!.areaId, a2);
  });
}
