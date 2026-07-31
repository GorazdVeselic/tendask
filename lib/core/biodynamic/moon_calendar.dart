import 'biodynamic_day.dart';
import 'calendar_system.dart';
import 'declination.dart';
import 'moon_distance.dart';
import 'moon_latitude.dart';
import 'moon_longitude.dart';
import 'moon_phase.dart';
import 'time_base.dart';
import 'zodiac.dart';

/// Unfavorable windows around a node passage / perigee (spec §4.5), calibrated
/// against the printed Thun 2024 hour marks (jan/feb/dec pages): node 15:03 ->
/// printed 10..19, perigee 19:54 -> printed 7..9 next day. Apogee is not
/// marked unfavorable in the reference, so it is deliberately not modeled.
const double _nodeBeforeHours = 5;
const double _nodeAfterHours = 4;
const double _perigeeWindowHours = 13;

/// Max |ecliptic latitude| at syzygy for an eclipse (covers partial solar and
/// penumbral lunar limits, Meeus ch. 54).
const double _eclipseMaxLatitudeDeg = 1.6;

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
/// (prototype method, spec §4.5). A day is unfavorable when a node passage
/// or perigee falls within the day padded by its window, or an eclipse-grade
/// syzygy falls within the day. Pure function: no I/O, no clock, no state.
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
    final jd = _bisect(jdStart, jdEnd, (jd) => signAt(jd) == startSign);
    transitionAt = dateTimeFromJulianDay(jd).toLocal();
    secondaryElement = elementOf(endSign);
  }

  final tMid = julianCenturies((jdStart + jdEnd) / 2);
  final descending = moonDeclination(julianCenturies(jdEnd)) <
      moonDeclination(julianCenturies(jdStart));
  return BiodynamicDay(
    sign: startSign,
    isConstellation: system == CalendarSystem.sidereal,
    element: elementOf(startSign),
    transitionAt: transitionAt,
    secondaryElement: secondaryElement,
    phase: phaseFor(tMid),
    illumFraction: illuminatedFraction(tMid),
    ascending: !descending,
    unfavorable: _isUnfavorable(jdStart, jdEnd),
  );
}

/// Bisects `[lo, hi]` to the point where [isBefore] flips to false; 40 steps
/// refine far below a millisecond.
double _bisect(double lo, double hi, bool Function(double jd) isBefore) {
  for (var i = 0; i < 40; i++) {
    final mid = (lo + hi) / 2;
    if (isBefore(mid)) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

/// True when a node/perigee unfavorable window or an eclipse-grade syzygy
/// touches the local day `[jdStart, jdEnd)`.
///
/// A window `[event - before, event + after]` overlaps the day iff the event
/// instant lies in `[jdStart - after, jdEnd + before]` — hence the swapped
/// padding on the search bounds.
bool _isUnfavorable(double jdStart, double jdEnd) =>
    _nodeCrossing(
          jdStart - _nodeAfterHours / 24,
          jdEnd + _nodeBeforeHours / 24,
        ) !=
        null ||
    _perigee(
          jdStart - _perigeeWindowHours / 24,
          jdEnd + _perigeeWindowHours / 24,
        ) !=
        null ||
    _eclipseWithin(jdStart, jdEnd);

double _latitudeAt(double jd) => moonEclipticLatitude(julianCenturies(jd));

/// Julian day in `[jdLo, jdHi]` where the Moon's latitude crosses zero
/// (node passage), or null if the window has none.
///
/// Crossings are ~13.6 days apart (half draconic month), so on the ~1.5-day
/// windows used here a single sign check per 0.5-day step cannot skip one.
double? _nodeCrossing(double jdLo, double jdHi) {
  const step = 0.5;
  var prevJd = jdLo;
  var prevNegative = _latitudeAt(jdLo) < 0;
  while (prevJd < jdHi) {
    final jd = prevJd + step < jdHi ? prevJd + step : jdHi;
    final negative = _latitudeAt(jd) < 0;
    if (negative != prevNegative) {
      return _bisect(prevJd, jd, (m) => (_latitudeAt(m) < 0) == prevNegative);
    }
    prevJd = jd;
    prevNegative = negative;
  }
  return null;
}

/// Julian day of the distance minimum (perigee) in `[jdLo, jdHi]`, or null.
///
/// Stationary points of the ~27.55-day distance cycle are ~13.8 days apart,
/// so the ~1.5-day window holds at most one: a minimum exactly when the slope
/// goes negative-to-positive across the window, refined by bisection.
double? _perigee(double jdLo, double jdHi) {
  double slope(double jd) =>
      moonDistanceKm(julianCenturies(jd + 0.01)) -
      moonDistanceKm(julianCenturies(jd - 0.01));

  if (slope(jdLo) >= 0 || slope(jdHi) < 0) return null;
  return _bisect(jdLo, jdHi, (jd) => slope(jd) < 0);
}

/// True when a syzygy in `[jdStart, jdEnd)` happens close enough to a node
/// to produce a solar or lunar eclipse.
bool _eclipseWithin(double jdStart, double jdEnd) {
  for (final target in const [0.0, 180.0]) {
    final syzygy = findPhaseTime(target, jdStart, jdEnd);
    if (syzygy != null &&
        _latitudeAt(syzygy).abs() < _eclipseMaxLatitudeDeg) {
      return true;
    }
  }
  return false;
}
