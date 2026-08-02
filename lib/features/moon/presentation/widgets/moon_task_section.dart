import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config.dart';
import '../../../../core/date_format.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../i18n/translations.g.dart';
import '../../application/moon_month_provider.dart';
import '../../application/moon_settings_controller.dart';
import '../moon_gate.dart';
import '../moon_text.dart';
import 'element_glyph.dart';

/// "Moon calendar" section on the task detail (FR-19 T4.3, wireframe board A):
/// the element day of the task's date, RE-DERIVED on every build — never
/// frozen like the weather snapshot (spec §6.1.2), so editing the date moves
/// it. Info only, no tap (MVP). Decides its own visibility — while the feature
/// flag or the opt-in switch is off it renders nothing (disabled feature, not
/// a swallowed error), including its section label.
class MoonTaskSection extends StatelessWidget {
  const MoonTaskSection({super.key, required this.date});

  /// Local task date (any instant of the day; normalized internally).
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    // Flag check without a ref, same pattern as MoonDayBadge (T4.2).
    if (!kMoonCalendarEnabled) return const SizedBox.shrink();
    return _MoonTaskSectionGate(date: date);
  }
}

class _MoonTaskSectionGate extends ConsumerWidget {
  const _MoonTaskSectionGate({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
    if (!moonSurfaceOn(settings)) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(context.t.moon.calendar.title),
        MoonTaskSectionCard(date: date),
      ],
    );
  }
}

/// The card itself. Public so tests, the layout matrix and previews can reach
/// it directly — the flag gate above stays const-false until ignition.
class MoonTaskSectionCard extends ConsumerWidget {
  const MoonTaskSectionCard({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    // The day label the calendar shows for the task's date (midnight-sliver
    // display rule); the phase-event marker of a full grid cell is unused here.
    final cell = moonDayLabelFor(date, ref.watch(moonSystemProvider));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  elementEmoji(cell.element),
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Map completeness against BiodynamicElement is
                        // enforced by i18n tests.
                        sentenceCase(t.moon.day_for[cell.element.name]!),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((cell.transitionAt, cell.secondaryElement) case (
                        final transitionAt?,
                        final secondary?,
                      ))
                        Text(
                          t.moon.sheet.until_then(
                            time: formatHm(transitionAt),
                            emoji: elementEmoji(secondary),
                            day: t.moon.day_for[secondary.name]!,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t.moon.task_section.footnote,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
