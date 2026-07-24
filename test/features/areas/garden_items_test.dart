import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/areas/presentation/garden_items.dart';
import 'package:tendask/i18n/translations.g.dart';

Area _area(String id, String name, AreaType type) => Area(
  id: id,
  userId: 'u1',
  name: name,
  type: type,
  protected: false,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

UserPlant _plant(String id, String? areaId) => UserPlant(
  id: id,
  userId: 'u1',
  areaId: areaId,
  plantId: 'tomato',
  customName: null,
  personalAlias: null,
  isCustom: false,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

Task _task(String id, String taskTypeId, DateTime date) => Task(
  id: id,
  userId: 'u1',
  taskTypeId: taskTypeId,
  date: date,
  status: TaskStatus.done,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

TaskType _type(String id, String slLabel) => TaskType(
  id: id,
  labels: '{"sl":"$slLabel","en":"$slLabel"}',
  icon: '💧',
  category: 'care',
  requiresSubject: false,
  weatherSensitive: false,
  consumesSupplies: false,
  seasonal: true,
);

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  group('groupPlantsByArea', () {
    test('splits plants into their area and the unassigned bucket', () {
      final grouped = groupPlantsByArea([
        _plant('p1', 'a1'),
        _plant('p2', null),
        _plant('p3', 'a1'),
        _plant('p4', 'a2'),
      ]);

      expect(grouped.byArea['a1']!.map((p) => p.id), ['p1', 'p3']);
      expect(grouped.byArea['a2']!.map((p) => p.id), ['p4']);
      expect(grouped.unassigned.map((p) => p.id), ['p2']);
    });

    test('no plants at all yields empty buckets', () {
      final grouped = groupPlantsByArea(const <UserPlant>[]);
      expect(grouped.byArea, isEmpty);
      expect(grouped.unassigned, isEmpty);
    });
  });

  group('buildGardenItems', () {
    test('empty garden yields no items (drives the first-run empty state)', () {
      final items = buildGardenItems(
        areas: const [],
        plantsByArea: const {},
        unassigned: const [],
        latestTaskPerArea: const {},
      );
      expect(items, isEmpty);
    });

    test('unassigned plants come first, before any area type', () {
      final items = buildGardenItems(
        areas: [_area('a1', 'Greda', AreaType.bed)],
        plantsByArea: {
          'a1': [_plant('p1', 'a1')],
        },
        unassigned: [_plant('p2', null)],
        latestTaskPerArea: const {},
      );

      expect(items[0], isA<GardenUnassignedSection>());
      expect((items[1] as GardenPlantsItem).plants.single.id, 'p2');
      expect((items[2] as GardenTypeSection).type, AreaType.bed);
      expect((items[3] as GardenAreaItem).area.id, 'a1');
      expect((items[4] as GardenPlantsItem).plants.single.id, 'p1');
    });

    test('areas group by type in enum order, not insertion order', () {
      final items = buildGardenItems(
        // Deliberately reversed against AreaType.values.
        areas: [
          _area('b1', 'Greda', AreaType.bed),
          _area('g1', 'Vrt', AreaType.garden),
          _area('b2', 'Druga greda', AreaType.bed),
        ],
        plantsByArea: const {},
        unassigned: const [],
        latestTaskPerArea: const {},
      );

      expect(
        items.map(
          (i) => switch (i) {
            GardenTypeSection(:final type) => 'type:${type.name}',
            GardenAreaItem(:final area) => 'area:${area.id}',
            _ => 'other',
          },
        ),
        ['type:garden', 'area:g1', 'type:bed', 'area:b1', 'area:b2'],
      );
    });

    test('an area with no plants renders its header but no plant card', () {
      final items = buildGardenItems(
        areas: [_area('a1', 'Greda', AreaType.bed)],
        plantsByArea: const {},
        unassigned: const [],
        latestTaskPerArea: const {},
      );

      expect(items.whereType<GardenPlantsItem>(), isEmpty);
      expect((items.whereType<GardenAreaItem>().single).plantCount, 0);
    });

    test('area item carries its latest task and plant count', () {
      final items = buildGardenItems(
        areas: [_area('a1', 'Greda', AreaType.bed)],
        plantsByArea: {
          'a1': [_plant('p1', 'a1'), _plant('p2', 'a1')],
        },
        unassigned: const [],
        latestTaskPerArea: {'a1': _task('t1', 'water', DateTime.utc(2026, 6, 1))},
      );

      final area = items.whereType<GardenAreaItem>().single;
      expect(area.plantCount, 2);
      expect(area.lastTask!.id, 't1');
    });
  });

  group('areaSubtitle', () {
    test('no task, no plants → the "no plants" hint', () {
      expect(
        areaSubtitle(t, lastTask: null, catalog: const {}, plantCount: 0),
        t.areas.no_plants,
      );
    });

    test('no task but plants → the plant count, never the area type', () {
      expect(
        areaSubtitle(t, lastTask: null, catalog: const {}, plantCount: 3),
        t.areas.plant_count(n: 3),
      );
    });

    test('last task wins over the plant count', () {
      final subtitle = areaSubtitle(
        t,
        lastTask: _task('t1', 'water', DateTime.utc(2026, 6, 1, 10)),
        catalog: {'water': _type('water', 'Zalivanje')},
        plantCount: 3,
      );

      expect(subtitle, startsWith(t.areas.last_prefix));
      expect(subtitle, contains('Zalivanje'));
      expect(subtitle, contains('1. 6. 2026'));
    });

    test('unknown task type falls back to its id instead of crashing', () {
      final subtitle = areaSubtitle(
        t,
        lastTask: _task('t1', 'mystery', DateTime.utc(2026, 6, 1, 10)),
        catalog: const {},
        plantCount: 0,
      );

      expect(subtitle, contains('mystery'));
    });
  });
}
