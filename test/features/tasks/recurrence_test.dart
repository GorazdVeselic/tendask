import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/tasks/data/recurrence.dart';

void main() {
  group('Recurrence.tryParse', () {
    test('null / empty → null (one-off)', () {
      expect(Recurrence.tryParse(null), isNull);
      expect(Recurrence.tryParse(''), isNull);
    });

    test('valid open-ended rule', () {
      final r = Recurrence.tryParse('{"everyDays":7}');
      expect(r, const Recurrence(everyDays: 7));
      expect(r!.remaining, isNull);
    });

    test('valid capped rule', () {
      expect(
        Recurrence.tryParse('{"everyDays":2,"remaining":3}'),
        const Recurrence(everyDays: 2, remaining: 3),
      );
    });

    test('malformed JSON → null', () {
      expect(Recurrence.tryParse('not json'), isNull);
      expect(Recurrence.tryParse('[1,2,3]'), isNull);
    });

    test('everyDays < 1 or missing → null', () {
      expect(Recurrence.tryParse('{"everyDays":0}'), isNull);
      expect(Recurrence.tryParse('{"remaining":3}'), isNull);
    });

    test('invalid remaining (< 1) degrades to open-ended', () {
      expect(
        Recurrence.tryParse('{"everyDays":7,"remaining":0}'),
        const Recurrence(everyDays: 7),
      );
    });
  });

  group('Recurrence.encode', () {
    test('omits remaining when open-ended', () {
      expect(const Recurrence(everyDays: 7).encode(), '{"everyDays":7}');
    });

    test('round-trips through tryParse', () {
      const r = Recurrence(everyDays: 3, remaining: 4);
      expect(Recurrence.tryParse(r.encode()), r);
    });
  });

  group('Recurrence.next', () {
    test('open-ended keeps repeating', () {
      expect(const Recurrence(everyDays: 7).next(), const Recurrence(everyDays: 7));
    });

    test('decrements remaining', () {
      expect(
        const Recurrence(everyDays: 2, remaining: 3).next(),
        const Recurrence(everyDays: 2, remaining: 2),
      );
    });

    test('remaining == 1 → child is terminal (null)', () {
      expect(const Recurrence(everyDays: 2, remaining: 1).next(), isNull);
    });
  });

  group('nextOccurrenceDate', () {
    test('daily / weekly / custom add the interval, keep the time', () {
      final base = DateTime(2026, 6, 2, 18, 30);
      expect(nextOccurrenceDate(base, 1), DateTime(2026, 6, 3, 18, 30));
      expect(nextOccurrenceDate(base, 7), DateTime(2026, 6, 9, 18, 30));
      expect(nextOccurrenceDate(base, 14), DateTime(2026, 6, 16, 18, 30));
    });

    test('rolls over month and year boundaries', () {
      expect(
        nextOccurrenceDate(DateTime(2026, 6, 28, 9), 7),
        DateTime(2026, 7, 5, 9),
      );
      expect(
        nextOccurrenceDate(DateTime(2026, 12, 30, 9), 7),
        DateTime(2027, 1, 6, 9),
      );
    });

    test('preserves wall-clock time across a DST boundary', () {
      // EU summer time starts 2026-03-29; civil-day arithmetic keeps 09:00.
      final next = nextOccurrenceDate(DateTime(2026, 3, 28, 9), 7);
      expect(next, DateTime(2026, 4, 4, 9));
      expect(next.hour, 9);
    });
  });
}
