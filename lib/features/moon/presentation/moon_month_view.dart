import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/moon_colors.dart';
import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/date_format.dart';
import '../../../core/month_cells.dart';
import '../../../core/widgets/month_chrome.dart';
import '../../../i18n/translations.g.dart';
import '../application/moon_month_provider.dart';
import 'moon_day_sheet.dart';
import 'widgets/element_badge.dart';
import 'widgets/moon_phase_icon.dart';

/// Month tab of the moon calendar (FR-19 T3.3): element-coloured grid with
/// phase-event markers, ★ garden highlight, ‹ › navigation and a legend.
class MoonMonthView extends ConsumerWidget {
  const MoonMonthView({
    super.key,
    required this.month,
    required this.starred,
    required this.onPrev,
    required this.onNext,
  });

  /// `DateTime(year, month)` key of the visible month.
  final DateTime month;

  /// Elements to mark with ★ (empty when the highlight is off).
  final Set<BiodynamicElement> starred;

  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ml = MaterialLocalizations.of(context);
    final days = ref.watch(moonMonthProvider(month));
    final cells = monthCells(month, ml.firstDayOfWeekIndex);
    final leading = cells.indexWhere((c) => c != null);
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        MonthNav(
          label: ml.formatMonthYear(month),
          onPrev: onPrev,
          onNext: onNext,
        ),
        const SizedBox(height: 8),
        WeekdayHeader(ml: ml),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            // Cells slightly taller than wide (wireframe 1/1.08).
            childAspectRatio: 1 / 1.08,
          ),
          itemCount: cells.length,
          itemBuilder: (context, i) {
            final inMonth = cells[i] != null;
            final date =
                cells[i] ?? DateTime(month.year, month.month, i - leading + 1);
            final day = days[date];
            if (day == null) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => showMoonDaySheet(context, date),
              child: _MoonDayCell(
                day: day,
                inMonth: inMonth,
                isToday: isSameDay(date, now),
                starred: inMonth && starred.contains(day.element),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        const _MoonLegend(),
      ],
    );
  }
}

/// One grid cell: day number (+★), phase-event marker, element emoji + short
/// label on the element's soft tone. A transition day splits its background
/// top (before) / bottom (after); the label follows the day-label convention.
class _MoonDayCell extends StatelessWidget {
  const _MoonDayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.starred,
  });

  final MoonMonthDay day;
  final bool inMonth;
  final bool isToday;
  final bool starred;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final moon = MoonColors.of(context);

    final soft = moon.softOf(day.element);
    final secondary = day.secondaryElement;
    final phase = day.principalPhase;

    final cell = Container(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      decoration: BoxDecoration(
        // Transition day: hard-split background, before on top, after below
        // (time flows down the cell).
        color: secondary == null ? soft : null,
        gradient: secondary == null
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  soft,
                  soft,
                  moon.softOf(secondary),
                  moon.softOf(secondary),
                ],
                stops: const [0, 0.5, 0.5, 1],
              ),
        borderRadius: BorderRadius.circular(9),
        border: isToday
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scale down rather than overflow: at the 320 px viewport a
              // two-digit number + ★ + phase icon exceed the ~29 px cell.
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${day.date.day}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (starred)
                          Text(
                            ' ★',
                            style: TextStyle(
                              fontSize: 9,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (phase != null)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: MoonPhaseIcon(
                    phase: phase,
                    illumFraction: principalIllumFraction(phase),
                    size: 11,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  elementEmoji(day.element),
                  style: const TextStyle(fontSize: 14, height: 1),
                ),
              ),
            ),
          ),
          if (inMonth)
            Center(
              // Scale down instead of clipping: large font scale pushes even
              // the abbreviated labels past the cell width.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  // Map completeness against BiodynamicElement is enforced by
                  // i18n tests.
                  t.moon.element_short[day.element.name]!.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return inMonth ? cell : Opacity(opacity: 0.4, child: cell);
  }
}

/// Legend under the grid: element tones, principal-phase markers and the ★
/// garden highlight.
class _MoonLegend extends StatelessWidget {
  const _MoonLegend();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final moon = MoonColors.of(context);

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    Widget item(Widget glyph, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        glyph,
        const SizedBox(width: 5),
        Text(label, style: labelStyle),
      ],
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final element in BiodynamicElement.values)
          item(
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: moon.strongOf(element),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Map completeness against BiodynamicElement is enforced by i18n
            // tests.
            t.moon.element[element.name]!,
          ),
        for (final phase in const [
          MoonPhase.newMoon,
          MoonPhase.firstQuarter,
          MoonPhase.fullMoon,
          MoonPhase.lastQuarter,
        ])
          item(
            MoonPhaseIcon(
              phase: phase,
              illumFraction: principalIllumFraction(phase),
              size: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            // Map completeness against MoonPhase is enforced by i18n tests.
            t.moon.phase[phase.name]!,
          ),
        item(
          Text(
            '★',
            style: TextStyle(fontSize: 11, color: theme.colorScheme.secondary),
          ),
          t.moon.calendar.legend_star,
        ),
      ],
    );
  }
}
