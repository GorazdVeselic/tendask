import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/declination.dart';
import 'package:tendask/core/biodynamic/moon_latitude.dart';
import 'package:tendask/core/biodynamic/time_base.dart';

void main() {
  group('moonEclipticLatitude', () {
    test('Meeus 47.a gatekeeper: beta -3.229126 within truncation error', () {
      // Book value for 1992-04-12 0h TD; the 13-term series carries
      // ~0.002 deg truncation error (measured against the prototype).
      final beta = moonEclipticLatitude(julianCenturies(2448724.5));
      expect(beta, closeTo(-3.229126, 0.005));
    });

    test('stays within the physical band over two years', () {
      // The truncated series peaks at ~5.30 deg over 2026-2027 (measured
      // against the prototype; 5.128 main term + minor terms).
      final start = julianDay(DateTime.utc(2026));
      for (var i = 0; i < 1461; i++) {
        final beta = moonEclipticLatitude(julianCenturies(start + i * 0.5));
        expect(beta.abs(), lessThan(5.35), reason: 'sample $i');
      }
    });
  });

  group('moonDeclination', () {
    test('stays within obliquity + max latitude over two years', () {
      final start = julianDay(DateTime.utc(2026));
      for (var i = 0; i < 1461; i++) {
        final decl = moonDeclination(julianCenturies(start + i * 0.5));
        expect(decl.abs(), lessThan(28.8), reason: 'sample $i');
      }
    });

    test('consecutive maxima are ~27.3 days apart (tropical month)', () {
      final start = julianDay(DateTime.utc(2026, 1, 1));
      const step = 0.1;
      final maximaJds = <double>[];
      var prevPrev = moonDeclination(julianCenturies(start));
      var prev = moonDeclination(julianCenturies(start + step));
      for (var i = 2; i < 900; i++) {
        final current = moonDeclination(julianCenturies(start + i * step));
        if (prev > prevPrev && prev > current) {
          maximaJds.add(start + (i - 1) * step);
        }
        prevPrev = prev;
        prev = current;
      }
      expect(maximaJds.length, inInclusiveRange(3, 4));
      for (var i = 1; i < maximaJds.length; i++) {
        expect(maximaJds[i] - maximaJds[i - 1], closeTo(27.32, 1.0));
      }
    });
  });
}
