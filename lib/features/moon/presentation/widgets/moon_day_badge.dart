import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/biodynamic/calendar_system.dart';
import '../../../../core/biodynamic/moon_calendar.dart';
import '../../../../core/config.dart';
import '../../../../core/date_format.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/moon_month_provider.dart';
import '../../application/moon_settings_controller.dart';
import 'element_badge.dart';

/// Element-day gate for a date row (FR-19 T4.2, wireframe board B): a muted
/// one-liner like "🌿 leaf day · until 14:20". Decides its own visibility —
/// while the feature flag or the opt-in switch is off it renders nothing
/// (disabled feature, not a swallowed error), so its host screens stay
/// untouched until ignition (T7).
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
    if (!(settings?.enabled ?? false)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: MoonDayBadgeRow(date: date),
    );
  }
}

/// The row itself. Public so tests, the layout matrix and previews can reach
/// it directly — the flag gate above stays const-false until ignition.
class MoonDayBadgeRow extends ConsumerWidget {
  const MoonDayBadgeRow({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    // Sidereal while the settings are still loading — same fallback as the
    // other moon screens (one system drives them all, spec §11.6).
    final system =
        ref.watch(moonSettingsControllerProvider).asData?.value.system ??
        CalendarSystem.sidereal;
    final day = dayFor(date, system);
    // The element of the day LABEL (midnight-sliver display rule), so the
    // badge agrees with the calendar cell for the same date.
    final cell = moonMonthDayFor(date, system);

    // Map completeness against BiodynamicElement is enforced by i18n tests.
    var text =
        '${elementEmoji(cell.element)} ${t.moon.day_for[cell.element.name]!}';
    if ((day.transitionAt, cell.secondaryElement) case (
      final transitionAt?,
      _?,
    )) {
      text = '$text · ${t.moon.badge.until(time: formatHm(transitionAt))}';
    }

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
