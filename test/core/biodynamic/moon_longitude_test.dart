import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/moon_longitude.dart';
import 'package:tendask/core/biodynamic/time_base.dart';

void main() {
  group('moonEclipticLongitude', () {
    test('gatekeeper, Meeus example 47.a: JD 2448724.5 gives 133.162655', () {
      // Truncated 36-term series is validated at ~0.003 deg vs the full
      // table; the Moon moves ~0.5 deg/hour, so this is minutes of time.
      final t = julianCenturies(2448724.5);
      expect(moonEclipticLongitude(t), closeTo(133.162655, 0.005));
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
        final lambda = moonEclipticLongitude(julianCenturies(julianDay(date)));
        expect(lambda, greaterThanOrEqualTo(0), reason: '$date');
        expect(lambda, lessThan(360), reason: '$date');
      }
    });

    test('daily motion stays within the physical band', () {
      // The Moon's longitude advances 11.8 (apogee) .. 15.4 (perigee)
      // degrees/day; values outside mean a broken term or mean element.
      final start = julianDay(DateTime.utc(2026, 1, 1));
      for (var day = 0; day < 60; day++) {
        final a = moonEclipticLongitude(julianCenturies(start + day));
        final b = moonEclipticLongitude(julianCenturies(start + day + 1));
        final motion = (b - a) % 360;
        expect(motion, greaterThan(11.0), reason: 'day $day');
        expect(motion, lessThan(16.0), reason: 'day $day');
      }
    });
  });
}
