import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';
import 'package:tendask/core/biodynamic/moon_longitude.dart';
import 'package:tendask/core/biodynamic/time_base.dart';
import 'package:tendask/core/biodynamic/zodiac.dart';

/// Oracle built from the lower-level verified pieces: sign at one instant.
ZodiacSign _signAt(DateTime instant, CalendarSystem system, int year) {
  final lambda = moonEclipticLongitude(julianCenturies(julianDay(instant)));
  return system == CalendarSystem.tropical
      ? tropicalSignFor(lambda)
      : siderealSignFor(lambda, year);
}

DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);

/// Checks dayFor wiring for one day against the oracle: start-of-day label,
/// transition bracketing, and the sign/element on both sides of a transition.
void _expectDayWiring(DateTime date, CalendarSystem system) {
  final day = dayFor(date, system);
  final start = DateTime(date.year, date.month, date.day);
  final end = _nextDay(date);
  final reason = '$date $system';

  expect(day.sign, _signAt(start, system, date.year), reason: reason);
  expect(day.element, elementOf(day.sign), reason: reason);
  expect(day.isConstellation, system == CalendarSystem.sidereal);

  final at = day.transitionAt;
  if (at == null) {
    expect(day.secondaryElement, isNull, reason: reason);
    expect(_signAt(end, system, date.year), day.sign, reason: reason);
  } else {
    expect(at.isAfter(start), isTrue, reason: reason);
    expect(at.isBefore(end), isTrue, reason: reason);
    final before = at.subtract(const Duration(minutes: 1));
    final after = at.add(const Duration(minutes: 1));
    expect(
      elementOf(_signAt(before, system, date.year)),
      day.element,
      reason: reason,
    );
    expect(
      elementOf(_signAt(after, system, date.year)),
      day.secondaryElement,
      reason: reason,
    );
  }
}

/// The element a day ends with must be the element the next day starts with.
void _expectContinuity(DateTime date, CalendarSystem system) {
  final day = dayFor(date, system);
  final next = dayFor(_nextDay(date), system);
  expect(
    day.secondaryElement ?? day.element,
    next.element,
    reason: '$date -> ${_nextDay(date)} $system',
  );
}

void main() {
  group('dateTimeFromJulianDay', () {
    test('JD 2451545.0 is 2000-01-01 12:00 UTC (no 13-day Julian shift)', () {
      expect(dateTimeFromJulianDay(2451545.0), DateTime.utc(2000, 1, 1, 12));
    });

    test('round-trips julianDay to the millisecond', () {
      final samples = [
        DateTime.utc(1992, 4, 12),
        DateTime.utc(2026, 3, 29, 1, 30, 15, 250),
        DateTime.utc(2026, 12, 31, 23, 59, 59, 999),
        DateTime(2026, 7, 14, 9, 43),
      ];
      for (final sample in samples) {
        expect(
          dateTimeFromJulianDay(julianDay(sample)),
          sample.toUtc(),
          reason: '$sample',
        );
      }
    });
  });

  group('dayFor', () {
    test('Meeus 47.a day (1992-04-12): tropical Moon in Leo, fruit day', () {
      final day = dayFor(DateTime(1992, 4, 12), CalendarSystem.tropical);
      expect(day.sign, ZodiacSign.leo);
      expect(day.isConstellation, isFalse);
      expect(day.element, BiodynamicElement.fruit);
    });

    test('phase and illumination around the July 2026 syzygies', () {
      final newMoonDay = dayFor(DateTime(2026, 7, 14), CalendarSystem.sidereal);
      expect(newMoonDay.phase, MoonPhase.newMoon);
      expect(newMoonDay.illumFraction, lessThan(0.03));

      final fullMoonDay =
          dayFor(DateTime(2026, 7, 29), CalendarSystem.tropical);
      expect(fullMoonDay.phase, MoonPhase.fullMoon);
      expect(fullMoonDay.illumFraction, greaterThan(0.97));
    });

    test('ascending and unfavorable stay null until T1.8/T1.9', () {
      final day = dayFor(DateTime(2026, 7, 14), CalendarSystem.sidereal);
      expect(day.ascending, isNull);
      expect(day.unfavorable, isNull);
    });

    test('wiring and continuity across the DST months, both systems', () {
      // Windows around the EU changeovers (late March / late October).
      final windows = [
        (DateTime(2026, 3, 20), DateTime(2026, 4, 5)),
        (DateTime(2026, 10, 18), DateTime(2026, 11, 3)),
      ];
      for (final (from, to) in windows) {
        for (var d = from; d.isBefore(to); d = _nextDay(d)) {
          for (final system in CalendarSystem.values) {
            _expectDayWiring(d, system);
            _expectContinuity(d, system);
          }
        }
      }
    });

    test('DST changeover days themselves (23 h / 25 h in EU zones)', () {
      final changeovers = [
        DateTime(2026, 3, 29),
        DateTime(2026, 10, 25),
        DateTime(2027, 3, 28),
        DateTime(2027, 10, 31),
      ];
      for (final d in changeovers) {
        for (final system in CalendarSystem.values) {
          _expectDayWiring(d, system);
          _expectContinuity(d, system);
        }
      }
    });

    test('about 44 percent of 2026 days have a transition (spec §14.7)', () {
      var transitions = 0;
      var days = 0;
      for (var d = DateTime(2026); d.year == 2026; d = _nextDay(d)) {
        days++;
        if (dayFor(d, CalendarSystem.sidereal).transitionAt != null) {
          transitions++;
        }
      }
      expect(transitions / days, closeTo(0.44, 0.05));
    });

    test('midnight sliver: first-hour transition keeps start-of-day label',
        () {
      // Spec §12.6: a day whose element changes shortly after midnight is
      // still labeled with the element it starts with.
      var found = 0;
      for (var d = DateTime(2026); d.year == 2026; d = _nextDay(d)) {
        final day = dayFor(d, CalendarSystem.sidereal);
        final at = day.transitionAt;
        if (at == null) continue;
        if (at.difference(DateTime(d.year, d.month, d.day)) >=
            const Duration(hours: 1)) {
          continue;
        }
        found++;
        expect(
          day.element,
          elementOf(_signAt(d, CalendarSystem.sidereal, d.year)),
          reason: '$d',
        );
        expect(day.element, isNot(day.secondaryElement), reason: '$d');
      }
      // Transitions land uniformly in the day, so a year has several
      // first-hour ones; zero would mean the scan or labeling is broken.
      expect(found, greaterThan(0));
    });
  });
}
