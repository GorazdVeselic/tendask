import 'dart:math' as math;

import 'angles.dart';

/// Meeus table 47.B, 13 largest periodic terms for the Moon's latitude:
/// (coefficient in 1e-6 deg, multipliers of D, M, M', F). Ported from the
/// validated prototype (P0.1); terms with M != 0 are scaled by E^|M|.
const List<(int, int, int, int, int)> _terms = [
  (5128122, 0, 0, 0, 1),
  (280602, 0, 0, 1, 1),
  (277693, 0, 0, 1, -1),
  (173237, 2, 0, 0, -1),
  (55413, 2, 0, -1, 1),
  (46271, 2, 0, -1, -1),
  (32573, 2, 0, 0, 1),
  (17198, 0, 0, 2, 1),
  (9266, 2, 0, 1, -1),
  (8822, 0, 0, 2, -1),
  (8216, 2, -1, 0, -1),
  (4324, 2, 0, -2, -1),
  (4200, 2, 0, 1, 1),
];

/// Moon's geocentric ecliptic latitude in degrees for julian centuries [t]
/// since J2000.0 (Meeus ch. 47, truncated; declination layer, spec §4.5).
///
/// Accuracy vs Meeus example 47.a is ~0.002 deg. The mean elements must stay
/// identical to the sweep-verified ones in `moon_longitude.dart` (that file
/// is frozen, hence the duplication).
double moonEclipticLatitude(double t) {
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;
  final d = 297.8501921 +
      445267.1114034 * t -
      0.0018819 * t2 +
      t3 / 545868 -
      t4 / 113065000;
  final m = 357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000;
  final mp = 134.9633964 +
      477198.8675055 * t +
      0.0087414 * t2 +
      t3 / 69699 -
      t4 / 14712000;
  final f = 93.2720950 +
      483202.0175233 * t -
      0.0036539 * t2 -
      t3 / 3526000 +
      t4 / 863310000;
  final eccentricity = 1 - 0.002516 * t - 0.0000074 * t2;

  final dr = radians(d);
  final mr = radians(m);
  final mpr = radians(mp);
  final fr = radians(f);
  var sum = 0.0;
  for (final (coef, cd, cm, cmp, cf) in _terms) {
    final arg = cd * dr + cm * mr + cmp * mpr + cf * fr;
    sum += coef * math.pow(eccentricity, cm.abs()) * math.sin(arg);
  }
  return sum / 1e6;
}
