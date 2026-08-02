import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/date_format.dart';

void main() {
  group('addDays', () {
    // The EU changeovers of 2026 in the zone the test suite pins
    // (Europe/Ljubljana, ci.yml): 29 March forward, 25 October back.
    test('the autumn 25-hour day still steps one date at a time', () {
      final from = DateTime(2026, 10, 24);
      expect(addDays(from, 1), DateTime(2026, 10, 25));
      expect(addDays(from, 2), DateTime(2026, 10, 26));
      expect(addDays(from, 3), DateTime(2026, 10, 27));
      // What the 24-hour arithmetic does instead: lands on the 25th twice and
      // never reaches the 30th (the bug this helper exists for).
      expect(from.add(const Duration(days: 2)), isNot(DateTime(2026, 10, 26)));
    });

    test('the spring 23-hour day steps too', () {
      expect(addDays(DateTime(2026, 3, 28), 1), DateTime(2026, 3, 29));
      expect(addDays(DateTime(2026, 3, 28), 2), DateTime(2026, 3, 30));
    });

    test('the wall-clock time rides along, and negative steps go back', () {
      expect(addDays(DateTime(2026, 10, 24, 18, 30), 2),
          DateTime(2026, 10, 26, 18, 30));
      expect(addDays(DateTime(2026, 10, 26), -1), DateTime(2026, 10, 25));
    });

    test('month and year boundaries are the calendar\'s problem, not ours', () {
      expect(addDays(DateTime(2026, 12, 31), 1), DateTime(2027, 1, 1));
      expect(addDays(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 28));
    });
  });

  group('combineDateAndTime', () {
    test('moves the task to another day, keeping its time of day', () {
      final moved = combineDateAndTime(
        DateTime(2026, 7, 20),
        DateTime(2026, 6, 1, 8, 5),
      );

      expect(moved, DateTime(2026, 7, 20, 8, 5));
    });

    test('the picked date brings no time of its own', () {
      final moved = combineDateAndTime(
        DateTime(2026, 7, 20, 23, 59),
        DateTime(2026, 6, 1, 6, 30),
      );

      expect(moved, DateTime(2026, 7, 20, 6, 30));
    });

    test('seconds are dropped — a rescheduled task is minute-precise', () {
      final moved = combineDateAndTime(
        DateTime(2026, 7, 20),
        DateTime(2026, 6, 1, 8, 5, 42),
      );

      expect(moved.second, 0);
    });
  });
}
