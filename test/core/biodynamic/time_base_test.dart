import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/time_base.dart';

void main() {
  group('julianDay', () {
    test('J2000.0 epoch (2000-01-01 12:00 UTC) is JD 2451545.0', () {
      expect(julianDay(DateTime.utc(2000, 1, 1, 12)), 2451545.0);
    });

    test('midnight before J2000.0 is JD 2451544.5', () {
      expect(julianDay(DateTime.utc(2000, 1, 1)), 2451544.5);
    });

    test('Meeus example 7.a: 1957-10-04.81 is JD 2436116.31', () {
      expect(
        julianDay(DateTime.utc(1957, 10, 4, 19, 26, 24)),
        closeTo(2436116.31, 1e-9),
      );
    });

    test('Meeus example 47.a date: 1992-04-12 00:00 is JD 2448724.5', () {
      expect(julianDay(DateTime.utc(1992, 4, 12)), 2448724.5);
    });

    test('Meeus chapter 7 samples', () {
      expect(julianDay(DateTime.utc(1987, 1, 27)), 2446822.5);
      expect(julianDay(DateTime.utc(1988, 6, 19, 12)), 2447332.0);
      expect(julianDay(DateTime.utc(1600, 1, 1)), 2305447.5);
    });

    test('1900 is not a leap year (century rule)', () {
      expect(julianDay(DateTime.utc(1900, 2, 28)), 2415078.5);
      expect(julianDay(DateTime.utc(1900, 3, 1)), 2415079.5);
    });

    test('non-UTC input is normalized to UTC', () {
      final local = DateTime.utc(2000, 1, 1, 12).toLocal();
      expect(julianDay(local), 2451545.0);
    });

    test('sub-second precision is carried into the day fraction', () {
      final jd = julianDay(DateTime.utc(2000, 1, 1, 12, 0, 0, 500));
      expect(jd, closeTo(2451545.0 + 0.5 / 86400, 1e-12));
    });
  });

  group('julianCenturies', () {
    test('J2000.0 is T = 0', () {
      expect(julianCenturies(2451545.0), 0.0);
    });

    test('Meeus example 47.a: JD 2448724.5 is T = -0.077221081451', () {
      expect(julianCenturies(2448724.5), closeTo(-0.077221081451, 1e-12));
    });

    test('Meeus example 25.a: JD 2448908.5 is T = -0.072183436', () {
      expect(julianCenturies(2448908.5), closeTo(-0.072183436, 1e-9));
    });
  });
}
