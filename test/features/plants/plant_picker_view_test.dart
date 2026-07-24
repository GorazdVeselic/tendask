import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/plants/presentation/plant_picker_view.dart';
import 'package:tendask/i18n/translations.g.dart';

Plant _plant(String id, String label, String category) =>
    Plant(id: id, labels: jsonEncode({'sl': label}), category: category);

UserPlant _userPlant(String id, {String? areaId, String? plantId}) => UserPlant(
  id: id,
  userId: 'u1',
  areaId: areaId,
  plantId: plantId,
  customName: null,
  personalAlias: null,
  isCustom: false,
  updatedAt: DateTime.utc(2026, 6, 16),
  deleted: false,
  syncStatus: 'synced',
);

final _apple = _plant('apple', 'Jablana', 'fruit_tree');
final _tomato = _plant('tomato', 'Paradižnik', 'vegetable');
final _catalog = {'apple': _apple, 'tomato': _tomato};

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  group('filterCatalog', () {
    test('sorts by label, not by insertion order', () {
      final rows = filterCatalog([
        _tomato,
        _apple,
      ], category: 'all', query: '');

      expect(rows.map((p) => p.id), ['apple', 'tomato']);
    });

    test('a category keeps only its own plants', () {
      final rows = filterCatalog([
        _apple,
        _tomato,
      ], category: 'vegetable', query: '');

      expect(rows.single.id, 'tomato');
    });

    test('search ignores case and surrounding spaces', () {
      final rows = filterCatalog([
        _apple,
        _tomato,
      ], category: 'all', query: '  JAB ');

      expect(rows.single.id, 'apple');
    });
  });

  group('splitByRelevance', () {
    test('a tree area lifts the tree and demotes the rest — nothing is hidden', () {
      final split = splitByRelevance([_apple, _tomato], AreaType.tree);

      expect(split.softSplit, isTrue);
      expect(split.first.single.id, 'apple');
      expect(split.other.single.id, 'tomato');
    });

    test('a garden is catch-all — no split, everything in one list', () {
      final split = splitByRelevance([_apple, _tomato], AreaType.garden);

      expect(split.softSplit, isFalse);
      expect(split.first.map((p) => p.id), ['apple', 'tomato']);
      expect(split.other, isEmpty);
    });

    test('no target area — no split', () {
      final split = splitByRelevance([_apple, _tomato], null);

      expect(split.softSplit, isFalse);
      expect(split.first, hasLength(2));
    });

    test('only irrelevant plants left — still no divider, they are all shown', () {
      final split = splitByRelevance([_tomato], AreaType.tree);

      expect(split.softSplit, isFalse);
      expect(split.first.single.id, 'tomato');
    });
  });

  group('pickerMembers', () {
    const added = [PickedPlant('up-new', 'apple', 'Jablana')];

    test('garden mode also counts the plants already in the target area', () {
      final members = pickerMembers(
        added: added,
        userPlants: [
          _userPlant('up-1', areaId: 'a1', plantId: 'tomato'),
          _userPlant('up-2', areaId: 'a2', plantId: 'tomato'),
        ],
        catalog: _catalog,
        targetAreaId: 'a1',
        managesArea: true,
      );

      // The one in another area is none of this target's business.
      expect(members.map((m) => m.id), ['up-new', 'up-1']);
    });

    test('"no area" is a target too — its plants count', () {
      final members = pickerMembers(
        added: const [],
        userPlants: [
          _userPlant('up-1', plantId: 'tomato'),
          _userPlant('up-2', areaId: 'a1', plantId: 'tomato'),
        ],
        catalog: _catalog,
        targetAreaId: null,
        managesArea: true,
      );

      expect(members.single.id, 'up-1');
    });

    test('subject mode counts only this session\'s adds', () {
      final members = pickerMembers(
        added: added,
        userPlants: [_userPlant('up-1', areaId: 'a1', plantId: 'tomato')],
        catalog: _catalog,
        targetAreaId: 'a1',
        managesArea: false,
      );

      expect(members.single.id, 'up-new');
    });

    test('a plant added this session is not counted twice', () {
      final members = pickerMembers(
        added: const [PickedPlant('up-1', 'tomato', 'Paradižnik')],
        userPlants: [_userPlant('up-1', areaId: 'a1', plantId: 'tomato')],
        catalog: _catalog,
        targetAreaId: 'a1',
        managesArea: true,
      );

      expect(members, hasLength(1));
    });
  });

  group('memberFor', () {
    test('finds the instance that represents a catalog plant', () {
      const members = [PickedPlant('up-1', 'apple', 'Jablana')];

      expect(memberFor(members, 'apple')?.id, 'up-1');
      expect(memberFor(members, 'tomato'), isNull);
    });
  });
}
