import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/features/notifications/application/journal_nudge_schedule.dart';

void main() {
  // "Now" = 29 Jun 2026 (Mon) at 10:00 local.
  final now = DateTime(2026, 6, 29, 10, 0);

  group('journalNudgeFireTimes', () {
    test('fires the decay chain N whole days out at the given hour', () {
      final times = journalNudgeFireTimes(
        fromLocal: now,
        dayOffsets: kJournalNudgeDayOffsets, // [7, 28]
        hour: kJournalNudgeHour, // 17
      );
      expect(times, [
        DateTime(2026, 7, 6, 17), // +7 days
        DateTime(2026, 7, 27, 17), // +28 days
      ]);
    });

    test('the time-of-day ignores the "now" time', () {
      final late = journalNudgeFireTimes(
        fromLocal: DateTime(2026, 6, 29, 23, 59),
        dayOffsets: const [7],
        hour: 17,
      );
      expect(late, [DateTime(2026, 7, 6, 17)]);
    });

    test('skips a day already carrying a task reminder', () {
      final times = journalNudgeFireTimes(
        fromLocal: now,
        dayOffsets: const [7, 28],
        hour: 17,
        taskReminderDays: {DateTime(2026, 7, 6)},
      );
      expect(times.first, DateTime(2026, 7, 7, 17)); // shifted off the 6th
      expect(times.last, DateTime(2026, 7, 27, 17)); // second step unaffected
    });

    test('skips several consecutive reminder days', () {
      final times = journalNudgeFireTimes(
        fromLocal: now,
        dayOffsets: const [7],
        hour: 17,
        taskReminderDays: {
          DateTime(2026, 7, 6),
          DateTime(2026, 7, 7),
          DateTime(2026, 7, 8),
        },
      );
      expect(times, [DateTime(2026, 7, 9, 17)]);
    });

    test('stays strictly increasing when a shift overruns the next step', () {
      // Step 1 (+7) collides and is pushed to day 8; step 2 (+8) must then land
      // after it, not on the same day.
      final times = journalNudgeFireTimes(
        fromLocal: now,
        dayOffsets: const [7, 8],
        hour: 17,
        taskReminderDays: {DateTime(2026, 7, 6)},
      );
      expect(times, [DateTime(2026, 7, 7, 17), DateTime(2026, 7, 8, 17)]);
      expect(times.last.isAfter(times.first), isTrue);
    });

    test('crosses a month boundary correctly', () {
      final times = journalNudgeFireTimes(
        fromLocal: DateTime(2026, 6, 29, 10),
        dayOffsets: const [7],
        hour: 17,
      );
      expect(times, [DateTime(2026, 7, 6, 17)]);
    });

    test('empty offsets yield no nudges', () {
      expect(
        journalNudgeFireTimes(fromLocal: now, dayOffsets: const [], hour: 17),
        isEmpty,
      );
    });

    test('every fire time is in the future', () {
      final times = journalNudgeFireTimes(
        fromLocal: now,
        dayOffsets: kJournalNudgeDayOffsets,
        hour: kJournalNudgeHour,
      );
      expect(times.every((t) => t.isAfter(now)), isTrue);
    });
  });
}
