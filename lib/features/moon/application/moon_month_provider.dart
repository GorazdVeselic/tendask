import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/biodynamic/moon_calendar.dart';
import '../../../core/config.dart';
import 'moon_settings_controller.dart';

part 'moon_month_provider.g.dart';

/// One day of the moon month grid (FR-19 T3.3), reduced to what a cell shows.
class MoonMonthDay {
  const MoonMonthDay({
    required this.date,
    required this.element,
    this.secondaryElement,
    this.principalPhase,
  });

  /// Local midnight of the day.
  final DateTime date;

  /// Element the cell is labelled with: start-of-day convention (spec §12.6),
  /// except a transition within [kMoonMidnightSliverWindow] hands the whole
  /// day to the new element (display rule, plan T3.3).
  final BiodynamicElement element;

  /// Post-transition element for the split cell background; null when the
  /// cell shows a single element.
  final BiodynamicElement? secondaryElement;

  /// Principal phase whose exact instant falls on this day, or null.
  final MoonPhase? principalPhase;
}

/// Computes the grid cell for one local calendar day.
MoonMonthDay moonMonthDayFor(DateTime localDate, CalendarSystem system) {
  final dayStart = DateTime(localDate.year, localDate.month, localDate.day);
  final day = dayFor(dayStart, system);

  var element = day.element;
  var secondary = day.secondaryElement;
  final transitionAt = day.transitionAt;
  if (transitionAt != null &&
      transitionAt.difference(dayStart) < kMoonMidnightSliverWindow) {
    // BiodynamicDay asserts secondaryElement is set whenever transitionAt is.
    element = day.secondaryElement!;
    secondary = null;
  }

  return MoonMonthDay(
    date: dayStart,
    element: element,
    secondaryElement: secondary,
    principalPhase: principalPhaseOn(dayStart),
  );
}

/// Cells of the month grid for [month] (a `DateTime(year, month)` key): every
/// day of the month plus six leading days of the previous month for the grid
/// fill, keyed by local midnight. Memoized per (month, system) — one grid
/// costs ~16 ms (measurement T1.11), too much to recompute on every rebuild.
/// The system comes from [MoonSettingsController] (one system drives all moon
/// screens, spec §11.6); sidereal while settings are still loading.
@riverpod
Map<DateTime, MoonMonthDay> moonMonth(Ref ref, DateTime month) {
  final system =
      ref.watch(moonSettingsControllerProvider).asData?.value.system ??
          CalendarSystem.sidereal;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  return {
    for (var d = -5; d <= daysInMonth; d++)
      DateTime(month.year, month.month, d):
          moonMonthDayFor(DateTime(month.year, month.month, d), system),
  };
}
