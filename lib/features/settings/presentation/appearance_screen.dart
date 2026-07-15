import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme_mode_controller.dart';
import '../../../app/theme/theme_palette.dart';
import '../../../app/theme/theme_palette_controller.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import 'palette_labels.dart';
import 'widgets/palette_card.dart';
import 'widgets/theme_live_preview.dart';
import 'widgets/theme_mode_selector.dart';

/// Screen 12b — Appearance. Two device-local choices: the theme MODE
/// (system/light/dark) and the colour PALETTE (6 options, green default). Both
/// apply instantly: changing them rebuilds the whole MaterialApp theme, so this
/// screen recolours live (the preview below shows the result).
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final mode =
        ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;
    final selected =
        ref.watch(themePaletteControllerProvider).value ?? greenPalette;
    final brightness = effectiveBrightness(
      mode,
      MediaQuery.platformBrightnessOf(context),
    );
    final hint = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    void selectPalette(String id) => unawaited(
      ref.read(themePaletteControllerProvider.notifier).set(id),
    );

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
            ThemeModeSelector(mode: mode),
            if (mode == ThemeMode.system) ...[
              const SizedBox(height: 8),
              SystemStatusChip(brightness: brightness),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
              child: Text(t.appearance.mode_help, style: hint),
            ),

            SectionLabel(t.appearance.palette_label),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // A fixed aspect ratio clips the card's label once the system font
              // scale grows the name row past the locked height. Derive the card
              // height from the actual label metrics instead: fixed chrome (10px
              // padding ×2 + 50px preview + 8px gap) plus one scaled text line.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent:
                    78 +
                    MediaQuery.textScalerOf(
                          context,
                        ).scale(theme.textTheme.bodyMedium?.fontSize ?? 14) *
                        1.4 +
                    8,
              ),
              children: [
                for (final palette in appPalettes)
                  PaletteCard(
                    palette: palette,
                    roles: brightness == Brightness.light
                        ? palette.light
                        : palette.dark,
                    isSelected: palette.id == selected.id,
                    isDefault: palette.id == greenPalette.id,
                    onTap: () => selectPalette(palette.id),
                  ),
              ],
            ),
            if (selected.id != greenPalette.id)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => selectPalette(greenPalette.id),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    '${t.appearance.reset} (${paletteName(greenPalette.id, t)})',
                  ),
                ),
              ),

            SectionLabel(t.appearance.preview_label),
            const ThemeLivePreview(),

            const SizedBox(height: 16),
            Text(t.appearance.applies_immediately, style: hint),
          ],
        ),
      ),
    );
  }
}
