import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/zodiac.dart';

void main() {
  group('tropicalSignFor', () {
    test('equal 30-degree bands from Aries at 0', () {
      expect(tropicalSignFor(0), ZodiacSign.aries);
      expect(tropicalSignFor(29.99), ZodiacSign.aries);
      expect(tropicalSignFor(30), ZodiacSign.taurus);
      expect(tropicalSignFor(133.16), ZodiacSign.leo);
      expect(tropicalSignFor(199.9), ZodiacSign.libra);
      expect(tropicalSignFor(359.99), ZodiacSign.pisces);
    });

    test('input outside [0, 360) is normalized', () {
      expect(tropicalSignFor(370), ZodiacSign.aries);
      expect(tropicalSignFor(-10), ZodiacSign.pisces);
    });
  });

  group('siderealSignFor', () {
    test('epoch year: entry thresholds are inclusive', () {
      expect(siderealSignFor(29.8, 2024), ZodiacSign.aries);
      expect(siderealSignFor(29.79, 2024), ZodiacSign.pisces);
      expect(siderealSignFor(54.1, 2024), ZodiacSign.taurus);
      expect(siderealSignFor(54.09, 2024), ZodiacSign.aries);
      expect(siderealSignFor(238.1, 2024), ZodiacSign.scorpio);
      expect(siderealSignFor(269.1, 2024), ZodiacSign.sagittarius);
      expect(siderealSignFor(269.09, 2024), ZodiacSign.scorpio);
    });

    test('Ophiuchus band belongs to Scorpio', () {
      // The ecliptic between Scorpio's end and Sagittarius' start crosses
      // Ophiuchus; tradition folds it into the Scorpio band.
      expect(siderealSignFor(250, 2024), ZodiacSign.scorpio);
      expect(siderealSignFor(260, 2024), ZodiacSign.scorpio);
    });

    test('Pisces band wraps through 0', () {
      expect(siderealSignFor(352.1, 2024), ZodiacSign.pisces);
      expect(siderealSignFor(359.9, 2024), ZodiacSign.pisces);
      expect(siderealSignFor(0, 2024), ZodiacSign.pisces);
      expect(siderealSignFor(10, 2024), ZodiacSign.pisces);
    });

    test('precession shifts thresholds for other years', () {
      // 2034: thresholds moved +0.13972 deg, so 29.9 is no longer Aries.
      expect(siderealSignFor(29.9, 2024), ZodiacSign.aries);
      expect(siderealSignFor(29.9, 2034), ZodiacSign.pisces);
      // 2014: thresholds moved -0.13972 deg, so 29.7 is already Aries.
      expect(siderealSignFor(29.7, 2024), ZodiacSign.pisces);
      expect(siderealSignFor(29.7, 2014), ZodiacSign.aries);
    });
  });

  group('boundary tables', () {
    test('both tables list 12 strictly increasing starts', () {
      for (final table in [kCalibratedStarts, kIauStarts]) {
        expect(table, hasLength(12));
        for (var i = 1; i < 12; i++) {
          expect(table[i], greaterThan(table[i - 1]), reason: 'index $i');
        }
      }
    });

    test('tables agree within the documented calibration margin', () {
      // Calibrated vs IAU differ most around the Ophiuchus region
      // (Libra..Sagittarius); everywhere the offset stays under ~4.4 deg.
      for (var i = 0; i < 12; i++) {
        expect(
          (kCalibratedStarts[i] - kIauStarts[i]).abs(),
          lessThan(4.5),
          reason: 'index $i',
        );
      }
    });
  });

  group('elementOf', () {
    test('fruit/root/flower/leaf cycle repeats three times from Aries', () {
      const expected = {
        ZodiacSign.aries: BiodynamicElement.fruit,
        ZodiacSign.taurus: BiodynamicElement.root,
        ZodiacSign.gemini: BiodynamicElement.flower,
        ZodiacSign.cancer: BiodynamicElement.leaf,
        ZodiacSign.leo: BiodynamicElement.fruit,
        ZodiacSign.virgo: BiodynamicElement.root,
        ZodiacSign.libra: BiodynamicElement.flower,
        ZodiacSign.scorpio: BiodynamicElement.leaf,
        ZodiacSign.sagittarius: BiodynamicElement.fruit,
        ZodiacSign.capricorn: BiodynamicElement.root,
        ZodiacSign.aquarius: BiodynamicElement.flower,
        ZodiacSign.pisces: BiodynamicElement.leaf,
      };
      for (final entry in expected.entries) {
        expect(elementOf(entry.key), entry.value, reason: '${entry.key}');
      }
    });
  });
}
