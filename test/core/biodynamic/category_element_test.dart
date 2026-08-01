import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/category_element.dart';
import 'package:tendask/core/plant_category.dart';
import 'package:tendask/data/seed/catalog_seed.dart';

void main() {
  group('coarse bucket completeness', () {
    test('every bucket has an element, an explicit opt-out, or per-plant map',
        () {
      for (final bucket in kPlantCategories) {
        if (bucket == 'all') continue;
        final covered = kCategoryElement.containsKey(bucket) ||
            kCategoryNoElement.contains(bucket) ||
            bucket == 'vegetable';
        expect(covered, isTrue, reason: 'bucket "$bucket" is unmapped');
      }
    });

    test('element map and opt-out set do not overlap', () {
      for (final bucket in kCategoryNoElement) {
        expect(kCategoryElement.containsKey(bucket), isFalse,
            reason: 'category "$bucket" is both mapped and opted out');
      }
      expect(kCategoryElement.containsKey('vegetable'), isFalse,
          reason: 'vegetable resolves per plant id, not per bucket');
    });
  });

  group('override map completeness', () {
    final seedPlantIds = CatalogSeed.plants.map((p) => p.id).toSet();
    final seedVegetableIds = CatalogSeed.plants
        .where((p) => coarsePlantCategory(p.category) == 'vegetable')
        .map((p) => p.id)
        .toSet();

    test('every seeded vegetable has an element', () {
      for (final id in seedVegetableIds) {
        expect(kPlantElementOverride.containsKey(id), isTrue,
            reason: 'vegetable "$id" is missing from kPlantElementOverride');
      }
    });

    test('map holds no stale ids absent from the seed', () {
      for (final id in kPlantElementOverride.keys) {
        expect(seedPlantIds.contains(id), isTrue,
            reason: '"$id" is mapped but not a seeded plant');
      }
    });
  });

  test('every seeded plant resolves to an element or an explicit opt-out', () {
    for (final plant in CatalogSeed.plants) {
      final element =
          plantElement(category: plant.category, plantId: plant.id);
      final optedOut = kCategoryNoElement.contains(plant.category);
      expect(element != null || optedOut, isTrue,
          reason: 'plant "${plant.id}" (${plant.category}) is unresolved');
    }
  });

  group('plantElement', () {
    test('vegetables resolve per plant id', () {
      expect(plantElement(category: 'vegetable', plantId: 'tomato'),
          BiodynamicElement.fruit);
      expect(plantElement(category: 'vegetable', plantId: 'carrot'),
          BiodynamicElement.root);
      expect(plantElement(category: 'vegetable', plantId: 'cauliflower'),
          BiodynamicElement.leaf);
      expect(plantElement(category: 'vegetable', plantId: 'broccoli'),
          BiodynamicElement.flower);
    });

    test('flower-harvested herbs override the leafy bucket default', () {
      expect(plantElement(category: 'herbs', plantId: 'chamomile'),
          BiodynamicElement.flower);
      expect(plantElement(category: 'herbs', plantId: 'lavender'),
          BiodynamicElement.flower);
      expect(plantElement(category: 'herbs', plantId: 'basil'),
          BiodynamicElement.leaf);
    });

    test('fine seed categories fold onto their coarse bucket', () {
      expect(plantElement(category: 'citrus', plantId: 'lemon'),
          BiodynamicElement.fruit);
      expect(plantElement(category: 'shrub', plantId: 'rose'),
          BiodynamicElement.flower);
      expect(plantElement(category: 'bulb', plantId: 'tulip'),
          BiodynamicElement.flower);
    });

    test('returns null without a recommendation', () {
      expect(plantElement(category: 'houseplant', plantId: 'monstera'), isNull);
      expect(plantElement(category: 'conifer', plantId: 'spruce'), isNull);
      expect(plantElement(category: 'hedge', plantId: 'box'), isNull);
      expect(plantElement(category: 'vegetable'), isNull);
      expect(plantElement(category: 'vegetable', plantId: 'custom-uuid'),
          isNull);
      expect(plantElement(category: 'unknown_custom'), isNull);
    });
  });
}
