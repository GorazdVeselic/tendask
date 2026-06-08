import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  /// Bundled font (assets/fonts) — never fetched at runtime (offline-first).
  static const _fontFamily = 'PlusJakartaSans';

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.green,
        onPrimary: Colors.white,
        primaryContainer: AppColors.soft,
        onPrimaryContainer: AppColors.green900,
        secondary: AppColors.honey,
        onSecondary: AppColors.ink,
        // Blue accent for neutral row actions (revert/edit/move swipe buttons).
        tertiary: AppColors.info,
        onTertiary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.soft,
        onSurfaceVariant: AppColors.muted,
        outline: AppColors.line,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      inputDecorationTheme: _inputTheme(AppColors.muted),
      chipTheme: _chipTheme(AppColors.soft, AppColors.green900),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: _fontFamily,
    );
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.green400,
        onPrimary: Colors.white,
        primaryContainer: AppColors.greenContainerDark,
        onPrimaryContainer: AppColors.onGreenContainerDark,
        secondary: AppColors.honey,
        onSecondary: AppColors.ink,
        tertiary: AppColors.info,
        onTertiary: Colors.white,
        surface: Color(0xFF1A2E1C),
        onSurface: Colors.white,
        onSurfaceVariant: Color(0xFFA8B5AC),
        outline: Color(0xFF3A4E3C),
        error: AppColors.danger300,
        onError: Color(0xFF690005),
      ),
      inputDecorationTheme: _inputTheme(const Color(0xFF8A988E)),
      chipTheme: _chipTheme(
        AppColors.greenContainerDark,
        AppColors.onGreenContainerDark,
      ),
    );
  }

  /// Hints must read as placeholders, not entered text — keep them muted.
  static InputDecorationTheme _inputTheme(Color hint) => InputDecorationTheme(
    hintStyle: TextStyle(color: hint, fontWeight: FontWeight.w400),
  );

  /// Selected chips read green (brand), not the M3 baseline purple that an
  /// under-specified ColorScheme would otherwise leak.
  static ChipThemeData _chipTheme(Color selected, Color onSelected) =>
      ChipThemeData(selectedColor: selected, checkmarkColor: onSelected);
}
