import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/moon_colors.dart';
import '../../../../core/config.dart';
import '../../../../core/date_format.dart';
import '../../../../i18n/translations.g.dart';
import '../../../plus/application/plus_provider.dart';
import '../../application/moon_month_provider.dart';
import '../../application/moon_settings_controller.dart';
import '../moon_gate.dart';
import 'element_glyph.dart';

/// Element-day gate for a date row (FR-19 T4.2, wireframe board B): a tinted
/// pill like "🌿 leaf day · until 14:20". Decides its own visibility — while the
/// feature flag, the element-label switch or the Tendask+ entitlement is
/// missing it renders nothing (disabled feature, not a swallowed error), so its
/// host screens stay untouched until ignition (T7). The element day is the paid
/// half of FR-19 (spec §6.5), so this row goes behind the wall whole.
class MoonDayBadge extends StatelessWidget {
  const MoonDayBadge({super.key, required this.date});

  /// Any instant of the local day to describe (normalized internally).
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    // Flag check without a ref: host steps are deliberately Riverpod-free and
    // their tests pump without a ProviderScope, so while the feature is dark
    // the badge must not require one. (Flow analysis does not fold const-var
    // conditions, so this is not flagged as dead code.)
    if (!kMoonCalendarEnabled) return const SizedBox.shrink();
    return _MoonDayBadgeGate(date: date);
  }
}

class _MoonDayBadgeGate extends ConsumerWidget {
  const _MoonDayBadgeGate({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
    final isPlus = ref.watch(plusActiveProvider);
    if (!moonElementLabelsOn(settings, isPlus)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: MoonDayBadgeRow(date: date),
    );
  }
}

/// The pill itself. Public so tests, the layout matrix and previews can reach
/// it directly — the flag gate above stays const-false until ignition.
///
/// It wears the element's soft colour rather than the muted body style it had
/// until 2026-08-03: sharing the style of the "defaults to the next full hour"
/// note right above made it read as that note's second line, and the owner
/// missed it on the device. Text stays `onSurface` on the tint (contrast rule
/// A4).
class MoonDayBadgeRow extends ConsumerWidget {
  const MoonDayBadgeRow({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    // The day label the calendar shows for the date (midnight-sliver display
    // rule) — the phase-event marker of a full grid cell is never read here.
    final cell = moonDayLabelFor(date, ref.watch(moonSystemProvider));

    // Map completeness against BiodynamicElement is enforced by i18n tests.
    var text =
        '${elementEmoji(cell.element)} ${t.moon.day_for[cell.element.name]!}';
    if (cell.transitionAt case final transitionAt?) {
      text = '$text · ${t.moon.badge.until(time: formatHm(transitionAt))}';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: MoonColors.of(context).softOf(cell.element),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
