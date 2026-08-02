import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_icons.dart';
import '../../../../core/config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/moon_settings_controller.dart';
import '../moon_gate.dart';

/// "When for …" chip in the plant detail hero (FR-19 T5.3, wireframe board D):
/// opens the finder prefilled with this plant. Decides its own visibility —
/// while the feature flag or the opt-in switch is off it renders nothing
/// (disabled feature, not a swallowed error), so the hero stays untouched
/// until ignition (T7).
class PlantMoonChip extends StatelessWidget {
  const PlantMoonChip({super.key, required this.plant});

  /// Catalog entry of the subject; null for a private plant, which the sowing
  /// calendar knows nothing about and the finder could not prefill.
  final Plant? plant;

  @override
  Widget build(BuildContext context) {
    // Flag check without a ref, same pattern as MoonDayBadge (T4.2).
    if (!kMoonCalendarEnabled) return const SizedBox.shrink();
    return _PlantMoonChipGate(plant: plant);
  }
}

class _PlantMoonChipGate extends ConsumerWidget {
  const _PlantMoonChipGate({required this.plant});

  final Plant? plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
    // Every visibility rule lives in the pure gate, so it is testable while the
    // feature flag above keeps this widget dark (finding T4.5).
    final target = plantMoonChipTarget(
      settings,
      category: plant?.category,
      plantId: plant?.id,
    );
    if (target == null) return const SizedBox.shrink();
    return PlantMoonChipButton(plantId: target);
  }
}

/// The chip itself. Public so tests, the layout matrix and previews can reach
/// it directly — the flag gate above stays const-false until ignition.
class PlantMoonChipButton extends StatelessWidget {
  const PlantMoonChipButton({super.key, required this.plantId});

  /// Catalog plant id passed to the finder as `?plant=`.
  final String plantId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(
        kIconNightlightOutlined,
        size: 18,
        color: theme.colorScheme.primary,
      ),
      label: Text(context.t.moon.finder.title),
      onPressed: () => context.pushNamed(
        'moon-finder',
        queryParameters: {'plant': plantId},
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
