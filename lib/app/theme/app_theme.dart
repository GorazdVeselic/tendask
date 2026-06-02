import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.green,
        onPrimary: Colors.white,
        secondary: AppColors.honey,
        onSecondary: AppColors.ink,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.soft,
        outline: AppColors.line,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.green400,
        onPrimary: Colors.white,
        secondary: AppColors.honey,
        onSecondary: AppColors.ink,
        surface: Color(0xFF1A2E1C),
        onSurface: Colors.white,
        outline: Color(0xFF3A4E3C),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
    );
  }
}
