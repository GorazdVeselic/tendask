import 'dart:math' as math;

import 'angles.dart';

/// Sun's geometric ecliptic longitude in degrees `[0, 360)` for julian
/// centuries [t] since J2000.0 (Meeus ch. 25, low accuracy; spec §14.3).
double sunEclipticLongitude(double t) {
  final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
  final m = radians(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
  final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(m) +
      (0.019993 - 0.000101 * t) * math.sin(2 * m) +
      0.000289 * math.sin(3 * m);
  return (l0 + c) % 360;
}

