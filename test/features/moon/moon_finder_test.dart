import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';
import 'package:tendask/features/moon/application/moon_finder.dart';
import 'package:tendask/features/moon/application/moon_month_provider.dart';

/// The "when for X" finder (FR-19 T5.2): stretches of days the calendar
/// labels with one element. Asserted as properties against the engine, not
/// against hardcoded dates, so a boundary recalibration cannot silently rot
/// the expectations.
void main() {
  const system = CalendarSystem.sidereal;
  final from = DateTime(2026, 8, 1);

  BiodynamicElement labelOf(DateTime d) => moonMonthDayFor(d, system).element;

  DateTime dayAfter(DateTime d) => DateTime(d.year, d.month, d.day + 1);
  DateTime dayBefore(DateTime d) => DateTime(d.year, d.month, d.day - 1);

  for (final element in BiodynamicElement.values) {
    test('${element.name}: every listed day carries the element', () {
      final runs = moonDayRuns(from: from, element: element, system: system);

      expect(runs, isNotEmpty, reason: 'every element recurs within 60 days');
      for (final run in runs) {
        for (
          var d = run.start;
          !d.isAfter(run.end);
          d = dayAfter(d)
        ) {
          expect(labelOf(d), element, reason: '$d inside ${run.start}');
        }
      }
    });

    test('${element.name}: runs are maximal and in order', () {
      final runs = moonDayRuns(from: from, element: element, system: system);

      for (final (i, run) in runs.indexed) {
        // A run must not be cut short: the days framing it carry another
        // element. Holds at the horizon too — the scan follows an open
        // stretch past it rather than truncating the range.
        if (run.start.isAfter(from)) {
          expect(labelOf(dayBefore(run.start)), isNot(element));
        }
        expect(labelOf(dayAfter(run.end)), isNot(element));
        expect(run.end.isBefore(run.start), isFalse);
        if (i > 0) expect(run.start.isAfter(runs[i - 1].end), isTrue);
      }
    });
  }

  test('the horizon bounds the answer', () {
    expect(
      moonDayRuns(
        from: from,
        element: BiodynamicElement.fruit,
        system: system,
        horizonDays: 0,
      ),
      isEmpty,
    );

    final short = moonDayRuns(
      from: from,
      element: BiodynamicElement.fruit,
      system: system,
      horizonDays: 20,
    );
    // Every stretch STARTS inside the horizon; one may end just past it,
    // because a stretch is never shown truncated.
    for (final run in short) {
      expect(run.start.isBefore(DateTime(2026, 8, 21)), isTrue);
    }
  });

  test('a run reports the phase half of its first day', () {
    for (final run in moonDayRuns(
      from: from,
      element: BiodynamicElement.leaf,
      system: system,
    )) {
      expect(run.waxing, isWaxing(dayFor(run.start, system).phase));
    }
  });

  test('the system decides which days come back', () {
    final sidereal = moonDayRuns(
      from: from,
      element: BiodynamicElement.fruit,
      system: CalendarSystem.sidereal,
    );
    final tropical = moonDayRuns(
      from: from,
      element: BiodynamicElement.fruit,
      system: CalendarSystem.tropical,
    );

    expect(
      sidereal.map((r) => r.start),
      isNot(tropical.map((r) => r.start)),
      reason: 'the zodiac division shifts the element days by days',
    );
  });
}
