import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/tasks/yield_summary.dart';
import 'package:tendask/features/tasks/yield_unit.dart';

void main() {
  group('summarizeYield', () {
    test('empty input → empty summary', () {
      final s = summarizeYield(const []);
      expect(s.isEmpty, isTrue);
      expect(s.totals, isEmpty);
      expect(s.byYear, isEmpty);
    });

    test('sums per unit, never mixing kg and pieces', () {
      final s = summarizeYield(const [
        (year: 2026, amount: 2.0, unit: YieldUnit.kg),
        (year: 2026, amount: 3.5, unit: YieldUnit.kg),
        (year: 2026, amount: 10.0, unit: YieldUnit.pieces),
      ]);
      expect(s.totals[YieldUnit.kg], 5.5);
      expect(s.totals[YieldUnit.pieces], 10.0);
      expect(s.isEmpty, isFalse);
    });

    test('breaks down per year, newest first', () {
      final s = summarizeYield(const [
        (year: 2024, amount: 1.0, unit: YieldUnit.kg),
        (year: 2026, amount: 2.0, unit: YieldUnit.kg),
        (year: 2025, amount: 4.0, unit: YieldUnit.kg),
      ]);
      expect(s.byYear.map((y) => y.year).toList(), [2026, 2025, 2024]);
      expect(s.totals[YieldUnit.kg], 7.0);
      expect(s.byYear.first.totals[YieldUnit.kg], 2.0);
    });

    test('per-year totals keep units separate', () {
      final s = summarizeYield(const [
        (year: 2026, amount: 2.0, unit: YieldUnit.kg),
        (year: 2026, amount: 6.0, unit: YieldUnit.pieces),
        (year: 2025, amount: 1.0, unit: YieldUnit.kg),
      ]);
      final y2026 = s.byYear.firstWhere((y) => y.year == 2026);
      expect(y2026.totals[YieldUnit.kg], 2.0);
      expect(y2026.totals[YieldUnit.pieces], 6.0);
    });
  });
}
