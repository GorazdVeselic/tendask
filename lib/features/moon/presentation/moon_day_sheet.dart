import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/moon_colors.dart';
import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/moon_calendar.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../i18n/translations.g.dart';
import '../application/moon_month_provider.dart';
import '../application/moon_settings_controller.dart';
import 'moon_text.dart';
import 'widgets/element_badge.dart';
import 'widgets/moon_phase_icon.dart';

/// Opens the day-detail bottom sheet (FR-19 T3.5, wireframe board 4): the
/// "what's happening" block (spec §11.6) plus the recommended-activity list
/// with a "+ task" CTA per element.
Future<void> showMoonDaySheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) =>
          _MoonDaySheet(date: date, scrollController: scrollController),
    ),
  );
}

class _MoonDaySheet extends ConsumerWidget {
  const _MoonDaySheet({required this.date, required this.scrollController});

  /// Local midnight of the shown day.
  final DateTime date;

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final ml = MaterialLocalizations.of(context);

    final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
    final system = ref.watch(moonSystemProvider);
    // Raw layers for the facts; the grid-cell reduction for the day label
    // (midnight-sliver display rule) so the sheet agrees with the calendar.
    final day = dayFor(date, system);
    final cell = moonMonthDayFor(date, system);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const SheetHandle(),
        Text(
          sentenceCase(ml.formatFullDate(date)),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _DayHero(cell: cell),
        // The astro details block is behind its own sub-toggle (T3.6).
        if (settings?.showAstroDetails ?? true) ...[
          const SizedBox(height: 14),
          _WhatsHappening(day: day),
        ],
        SectionLabel(
          // Map completeness against BiodynamicElement is enforced by i18n
          // tests.
          t.moon.sheet.recommended_for(day: t.moon.day_for[cell.element.name]!),
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 4),
        ),
        if (cell.principalPhase == MoonPhase.newMoon)
          _RecommendedRow(
            leading: const MoonPhaseIcon(
              phase: MoonPhase.newMoon,
              illumFraction: 0,
              size: 20,
            ),
            text: t.moon.activity_new_moon,
            date: date,
          )
        else ...[
          for (final element in [cell.element, ?cell.secondaryElement])
            _RecommendedRow(
              leading: Text(
                elementEmoji(element),
                style: const TextStyle(fontSize: 18),
              ),
              avatarColor: MoonColors.of(context).softOf(element),
              text: t.moon.activity[element.name]!,
              date: date,
            ),
        ],
      ],
    );
  }
}

/// Banner naming the day ("Fruit day"), with the transition tail
/// ("until 14:20, then …") on element-change days.
class _DayHero extends StatelessWidget {
  const _DayHero({required this.cell});

  final MoonMonthDay cell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final moon = MoonColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: moon.softOf(cell.element),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            elementEmoji(cell.element),
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sentenceCase(t.moon.day_for[cell.element.name]!),
                  // Text on a soft element background stays onSurface (A4).
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
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
                      color: theme.colorScheme.onSurface,
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

/// Test handle for the astro-details block (behind the 🌌 sub-toggle).
const kMoonWhatsHappeningKey = Key('moon-whats-happening');

/// The "what's happening" box (spec §11.6): position + transition hour, phase
/// meaning, ascending/descending, favorability — slot-filled templates.
class _WhatsHappening extends StatelessWidget {
  const _WhatsHappening({required this.day});

  final BiodynamicDay day;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    TextSpan bold(String text) => TextSpan(
      text: text,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );

    // The wording variant is the whole template: sidereal names a
    // constellation, tropical a sign (spec §11.6).
    final position = day.isConstellation
        ? t.moon.sheet.in_constellation
        : t.moon.sheet.in_sign;
    // Map completeness against ZodiacSign / BiodynamicElement is enforced by
    // i18n tests.
    final positionSpans = <InlineSpan>[
      position(
        sign: bold(t.moon.sign[day.sign.name]!),
        day: bold(t.moon.day_for[day.element.name]!),
      ),
    ];
    if ((day.transitionAt, day.secondaryElement) case (
      final transitionAt?,
      final secondary?,
    )) {
      // The Moon moves prograde through the zodiac, so the division after the
      // transition is always the next one in ecliptic order.
      final nextSign =
          ZodiacSign.values[(day.sign.index + 1) % ZodiacSign.values.length];
      positionSpans
        ..add(const TextSpan(text: ' '))
        ..add(
          t.moon.sheet.transition(
            time: bold(formatHm(transitionAt)),
            sign: bold(t.moon.sign[nextSign.name]!),
            day: bold(t.moon.day_for[secondary.name]!),
          ),
        );
    }

    final waxing = isWaxing(day.phase);

    return Container(
      key: kMoonWhatsHappeningKey,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            t.moon.sheet.whats_happening,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
          ),
          _InfoRow(
            leading: const Text('🌌', style: TextStyle(fontSize: 14)),
            span: TextSpan(children: positionSpans),
          ),
          _InfoRow(
            leading: MoonPhaseIcon(
              phase: day.phase,
              illumFraction: day.illumFraction,
              size: 15,
              color: theme.colorScheme.onSurface,
            ),
            span: waxing
                ? t.moon.sheet.phase_waxing(b: bold)
                : t.moon.sheet.phase_waning(b: bold),
          ),
          if (day.ascending case final ascending?)
            _InfoRow(
              leading: Text(
                ascending ? '↗' : '↘',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              span: ascending
                  ? t.moon.sheet.ascending(b: bold)
                  : t.moon.sheet.descending(b: bold),
            ),
          if (day.unfavorable case final unfavorable?)
            _InfoRow(
              leading: unfavorable
                  ? Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: theme.colorScheme.error,
                    )
                  : Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
              span: unfavorable
                  ? t.moon.sheet.unfavorable(b: bold)
                  : t.moon.sheet.favorable(b: bold),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.leading, required this.span});

  final Widget leading;
  final InlineSpan span;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 22, child: Center(child: leading)),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              span,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// One recommended-activity row: element avatar, activity text and the
/// "+ task" CTA into the prefilled task form.
class _RecommendedRow extends StatelessWidget {
  const _RecommendedRow({
    required this.leading,
    required this.text,
    required this.date,
    this.avatarColor,
  });

  final Widget leading;
  final String text;
  final DateTime date;
  final Color? avatarColor;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: avatarColor ?? theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(child: leading),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => context.pushNamed(
              'task-new',
              queryParameters: {'date': date.toIso8601String()},
            ),
            child: Text(t.moon.sheet.add_task),
          ),
        ],
      ),
    );
  }
}
