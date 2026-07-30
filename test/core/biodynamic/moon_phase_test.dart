import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/moon_phase.dart';
import 'package:tendask/core/biodynamic/time_base.dart';

/// Published UTC phase times for 2026 (starwalk/moongiant/timeanddate),
/// the same references the prototype was validated against (1-3 min).
final _newMoonJul = DateTime.utc(2026, 7, 14, 9, 43);
final _fullMoonJul = DateTime.utc(2026, 7, 29, 14, 35);
final _newMoonAug = DateTime.utc(2026, 8, 12, 17, 37);

const _fiveMinutesInDays = 5 / (24 * 60);

void main() {
  group('findPhaseTime', () {
    test('new moon 2026-07-14 09:43 UTC within minutes', () {
      final jd = findPhaseTime(
        0,
        julianDay(DateTime.utc(2026, 7, 8)),
        julianDay(DateTime.utc(2026, 7, 20)),
      );
      expect(jd, isNotNull);
      expect(jd, closeTo(julianDay(_newMoonJul), _fiveMinutesInDays));
    });

    test('full moon 2026-07-29 14:35 UTC within minutes', () {
      final jd = findPhaseTime(
        180,
        julianDay(DateTime.utc(2026, 7, 22)),
        julianDay(DateTime.utc(2026, 8, 5)),
      );
      expect(jd, isNotNull);
      expect(jd, closeTo(julianDay(_fullMoonJul), _fiveMinutesInDays));
    });

    test('new moon 2026-08-12 17:37 UTC within minutes', () {
      final jd = findPhaseTime(
        0,
        julianDay(DateTime.utc(2026, 8, 5)),
        julianDay(DateTime.utc(2026, 8, 20)),
      );
      expect(jd, isNotNull);
      expect(jd, closeTo(julianDay(_newMoonAug), _fiveMinutesInDays));
    });

    test('returns null when the window has no crossing', () {
      final jd = findPhaseTime(
        0,
        julianDay(DateTime.utc(2026, 7, 5)),
        julianDay(DateTime.utc(2026, 7, 10)),
      );
      expect(jd, isNull);
    });
  });

  group('illuminatedFraction', () {
    test('near 0 at new moon, near 1 at full moon', () {
      expect(
        illuminatedFraction(julianCenturies(julianDay(_newMoonJul))),
        closeTo(0, 0.001),
      );
      expect(
        illuminatedFraction(julianCenturies(julianDay(_fullMoonJul))),
        closeTo(1, 0.001),
      );
    });

    test('stays within [0, 1] across a synodic month', () {
      final start = julianDay(DateTime.utc(2026, 7, 1));
      for (var i = 0; i < 60; i++) {
        final fraction = illuminatedFraction(julianCenturies(start + i * 0.5));
        expect(fraction, greaterThanOrEqualTo(0), reason: 'sample $i');
        expect(fraction, lessThanOrEqualTo(1), reason: 'sample $i');
      }
    });
  });

  group('phaseFor', () {
    test('principal phases land in their buckets', () {
      expect(
        phaseFor(julianCenturies(julianDay(_newMoonJul))),
        MoonPhase.newMoon,
      );
      expect(
        phaseFor(julianCenturies(julianDay(_fullMoonJul))),
        MoonPhase.fullMoon,
      );
    });

    test('quarters found by elongation land in quarter buckets', () {
      final firstQuarterJd = findPhaseTime(
        90,
        julianDay(DateTime.utc(2026, 7, 14)),
        julianDay(DateTime.utc(2026, 7, 29)),
      );
      expect(firstQuarterJd, isNotNull);
      // firstQuarterJd is non-null: the 15-day window spans elongation 0->180.
      expect(phaseFor(julianCenturies(firstQuarterJd!)), MoonPhase.firstQuarter);

      final lastQuarterJd = findPhaseTime(
        270,
        julianDay(DateTime.utc(2026, 7, 29)),
        julianDay(DateTime.utc(2026, 8, 12)),
      );
      expect(lastQuarterJd, isNotNull);
      // Same guarantee for the waning half of the cycle.
      expect(phaseFor(julianCenturies(lastQuarterJd!)), MoonPhase.lastQuarter);
    });

    test('waxing crescent between new moon and first quarter', () {
      final t = julianCenturies(julianDay(DateTime.utc(2026, 7, 17)));
      expect(phaseFor(t), MoonPhase.waxingCrescent);
    });
  });
}
