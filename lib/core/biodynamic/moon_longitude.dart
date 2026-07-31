import 'dart:math' as math;

import 'angles.dart';

/// Meeus table 47.A, ~36 largest periodic terms for the Moon's longitude:
/// (coefficient in 1e-6 deg, multipliers of D, M, M', F). Ported from the
/// validated prototype (P0.1); terms with M != 0 are scaled by E^|M|.
/// The (0,1,-2,0)/(0,1,2,0) M' signs are book-corrected (T1.9): the prototype
/// carries them swapped, so a sweep against it differs by ~0.001 deg there.
const List<(int, int, int, int, int)> _terms = [
  (6288774, 0, 0, 1, 0),
  (1274027, 2, 0, -1, 0),
  (658314, 2, 0, 0, 0),
  (213618, 0, 0, 2, 0),
  (-185116, 0, 1, 0, 0),
  (-114332, 0, 0, 0, 2),
  (58793, 2, 0, -2, 0),
  (57066, 2, -1, -1, 0),
  (53322, 2, 0, 1, 0),
  (45758, 2, -1, 0, 0),
  (-40923, 0, 1, -1, 0),
  (-34720, 1, 0, 0, 0),
  (-30383, 0, 1, 1, 0),
  (15327, 2, 0, 0, -2),
  (-12528, 0, 0, 1, 2),
  (10980, 0, 0, 1, -2),
  (10675, 4, 0, -1, 0),
  (10034, 0, 0, 3, 0),
  (8548, 4, 0, -2, 0),
  (-7888, 2, 1, -1, 0),
  (-6766, 2, 1, 0, 0),
  (-5163, 1, 0, -1, 0),
  (4987, 1, 1, 0, 0),
  (4036, 2, -1, 1, 0),
  (3994, 2, 0, 2, 0),
  (3861, 4, 0, 0, 0),
  (3665, 2, 0, -3, 0),
  (-2689, 0, 1, -2, 0),
  (-2602, 2, 0, -1, 2),
  (2390, 2, -1, -2, 0),
  (-2348, 1, 0, 1, 0),
  (2236, 2, -2, 0, 0),
  (-2120, 0, 1, 2, 0),
  (-2069, 0, 2, 0, 0),
  (2048, 2, -2, -1, 0),
  (-1773, 2, 0, 1, -2),
];

/// Moon's geocentric ecliptic longitude in degrees `[0, 360)` for julian
/// centuries [t] since J2000.0 (Meeus ch. 47, truncated; spec §14.2).
///
/// Nutation is omitted (~17 arcsec, negligible for day classification);
/// accuracy vs Meeus example 47.a is ~0.003 deg.
double moonEclipticLongitude(double t) {
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;
  final lp = 218.3164477 +
      481267.88123421 * t -
      0.0015786 * t2 +
      t3 / 538841 -
      t4 / 65194000;
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
  return (lp + sum / 1e6) % 360;
}
