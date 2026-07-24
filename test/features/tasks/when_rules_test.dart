import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/tasks/data/recurrence.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/when_rules.dart';

void main() {
  // Mid-morning "now" — presets must split by calendar day, not by a 24h window.
  final now = DateTime(2026, 6, 10, 9);

  group('whenPreset', () {
    test('later the same day is still the today preset', () {
      expect(whenPreset(DateTime(2026, 6, 10, 23), now), WhenPreset.today);
    });

    test('the next calendar day is tomorrow', () {
      expect(whenPreset(DateTime(2026, 6, 11, 1), now), WhenPreset.tomorrow);
    });

    test('anything else is custom — including yesterday', () {
      expect(whenPreset(DateTime(2026, 6, 12), now), WhenPreset.custom);
      expect(whenPreset(DateTime(2026, 6, 9, 23), now), WhenPreset.custom);
    });
  });

  group('dateForPreset', () {
    test('today keeps the time of day already set', () {
      final picked = dateForPreset(
        WhenPreset.today,
        DateTime(2026, 6, 20, 17, 45),
        now,
      );

      expect(picked, DateTime(2026, 6, 10, 17, 45));
    });

    test('tomorrow keeps the time of day already set', () {
      final picked = dateForPreset(
        WhenPreset.tomorrow,
        DateTime(2026, 6, 20, 6, 5),
        now,
      );

      expect(picked, DateTime(2026, 6, 11, 6, 5));
    });

    test('custom decides nothing — the caller opens the picker', () {
      expect(dateForPreset(WhenPreset.custom, DateTime(2026, 6, 20), now), isNull);
    });
  });

  group('recurrenceModeOf', () {
    test('no rule is off; 1 day is daily; 7 days is weekly', () {
      expect(recurrenceModeOf(null), RecurrenceMode.off);
      expect(
        recurrenceModeOf(const Recurrence(everyDays: 1)),
        RecurrenceMode.daily,
      );
      expect(
        recurrenceModeOf(const Recurrence(everyDays: 7)),
        RecurrenceMode.weekly,
      );
    });

    test('any other interval is custom', () {
      expect(
        recurrenceModeOf(const Recurrence(everyDays: 14)),
        RecurrenceMode.custom,
      );
    });
  });

  group('evaluateRecurrence', () {
    RecurrenceDraft evaluate({
      required RecurrenceMode mode,
      String intervalText = '14',
      bool limited = false,
      String countText = '3',
    }) => evaluateRecurrence(
      mode: mode,
      intervalText: intervalText,
      limited: limited,
      countText: countText,
    );

    test('off emits no rule and never blocks', () {
      final draft = evaluate(mode: RecurrenceMode.off);

      expect(draft.rule, isNull);
      expect(draft.valid, isTrue);
    });

    test('daily and weekly emit their fixed intervals, open-ended', () {
      expect(
        evaluate(mode: RecurrenceMode.daily).rule,
        const Recurrence(everyDays: 1),
      );
      expect(
        evaluate(mode: RecurrenceMode.weekly).rule,
        const Recurrence(everyDays: 7),
      );
    });

    test('a capped rule carries the repeat count', () {
      final draft = evaluate(
        mode: RecurrenceMode.weekly,
        limited: true,
        countText: '4',
      );

      expect(draft.rule, const Recurrence(everyDays: 7, remaining: 4));
      expect(draft.valid, isTrue);
    });

    test('a single repeat is valid', () {
      expect(
        evaluate(mode: RecurrenceMode.daily, limited: true, countText: '1').rule,
        const Recurrence(everyDays: 1, remaining: 1),
      );
    });

    test('an empty custom interval blocks and emits no rule', () {
      final draft = evaluate(mode: RecurrenceMode.custom, intervalText: '');

      expect(draft.valid, isFalse);
      expect(draft.intervalInvalid, isTrue);
      expect(draft.rule, isNull);
    });

    test('a zero interval blocks — the digits-only field lets 0 through', () {
      final draft = evaluate(mode: RecurrenceMode.custom, intervalText: '0');

      expect(draft.valid, isFalse);
      expect(draft.intervalInvalid, isTrue);
    });

    test('an interval too large to parse blocks', () {
      final draft = evaluate(
        mode: RecurrenceMode.custom,
        intervalText: '99999999999999999999999',
      );

      expect(draft.valid, isFalse);
      expect(draft.intervalInvalid, isTrue);
    });

    test('a zero repeat count blocks', () {
      final draft = evaluate(
        mode: RecurrenceMode.daily,
        limited: true,
        countText: '0',
      );

      expect(draft.valid, isFalse);
      expect(draft.countInvalid, isTrue);
      expect(draft.rule, isNull);
    });

    test('both fields wrong at once reports both', () {
      final draft = evaluate(
        mode: RecurrenceMode.custom,
        intervalText: '',
        limited: true,
        countText: '',
      );

      expect(draft.intervalInvalid, isTrue);
      expect(draft.countInvalid, isTrue);
      expect(draft.valid, isFalse);
    });

    test('garbage left behind a hidden interval field does not block', () {
      // The user typed into "custom", then switched to weekly: the interval
      // field is gone, so its text must not gate "Continue".
      final draft = evaluate(mode: RecurrenceMode.weekly, intervalText: '');

      expect(draft.valid, isTrue);
      expect(draft.intervalInvalid, isFalse);
      expect(draft.rule, const Recurrence(everyDays: 7));
    });

    test('a wrong count behind an unchecked cap does not block', () {
      final draft = evaluate(
        mode: RecurrenceMode.daily,
        limited: false,
        countText: '0',
      );

      expect(draft.valid, isTrue);
      expect(draft.countInvalid, isFalse);
      expect(draft.rule, const Recurrence(everyDays: 1));
    });

    test('the preview interval follows the mode', () {
      expect(evaluate(mode: RecurrenceMode.daily).everyDays, 1);
      expect(evaluate(mode: RecurrenceMode.weekly).everyDays, 7);
      expect(
        evaluate(mode: RecurrenceMode.custom, intervalText: '21').everyDays,
        21,
      );
    });
  });
}
