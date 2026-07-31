import 'biodynamic_day.dart';
import 'calendar_system.dart';
import 'declination.dart';
import 'moon_longitude.dart';
import 'moon_phase.dart';
import 'time_base.dart';
import 'zodiac.dart';

/// UTC instant for julian day [jd] via epoch arithmetic (JD 2440587.5 =
/// Unix epoch) — no manual calendar inversion (13-day-shift bug class, T1.6).
DateTime dateTimeFromJulianDay(double jd) => DateTime.fromMillisecondsSinceEpoch(
      ((jd - 2440587.5) * 86400000).round(),
      isUtc: true,
    );

/// Computes the biodynamic layers for one local calendar day (FR-19 spec §14).
///
/// Time contract: [localDate] is a local calendar day (`DateTime(y, m, d)` in
/// the caller's zone); the day spans local midnight to midnight. All astronomy
/// runs internally in UTC; [BiodynamicDay.transitionAt] is local wall-clock.
/// The day label is the element at the start of the day (spec §12.6); phase
/// and illumination are sampled at the middle of the local day; ascending
/// compares the Moon's declination at the end of the day against the start
/// (prototype method, spec §4.5). Pure function: no I/O, no clock, no state.
BiodynamicDay dayFor(DateTime localDate, CalendarSystem system) {
  final dayStart = DateTime(localDate.year, localDate.month, localDate.day);
  final dayEnd = DateTime(localDate.year, localDate.month, localDate.day + 1);
  final jdStart = julianDay(dayStart);
  final jdEnd = julianDay(dayEnd);

  ZodiacSign signAt(double jd) {
    final lambda = moonEclipticLongitude(julianCenturies(jd));
    return switch (system) {
      CalendarSystem.sidereal => siderealSignFor(lambda, localDate.year),
      CalendarSystem.tropical => tropicalSignFor(lambda),
    };
  }

  final startSign = signAt(jdStart);
  final endSign = signAt(jdEnd);

  DateTime? transitionAt;
  BiodynamicElement? secondaryElement;
  if (endSign != startSign) {
    // At most one boundary per day: the narrowest band (21 degrees) exceeds
    // the Moon's motion even on a 25-hour DST day (~16 degrees), so a single
    // bisection over the day finds the only crossing.
    var lo = jdStart;
    var hi = jdEnd;
    for (var i = 0; i < 40; i++) {
      final mid = (lo + hi) / 2;
      if (signAt(mid) == startSign) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    transitionAt = dateTimeFromJulianDay((lo + hi) / 2).toLocal();
    secondaryElement = elementOf(endSign);
  }

  final tMid = julianCenturies((jdStart + jdEnd) / 2);
  final descending = moonDeclination(julianCenturies(jdEnd)) <
      moonDeclination(julianCenturies(jdStart));
  // TODO(gorazd, 2026-08-15): unfavorable (T1.9).
  return BiodynamicDay(
    sign: startSign,
    isConstellation: system == CalendarSystem.sidereal,
    element: elementOf(startSign),
    transitionAt: transitionAt,
    secondaryElement: secondaryElement,
    phase: phaseFor(tMid),
    illumFraction: illuminatedFraction(tMid),
    ascending: !descending,
  );
}
