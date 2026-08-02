import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/date_format.dart';
import '../../../core/notifications/hint_rules.dart';
import '../../../core/notifications/notification_settings.dart';
import 'moon_month_provider.dart';

/// One moon hint: post [fireTime] (local wall clock), about the day [date].
class MoonHint {
  const MoonHint({
    required this.fireTime,
    required this.date,
    required this.element,
    required this.isNewMoon,
  });

  /// Evening before [date] — the hint says "tomorrow".
  final DateTime fireTime;

  /// Local midnight of the day the hint is about.
  final DateTime date;

  /// Element the day is labelled with (same reduction the grid cell shows).
  final BiodynamicElement element;

  /// The day carries the new moon, whose "let the garden rest" copy overrides
  /// the per-element activity everywhere else in the app.
  final bool isNewMoon;

  MoonHint _at(DateTime newFireTime) => MoonHint(
    fireTime: newFireTime,
    date: date,
    element: element,
    isNewMoon: isNewMoon,
  );

  @override
  String toString() =>
      'MoonHint(fireTime: $fireTime, date: $date, element: ${element.name}, '
      'isNewMoon: $isNewMoon)';
}

/// Hints worth posting in the [horizonDays] days after [fromLocal]: one per day
/// whose element is among [gardenElements] — the same ★ rule the month grid
/// highlights with, so the user only hears about days they can act on
/// (decision 2026-08-01). An empty garden yields no hints at all.
///
/// Each fires at [hour] on the eve of its day, and times already past are
/// dropped (arming at 20:00 no longer schedules tonight's 18:00). These are the
/// *wanted* times — [planMoonHints] is what runs them through the gentle-hint
/// rules.
List<MoonHint> moonHintCandidates({
  required DateTime fromLocal,
  required int horizonDays,
  required int hour,
  required CalendarSystem system,
  required Set<BiodynamicElement> gardenElements,
}) {
  if (gardenElements.isEmpty) return const [];

  final hints = <MoonHint>[];
  final today = startOfDay(fromLocal);
  for (var offset = 1; offset <= horizonDays; offset++) {
    // Calendar step, never `add(Duration(days:))`: on the autumn changeover a
    // local day is 25 hours long, so adding 24-hour blocks would land twice on
    // the same date and drop the last day of the horizon.
    final date = addDays(today, offset);
    final cell = moonMonthDayFor(date, system);
    if (!gardenElements.contains(cell.element)) continue;

    // Calendar step for the same reason: the eve of a 25-hour day is not
    // "24 hours earlier".
    final fireTime = DateTime(date.year, date.month, date.day - 1, hour);
    if (!fireTime.isAfter(fromLocal)) continue;

    hints.add(
      MoonHint(
        fireTime: fireTime,
        date: date,
        element: cell.element,
        isNewMoon: cell.principalPhase == MoonPhase.newMoon,
      ),
    );
  }
  return hints;
}

/// The hints to arm at [nowLocal], in fire order and at most [maxHints] long
/// (one per reserved OS id) — [moonHintCandidates] put through the gentle-hint
/// rules: quiet hours may move one, the frequency cap drops one whose day is
/// already taken, and every hint that survives takes its own day, so the next
/// one yields to it. [takenDays] seeds those days with what other hints
/// (the senior journal nudge) already own.
///
/// A hint is dropped when quiet hours would push it past midnight: it says
/// "tomorrow", which is wrong once the day it announces has begun. With
/// [hour] outside the window that cannot happen, but the rule is the reason the
/// window may never grow into the evening unnoticed.
List<MoonHint> planMoonHints({
  required DateTime nowLocal,
  required NotificationSettings settings,
  required CalendarSystem system,
  required Set<BiodynamicElement> gardenElements,
  required Set<DateTime> takenDays,
  required int maxHints,
  required int horizonDays,
  required int hour,
}) {
  final candidates = moonHintCandidates(
    fromLocal: nowLocal,
    horizonDays: horizonDays,
    hour: hour,
    system: system,
    gardenElements: gardenElements,
  );

  final taken = {...takenDays};
  final planned = <MoonHint>[];
  for (final hint in candidates) {
    if (planned.length == maxHints) break;
    final when = hintFireTime(
      desiredLocal: hint.fireTime,
      settings: settings,
      otherHintDays: taken,
    );
    if (when == null || !when.isAfter(nowLocal)) continue;
    if (startOfDay(when) != startOfDay(hint.fireTime)) continue;

    taken.add(startOfDay(when));
    planned.add(hint._at(when));
  }
  return planned;
}
