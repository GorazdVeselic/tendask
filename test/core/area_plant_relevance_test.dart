import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_plant_relevance.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/catalog_relevance.dart';

void main() {
  group('relevantPlantCategories', () {
    test('garden / other / null are catch-all (empty = no split)', () {
      expect(relevantPlantCategories(AreaType.garden), isEmpty);
      expect(relevantPlantCategories(AreaType.other), isEmpty);
      expect(relevantPlantCategories(null), isEmpty);
    });

    test('typed areas lift their own plant kinds', () {
      expect(relevantPlantCategories(AreaType.lawn), {'lawn'});
      expect(relevantPlantCategories(AreaType.tree), contains('fruit_tree'));
      expect(relevantPlantCategories(AreaType.bed), contains('vegetable'));
      expect(relevantPlantCategories(AreaType.hedge), contains('shrub'));
    });

    test('a tree does not belong in a raised bed', () {
      expect(
        relevantPlantCategories(AreaType.bed),
        isNot(contains('fruit_tree')),
      );
      expect(
        relevantPlantCategories(AreaType.tree),
        isNot(contains('vegetable')),
      );
    });
  });

  group('relevantPlantCategories + isCategoryRelevant', () {
    test('bed lifts vegetables, demotes fruit trees', () {
      final cats = relevantPlantCategories(AreaType.bed);
      expect(isCategoryRelevant(cats, 'vegetable'), isTrue);
      expect(isCategoryRelevant(cats, 'fruit_tree'), isFalse);
    });

    test('garden keeps every category relevant', () {
      final cats = relevantPlantCategories(AreaType.garden);
      expect(isCategoryRelevant(cats, 'fruit_tree'), isTrue);
      expect(isCategoryRelevant(cats, 'lawn'), isTrue);
    });

    test('unknown (custom) plant stays relevant even in a typed area', () {
      final cats = relevantPlantCategories(AreaType.lawn);
      expect(isCategoryRelevant(cats, null), isTrue);
    });
  });
}
