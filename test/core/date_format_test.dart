import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/date_format.dart';

void main() {
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
