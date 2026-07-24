import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/journal/presentation/note_date.dart';

void main() {
  // Afternoon, so start-of-day rounding is actually exercised.
  final now = DateTime(2026, 7, 15, 14, 30);

  group('noteDateOption', () {
    test('any time on the same calendar day is "today"', () {
      expect(noteDateOption(DateTime(2026, 7, 15, 8), now), NoteDateOption.today);
    });

    test('the day before is "yesterday"', () {
      expect(
        noteDateOption(DateTime(2026, 7, 14, 23), now),
        NoteDateOption.yesterday,
      );
    });

    test('anything older is "custom"', () {
      expect(noteDateOption(DateTime(2026, 7, 13), now), NoteDateOption.custom);
    });

    test('a future date is "custom"', () {
      expect(noteDateOption(DateTime(2026, 7, 20), now), NoteDateOption.custom);
    });
  });

  group('noteSelectedDate', () {
    test('today resolves to now', () {
      expect(noteSelectedDate(NoteDateOption.today, null, now), now);
    });

    test('yesterday is exactly one day back', () {
      expect(
        noteSelectedDate(NoteDateOption.yesterday, null, now),
        DateTime(2026, 7, 14, 14, 30),
      );
    });

    test('custom uses the picked date', () {
      final picked = DateTime(2026, 7, 1);
      expect(noteSelectedDate(NoteDateOption.custom, picked, now), picked);
    });

    test('custom with no picked date falls back to now', () {
      expect(noteSelectedDate(NoteDateOption.custom, null, now), now);
    });
  });
}
