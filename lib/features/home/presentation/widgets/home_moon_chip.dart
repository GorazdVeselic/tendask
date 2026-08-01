import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/biodynamic/moon_calendar.dart';
import '../../../../core/config.dart';
import '../../../../i18n/translations.g.dart';
import '../../../moon/application/moon_month_provider.dart';
import '../../../moon/application/moon_settings_controller.dart';
import '../../../moon/presentation/moon_gate.dart';
import '../../../moon/presentation/widgets/moon_phase_icon.dart';

/// Moon calendar entry gate on the dashboard (FR-19 T4.1, wireframe board 1).
/// Decides its own visibility — while the feature flag or the opt-in switch is
/// off it renders nothing (disabled feature, not a swallowed error), so the
/// dashboard stays untouched until ignition (T7). The locked → ✦ Tendask+
/// state comes with T6.
class HomeMoonChip extends ConsumerWidget {
  const HomeMoonChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warmed in bootstrap (keepAlive), so no flash: the value is present from
    // the first frame and the null branch only covers a failed load.
    final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
    if (!kMoonCalendarEnabled || !moonSurfaceOn(settings)) {
      return const SizedBox.shrink();
    }
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: HomeMoonChipCard(),
    );
  }
}

/// The chip itself: today's phase (the free part) with the element-day CTA
/// into /moon-calendar. Public so tests and previews can reach it directly —
/// the flag gate above stays const-false until ignition.
class HomeMoonChipCard extends ConsumerStatefulWidget {
  const HomeMoonChipCard({super.key});

  @override
  ConsumerState<HomeMoonChipCard> createState() => _HomeMoonChipCardState();
}

class _HomeMoonChipCardState extends ConsumerState<HomeMoonChipCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // "Today" is read in build; an app resumed the next morning must not keep
    // showing yesterday's day.
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final system = ref.watch(moonSystemProvider);
    final today = DateTime.now();
    final day = dayFor(today, system);
    // The element of the day LABEL (midnight-sliver display rule), so the chip
    // agrees with the calendar cell it opens.
    final cell = moonMonthDayFor(today, system);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/moon-calendar'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              MoonPhaseIcon(
                phase: day.phase,
                illumFraction: day.illumFraction,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // One word in German ("Mondkalender"), so wrapping would
                    // break it mid-word at 320 px with large text — scale it
                    // down instead. Untouched at ordinary sizes (scaleDown
                    // never enlarges).
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          t.moon.calendar.title,
                          maxLines: 1,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      // Map completeness against MoonPhase is enforced by
                      // i18n tests.
                      t.moon.phase[day.phase.name]!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // The CTA yields width instead of taking its natural size: laid
              // out rigidly it starves the title column, and German
              // ("Mondkalender" · "Blütentag") then breaks mid-word at 320 px
              // with large text. It scales down rather than wrap.
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.moon.day_for[cell.element.name]!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
