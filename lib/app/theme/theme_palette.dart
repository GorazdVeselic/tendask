import 'package:flutter/material.dart';

import '../../core/widgets/swipe_actions.dart';
import 'app_colors.dart';

/// One palette's colours for a single brightness (light or dark): the full set
/// of Material 3 roles the app actually uses, plus the input-hint tone and the
/// reveal-swipe [SwipeColors]. The catalog ([appPalettes]) is the single source
/// of these values; widgets read them through the theme, never directly.
@immutable
class ThemeRoles {
  const ThemeRoles({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.hint,
    required this.swipe,
    this.surfaceContainerHighest,
    this.inverseSurface,
    this.onInverseSurface,
  });

  /// Roles whose [SwipeColors] follow the standard wireframe mapping
  /// (complete=primary, postpone=secondary, neutral=onSurfaceVariant on surface,
  /// delete=error) — used by every palette except the legacy green one, which
  /// keeps its hand-tuned swipe tones.
  factory ThemeRoles.derived({
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color onSecondary,
    required Color surface,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color error,
    required Color onError,
    required Color errorContainer,
    required Color onErrorContainer,
    required Color surfaceContainerHighest,
    required Color inverseSurface,
    required Color onInverseSurface,
  }) => ThemeRoles(
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    // Hints reuse onSurfaceVariant (placeholders stay muted, never read as text).
    hint: onSurfaceVariant,
    surfaceContainerHighest: surfaceContainerHighest,
    inverseSurface: inverseSurface,
    onInverseSurface: onInverseSurface,
    swipe: SwipeColors(
      complete: primary,
      onComplete: onPrimary,
      postpone: secondary,
      onPostpone: onSecondary,
      neutral: onSurfaceVariant,
      onNeutral: surface,
      delete: error,
      onDelete: onError,
    ),
  );

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  /// Placeholder tone for input fields — kept a separate role because the green
  /// dark theme uses a more muted hint than its onSurfaceVariant.
  final Color hint;

  final SwipeColors swipe;

  /// Roles the legacy green theme left to the framework default (null = "let
  /// Material 3 fill it"), so green renders byte-identically to before. Every
  /// other palette sets all three.
  final Color? surfaceContainerHighest;
  final Color? inverseSurface;
  final Color? onInverseSurface;
}

/// A selectable colour theme: a stable [id] (persisted device-locally) plus its
/// [light] and [dark] role sets. The user-facing name is resolved in the UI via
/// i18n — the model stays pure data (no [BuildContext], no translations).
@immutable
class ThemePalette {
  const ThemePalette({
    required this.id,
    required this.light,
    required this.dark,
  });

  final String id;
  final ThemeRoles light;
  final ThemeRoles dark;
}

// ─────────────────────────────────────────────────────────────────────────────
// Catalog. Values are transcribed verbatim from docs/wireframes/themes-gallery.html
// (the visually-approved palettes) — NOT generated via ColorScheme.fromSeed,
// which would not reproduce the confirmed surface/secondary tones.
// ─────────────────────────────────────────────────────────────────────────────

/// Brand green (default). Built from the existing [AppColors] tokens so it is
/// byte-identical to the pre-palette theme; its swipe tones are hand-tuned (not
/// the derived mapping), so they are spelled out explicitly here.
const greenPalette = ThemePalette(
  id: 'green',
  light: ThemeRoles(
    primary: AppColors.green,
    onPrimary: Colors.white,
    primaryContainer: AppColors.soft,
    onPrimaryContainer: AppColors.green900,
    secondary: AppColors.honey,
    onSecondary: AppColors.ink,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    outline: AppColors.line,
    error: AppColors.terracotta,
    onError: Colors.white,
    errorContainer: AppColors.terracottaSoft,
    onErrorContainer: AppColors.onTerracottaSoft,
    hint: AppColors.muted,
    surfaceContainerHighest: AppColors.soft,
    swipe: SwipeColors(
      complete: AppColors.green,
      onComplete: Colors.white,
      postpone: AppColors.honey,
      onPostpone: AppColors.ink,
      neutral: AppColors.muted,
      onNeutral: Colors.white,
      delete: AppColors.terracotta,
      onDelete: Colors.white,
    ),
  ),
  dark: ThemeRoles(
    primary: AppColors.green400,
    onPrimary: Colors.white,
    primaryContainer: AppColors.greenContainerDark,
    onPrimaryContainer: AppColors.onGreenContainerDark,
    secondary: AppColors.honey,
    onSecondary: AppColors.ink,
    surface: AppColors.surfaceDark,
    onSurface: Colors.white,
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    outline: AppColors.outlineDark,
    error: AppColors.terracottaDark,
    onError: AppColors.ink,
    errorContainer: AppColors.terracottaContainerDark,
    onErrorContainer: AppColors.onTerracottaContainerDark,
    hint: AppColors.hintDark,
    // surfaceContainerHighest / inverseSurface intentionally unset → M3 default,
    // matching the pre-palette green dark theme exactly.
    swipe: SwipeColors(
      complete: AppColors.green400,
      onComplete: AppColors.ink,
      postpone: AppColors.honey,
      onPostpone: AppColors.ink,
      neutral: AppColors.neutralActionDark,
      onNeutral: AppColors.ink,
      delete: AppColors.terracottaDark,
      onDelete: AppColors.ink,
    ),
  ),
);

