import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_icons.dart';
import '../../../../core/biodynamic/biodynamic_day.dart';
import '../../../../core/biodynamic/moon_calendar.dart';
import '../../../../core/config.dart';
import '../../../../core/date_format.dart';
import '../../../../i18n/translations.g.dart';
import '../../../moon/application/moon_month_provider.dart';
import '../../../moon/application/moon_settings_controller.dart';
import '../../../moon/presentation/widgets/moon_phase_icon.dart';
import '../../../plus/application/plus_provider.dart';
import '../../../plus/presentation/plus_label.dart';

/// Moon calendar entry gate on the dashboard (FR-19 T4.1, wireframe board 1).
/// While the feature flag is off it renders nothing, so the dashboard stays
/// untouched until ignition (T7); once lit, the chip is ALWAYS here — the phase
/// is the one free hook and is worth more as a teaser than as something the
/// user can hide (decision B3), so there is no switch for it.
///
/// This is the one moon surface with SPLIT gating (T6.6): the phase is free
/// forever (spec §6.5), so the chip stays whole without Tendask+ and only its
/// element-day CTA is swapped for the lock.
class HomeMoonChip extends StatelessWidget {
  const HomeMoonChip({super.key});

  @override
  Widget build(BuildContext context) {
    // Flag check before any ref, same pattern as the other three entry points
    // (T4.2): while the feature is dark nothing here may touch Riverpod.
    if (!kMoonCalendarEnabled) return const SizedBox.shrink();
    return const _HomeMoonChipGate();
  }
}

class _HomeMoonChipGate extends ConsumerWidget {
  const _HomeMoonChipGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The entitlement only decides which CTA the card carries — never whether
    // the card is here.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: HomeMoonChipCard(isPlus: ref.watch(plusActiveProvider)),
    );
  }
}

/// The chip itself: today's phase (free for everyone) plus the element-day CTA
/// into /moon-calendar — or, without [isPlus], the lock that leads to
/// /tendask-plus instead. Public so tests and previews can reach it directly —
/// the flag gate above stays const-false until ignition.
class HomeMoonChipCard extends ConsumerStatefulWidget {
  const HomeMoonChipCard({super.key, required this.isPlus});

  /// Whether Tendask+ is active; false hides the element day, never the phase.
  final bool isPlus;

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
    final today = startOfDay(DateTime.now());
    final day = dayFor(today, system);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // Without the entitlement the calendar is walled, so a tap anywhere on
        // the card leads to what unlocks it rather than to a bounced route.
        onTap: () =>
            context.push(widget.isPlus ? '/moon-calendar' : '/tendask-plus'),
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
                  child: widget.isPlus
                      // The element of the day LABEL (midnight-sliver display
                      // rule), so the chip agrees with the calendar cell it
                      // opens. Reduced from the day computed above rather than
                      // recomputed — the engine pass is the expensive part.
                      ? _ElementCta(element: moonDayLabel(day, today).element)
                      : const _LockedCta(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The unlocked CTA: today's element day, the way into the calendar.
class _ElementCta extends StatelessWidget {
  const _ElementCta({required this.element});

  final BiodynamicElement element;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          // Map completeness against BiodynamicElement is enforced by i18n
          // tests.
          context.t.moon.day_for[element.name]!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Icon(kIconChevronRight, size: 20, color: theme.colorScheme.primary),
      ],
    );
  }
}

/// The locked CTA (wireframe board 1, left phone): a filled pill in place of
/// the element day. It wears the palette's accent (honey on the green theme —
/// owner's pick 2026-08-03 over the wireframe's red, which is this app's
/// destructive tone and would read as a warning). Not translated — the pill
/// carries the brand name only, so nothing here reads as a purchase
/// (FR-20 §3.1).
class _LockedCta extends StatelessWidget {
  const _LockedCta();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPill = theme.colorScheme.onSecondary;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(kPlusMarkIcon, size: 14, color: onPill),
          const SizedBox(width: 5),
          Text(
            kPlusLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: onPill,
              fontWeight: FontWeight.w800,
            ),
          ),
          Icon(kIconChevronRight, size: 16, color: onPill),
        ],
      ),
    );
  }
}
