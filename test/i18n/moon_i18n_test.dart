import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/i18n/translations.g.dart';

/// The moon namespace uses slang maps keyed by engine enum `.name`s, which
/// trades compile-time key safety for lookup ergonomics — a missing or
/// renamed key returns null at runtime. These tests restore the guarantee:
/// every enum value resolves in every locale (de falls back to en wholesale).
void main() {
  test('moon maps cover every engine enum value in every locale', () {
    for (final locale in AppLocale.values) {
      final moon = locale.buildSync().moon;
      expect(
        moon.day_for.keys.toSet(),
        BiodynamicElement.values.map((e) => e.name).toSet(),
        reason: '${locale.languageCode} day_for',
      );
      expect(
        moon.sign.keys.toSet(),
        ZodiacSign.values.map((e) => e.name).toSet(),
        reason: '${locale.languageCode} sign',
      );
      expect(
        moon.phase.keys.toSet(),
        MoonPhase.values.map((e) => e.name).toSet(),
        reason: '${locale.languageCode} phase',
      );
    }
  });

  test('moon map values are non-empty in every locale', () {
    for (final locale in AppLocale.values) {
      final moon = locale.buildSync().moon;
      final values = [
        ...moon.day_for.values,
        ...moon.sign.values,
        ...moon.phase.values,
        moon.division.constellation,
        moon.division.sign,
      ];
      for (final value in values) {
        expect(value.trim(), isNotEmpty, reason: locale.languageCode);
      }
    }
  });
}
