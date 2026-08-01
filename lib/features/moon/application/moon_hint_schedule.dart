import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/date_format.dart';
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
/// dropped (arming at 20:00 no longer schedules tonight's 18:00). The caller
/// still runs every time through `hintFireTime` for quiet hours and the cap.
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
    final date = startOfDay(today.add(Duration(days: offset)));
    final cell = moonMonthDayFor(date, system);
    if (!gardenElements.contains(cell.element)) continue;

    // startOfDay first: a DST day is 23 or 25 hours long, so the eve is a
    // calendar step, not a 24-hour subtraction.
    final eve = startOfDay(date.subtract(const Duration(days: 1)));
    final fireTime = DateTime(eve.year, eve.month, eve.day, hour);
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
