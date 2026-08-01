import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/moon_colors.dart';
import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/date_format.dart';
import '../../../core/month_cells.dart';
import '../../../core/widgets/month_chrome.dart';
import '../../../i18n/translations.g.dart';
import '../application/garden_elements_provider.dart';
import '../application/moon_month_provider.dart';
import '../application/moon_settings_controller.dart';
import 'widgets/element_badge.dart';
import 'widgets/moon_phase_icon.dart';

/// Canonical illuminated fraction for a principal-phase marker — the event
/// glyph should be a crisp new/quarter/full disc, not the midday sample.
double _principalIllum(MoonPhase phase) => switch (phase) {
      MoonPhase.newMoon => 0.0,
      MoonPhase.firstQuarter || MoonPhase.lastQuarter => 0.5,
      _ => 1.0,
    };

/// Month view of the moon calendar (FR-19 T3.3): element-coloured grid with
/// phase-event markers, ★ garden highlight, ‹ › navigation and a legend.
/// Reachable only with [kMoonCalendarEnabled] flipped on (route guard).
class MoonCalendarScreen extends ConsumerStatefulWidget {
  const MoonCalendarScreen({super.key});

  @override
  ConsumerState<MoonCalendarScreen> createState() =>
      _MoonCalendarScreenState();
}

class _MoonCalendarScreenState extends ConsumerState<MoonCalendarScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _shift(int months) => setState(() {
        _visibleMonth = DateTime(
          _visibleMonth.year,
          _visibleMonth.month + months,
        );
      });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ml = MaterialLocalizations.of(context);

    final days = ref.watch(moonMonthProvider(_visibleMonth));
    final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
    final starred = (settings?.highlightGarden ?? true)
        ? ref.watch(gardenElementsProvider)
        : const <BiodynamicElement>{};

    final cells = monthCells(_visibleMonth, ml.firstDayOfWeekIndex);
    final leading = cells.indexWhere((c) => c != null);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(t.moon.calendar.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          MonthNav(
            label: ml.formatMonthYear(_visibleMonth),
            onPrev: () => _shift(-1),
            onNext: () => _shift(1),
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
              final date = cells[i] ??
                  DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month,
                    i - leading + 1,
                  );
              final day = days[date];
              if (day == null) return const SizedBox.shrink();
              return _MoonDayCell(
                day: day,
                inMonth: inMonth,
                isToday: isSameDay(date, now),
                starred: inMonth && starred.contains(day.element),
              );
            },
          ),
          const SizedBox(height: 14),
          const _MoonLegend(),
        ],
      ),
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
    // Fallback covers bare ThemeData in tests; app themes always register it.
    final moon = theme.extension<MoonColors>() ?? moonColorsLight;

    final soft = _softOf(moon, day.element);
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
                colors: [soft, soft, _softOf(moon, secondary),
                    _softOf(moon, secondary)],
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
              const Spacer(),
              if (phase != null)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: MoonPhaseIcon(
                    phase: phase,
                    illumFraction: _principalIllum(phase),
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
              child: Text(
                // Map completeness against BiodynamicElement is enforced by
                // i18n tests.
                t.moon.element_short[day.element.name]!.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );

    return inMonth ? cell : Opacity(opacity: 0.4, child: cell);
  }
}

Color _softOf(MoonColors moon, BiodynamicElement element) =>
    switch (element) {
      BiodynamicElement.fruit => moon.fruitSoft,
      BiodynamicElement.root => moon.rootSoft,
      BiodynamicElement.flower => moon.flowerSoft,
      BiodynamicElement.leaf => moon.leafSoft,
    };

Color _strongOf(MoonColors moon, BiodynamicElement element) =>
    switch (element) {
      BiodynamicElement.fruit => moon.fruit,
      BiodynamicElement.root => moon.root,
      BiodynamicElement.flower => moon.flower,
      BiodynamicElement.leaf => moon.leaf,
    };

/// Legend under the grid: element tones, principal-phase markers and the ★
/// garden highlight.
class _MoonLegend extends StatelessWidget {
  const _MoonLegend();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    // Fallback covers bare ThemeData in tests; app themes always register it.
    final moon = theme.extension<MoonColors>() ?? moonColorsLight;

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
                color: _strongOf(moon, element),
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
              illumFraction: _principalIllum(phase),
              size: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            // Map completeness against MoonPhase is enforced by i18n tests.
            t.moon.phase[phase.name]!,
          ),
        item(
          Text(
            '★',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.secondary,
            ),
          ),
          t.moon.calendar.legend_star,
        ),
      ],
    );
  }
}
