import 'package:flutter/material.dart';

import 'theme_palette.dart';

abstract final class AppTheme {
  /// Bundled font (assets/fonts) — never fetched at runtime (offline-first).
  static const _fontFamily = 'PlusJakartaSans';

  static ThemeData light(ThemePalette palette) {
    final r = palette.light;
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: _scheme(r, Brightness.light),
      inputDecorationTheme: _inputTheme(r.hint),
      chipTheme: _chipTheme(r.primaryContainer, r.onPrimaryContainer),
      extensions: [r.swipe],
    );
  }

  static ThemeData dark(ThemePalette palette) {
    final r = palette.dark;
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: _fontFamily,
    );
    return base.copyWith(
      colorScheme: _scheme(r, Brightness.dark),
      inputDecorationTheme: _inputTheme(r.hint),
      chipTheme: _chipTheme(r.primaryContainer, r.onPrimaryContainer),
      extensions: [r.swipe],
    );
  }

  static ColorScheme _scheme(ThemeRoles r, Brightness brightness) {
    final base = brightness == Brightness.light
        ? ColorScheme.light(
            primary: r.primary,
            onPrimary: r.onPrimary,
            primaryContainer: r.primaryContainer,
            onPrimaryContainer: r.onPrimaryContainer,
            secondary: r.secondary,
            onSecondary: r.onSecondary,
            surface: r.surface,
            onSurface: r.onSurface,
            onSurfaceVariant: r.onSurfaceVariant,
            outline: r.outline,
            error: r.error,
            onError: r.onError,
            errorContainer: r.errorContainer,
            onErrorContainer: r.onErrorContainer,
          )
        : ColorScheme.dark(
            primary: r.primary,
            onPrimary: r.onPrimary,
            primaryContainer: r.primaryContainer,
            onPrimaryContainer: r.onPrimaryContainer,
            secondary: r.secondary,
            onSecondary: r.onSecondary,
            surface: r.surface,
            onSurface: r.onSurface,
            onSurfaceVariant: r.onSurfaceVariant,
            outline: r.outline,
            error: r.error,
            onError: r.onError,
            errorContainer: r.errorContainer,
            onErrorContainer: r.onErrorContainer,
          );
    // Optional roles: applied only when the palette sets them. Green leaves the
    // dark surfaceContainerHighest/inverseSurface unset → the M3 default, so the
    // legacy green theme is reproduced exactly.
    //
    // secondaryContainer mirrors primaryContainer because M3 draws a selected
    // chip's LABEL from onSecondaryContainer while our chipTheme paints its
    // BACKGROUND with primaryContainer — left unset, the label kept the M3
    // baseline tone and read as disabled on top of the palette container.
    return base.copyWith(
      surfaceContainerHighest: r.surfaceContainerHighest,
      inverseSurface: r.inverseSurface,
      onInverseSurface: r.onInverseSurface,
      secondaryContainer: r.primaryContainer,
      onSecondaryContainer: r.onPrimaryContainer,
    );
  }

  /// Hints must read as placeholders, not entered text — keep them muted.
  static InputDecorationTheme _inputTheme(Color hint) => InputDecorationTheme(
    hintStyle: TextStyle(color: hint, fontWeight: FontWeight.w400),
  );

  /// Selected chips read in the palette's container tone, not the M3 baseline
  /// purple that an under-specified ColorScheme would otherwise leak.
  static ChipThemeData _chipTheme(Color selected, Color onSelected) =>
      ChipThemeData(selectedColor: selected, checkmarkColor: onSelected);
}
