/// Julian day for the given instant, normalized to UTC (FR-19 spec §14.1).
///
/// Calendar part via the Fliegel/Van Flandern integer algorithm (proleptic
/// Gregorian, matching Dart's `DateTime`); time of day added as a fraction.
double julianDay(DateTime dateTime) {
  final utc = dateTime.toUtc();
  final a = (14 - utc.month) ~/ 12;
  final y = utc.year + 4800 - a;
  final m = utc.month + 12 * a - 3;
  final jdn = utc.day +
      (153 * m + 2) ~/ 5 +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;
  final dayFraction = (utc.hour - 12) / 24 +
      utc.minute / 1440 +
      (utc.second + utc.millisecond / 1000 + utc.microsecond / 1e6) / 86400;
  return jdn + dayFraction;
}

/// Julian centuries since J2000.0: `T = (JD − 2451545) / 36525` (Meeus).
double julianCenturies(double julianDay) => (julianDay - 2451545.0) / 36525.0;
