import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/local_prefs/local_prefs.dart';
import 'package:tendask/features/moon/application/moon_month_provider.dart';
import 'package:tendask/features/moon/application/moon_settings_controller.dart';

/// First 2026 day whose element changes within [kMoonMidnightSliverWindow]
/// after local midnight — the display rule's own case (7 such days in 2026).
DateTime _sliverDate() => _firstDayWhere(
  (day, dayStart) =>
      day.transitionAt != null &&
      day.transitionAt!.difference(dayStart) < kMoonMidnightSliverWindow,
);

/// First 2026 day with a transition well past the sliver window.
DateTime _plainTransitionDate() => _firstDayWhere(
  (day, dayStart) =>
      day.transitionAt != null &&
      day.transitionAt!.difference(dayStart) > const Duration(hours: 6),
);

/// First 2026 day the Moon spends in a single division.
DateTime _quietDate() => _firstDayWhere((day, _) => day.transitionAt == null);

DateTime _firstDayWhere(bool Function(BiodynamicDay, DateTime) test) {
  for (var d = DateTime(2026); d.year == 2026; d = _nextDay(d)) {
    if (test(dayFor(d, CalendarSystem.sidereal), d)) return d;
  }
  throw StateError('no matching day in 2026');
}

DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);

void main() {
  group('moonMonthDayFor (grid-cell reduction)', () {
    test('a midnight sliver hands the whole day to the new element', () {
      final date = _sliverDate();
      final day = dayFor(date, CalendarSystem.sidereal);
      final cell = moonMonthDayFor(date, CalendarSystem.sidereal);

      // The engine still reports the start-of-day element and the transition;
      // the display rule is what swallows a sliver (plan T3.3).
      expect(day.secondaryElement, isNotNull, reason: '$date');
      expect(cell.element, day.secondaryElement, reason: '$date');
      expect(cell.element, isNot(day.element), reason: '$date');
      // No split background and no "until HH:MM" tail for a sliver: the cell
      // carries one element, so both must be gone together.
      expect(cell.secondaryElement, isNull, reason: '$date');
      expect(cell.transitionAt, isNull, reason: '$date');
    });

    test('an ordinary transition keeps its hour and second element', () {
      final date = _plainTransitionDate();
      final day = dayFor(date, CalendarSystem.sidereal);
      final cell = moonMonthDayFor(date, CalendarSystem.sidereal);

      expect(cell.element, day.element, reason: '$date');
      expect(cell.secondaryElement, day.secondaryElement, reason: '$date');
      expect(cell.transitionAt, day.transitionAt, reason: '$date');
    });

    test('a single-element day carries neither a tail nor a split', () {
      final cell = moonMonthDayFor(_quietDate(), CalendarSystem.sidereal);
      expect(cell.transitionAt, isNull);
      expect(cell.secondaryElement, isNull);
    });

    test('moonDayLabel is the same reduction, without the phase scan', () {
      // The three light surfaces (home chip, when-step badge, task section)
      // read the label through this cheaper path; it must not diverge from the
      // grid cell they have to agree with.
      for (final date in [_sliverDate(), _plainTransitionDate(), _quietDate()]) {
        final cell = moonMonthDayFor(date, CalendarSystem.sidereal);
        final label = moonDayLabelFor(date, CalendarSystem.sidereal);

        expect(label.element, cell.element, reason: '$date');
        expect(label.transitionAt, cell.transitionAt, reason: '$date');
        expect(label.secondaryElement, cell.secondaryElement, reason: '$date');
      }
    });

    test('moonDayLabel normalizes the date like the grid cell does', () {
      final label = moonDayLabelFor(
        DateTime(2026, 8, 15, 21, 30),
        CalendarSystem.sidereal,
      );
      expect(label.element, moonMonthDayFor(
        DateTime(2026, 8, 15),
        CalendarSystem.sidereal,
      ).element);
    });

    test('the date is normalized to local midnight', () {
      final cell = moonMonthDayFor(
        DateTime(2026, 8, 15, 21, 30),
        CalendarSystem.sidereal,
      );
      expect(cell.date, DateTime(2026, 8, 15));
    });

    test('the sliver rule holds for every such day of 2026', () {
      var slivers = 0;
      for (var d = DateTime(2026); d.year == 2026; d = _nextDay(d)) {
        final day = dayFor(d, CalendarSystem.sidereal);
        final at = day.transitionAt;
        if (at == null) continue;
        if (at.difference(d) >= kMoonMidnightSliverWindow) continue;
        slivers++;
        final cell = moonMonthDayFor(d, CalendarSystem.sidereal);
        expect(cell.element, day.secondaryElement, reason: '$d');
        expect(cell.transitionAt, isNull, reason: '$d');
      }
      // Zero would mean the scan (or the engine) stopped producing slivers and
      // the rule above is being verified against nothing.
      expect(slivers, greaterThan(0));
    });
  });

  group('principalPhaseOn', () {
    test('marks the exact August 2026 event days and nothing else', () {
      // Published events: new moon 12 Aug 17:37 UTC (partial solar eclipse),
      // full moon 28 Aug (partial lunar) — the same references the fixture
      // is anchored on.
      final marked = <int, MoonPhase>{};
      for (var d = 1; d <= 31; d++) {
        final phase = principalPhaseOn(DateTime(2026, 8, d));
        if (phase != null) marked[d] = phase;
      }
      expect(marked[12], MoonPhase.newMoon);
      expect(marked[28], MoonPhase.fullMoon);
      // One marker per principal phase, so exactly four in a month whose
      // cycle fits: new, first quarter, full, last quarter.
      expect(marked.length, 4);
      expect(
        marked.values.toSet(),
        {
          MoonPhase.newMoon,
          MoonPhase.firstQuarter,
          MoonPhase.fullMoon,
          MoonPhase.lastQuarter,
        },
      );
    });

    test('a day without an exact event carries no marker', () {
      expect(principalPhaseOn(DateTime(2026, 8, 15)), isNull);
    });
  });

  group('moonMonth provider', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('covers every day of the month plus six leading days', () {
      // Six is exactly what both consumers need: the grid's leading fill (up
      // to six) and the week agenda of a week ending on the 1st.
      final month = DateTime(2026, 8);
      final days = container.read(moonMonthProvider(month));

      for (var d = 1; d <= 31; d++) {
        expect(days.containsKey(DateTime(2026, 8, d)), isTrue, reason: 'Aug $d');
      }
      for (var back = 1; back <= 6; back++) {
        final date = DateTime(2026, 8, 1 - back);
        expect(days.containsKey(date), isTrue, reason: '$date');
      }
      expect(days.containsKey(DateTime(2026, 7, 24)), isFalse); // 8 days back
      expect(days.length, 37);
    });

    test('keys are local midnight and match their cell date', () {
      final days = container.read(moonMonthProvider(DateTime(2026, 8)));
      for (final MapEntry(key: date, value: cell) in days.entries) {
        expect(date.hour, 0);
        expect(cell.date, date);
      }
    });

    test('follows the stored system (one system drives every surface)',
        () async {
      await container.read(localPrefsProvider).setMoonSystem('tropical');
      // Resolve the settings first: until they load, every moon surface reads
      // the sidereal fallback by design.
      await container.read(moonSettingsControllerProvider.future);
      expect(container.read(moonSystemProvider), CalendarSystem.tropical);

      final days = container.read(moonMonthProvider(DateTime(2026, 8)));
      for (final MapEntry(key: date, value: cell) in days.entries) {
        expect(
          cell.element,
          moonMonthDayFor(date, CalendarSystem.tropical).element,
          reason: '$date',
        );
      }
      // The systems really do differ in this month, so the check above is not
      // vacuous.
      final sidereal = {
        for (final date in days.keys)
          date: moonMonthDayFor(date, CalendarSystem.sidereal).element,
      };
      expect(
        days.entries.any((e) => sidereal[e.key] != e.value.element),
        isTrue,
      );
    });

    test('falls back to sidereal while the settings are still loading', () {
      expect(container.read(moonSystemProvider), CalendarSystem.sidereal);
    });
  });
}
