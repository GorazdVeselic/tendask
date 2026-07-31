import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/app/theme/app_theme.dart';
import 'package:tendask/app/theme/moon_colors.dart';
import 'package:tendask/app/theme/theme_palette.dart';

void main() {
  test('every palette exposes MoonColors in light and dark', () {
    for (final palette in appPalettes) {
      expect(
        AppTheme.light(palette).extension<MoonColors>(),
        moonColorsLight,
        reason: '${palette.id} light',
      );
      expect(
        AppTheme.dark(palette).extension<MoonColors>(),
        moonColorsDark,
        reason: '${palette.id} dark',
      );
    }
  });
}
