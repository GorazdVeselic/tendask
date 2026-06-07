import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color green900 = Color(0xFF205A28);
  static const Color green = Color(0xFF2E7D32);
  static const Color green400 = Color(0xFF3A9A57);
  static const Color honey = Color(0xFFE0A82E);
  static const Color soft = Color(0xFFE8F3EA);
  static const Color softer = Color(0xFFF2F8F3);
  static const Color ink = Color(0xFF1D2823);
  static const Color muted = Color(0xFF6B7770);
  static const Color bg = Color(0xFFECEEF0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE4E8E5);
  static const Color warn = Color(0xFFB46B00);
  static const Color warnSoft = Color(0xFFFFF4E0);
  static const Color info = Color(0xFF2266AA);
  static const Color infoSoft = Color(0xFFE6F0FA);
  // Destructive / error — used for delete actions and validation.
  static const Color danger = Color(0xFFBA1A1A);
  static const Color dangerSoft = Color(0xFFFCEDEC);
  // Lighter destructive tone for dark theme.
  static const Color danger300 = Color(0xFFFFB4AB);
  // Green container tones for the dark theme (selected chips, swipe-move bg) —
  // the light theme reuses [soft]/[green900].
  static const Color greenContainerDark = Color(0xFF24432A);
  static const Color onGreenContainerDark = Color(0xFFBCEAC2);
}
