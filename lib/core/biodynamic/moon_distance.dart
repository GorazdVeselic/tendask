import 'dart:math' as math;

import 'angles.dart';

/// Meeus table 47.A cosine column, all terms with a non-zero distance
/// coefficient: (coefficient in 1e-3 km, multipliers of D, M, M', F).
/// Ported from the book (the prototype covers longitude, latitude and
/// phases only); terms with M != 0 are scaled by E^|M|.
const List<(int, int, int, int, int)> _terms = [
  (-20905355, 0, 0, 1, 0),
  (-3699111, 2, 0, -1, 0),
  (-2955968, 2, 0, 0, 0),
  (-569925, 0, 0, 2, 0),
  (48888, 0, 1, 0, 0),
  (-3149, 0, 0, 0, 2),
  (246158, 2, 0, -2, 0),
  (-152138, 2, -1, -1, 0),
  (-170733, 2, 0, 1, 0),
  (-204586, 2, -1, 0, 0),
  (-129620, 0, 1, -1, 0),
  (108743, 1, 0, 0, 0),
  (104755, 0, 1, 1, 0),
  (10321, 2, 0, 0, -2),
  (79661, 0, 0, 1, -2),
  (-34782, 4, 0, -1, 0),
  (-23210, 0, 0, 3, 0),
  (-21636, 4, 0, -2, 0),
  (24208, 2, 1, -1, 0),
  (30824, 2, 1, 0, 0),
  (-8379, 1, 0, -1, 0),
  (-16675, 1, 1, 0, 0),
  (-12831, 2, -1, 1, 0),
  (-10445, 2, 0, 2, 0),
  (-11650, 4, 0, 0, 0),
  (14403, 2, 0, -3, 0),
  (-7003, 0, 1, -2, 0),
  (10056, 2, -1, -2, 0),
  (6322, 1, 0, 1, 0),
  (-9884, 2, -2, 0, 0),
  (5751, 0, 1, 2, 0),
  (-4950, 2, -2, -1, 0),
  (4130, 2, 0, 1, -2),
  (-3958, 4, -1, -1, 0),
  (3258, 3, 0, -1, 0),
  (2616, 2, 1, 1, 0),
  (-1897, 4, -1, -2, 0),
  (-2117, 0, 2, -1, 0),
  (2354, 2, 2, -1, 0),
  (-1423, 4, 0, 1, 0),
  (-1117, 0, 0, 4, 0),
  (-1571, 4, -1, 0, 0),
  (-1739, 1, 0, -2, 0),
  (-4421, 0, 0, 2, -2),
  (1165, 0, 2, 1, 0),
  (8752, 2, 0, -1, -2),
];

/// Earth-Moon distance in kilometers for julian centuries [t] since J2000.0
/// (Meeus ch. 47; unfavorable-day layer, spec §4.5).
///
/// Accuracy vs Meeus example 47.a is ~0.1 km. The mean elements must stay
/// identical to the sweep-verified ones in `moon_longitude.dart` (that file
/// is frozen, hence the duplication).
double moonDistanceKm(double t) {
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
    sum += coef * math.pow(eccentricity, cm.abs()) * math.cos(arg);
  }
  return 385000.56 + sum / 1000;
}