final lavenderPalette = ThemePalette(
  id: 'lavender',
  light: ThemeRoles.derived(
    primary: const Color(0xFF6A5AD0),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE7E2FB),
    onPrimaryContainer: const Color(0xFF352A75),
    secondary: const Color(0xFFD9A441),
    onSecondary: const Color(0xFF2B2640),
    surface: Colors.white,
    onSurface: const Color(0xFF211F2B),
    onSurfaceVariant: const Color(0xFF6E6A82),
    outline: const Color(0xFFE5E2EE),
    error: const Color(0xFFB0473B),
    onError: Colors.white,
    errorContainer: const Color(0xFFF1DAD3),
    onErrorContainer: const Color(0xFF9A3B2E),
    surfaceContainerHighest: const Color(0xFFECE9FA),
    inverseSurface: const Color(0xFF2E2A40),
    onInverseSurface: Colors.white,
  ),
  dark: ThemeRoles.derived(
    primary: const Color(0xFFA99CEC),
    onPrimary: const Color(0xFF241C46),
    primaryContainer: const Color(0xFF2E2A4A),
    onPrimaryContainer: const Color(0xFFDCD4F7),
    secondary: const Color(0xFFE0B45A),
    onSecondary: const Color(0xFF2B2640),
    surface: const Color(0xFF1E1B2E),
    onSurface: Colors.white,
    onSurfaceVariant: const Color(0xFFABA6C0),
    outline: const Color(0xFF3E3A52),
    error: const Color(0xFFD2685F),
    onError: const Color(0xFF1D1622),
    errorContainer: const Color(0xFF4A2A30),
    onErrorContainer: const Color(0xFFF2B5A8),
    surfaceContainerHighest: const Color(0xFF2E2A4A),
    inverseSurface: const Color(0xFFECE9FA),
    onInverseSurface: const Color(0xFF211F2B),
  ),
);

final oceanPalette = ThemePalette(
  id: 'ocean',
  light: ThemeRoles.derived(
    primary: const Color(0xFF1E7E8C),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFD4EDF1),
    onPrimaryContainer: const Color(0xFF0A4751),
    // Nudged darker from the wireframe's #E5774E (white-on-orange was 2.97:1) so
    // white text/icons clear the 3:1 AA floor — see the theme contrast audit.
    secondary: const Color(0xFFDE6E45),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF182426),
    onSurfaceVariant: const Color(0xFF5E7378),
    outline: const Color(0xFFDCE8EA),
    error: const Color(0xFFB0473B),
    onError: Colors.white,
    errorContainer: const Color(0xFFF1DAD3),
    onErrorContainer: const Color(0xFF9A3B2E),
    surfaceContainerHighest: const Color(0xFFE0F0F2),
    inverseSurface: const Color(0xFF20383B),
    onInverseSurface: Colors.white,
  ),
  dark: ThemeRoles.derived(
    primary: const Color(0xFF4FB8C6),
    onPrimary: const Color(0xFF06343B),
    primaryContainer: const Color(0xFF1B4248),
    onPrimaryContainer: const Color(0xFFB3E5ED),
    secondary: const Color(0xFFEE9170),
    onSecondary: const Color(0xFF3A1A0E),
    surface: const Color(0xFF122A2E),
    onSurface: Colors.white,
    onSurfaceVariant: const Color(0xFF9FB6BB),
    outline: const Color(0xFF2F4A4F),
    error: const Color(0xFFD2685F),
    onError: const Color(0xFF1D1622),
    errorContainer: const Color(0xFF4A2A24),
    onErrorContainer: const Color(0xFFF2B5A8),
    surfaceContainerHighest: const Color(0xFF1B4248),
    inverseSurface: const Color(0xFFE0F0F2),
    onInverseSurface: const Color(0xFF182426),
  ),
);

