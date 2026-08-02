import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_icons.dart';
import '../../../../core/config.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/moon_month_provider.dart';
import '../../application/moon_settings_controller.dart';
import '../moon_gate.dart';

/// Moon calendar entry in the journal AppBar (FR-19 T4.4, wireframe board C):
/// pushes /moon-calendar. Decides its own visibility — while the feature flag
/// or the opt-in switch is off it renders nothing (disabled feature, not a
/// swallowed error). Gated by flag + opt-in only; the "show in journal"
/// sub-switch governs the colour layer, not this entry (screen-map §1.3).
class JournalMoonButton extends StatelessWidget {
  const JournalMoonButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Flag check without a ref, same pattern as MoonDayBadge (T4.2).
    if (!kMoonCalendarEnabled) return const SizedBox.shrink();
    return const _JournalMoonButtonGate();
  }
}

class _JournalMoonButtonGate extends ConsumerWidget {
  const _JournalMoonButtonGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
    if (!moonSurfaceOn(settings)) return const SizedBox.shrink();
    return const JournalMoonIconButton();
  }
}

/// The button itself. Public so tests and previews can reach it directly —
/// the flag gate above stays const-false until ignition.
class JournalMoonIconButton extends StatelessWidget {
  const JournalMoonIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.t.moon.calendar.title,
      icon: const Icon(kIconNightlightOutlined),
      onPressed: () => context.push('/moon-calendar'),
    );
  }
}

/// Moon colour-layer data for the journal month grid: the moon days of
/// [month], or null while the layer is off (feature flag, opt-in switch or
/// the "show in journal" sub-switch — board C). Null keeps the grid
/// pixel-identical to the moonless journal.
Map<DateTime, MoonMonthDay>? journalMoonDays(WidgetRef ref, DateTime month) {
  // Flag check before any ref — journal tests may pump without moon prefs.
  if (!kMoonCalendarEnabled) return null;
  final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
  if (!journalMoonLayerOn(settings)) return null;
  return ref.watch(moonMonthProvider(month));
}
