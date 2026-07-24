import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/app/theme/theme_palette.dart';
import 'package:tendask/features/settings/presentation/palette_labels.dart';
import 'package:tendask/i18n/translations.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  group('paletteName', () {
    test('every shipped palette resolves to a non-empty name', () {
      for (final palette in appPalettes) {
        expect(paletteName(palette.id, t), isNotEmpty);
      }
    });

    test('a palette id we no longer ship reads as green, never blank', () {
      expect(paletteName('dropped-in-a-future-build', t), t.appearance.palette_green);
    });
  });

  group('effectiveBrightness', () {
    test('an explicit mode ignores the platform', () {
      expect(
        effectiveBrightness(ThemeMode.light, Brightness.dark),
        Brightness.light,
      );
      expect(
        effectiveBrightness(ThemeMode.dark, Brightness.light),
        Brightness.dark,
      );
    });

    test('system follows the platform — the previews must match the phone', () {
      expect(
        effectiveBrightness(ThemeMode.system, Brightness.dark),
        Brightness.dark,
      );
      expect(
        effectiveBrightness(ThemeMode.system, Brightness.light),
        Brightness.light,
      );
    });
  });
}