final clayPalette = ThemePalette(
  id: 'clay',
  light: ThemeRoles.derived(
    primary: const Color(0xFFB5623F),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFF4E0D4),
    onPrimaryContainer: const Color(0xFF5E3318),
    secondary: const Color(0xFF7B8B3B),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF2A211B),
    onSurfaceVariant: const Color(0xFF786A5F),
    outline: const Color(0xFFEBE2DA),
    error: const Color(0xFFA3303C),
    onError: Colors.white,
    errorContainer: const Color(0xFFF6D9D8),
    onErrorContainer: const Color(0xFF8A1F2C),
    surfaceContainerHighest: const Color(0xFFF4E9E1),
    inverseSurface: const Color(0xFF3A2E26),
    onInverseSurface: Colors.white,
  ),
  dark: ThemeRoles.derived(
    primary: const Color(0xFFD89067),
    onPrimary: const Color(0xFF3A1C0C),
    primaryContainer: const Color(0xFF3E2D22),
    onPrimaryContainer: const Color(0xFFF2CBAE),
    secondary: const Color(0xFFA9BB63),
    onSecondary: const Color(0xFF28310E),
    surface: const Color(0xFF2A211B),
    onSurface: Colors.white,
    onSurfaceVariant: const Color(0xFFBCA99A),
    outline: const Color(0xFF45382E),
    error: const Color(0xFFD9737A),
    onError: const Color(0xFF2A0E12),
    errorContainer: const Color(0xFF4A2226),
    onErrorContainer: const Color(0xFFF6C2C5),
    surfaceContainerHighest: const Color(0xFF3E2D22),
    inverseSurface: const Color(0xFFF4E9E1),
    onInverseSurface: const Color(0xFF2A211B),
  ),
);

final berryPalette = ThemePalette(
  id: 'berry',
  light: ThemeRoles.derived(
    primary: const Color(0xFF8A3D72),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFF3DCEC),
    onPrimaryContainer: const Color(0xFF551446),
    secondary: const Color(0xFF4F9D6E),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF271E25),
    onSurfaceVariant: const Color(0xFF756575),
    outline: const Color(0xFFECE0E8),
    error: const Color(0xFFB0473B),
    onError: Colors.white,
    errorContainer: const Color(0xFFF1DAD3),
    onErrorContainer: const Color(0xFF9A3B2E),
    surfaceContainerHighest: const Color(0xFFF4E6EF),
    inverseSurface: const Color(0xFF322631),
    onInverseSurface: Colors.white,
  ),
  dark: ThemeRoles.derived(
    primary: const Color(0xFFCA82B2),
    onPrimary: const Color(0xFF45123A),
    primaryContainer: const Color(0xFF3E2C39),
    onPrimaryContainer: const Color(0xFFF2C4E2),
    secondary: const Color(0xFF6FC495),
    onSecondary: const Color(0xFF0C3320),
    surface: const Color(0xFF281E26),
    onSurface: Colors.white,
    onSurfaceVariant: const Color(0xFFC0A9BC),
    outline: const Color(0xFF463A44),
    error: const Color(0xFFD2685F),
    onError: const Color(0xFF1D1622),
    errorContainer: const Color(0xFF4A2A24),
    onErrorContainer: const Color(0xFFF2B5A8),
    surfaceContainerHighest: const Color(0xFF3E2C39),
    inverseSurface: const Color(0xFFF4E6EF),
    onInverseSurface: const Color(0xFF271E25),
  ),
);

final neboPalette = ThemePalette(
  id: 'nebo',
  light: ThemeRoles.derived(
    primary: const Color(0xFF2E6BD6),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDCE7FB),
    onPrimaryContainer: const Color(0xFF123A7A),
    // Nudged darker from the wireframe's #E5774E (white-on-orange was 2.97:1) so
    // white text/icons clear the 3:1 AA floor — see the theme contrast audit.
    secondary: const Color(0xFFDE6E45),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF1A2230),
    onSurfaceVariant: const Color(0xFF5E6675),
    outline: const Color(0xFFDFE3EC),
    error: const Color(0xFFB0473B),
    onError: Colors.white,
    errorContainer: const Color(0xFFF1DAD3),
    onErrorContainer: const Color(0xFF9A3B2E),
    surfaceContainerHighest: const Color(0xFFE5EBF8),
    inverseSurface: const Color(0xFF23304A),
    onInverseSurface: Colors.white,
  ),
  dark: ThemeRoles.derived(
    primary: const Color(0xFF7BA8F0),
    onPrimary: const Color(0xFF0E2348),
    primaryContainer: const Color(0xFF1E2E50),
    onPrimaryContainer: const Color(0xFFCFE0FB),
    secondary: const Color(0xFFEE9170),
    onSecondary: const Color(0xFF3A1A0E),
    surface: const Color(0xFF161C28),
    onSurface: Colors.white,
    onSurfaceVariant: const Color(0xFFA6B0C2),
    outline: const Color(0xFF34405A),
    error: const Color(0xFFD2685F),
    onError: const Color(0xFF1D1622),
    errorContainer: const Color(0xFF4A2A24),
    onErrorContainer: const Color(0xFFF2B5A8),
    surfaceContainerHighest: const Color(0xFF243353),
    inverseSurface: const Color(0xFFE5EBF8),
    onInverseSurface: const Color(0xFF1A2230),
  ),
);

/// All selectable palettes, in display order. Green is first (the default).
final List<ThemePalette> appPalettes = [
  greenPalette,
  lavenderPalette,
  oceanPalette,
  clayPalette,
  berryPalette,
  neboPalette,
];

/// Resolves a stored id back to its palette, falling back to green for an
/// unknown or null id (a dropped palette must never crash an old install).
ThemePalette paletteForId(String? id) =>
    appPalettes.firstWhere((p) => p.id == id, orElse: () => greenPalette);
