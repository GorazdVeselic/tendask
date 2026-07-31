import 'dart:math' as math;

import 'angles.dart';
import 'moon_latitude.dart';
import 'moon_longitude.dart';

/// Mean obliquity of the ecliptic in degrees for julian centuries [t]
/// (linear fit from the validated prototype; its slope differs from Meeus
/// 22.2 by ~0.0016 deg/century — ~0.0004 deg around 2026, far below what the
/// declination-trend layer needs).
double meanObliquity(double t) => 23.439 - 0.014610 * t;

/// Moon's declination in degrees for julian centuries [t]: ecliptic
/// (lambda, beta) rotated to the equator (spec §4.5).
///
/// Prototype method, validated 96/100 % against the 2024 printed
/// transplanting-time reference (spec §12.4).
double moonDeclination(double t) {
  final lambda = radians(moonEclipticLongitude(t));
  final beta = radians(moonEclipticLatitude(t));
  final eps = radians(meanObliquity(t));
  final sinDecl = math.sin(beta) * math.cos(eps) +
      math.cos(beta) * math.sin(eps) * math.sin(lambda);
  return math.asin(sinDecl) * 180 / math.pi;
}
