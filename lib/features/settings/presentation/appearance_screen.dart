import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme_mode_controller.dart';
import '../../../app/theme/theme_palette.dart';
import '../../../app/theme/theme_palette_controller.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';

/// Screen 12b — Appearance. Two device-local choices: the theme MODE
/// (system/light/dark) and the colour PALETTE (6 options, green default). Both
/// apply instantly: changing them rebuilds the whole MaterialApp theme, so this
/// screen recolours live (the preview below shows the result).
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  /// The light/dark actually in effect right now — for the mini-previews, which
  /// must show each palette in the current brightness (the screen's own theme
  /// only reflects the *selected* palette).
  Brightness _effectiveBrightness(BuildContext context, ThemeMode mode) =>
      switch (mode) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system => MediaQuery.platformBrightnessOf(context),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final mode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    final selected =
        ref.watch(themePaletteControllerProvider).value ?? greenPalette;
    final brightness = _effectiveBrightness(context, mode);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        title: Text(t.settings.section_appearance),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            SectionLabel(t.appearance.mode_label),
            _ModeSelector(mode: mode),
            if (mode == ThemeMode.system) ...[
              const SizedBox(height: 8),
              _SystemStatusChip(brightness: brightness),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
              child: Text(
                t.appearance.mode_help,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),

            SectionLabel(t.appearance.palette_label),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                for (final palette in appPalettes)
                  _PaletteCard(
                    palette: palette,
                    roles: brightness == Brightness.light
                        ? palette.light
                        : palette.dark,
                    isSelected: palette.id == selected.id,
                    isDefault: palette.id == greenPalette.id,
                    onTap: () => unawaited(
                      ref
                          .read(themePaletteControllerProvider.notifier)
                          .set(palette.id),
                    ),
                  ),
              ],
            ),
            if (selected.id != greenPalette.id)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => unawaited(
                    ref
                        .read(themePaletteControllerProvider.notifier)
                        .set(greenPalette.id),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    '${t.appearance.reset} (${_paletteName(context, greenPalette.id)})',
                  ),
                ),
              ),

            SectionLabel(t.appearance.preview_label),
            const _LivePreview(),

            const SizedBox(height: 16),
            Text(
              t.appearance.applies_immediately,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The palette names live in i18n; resolve by id (green for anything unknown).
String _paletteName(BuildContext context, String id) {
  final a = context.t.appearance;
  return switch (id) {
    'lavender' => a.palette_lavender,
    'ocean' => a.palette_ocean,
    'clay' => a.palette_clay,
    'berry' => a.palette_berry,
    'nebo' => a.palette_nebo,
    _ => a.palette_green,
  };
}

class _ModeSelector extends ConsumerWidget {
  const _ModeSelector({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(
          value: ThemeMode.system,
          icon: const Icon(Icons.smartphone),
          label: Text(t.settings.theme_system),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: const Icon(Icons.light_mode),
          label: Text(t.settings.theme_light),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: const Icon(Icons.dark_mode),
          label: Text(t.settings.theme_dark),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => unawaited(
        ref.read(themeModeControllerProvider.notifier).set(s.first),
      ),
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}

class _SystemStatusChip extends StatelessWidget {
  const _SystemStatusChip({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final label = brightness == Brightness.dark
        ? t.appearance.follows_system_dark
        : t.appearance.follows_system_light;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.brightness_auto, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable palette card: a mini-preview (the palette's own colours in the
/// current brightness), its name, a "Default" badge for green, and a corner
/// check when selected.
class _PaletteCard extends StatelessWidget {
  const _PaletteCard({
    required this.palette,
    required this.roles,
    required this.isSelected,
    required this.isDefault,
    required this.onTap,
  });

  final ThemePalette palette;
  final ThemeRoles roles;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outline,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniPreview(roles: roles),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _paletteName(context, palette.id),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t.appearance.default_badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cs.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 14, color: cs.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

/// A tiny static mock (app bar + body row) painted in a specific palette's
/// roles — independent of the screen's own theme.
class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.roles});

  final ThemeRoles roles;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 50,
        child: Column(
          children: [
            Container(
              height: 17,
              color: roles.primary,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              alignment: Alignment.centerLeft,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: roles.onPrimary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: roles.surface,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 9,
                      decoration: BoxDecoration(
                        color: roles.secondary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 9,
                        decoration: BoxDecoration(
                          color: roles.onSurface.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live preview of the selected palette (uses the screen's theme, which is the
/// selected palette): an app-bar pill, a task card, and a swipe row.
class _LivePreview extends StatelessWidget {
  const _LivePreview();

  @override
  Widget build(BuildContext context) {
    final t = context.t.appearance;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              t.preview_appbar,
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.preview_task,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.preview_task_sub,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t.preview_action,
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t.preview_chip,
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 40,
                  color: cs.primary,
                  child: Icon(Icons.check, size: 16, color: cs.onPrimary),
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    color: cs.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t.preview_swipe,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                Container(
                  width: 46,
                  height: 40,
                  color: cs.error,
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: cs.onError,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
