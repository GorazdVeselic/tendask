import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
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
