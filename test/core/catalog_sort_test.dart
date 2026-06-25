import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/catalog_sort.dart';

void main() {
  group('compareCatalogLabels', () {
    test('plain ASCII is alphabetical and case-insensitive', () {
      final input = ['Basil', 'apple', 'Cherry', 'beet'];
      final sorted = sortedByLabel(input, (s) => s);
      expect(sorted, ['apple', 'Basil', 'beet', 'Cherry']);
    });

    test('Slovenian č sorts between c and d, not after z', () {
      // Raw compareTo would push "čaj" after "zelje" (č = U+010D > z).
      final input = ['zelje', 'čaj', 'cvet', 'detelja'];
      final sorted = sortedByLabel(input, (s) => s);
      expect(sorted, ['cvet', 'čaj', 'detelja', 'zelje']);
    });

    test('Slovenian š and ž sit right after s and z', () {
      final input = ['žajbelj', 'zelena', 'špinača', 'solata'];
      final sorted = sortedByLabel(input, (s) => s);
      expect(sorted, ['solata', 'špinača', 'zelena', 'žajbelj']);
    });

    test('first letter c before č decides over later letters', () {
      // "cvetača" (c…) must precede "čebula" (č…) even though e < v.
      final input = ['čebula', 'cvetača'];
      final sorted = sortedByLabel(input, (s) => s);
      expect(sorted, ['cvetača', 'čebula']);
    });

    test('German umlauts fold next to their base vowel', () {
      final input = ['Zitrone', 'Öl', 'Apfel', 'Ähre'];
      final sorted = sortedByLabel(input, (s) => s);
      expect(sorted, ['Ähre', 'Apfel', 'Öl', 'Zitrone']);
    });

    test('comparator is symmetric and self-equal', () {
      expect(compareCatalogLabels('čaj', 'cvet'), greaterThan(0));
      expect(compareCatalogLabels('cvet', 'čaj'), lessThan(0));
      expect(compareCatalogLabels('limona', 'limona'), 0);
    });
  });
}
