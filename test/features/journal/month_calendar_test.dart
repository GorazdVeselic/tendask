import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/journal/presentation/month_calendar_view.dart';

void main() {
  group('monthCells', () {
    test('June 2026 with Monday start: 1st is Monday → no leading nulls', () {
      // 1 June 2026 is a Monday; firstWeekday=1 (Monday).
      final cells = monthCells(DateTime(2026, 6), 1);
      expect(cells.length, 30);
      expect(cells.first, DateTime(2026, 6, 1));
      expect(cells.last, DateTime(2026, 6, 30));
    });

    test('June 2026 with Sunday start: 1st (Mon) → 1 leading null', () {
      final cells = monthCells(DateTime(2026, 6), 0);
      expect(cells.length, 31); // 1 leading null + 30 days
      expect(cells.first, isNull);
      expect(cells[1], DateTime(2026, 6, 1));
      expect(cells.last, DateTime(2026, 6, 30));
    });

    test('leading nulls align the 1st under its weekday column', () {
      // 1 Feb 2026 is a Sunday (weekday 7). Monday start → 6 leading nulls.
      final cells = monthCells(DateTime(2026, 2), 1);
      final leading = cells.takeWhile((c) => c == null).length;
      expect(leading, 6);
      expect(cells[leading], DateTime(2026, 2, 1));
    });

    test('handles leap February (29 days)', () {
      final days = monthCells(DateTime(2024, 2), 1).whereType<DateTime>();
      expect(days.length, 29);
      expect(days.last, DateTime(2024, 2, 29));
    });

    test('handles 31-day month', () {
      final days = monthCells(DateTime(2026, 1), 1).whereType<DateTime>();
      expect(days.length, 31);
    });
  });
}
