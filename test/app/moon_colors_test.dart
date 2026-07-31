import 'package:flutter/material.dart';
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

  test('lerp keeps every field on its own channel (no swapped boilerplate)',
      () {
    final atDark = moonColorsLight.lerp(moonColorsDark, 1.0);
    final channels = <String, (Color, Color)>{
      'fruit': (atDark.fruit, moonColorsDark.fruit),
      'fruitSoft': (atDark.fruitSoft, moonColorsDark.fruitSoft),
      'root': (atDark.root, moonColorsDark.root),
      'rootSoft': (atDark.rootSoft, moonColorsDark.rootSoft),
      'flower': (atDark.flower, moonColorsDark.flower),
      'flowerSoft': (atDark.flowerSoft, moonColorsDark.flowerSoft),
      'leaf': (atDark.leaf, moonColorsDark.leaf),
      'leafSoft': (atDark.leafSoft, moonColorsDark.leafSoft),
    };
    for (final MapEntry(key: name, value: (actual, expected))
        in channels.entries) {
      expect(actual, expected, reason: name);
    }
    expect(moonColorsLight.lerp(null, 0.5), same(moonColorsLight));
  });

  test('copyWith overrides only the named field', () {
    final copied = moonColorsLight.copyWith(leaf: Colors.black);
    expect(copied.leaf, Colors.black);
    expect(copied.leafSoft, moonColorsLight.leafSoft);
    expect(copied.fruit, moonColorsLight.fruit);
    expect(copied.fruitSoft, moonColorsLight.fruitSoft);
    expect(copied.root, moonColorsLight.root);
    expect(copied.rootSoft, moonColorsLight.rootSoft);
    expect(copied.flower, moonColorsLight.flower);
    expect(copied.flowerSoft, moonColorsLight.flowerSoft);
  });
}
