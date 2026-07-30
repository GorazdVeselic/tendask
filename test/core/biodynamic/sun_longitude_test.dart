import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/sun_longitude.dart';
import 'package:tendask/core/biodynamic/time_base.dart';

void main() {
  group('sunEclipticLongitude', () {
    test('Meeus example 25.a: 1992-10-13.0 TD gives 199.90988 degrees', () {
      final t = julianCenturies(2448908.5);
      expect(sunEclipticLongitude(t), closeTo(199.90988, 1e-4));
    });

    test('result stays in [0, 360) across decades', () {
      final dates = [
        DateTime.utc(1957, 10, 4),
        DateTime.utc(1992, 4, 12),
        DateTime.utc(2000, 1, 1, 12),
        DateTime.utc(2026, 7, 30),
        DateTime.utc(2050, 12, 31, 23, 59),
      ];
      for (final date in dates) {
        final lambda = sunEclipticLongitude(julianCenturies(julianDay(date)));
        expect(lambda, greaterThanOrEqualTo(0), reason: '$date');
        expect(lambda, lessThan(360), reason: '$date');
      }
    });

    test('daily motion is roughly one degree per day', () {
      // Apparent solar motion varies 0.953 (aphelion) .. 1.019 (perihelion)
      // degrees/day; a value outside that band means a broken coefficient.
      final start = julianDay(DateTime.utc(2026, 1, 1));
      for (var day = 0; day < 365; day += 30) {
        final a = sunEclipticLongitude(julianCenturies(start + day));
        final b = sunEclipticLongitude(julianCenturies(start + day + 1));
        final motion = (b - a) % 360;
        expect(motion, greaterThan(0.94), reason: 'day $day');
        expect(motion, lessThan(1.03), reason: 'day $day');
      }
    });
  });
}
