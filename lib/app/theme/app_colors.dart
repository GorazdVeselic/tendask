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
  // Green container tones for the dark theme (selected chips) — the light theme
  // reuses [soft]/[green900].
  static const Color greenContainerDark = Color(0xFF24432A);
  static const Color onGreenContainerDark = Color(0xFFBCEAC2);

  // Dark-theme surface/neutral tones.
  static const Color surfaceDark = Color(0xFF1A2E1C);
  static const Color onSurfaceVariantDark = Color(0xFFA8B5AC);
  static const Color outlineDark = Color(0xFF3A4E3C);
  static const Color hintDark = Color(0xFF8A988E);
  // Neutral row-action tone (revert/edit/move) on the dark theme.
  static const Color neutralActionDark = Color(0xFF8A948C);

  // Destructive / error — terracotta (warm, garden-friendly): the single
  // destructive + error tone app-wide. No M3 neon/pink red.
  static const Color terracotta = Color(0xFFB0473B);
  static const Color terracottaDark = Color(0xFFC25A4D);
  static const Color terracottaSoft = Color(0xFFF1DAD3);
  static const Color onTerracottaSoft = Color(0xFF9A3B2E);
  static const Color terracottaContainerDark = Color(0xFF4A2A24);
  static const Color onTerracottaContainerDark = Color(0xFFF2B5A8);

  // Moon calendar elements (FR-19, decision A4): fixed semantic tones shared by
  // all palettes, light from the v2 wireframe, dark per the terracotta pattern
  // (lighter accent, muted dark container). Consumed via [MoonColors] only.
  static const Color moonFruit = Color(0xFFE5484D);
  static const Color moonFruitSoft = Color(0xFFFDE7E8);
  static const Color moonFruitDark = Color(0xFFEF6A6E);
  static const Color moonFruitContainerDark = Color(0xFF46282A);
  static const Color moonRoot = Color(0xFF7E57C2);
  static const Color moonRootSoft = Color(0xFFEFE9F8);
  static const Color moonRootDark = Color(0xFF9B7FD4);
  static const Color moonRootContainerDark = Color(0xFF322A44);
  static const Color moonFlower = Color(0xFFF4A91B);
  static const Color moonFlowerSoft = Color(0xFFFDF1D6);
  static const Color moonFlowerDark = Color(0xFFF0B24A);
  static const Color moonFlowerContainerDark = Color(0xFF453718);
  static const Color moonLeaf = Color(0xFF1E88E5);
  static const Color moonLeafSoft = Color(0xFFE4F0FB);
  static const Color moonLeafDark = Color(0xFF5BA1E8);
  static const Color moonLeafContainerDark = Color(0xFF223649);

  // Text and scrims on top of the brand gradient (splash, onboarding, the
  // notification preview): those surfaces are always dark, so their foreground
  // is white regardless of the palette or the light/dark mode.
  static const Color onBrand = Color(0xFFFFFFFF);

  // Soft drop shadow under a floating bar (save bar).
  static const Color shadowSoft = Color(0x0F000000);

  // Google sign-in button — black on white is mandated by Google's branding
  // guidelines, so it never follows the app palette.
  static const Color googleButton = Color(0xFF000000);
  static const Color onGoogleButton = Color(0xFFFFFFFF);

  // Build-environment ribbon (debug/staging builds only, never in production).
  static const Color envStaging = Color(0xFFFF9800);
  static const Color envOther = Color(0xFF9E9E9E);
}
