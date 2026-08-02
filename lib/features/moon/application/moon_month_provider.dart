import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/biodynamic/moon_calendar.dart';
import '../../../core/config.dart';
import '../../../core/date_format.dart';
import 'moon_settings_controller.dart';

part 'moon_month_provider.g.dart';

/// One day of the moon month grid (FR-19 T3.3), reduced to what a cell shows.
class MoonMonthDay {
  const MoonMonthDay({
    required this.date,
    required this.element,
    this.transitionAt,
    this.secondaryElement,
    this.principalPhase,
  }) : assert(
         (transitionAt == null) == (secondaryElement == null),
         'transitionAt and secondaryElement must be set together',
       );

  /// Local midnight of the day.
  final DateTime date;

  /// Element the cell is labelled with: start-of-day convention (spec §12.6),
  /// except a transition within [kMoonMidnightSliverWindow] hands the whole
  /// day to the new element (display rule, plan T3.3).
  final BiodynamicElement element;

  /// Local wall-clock time the day changes element, as the cell sees it: null
  /// when the day carries one element — including a midnight sliver, which the
  /// display rule swallows into [element].
  final DateTime? transitionAt;

  /// Post-transition element for the split cell background; null when the
  /// cell shows a single element.
  final BiodynamicElement? secondaryElement;

  /// Principal phase whose exact instant falls on this day, or null.
  final MoonPhase? principalPhase;
}

/// What the calendar labels a day with: the element of the cell plus the
/// transition the cell still shows (null on a single-element day, and on a
/// midnight sliver, which the display rule swallows).
typedef MoonDayLabel = ({
  BiodynamicElement element,
  DateTime? transitionAt,
  BiodynamicElement? secondaryElement,
});

/// Applies the display rule to an already computed [day] (of [dayStart]).
///
/// Takes the engine result instead of a date so a surface that needs other
/// layers too (the home chip needs the phase) computes [dayFor] once.
MoonDayLabel moonDayLabel(BiodynamicDay day, DateTime dayStart) {
  final transitionAt = day.transitionAt;
  if (transitionAt != null &&
      transitionAt.difference(dayStart) < kMoonMidnightSliverWindow) {
    // BiodynamicDay asserts secondaryElement is set whenever transitionAt is.
    return (
      element: day.secondaryElement!,
      transitionAt: null,
      secondaryElement: null,
    );
  }
  return (
    element: day.element,
    transitionAt: transitionAt,
    secondaryElement: day.secondaryElement,
  );
}

/// The day label for a date — for surfaces that show only the label (the
/// when-step badge, the task detail section) and would otherwise pay for the
/// phase-event scan of [moonMonthDayFor] without ever reading it.
MoonDayLabel moonDayLabelFor(DateTime localDate, CalendarSystem system) {
  final dayStart = startOfDay(localDate);
  return moonDayLabel(dayFor(dayStart, system), dayStart);
}

/// Computes the grid cell for one local calendar day.
MoonMonthDay moonMonthDayFor(DateTime localDate, CalendarSystem system) {
  final dayStart = startOfDay(localDate);
  final label = moonDayLabel(dayFor(dayStart, system), dayStart);

  return MoonMonthDay(
    date: dayStart,
    element: label.element,
    transitionAt: label.transitionAt,
    secondaryElement: label.secondaryElement,
    principalPhase: principalPhaseOn(dayStart),
  );
}

/// Cells of the month grid for [month] (a `DateTime(year, month)` key): every
/// day of the month plus six leading days of the previous month, keyed by
/// local midnight. Six covers both consumers exactly — the grid's leading fill
/// and the week agenda of a week ending on the 1st. Memoized per (month,
/// system): one grid costs ~16 ms (measurement T1.11), too much to recompute
/// on every rebuild.
@riverpod
Map<DateTime, MoonMonthDay> moonMonth(Ref ref, DateTime month) {
  final system = ref.watch(moonSystemProvider);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  return {
    for (var d = -5; d <= daysInMonth; d++)
      DateTime(month.year, month.month, d):
          moonMonthDayFor(DateTime(month.year, month.month, d), system),
  };
}
