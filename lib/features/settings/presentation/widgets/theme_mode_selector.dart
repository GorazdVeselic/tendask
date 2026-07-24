import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../i18n/translations.g.dart';

/// System / light / dark. Applies instantly (the whole MaterialApp rebuilds).
class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key, required this.mode});

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

/// Under "system", spells out which way the phone currently leans.
class SystemStatusChip extends StatelessWidget {
  const SystemStatusChip({super.key, required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
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
              style: theme.textTheme.labelSmall?.copyWith(
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
