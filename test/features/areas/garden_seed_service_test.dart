import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';
import 'package:tendask/features/areas/data/areas_repository.dart';
import 'package:tendask/features/areas/data/garden_seed_service.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late AreasRepository areas;
  late LocalPrefsRepository prefs;
  late GardenSeedService seed;

  const userId = 'user-1';
  final t0 = DateTime.utc(2026, 6, 16, 8);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    areas = AreasRepository(db, clock: _FakeClock(t0));
    prefs = LocalPrefsRepository(db);
    seed = GardenSeedService(db, areas, prefs);
  });

  tearDown(() async => db.close());

  test('seeds the default garden once, as a garden-type area', () async {
    await seed.seedDefaultIfNeeded(userId: userId, name: 'Vrt');

    final all = await areas.watchAll().first;
    expect(all, hasLength(1));
    expect(all.single.name, 'Vrt');
    expect(all.single.type, AreaType.garden);
    expect(all.single.userId, userId);
    expect(await prefs.defaultGardenSeeded(), isTrue);
  });

  test('does not seed again on a later launch (flag already set)', () async {
    await seed.seedDefaultIfNeeded(userId: userId, name: 'Vrt');
    await seed.seedDefaultIfNeeded(userId: userId, name: 'Vrt');

    expect(await areas.watchAll().first, hasLength(1));
  });

  test('a deleted garden is not resurrected on the next launch', () async {
    await seed.seedDefaultIfNeeded(userId: userId, name: 'Vrt');
    final garden = (await areas.watchAll().first).single;

    // User removes the garden (they only keep beds/lawns).
    await areas.softDelete(garden.id);

    // Next launch must respect the deletion — the one-shot flag prevents re-seed.
    await seed.seedDefaultIfNeeded(userId: userId, name: 'Vrt');

    expect(
      await areas.watchAll().first,
      isEmpty,
      reason: 'deletion must stick; no re-seed',
    );
  });
}
