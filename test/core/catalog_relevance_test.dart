import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/catalog_relevance.dart';

void main() {
  group('isCategoryRelevant', () {
    test('empty matrix → everything relevant (no soft sort)', () {
      expect(isCategoryRelevant(const {}, 'fruit_tree'), isTrue);
      expect(isCategoryRelevant(const {}, null), isTrue);
    });

    test('matching category is relevant', () {
      expect(isCategoryRelevant({'lawn'}, 'lawn'), isTrue);
      expect(isCategoryRelevant({'lawn', 'hedge'}, 'hedge'), isTrue);
    });

    test('non-matching category is not relevant', () {
      expect(isCategoryRelevant({'lawn'}, 'fruit_tree'), isFalse);
    });

    test('unknown category (custom plant / unloaded catalog) is not demoted', () {
      // F1: null category must stay relevant even with a restricting matrix.
      expect(isCategoryRelevant({'lawn'}, null), isTrue);
    });
  });
}
