import 'dart:math' as math;

import 'angles.dart';
import 'biodynamic_day.dart';
import 'moon_longitude.dart';
import 'sun_longitude.dart';
import 'time_base.dart';

/// Moon-Sun elongation in degrees `[0, 360)` for julian centuries [t]
/// (spec §14.6): 0 = new moon, 180 = full moon. System-independent.
double elongation(double t) =>
    (moonEclipticLongitude(t) - sunEclipticLongitude(t)) % 360;

/// Illuminated fraction of the Moon's disc, 0 (new) .. 1 (full).
double illuminatedFraction(double t) =>
    (1 - math.cos(radians(elongation(t)))) / 2;

/// Eight-step phase for julian centuries [t]: 45-degree elongation buckets
/// centered on the principal phases (new moon spans 337.5..22.5).
MoonPhase phaseFor(double t) =>
    MoonPhase.values[((elongation(t) + 22.5) % 360) ~/ 45];

/// Julian day in `[jdStart, jdEnd)` where elongation crosses [targetDegrees]
/// upward (0 = new moon, 180 = full moon), or null if the window has none.
///
/// Sampling every 0.02 days catches the ~29.5-day synodic cycle safely;
/// 40 bisection steps refine far below the validated 1-3 min accuracy.
double? findPhaseTime(double targetDegrees, double jdStart, double jdEnd) {
  double offset(double jd) {
    final e = (elongation(julianCenturies(jd)) - targetDegrees) % 360;
    return e > 180 ? e - 360 : e;
  }

  const step = 0.02;
  var prevJd = jdStart;
  var prevOffset = offset(jdStart);
  for (var jd = jdStart + step; jd < jdEnd; jd += step) {
    final current = offset(jd);
    if (prevOffset <= 0 && current > 0 && (current - prevOffset) < 180) {
      var lo = prevJd;
      var hi = jd;
      for (var i = 0; i < 40; i++) {
        final mid = (lo + hi) / 2;
        if (offset(mid) <= 0) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      return (lo + hi) / 2;
    }
    prevJd = jd;
    prevOffset = current;
  }
  return null;
}
