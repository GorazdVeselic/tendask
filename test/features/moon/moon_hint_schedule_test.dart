import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/date_format.dart';
import 'package:tendask/core/notifications/notification_settings.dart';
import 'package:tendask/features/moon/application/moon_hint_schedule.dart';

/// Anchor for every case: the morning of 6 Aug 2026. Over the seven days that
/// follow, the sidereal calendar runs root · root · root · flower · flower ·
/// leaf (new moon on the 12th) · fruit, while the tropical one disagrees with
/// it on all but the first — so a garden filter, a calendar system and a
/// hardcoded list are all told apart by the same fixture.
final _from = DateTime(2026, 8, 6, 9);

const _off = NotificationSettings();
const _quiet = NotificationSettings(quietHoursEnabled: true);
const _capped = NotificationSettings(frequencyCapEnabled: true);

const _root = {BiodynamicElement.root};

List<MoonHint> _candidates({
  DateTime? from,
  int horizonDays = kMoonHintHorizonDays,
  int hour = kMoonHintHour,
  CalendarSystem system = CalendarSystem.sidereal,
  Set<BiodynamicElement> garden = _root,
}) => moonHintCandidates(
  fromLocal: from ?? _from,
  horizonDays: horizonDays,
  hour: hour,
  system: system,
  gardenElements: garden,
);

List<MoonHint> _plan({
  DateTime? from,
  NotificationSettings settings = _off,
  Set<DateTime> takenDays = const {},
  int maxHints = kMoonHintHorizonDays,
  int hour = kMoonHintHour,
  CalendarSystem system = CalendarSystem.sidereal,
  Set<BiodynamicElement> garden = _root,
}) => planMoonHints(
  nowLocal: from ?? _from,
  settings: settings,
  system: system,
  gardenElements: garden,
  takenDays: takenDays,
  maxHints: maxHints,
  horizonDays: kMoonHintHorizonDays,
  hour: hour,
);

List<DateTime> _fireTimes(List<MoonHint> hints) =>
    [for (final hint in hints) hint.fireTime];

void main() {
  group('moonHintCandidates', () {
    test('an empty garden is never interrupted', () {
      expect(_candidates(garden: const {}), isEmpty);
    });

    test('only days the garden can use, announced the evening before', () {
      final hints = _candidates();

      expect([for (final h in hints) h.date], [
        DateTime(2026, 8, 7),
        DateTime(2026, 8, 8),
        DateTime(2026, 8, 9),
      ]);
      expect(_fireTimes(hints), [
        DateTime(2026, 8, 6, kMoonHintHour),
        DateTime(2026, 8, 7, kMoonHintHour),
        DateTime(2026, 8, 8, kMoonHintHour),
      ]);
      expect(hints.every((h) => h.element == BiodynamicElement.root), isTrue);
      expect(hints.every((h) => !h.isNewMoon), isTrue);
    });

    test('a new moon day is flagged, so its own copy can replace the element '
        'activity', () {
      final hints = _candidates(garden: const {BiodynamicElement.leaf});

      expect(hints.single.date, DateTime(2026, 8, 12));
      expect(hints.single.isNewMoon, isTrue);
    });

    test('the horizon ends where it says', () {
      final hints = _candidates();

      for (final hint in hints) {
        expect(hint.date.isAfter(startOfDay(_from)), isTrue);
        expect(
          hint.date.isAfter(
            startOfDay(_from).add(const Duration(days: kMoonHintHorizonDays)),
          ),
          isFalse,
          reason: '${hint.date} is past the horizon',
        );
      }
      // 16 Aug is a root day too — just outside the window, so the filter
      // above is not passing everything.
      expect(hints.map((h) => h.date), isNot(contains(DateTime(2026, 8, 16))));
    });

    test("arming after the hour no longer schedules tonight's slot", () {
      final hints = _candidates(from: DateTime(2026, 8, 6, 20));

      // The 7th was announced at 18:00 tonight — two hours ago.
      expect([for (final h in hints) h.date], [
        DateTime(2026, 8, 8),
        DateTime(2026, 8, 9),
      ]);
    });

    test('the autumn daylight-saving day neither repeats nor swallows a day',
        () {
      // 25 Oct 2026 is 25 hours long in the suite's zone. Adding 24-hour blocks
      // used to land on it twice (two identical notifications for the same
      // evening) and never reach the last day of the horizon.
      final hints = _candidates(
        from: DateTime(2026, 10, 23, 9),
        garden: BiodynamicElement.values.toSet(),
      );

      expect([for (final h in hints) h.date], [
        for (var d = 24; d <= 30; d++) DateTime(2026, 10, d),
      ]);
      expect(
        {for (final h in hints) h.fireTime}.length,
        hints.length,
        reason: 'no two hints may share a fire time',
      );
    });

    test('the zodiac system decides which days qualify', () {
      final tropical = _candidates(system: CalendarSystem.tropical);

      expect([for (final h in tropical) h.date], [DateTime(2026, 8, 7)]);
      expect(
        [for (final h in tropical) h.date],
        isNot([for (final h in _candidates()) h.date]),
      );
    });
  });

  group('planMoonHints', () {
    test('with both anti-spam toggles off it is the candidate list', () {
      expect(_fireTimes(_plan()), _fireTimes(_candidates()));
    });

    test('never arms more hints than there are reserved ids', () {
      expect(_fireTimes(_plan(maxHints: 2)), _fireTimes(_candidates()).take(2));
    });

    test('the frequency cap drops a hint whose day is already taken', () {
      // The evening the first hint wants — the senior journal nudge's day.
      final taken = {DateTime(2026, 8, 6)};

      expect(
        _fireTimes(_plan(settings: _capped, takenDays: taken)),
        _fireTimes(_candidates()).skip(1),
      );
      // Same day, cap off: the user asked for both, so both are posted.
      expect(
        _fireTimes(_plan(settings: _off, takenDays: taken)),
        _fireTimes(_candidates()),
      );
    });

    test('quiet hours move a night hint into the morning instead of dropping '
        'it', () {
      // 03:00 sits inside the window; the window ends at 07:00 the same day,
      // still the eve of the day being announced.
      final hints = _plan(settings: _quiet, hour: 3);

      expect(_fireTimes(hints), [
        DateTime(2026, 8, 7, kQuietHoursEndHour),
        DateTime(2026, 8, 8, kQuietHoursEndHour),
      ]);
      expect([for (final h in hints) h.date], [
        DateTime(2026, 8, 8),
        DateTime(2026, 8, 9),
      ]);
    });

    test('a hint that would slip past midnight is dropped, not sent late', () {
      // 23:00 is inside the window, so it would land at 07:00 on the very day
      // it calls "tomorrow" — wrong, and silence is the lesser error.
      expect(_plan(settings: _quiet, hour: 23), isEmpty);
      // Without quiet hours the same three hints go out untouched, so the
      // emptiness above is the rule and not a broken fixture.
      expect(_plan(settings: _off, hour: 23), hasLength(3));
    });

    test('an empty garden plans nothing, whatever the toggles say', () {
      expect(_plan(garden: const {}, settings: _quiet), isEmpty);
    });
  });
}
