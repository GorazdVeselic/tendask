import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/subject_picker.dart';
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
  updatedAt: DateTime.utc(2026, 7, 15),
  deleted: false,
  syncStatus: 'synced',
);

Area _area(String id, String name) => Area(
  id: id,
  userId: 'u1',
  name: name,
  type: AreaType.bed,
  protected: false,
  updatedAt: DateTime.utc(2026, 7, 15),
  deleted: false,
  syncStatus: 'synced',
);

final _apple = _plant('apple', 'Jablana', 'fruit_tree');
final _tomato = _plant('tomato', 'Paradižnik', 'vegetable');
final _basil = _plant('basil', 'Bazilika', 'herbs');
final _catalog = {'apple': _apple, 'tomato': _tomato, 'basil': _basil};

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  group('filterSubjectPlants', () {
    test('sorts by label and keeps everything under "all"', () {
      final rows = filterSubjectPlants(
        [
          _userPlant('up-t', plantId: 'tomato'),
          _userPlant('up-a', plantId: 'apple'),
        ],
        catalog: _catalog,
        category: 'all',
        query: '',
      );

      // Jablana < Paradižnik.
      expect(rows.map((p) => p.id), ['up-a', 'up-t']);
    });

    test('a coarse category chip keeps only its own plants', () {
      final rows = filterSubjectPlants(
        [
          _userPlant('up-t', plantId: 'tomato'),
          _userPlant('up-a', plantId: 'apple'),
        ],
        catalog: _catalog,
        category: 'vegetable',
        query: '',
      );

      expect(rows.single.id, 'up-t');
    });

    test('search ignores case and surrounding spaces', () {
      final rows = filterSubjectPlants(
        [
          _userPlant('up-t', plantId: 'tomato'),
          _userPlant('up-a', plantId: 'apple'),
        ],
        catalog: _catalog,
        category: 'all',
        query: '  JAB ',
      );

      expect(rows.single.id, 'up-a');
    });
  });

  group('splitSubjectPlants', () {
    final plants = [
      _userPlant('up-t', plantId: 'tomato'),
      _userPlant('up-a', plantId: 'apple'),
    ];

    test('the task type lifts its categories and demotes the rest', () {
      final split = splitSubjectPlants(
        plants,
        relevantCategories: {'vegetable'},
        catalog: _catalog,
      );

      expect(split.softSplit, isTrue);
      expect(split.relevant.single.id, 'up-t');
      expect(split.other.single.id, 'up-a');
    });

    test('no chosen type (empty set) — everything relevant, no divider', () {
      final split = splitSubjectPlants(
        plants,
        relevantCategories: const {},
        catalog: _catalog,
      );

      expect(split.softSplit, isFalse);
      expect(split.relevant, hasLength(2));
      expect(split.other, isEmpty);
    });

    test('a custom plant (unknown category) is never demoted', () {
      final split = splitSubjectPlants(
        [_userPlant('up-custom')],
        relevantCategories: {'vegetable'},
        catalog: _catalog,
      );

      expect(split.softSplit, isFalse);
      expect(split.relevant.single.id, 'up-custom');
    });
  });

  group('ownedPlantIds', () {
    test('collects catalog ids and skips custom plants', () {
      final owned = ownedPlantIds([
        _userPlant('up-a', plantId: 'apple'),
        _userPlant('up-a2', plantId: 'apple'),
        _userPlant('up-custom'),
      ]);

      expect(owned, {'apple'});
    });
  });

  group('subjectCatalogMatches', () {
    test('an empty query offers nothing', () {
      final rows = subjectCatalogMatches(
        [_apple, _tomato],
        owned: const {},
        relevantCategories: const {},
        category: 'all',
        query: '',
      );

      expect(rows, isEmpty);
    });

    test('excludes owned plants and orders relevant species first', () {
      final rows = subjectCatalogMatches(
        [_apple, _tomato, _basil],
        owned: {'apple'},
        relevantCategories: {'vegetable'},
        category: 'all',
        query: 'a', // matches Jablana, Paradižnik, Bazilika
      );

      // apple is owned → dropped; tomato (vegetable) relevant → first;
      // basil demoted after it.
      expect(rows.map((p) => p.id), ['tomato', 'basil']);
    });
  });

  group('selectedPlantAreaNames', () {
    test('names the areas of the selected plants, skipping ones without', () {
      final names = selectedPlantAreaNames(
        plantIds: {'up-a', 'up-t', 'up-x'},
        userPlants: {
          'up-a': _userPlant('up-a', areaId: 'bed', plantId: 'apple'),
          'up-t': _userPlant('up-t', areaId: 'bed', plantId: 'tomato'),
          'up-x': _userPlant('up-x', plantId: 'basil'), // no area
        },
        areas: {'bed': _area('bed', 'Gredica')},
      );

      // Two plants share "Gredica" (deduped by the set); up-x has no area.
      expect(names, {'Gredica'});
    });
  });

  group('subjectCategoryChips', () {
    test('offers only categories the user has, "all" first, in catalog order', () {
      final chips = subjectCategoryChips([
        _userPlant('up-a', plantId: 'apple'), // fruit_tree
        _userPlant('up-t', plantId: 'tomato'), // vegetable
      ], _catalog);

      expect(chips, ['all', 'vegetable', 'fruit_tree']);
    });

    test('no categorised plants — no chips at all', () {
      final chips = subjectCategoryChips([_userPlant('up-custom')], _catalog);

      expect(chips, isEmpty);
    });
  });
}
