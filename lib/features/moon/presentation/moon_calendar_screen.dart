import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/date_format.dart';
import '../../../i18n/translations.g.dart';
import '../application/garden_elements_provider.dart';
import '../application/moon_settings_controller.dart';
import 'moon_month_view.dart';
import 'moon_week_view.dart';

enum _MoonView { month, week }

/// The moon calendar (FR-19): segmented Month grid / Week agenda over one
/// shared anchor date, so switching views stays on the same period.
/// Reachable only with [kMoonCalendarEnabled] flipped on (route guard).
class MoonCalendarScreen extends ConsumerStatefulWidget {
  const MoonCalendarScreen({super.key});

  @override
  ConsumerState<MoonCalendarScreen> createState() =>
      _MoonCalendarScreenState();
}

class _MoonCalendarScreenState extends ConsumerState<MoonCalendarScreen> {
  _MoonView _view = _MoonView.month;

  /// Any day inside the visible period (month or week).
  late DateTime _anchor;

  @override
  void initState() {
    super.initState();
    _anchor = startOfDay(DateTime.now());
  }

  DateTime _weekStartOf(DateTime d) {
    final firstWeekday = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    // DateTime.weekday: Mon=1..Sun=7 → normalize to 0=Sun..6=Sat.
    final offset = (d.weekday % 7 - firstWeekday + 7) % 7;
    return DateTime(d.year, d.month, d.day - offset);
  }

  void _shiftMonth(int months) => setState(() {
        _anchor = DateTime(_anchor.year, _anchor.month + months);
      });

  void _shiftWeek(int weeks) => setState(() {
        _anchor =
            DateTime(_anchor.year, _anchor.month, _anchor.day + 7 * weeks);
      });

  void _switchView(_MoonView view) {
    final today = startOfDay(DateTime.now());
    final visiblePeriodHasToday = switch (_view) {
      _MoonView.month =>
        _anchor.year == today.year && _anchor.month == today.month,
      _MoonView.week => isSameDay(_weekStartOf(_anchor), _weekStartOf(today)),
    };
    setState(() {
      // Land on the current week/month when today is already in view —
      // the anchor may sit on another day of the period.
      if (visiblePeriodHasToday) _anchor = today;
      _view = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    final settings = ref.watch(moonSettingsControllerProvider).asData?.value;
    final starred = (settings?.highlightGarden ?? true)
        ? ref.watch(gardenElementsProvider)
        : const <BiodynamicElement>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(t.moon.calendar.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed('moon-settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SegmentedButton<_MoonView>(
              segments: [
                ButtonSegment(
                  value: _MoonView.month,
                  label: Text(t.moon.calendar.month_view),
                ),
                ButtonSegment(
                  value: _MoonView.week,
                  label: Text(t.moon.calendar.week_view),
                ),
              ],
              selected: {_view},
              showSelectedIcon: false,
              onSelectionChanged: (s) => _switchView(s.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ),
          Expanded(
            child: switch (_view) {
              _MoonView.month => MoonMonthView(
                  month: DateTime(_anchor.year, _anchor.month),
                  starred: starred,
                  onPrev: () => _shiftMonth(-1),
                  onNext: () => _shiftMonth(1),
                ),
              _MoonView.week => MoonWeekView(
                  weekStart: _weekStartOf(_anchor),
                  starred: starred,
                  onPrev: () => _shiftWeek(-1),
                  onNext: () => _shiftWeek(1),
                ),
            },
          ),
        ],
      ),
    );
  }
}
