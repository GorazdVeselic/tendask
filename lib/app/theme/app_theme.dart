import 'package:flutter/material.dart';

import '../../core/widgets/swipe_actions.dart';
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
      extensions: const [_swipeLight],
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
      extensions: const [_swipeDark],
    );
  }

  // Scheme A (full brand tones): green = done, honey = +1 day, muted grey =
  // neutral (revert/edit/move), terracotta = delete. No off-brand blue/red.
  static const _swipeLight = SwipeColors(
    complete: AppColors.green,
    onComplete: Colors.white,
    postpone: AppColors.honey,
    onPostpone: AppColors.ink,
    neutral: AppColors.muted,
    onNeutral: Colors.white,
    delete: AppColors.terracotta,
    onDelete: Colors.white,
  );

  static const _swipeDark = SwipeColors(
    complete: AppColors.green400,
    onComplete: AppColors.ink,
    postpone: AppColors.honey,
    onPostpone: AppColors.ink,
    neutral: AppColors.neutralActionDark,
    onNeutral: AppColors.ink,
    delete: AppColors.terracottaDark,
    onDelete: AppColors.ink,
  );

  /// Hints must read as placeholders, not entered text — keep them muted.
  static InputDecorationTheme _inputTheme(Color hint) => InputDecorationTheme(
    hintStyle: TextStyle(color: hint, fontWeight: FontWeight.w400),
  );

  /// Selected chips read green (brand), not the M3 baseline purple that an
  /// under-specified ColorScheme would otherwise leak.
  static ChipThemeData _chipTheme(Color selected, Color onSelected) =>
      ChipThemeData(selectedColor: selected, checkmarkColor: onSelected);
}
