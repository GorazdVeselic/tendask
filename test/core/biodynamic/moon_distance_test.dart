import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/moon_distance.dart';
import 'package:tendask/core/biodynamic/time_base.dart';

void main() {
  group('moonDistanceKm', () {
    test('gatekeeper, Meeus example 47.a: JD 2448724.5 gives 368409.7 km', () {
      // Book value for 1992-04-12 0h TD; the full cosine column is ported,
      // so the tolerance is dominated by rounding of the book value itself.
      final t = julianCenturies(2448724.5);
      expect(moonDistanceKm(t), closeTo(368409.7, 0.1));
    });

    test('stays within the physical band over two years', () {
      // Perigee can reach ~356400 km, apogee ~406700 km; values outside
      // mean a broken term or mean element.
      final start = julianDay(DateTime.utc(2026));
      for (var i = 0; i < 1461; i++) {
        final distance = moonDistanceKm(julianCenturies(start + i * 0.5));
        expect(distance, greaterThan(356000), reason: 'sample $i');
        expect(distance, lessThan(407500), reason: 'sample $i');
      }
    });

    test('minima are perigee-deep and spaced like the anomalistic month', () {
      // Perigee-to-perigee intervals genuinely oscillate ~24.5..28.6 days
      // around the 27.55-day mean (solar perturbation), so the assertion
      // is a band, not a fixed period.
      final start = julianDay(DateTime.utc(2026, 1, 1));
      const step = 0.1;
      final minimaJds = <double>[];
      var prevPrev = moonDistanceKm(julianCenturies(start));
      var prev = moonDistanceKm(julianCenturies(start + step));
      for (var i = 2; i < 900; i++) {
        final current = moonDistanceKm(julianCenturies(start + i * step));
        if (prev < prevPrev && prev < current) {
          minimaJds.add(start + (i - 1) * step);
          expect(prev, lessThan(371000), reason: 'shallow minimum (wiggle?)');
        }
        prevPrev = prev;
        prev = current;
      }
      expect(minimaJds.length, inInclusiveRange(3, 4));
      for (var i = 1; i < minimaJds.length; i++) {
        expect(minimaJds[i] - minimaJds[i - 1], inInclusiveRange(24.0, 29.0));
      }
    });
  });
}
