import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/biodynamic/moon_calendar.dart';
import '../../../core/config.dart';
import '../../../core/date_format.dart';
import 'moon_month_provider.dart';
import 'moon_settings_controller.dart';

part 'moon_finder.g.dart';

/// A stretch of consecutive days carrying the same element (FR-19 T5.2): the
/// reverse finder answers "when for X" in stretches, because element days
/// arrive in runs of two or three, not one by one.
class MoonDayRun {
  const MoonDayRun({
    required this.start,
    required this.end,
    required this.waxing,
  });

  /// Local midnight of the first day of the run.
  final DateTime start;

  /// Local midnight of the last day of the run (inclusive; equals [start] for
  /// a single day).
  final DateTime end;

  /// Phase half the run starts in — a run never spans more than three days,
  /// so its first day speaks for it.
  final bool waxing;
}

/// Upcoming runs of days labelled with [element], starting at [from] (a local
/// midnight) and looking [horizonDays] ahead.
///
/// Matches the day label the calendar shows (start-of-day element with the
/// midnight-sliver rule) — the same reduction the ★ highlight uses, so the
/// finder can never recommend a day the grid labels differently.
List<MoonDayRun> moonDayRuns({
  required DateTime from,
  required BiodynamicElement element,
  required CalendarSystem system,
  int horizonDays = kMoonFinderHorizonDays,
}) {
  final runs = <MoonDayRun>[];
  DateTime? start;
  DateTime? last;

  void closeRun() {
    final (first, until) = (start, last);
    if (first == null || until == null) return;
    runs.add(
      MoonDayRun(
        start: first,
        end: until,
        waxing: isWaxing(dayFor(first, system).phase),
      ),
    );
    start = null;
  }

  // Runs past the horizon until the open stretch ends: a range cut at the
  // horizon would claim the good days stop earlier than they do. The Moon
  // leaves a division within a few days, so the tail cannot grow.
  const maxTailDays = 8;
  for (var i = 0; i < horizonDays + maxTailDays; i++) {
    if (i >= horizonDays && start == null) break;
    final date = addDays(from, i);
    if (moonMonthDayFor(date, system).element == element) {
      start ??= date;
      last = date;
    } else {
      closeRun();
    }
  }
  closeRun(); // only reachable if the tail cap cut an open stretch
  return runs;
}

/// Runs for the finder screen, memoized per (element, day, system): one call
/// walks [kMoonFinderHorizonDays] days through the engine (~0.19 ms per day,
/// measurement T1.11), too much to redo on every rebuild.
@riverpod
List<MoonDayRun> moonFinderRuns(
  Ref ref,
  BiodynamicElement element,
  DateTime from,
) => moonDayRuns(
  from: from,
  element: element,
  system: ref.watch(moonSystemProvider),
);
