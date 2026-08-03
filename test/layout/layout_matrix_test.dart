import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/core/notifications/notification_settings.dart';
import 'package:tendask/core/notifications/reminder_audio.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/areas/presentation/areas_screen.dart';
import 'package:tendask/features/auth/presentation/location_screen.dart';
import 'package:tendask/core/biodynamic/biodynamic_day.dart';
import 'package:tendask/core/biodynamic/calendar_system.dart';
import 'package:tendask/core/biodynamic/moon_calendar.dart';
import 'package:tendask/core/month_cells.dart';
import 'package:tendask/core/widgets/sheet_handle.dart';
import 'package:tendask/features/journal/application/notes_providers.dart';
import 'package:tendask/features/home/presentation/widgets/home_moon_chip.dart';
import 'package:tendask/features/journal/presentation/journal_screen.dart';
import 'package:tendask/features/journal/presentation/widgets/day_cell.dart';
import 'package:tendask/features/moon/application/garden_elements_provider.dart';
import 'package:tendask/features/moon/application/moon_month_provider.dart';
import 'package:tendask/features/moon/presentation/moon_calendar_screen.dart';
import 'package:tendask/features/moon/presentation/moon_day_sheet.dart';
import 'package:tendask/features/moon/presentation/moon_finder_screen.dart';
import 'package:tendask/features/moon/presentation/moon_settings_screen.dart';
import 'package:tendask/features/moon/presentation/moon_week_view.dart';
import 'package:tendask/features/moon/presentation/widgets/moon_day_badge.dart';
import 'package:tendask/features/moon/presentation/widgets/moon_task_section.dart';
import 'package:tendask/features/moon/presentation/widgets/plant_moon_chip.dart';
import 'package:tendask/features/journal/presentation/note_form_screen.dart';
import 'package:tendask/features/notifications/presentation/notification_settings_screen.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/plus/application/plus_provider.dart';
import 'package:tendask/features/plus/application/plus_token.dart';
import 'package:tendask/features/plus/presentation/tendask_plus_screen.dart';
import 'package:tendask/features/plus/presentation/widgets/plus_settings_card.dart';
import 'package:tendask/features/settings/application/profile_providers.dart';
import 'package:tendask/features/settings/presentation/appearance_screen.dart';
import 'package:tendask/features/settings/presentation/settings_screen.dart';
import 'package:tendask/features/supplies/application/supplies_providers.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/features/tasks/data/recurrence.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/reminder_step.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/review_step.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/when_step.dart';
import 'package:tendask/features/tasks/presentation/task_detail_screen.dart';
import 'package:tendask/features/tasks/presentation/tasks_screen.dart';
import 'package:tendask/features/tasks/task_specs.dart';
import 'package:tendask/features/weather/presentation/weather_no_location_card.dart';
import 'package:tendask/i18n/translations.g.dart';

import '../core/location/fake_location_repository.dart';
import 'layout_harness.dart';

// ─── fixtures ─────────────────────────────────────────────────────────────────
//
// Ordinary garden data, not adversarial: a real user's watering task on a bed.
// If the layout breaks on this, it breaks in the field.

const _taskId = 'task-1';
const _areaId = 'area-1';
final _date = DateTime(2026, 7, 14, 8);

TaskType _taskType() => TaskType(
  id: 'water',
  labels: jsonEncode({'sl': 'Zalivanje', 'en': 'Watering', 'de': 'Gießen'}),
  icon: '💧',
  category: 'water',
  requiresSubject: true,
  weatherSensitive: true,
  consumesSupplies: false,
  defaultCadence: null,
);

Area _area() => Area(
  id: _areaId,
  userId: 'u1',
  name: 'Zelenjavni vrt',
  type: AreaType.bed,
  protected: false,
  updatedAt: _date,
  deleted: false,
  syncStatus: 'synced',
);

Task _task({TaskStatus status = TaskStatus.waiting}) => Task(
  id: _taskId,
  userId: 'u1',
  taskTypeId: 'water',
  date: _date,
  status: status,
  note: null,
  weather: null,
  recurrence: null,
  seriesId: null,
  yieldAmount: null,
  yieldUnit: null,
  updatedAt: _date,
  deleted: false,
  syncStatus: 'synced',
);

TaskSubject _subject() => TaskSubject(
  id: 'sub-1',
  taskId: _taskId,
  userPlantId: null,
  areaId: _areaId,
  updatedAt: _date,
  deleted: false,
  syncStatus: 'synced',
);

/// The provider stubs every task-shaped screen needs. No database, no router:
/// streams are one-shot values, so the tree settles immediately.
List<Override> _taskWorldOverrides() => [
  pendingTasksProvider.overrideWith((ref) => Stream.value([_task()])),
  completedTasksProvider.overrideWith(
    (ref) => Stream.value([_task(status: TaskStatus.done)]),
  ),
  allTasksProvider.overrideWith((ref) => Stream.value([_task()])),
  taskIdsWithRemindersProvider.overrideWith((ref) => Stream.value({_taskId})),
  allTaskSubjectsProvider.overrideWith((ref) => Stream.value([_subject()])),
  taskTypesMapProvider.overrideWith(
    (ref) => Stream.value({'water': _taskType()}),
  ),
  taskTypeCategoriesProvider.overrideWith(
    (ref) => Stream.value({
      'water': {'water'},
    }),
  ),
  areasMapProvider.overrideWith((ref) => Stream.value({_areaId: _area()})),
  areasListProvider.overrideWith((ref) => Stream.value([_area()])),
  latestTaskPerAreaProvider.overrideWith(
    (ref) => Stream.value({_areaId: _task()}),
  ),
  userPlantsMapProvider.overrideWith(
    (ref) => Stream.value(<String, UserPlant>{}),
  ),
  plantsMapProvider.overrideWith((ref) => Stream.value(<String, Plant>{})),
  plantsListProvider.overrideWith((ref) => Stream.value(<Plant>[])),
  suppliesListProvider.overrideWith((ref) => Stream.value(<Supply>[])),
  notesProvider.overrideWith((ref) => Stream.value(<Note>[])),
  // Unset, which is the wordiest state for every task-shaped screen that reads
  // it (the detail's weather hint, the review step's note). Overridden rather
  // than faked at the repository, because the real provider derives the centroid
  // through the native H3 library, whose FFI cannot load here.
  gardenLocationProvider.overrideWith((ref) => Stream.value(null)),
];

/// Screens that persist (settings, appearance, note form) read through the
/// database; an in-memory one keeps them off the real file.
List<Override> _dbOverrides() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return [databaseProvider.overrideWithValue(db)];
}

void main() {
  // ── task entry wizard ──────────────────────────────────────────────────────

  layoutMatrix(
    'entry/when',
    build: () => WhenStepBody(
      date: _date,
      status: TaskStatus.waiting,
      recurrence: null,
      onSetDate: (_) {},
      onSetStatus: (_) {},
      onSetRecurrence: (_, _) {},
    ),
  );

  layoutMatrix(
    'entry/when (custom recurrence)',
    build: () => WhenStepBody(
      date: _date,
      status: TaskStatus.waiting,
      recurrence: const Recurrence(everyDays: 3),
      onSetDate: (_) {},
      onSetStatus: (_) {},
      onSetRecurrence: (_, _) {},
    ),
  );

  layoutMatrix(
    'entry/reminder',
    overrides: _taskWorldOverrides,
    build: () => ReminderStepBody(
      reminders: const [ReminderSpec(offsetMinutes: 60)],
      taskDate: _date,
      seededDefault: true,
      onAdd: (_) {},
      onRemove: (_) {},
    ),
  );

  layoutMatrix(
    'entry/review',
    overrides: _taskWorldOverrides,
    build: () => ReviewStepBody(
      taskTypeId: 'water',
      subjects: const [TaskSubjectSpec.area(_areaId)],
      date: _date,
      status: TaskStatus.waiting,
      recurrence: const Recurrence(everyDays: 7),
      reminders: const [ReminderSpec(offsetMinutes: 60)],
      supplies: const [],
      noteController: TextEditingController(),
      consumesSupplies: false,
      onFix: (_) {},
      showYield: false,
      yieldAmount: null,
      yieldUnit: null,
      onEditYield: () {},
    ),
  );

  // ── task list and detail ───────────────────────────────────────────────────

  layoutMatrix(
    'tasks',
    overrides: _taskWorldOverrides,
    build: () => const TasksScreen(),
  );

  layoutMatrix(
    'task-detail',
    overrides: () => [
      ..._taskWorldOverrides(),
      taskByIdProvider(_taskId).overrideWith((ref) => Stream.value(_task())),
      taskSubjectsForTaskProvider(
        _taskId,
      ).overrideWith((ref) => Stream.value([_subject()])),
      remindersForTaskProvider(
        _taskId,
      ).overrideWith((ref) => Stream.value(<TaskReminder>[])),
      taskSuppliesProvider(
        _taskId,
      ).overrideWith((ref) => Stream.value(<TaskSupply>[])),
    ],
    build: () => const TaskDetailScreen(id: _taskId),
  );

  // ── journal ────────────────────────────────────────────────────────────────

  layoutMatrix(
    'journal/timeline',
    overrides: _taskWorldOverrides,
    build: () => const JournalScreen(),
  );

  layoutMatrix(
    'journal/month',
    overrides: _taskWorldOverrides,
    build: () => const JournalScreen(),
    after: (tester) async {
      await tester.tap(find.text(t.journal.month_view));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    },
  );

  // ── garden, settings, notifications, appearance, notes ─────────────────────

  layoutMatrix(
    'areas',
    overrides: _taskWorldOverrides,
    build: () => const AreasScreen(),
  );

  layoutMatrix(
    'settings',
    overrides: _dbOverrides,
    build: () => const SettingsScreen(),
  );

  layoutMatrix(
    'notifications',
    overrides: () => [
      ..._dbOverrides(),
      notificationSettingsProvider.overrideWith(
        (ref) => Stream.value(const NotificationSettings()),
      ),
      reminderAudioProvider.overrideWith(
        (ref) => Stream.value(ReminderAudio.audible),
      ),
    ],
    build: () => const NotificationSettingsScreen(),
  );

  layoutMatrix(
    'appearance',
    overrides: _dbOverrides,
    build: () => const AppearanceScreen(),
  );

  layoutMatrix(
    'note-form',
    overrides: () => [..._dbOverrides(), ..._taskWorldOverrides()],
    build: () => const NoteFormScreen(),
  );

  // ── onboarding location ────────────────────────────────────────────────────
  //
  // Both states, because they do not render the same thing: unset puts the
  // emphasis on the GPS card and labels the bottom button "skip", set flips
  // both and adds the resolved place name to the status banner.

  layoutMatrix(
    'location (unset)',
    overrides: () => locationOverrides(FakeLocationRepository()),
    build: () => const LocationScreen(),
  );

  layoutMatrix(
    'location (set)',
    overrides: () => locationOverrides(
      FakeLocationRepository(cell: FakeLocationRepository.savedCell),
      placeLabel: 'Šentjur',
    ),
    build: () => const LocationScreen(),
    // The place name arrives a microtask after the banner first asks for it and
    // then cross-fades in; without this frame the widest banner is never
    // measured.
    after: (tester) => tester.pump(const Duration(milliseconds: 400)),
  );

  // The invite that replaces the weather card without a location (FR-22). The
  // card, not HomeScreen: it is a pure widget precisely so the matrix can reach
  // it without the dashboard's whole provider world.
  layoutMatrix(
    'weather/no-location',
    build: () => WeatherNoLocationCard(onSetLocation: () {}),
  );

  // ── moon calendar (FR-19) ──────────────────────────────────────────────────
  //
  // Pure functions of the date, so no task-world providers — just the database
  // (settings) and a non-empty garden so the ★ markers render too.

  List<Override> moonOverrides() => [
    ..._dbOverrides(),
    gardenElementsProvider.overrideWithValue(
      const {BiodynamicElement.fruit, BiodynamicElement.leaf},
    ),
  ];

  layoutMatrix(
    'moon/month',
    overrides: moonOverrides,
    build: () => const MoonCalendarScreen(),
  );

  layoutMatrix(
    'moon/week',
    overrides: moonOverrides,
    build: () => const MoonCalendarScreen(),
    after: (tester) async {
      await tester.tap(find.text(t.moon.calendar.week_view));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // Guard against silently measuring the month again when the tap missed.
      expect(find.byType(MoonWeekView), findsOneWidget);
    },
  );

  layoutMatrix(
    'moon/day-sheet',
    overrides: moonOverrides,
    build: () => const MoonCalendarScreen(),
    after: (tester) async {
      // Mid-month day: always in the current month and unique in the grid.
      await tester.ensureVisible(find.text('15'));
      await tester.tap(find.text('15'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // Guard against silently measuring the calendar when the tap missed.
      expect(find.byType(SheetHandle), findsOneWidget);
    },
  );

  // The 🔔 row watches the profile through a drift stream. Cancelling that
  // stream when the harness-owned ProviderScope unmounts leaves drift's cleanup
  // timer pending (and then blocks db.close()), so feed the row a plain value —
  // layout only needs the switch's text, same reasoning as gardenLocation above.
  layoutMatrix(
    'moon-settings',
    overrides: () => [
      ..._dbOverrides(),
      notificationSettingsProvider.overrideWith(
        (ref) => Stream.value(const NotificationSettings()),
      ),
      plusProvider.overrideWith(
        (ref) => Stream.value(PlusStatus.active(until: DateTime.utc(2027))),
      ),
    ],
    build: () => const MoonSettingsScreen(),
  );

  // Without a licence the same screen is a disabled showroom (B3): identical
  // rows, but every one of them wears the default value, so German lands on
  // different strings than the licensed run above.
  layoutMatrix(
    'moon-settings (free)',
    overrides: () => [
      ..._dbOverrides(),
      notificationSettingsProvider.overrideWith(
        (ref) => Stream.value(const NotificationSettings()),
      ),
      plusProvider.overrideWith((ref) => Stream.value(const PlusStatus.none())),
    ],
    build: () => const MoonSettingsScreen(),
  );

  // The card, not the HomeMoonChip gate: the gate is const-false until T7, so
  // only the card can be measured (same pattern as weather/no-location). Both
  // CTAs are measured — the locked pill is a different width from the element
  // day, and it is the one German squeezes hardest.
  layoutMatrix(
    'home/moon-chip',
    overrides: _dbOverrides,
    build: () => const HomeMoonChipCard(isPlus: true),
  );

  layoutMatrix(
    'home/moon-chip (locked)',
    overrides: _dbOverrides,
    build: () => const HomeMoonChipCard(isPlus: false),
  );

  // The finder with a plant already chosen — the wordiest state (callout plus
  // the list of stretches). The catalog comes as a plain value, not the drift
  // stream, for the same reason the 🔔 row does above.
  layoutMatrix(
    'moon/finder',
    overrides: () => [
      ..._dbOverrides(),
      plantsMapProvider.overrideWith((ref) => Stream.value({'tomato': _plant()})),
    ],
    build: () => const MoonFinderScreen(initialPlantId: 'tomato'),
  );

  // The chip button, not the gate (const-false until T7), inside the hero's
  // chip row: on its own it would never be squeezed.
  layoutMatrix(
    'plant/moon-chip',
    build: () => const _PlantChipRow(),
  );

  // The sheet's wordiest days, which the tap-on-'15' entry above can never
  // reach: a transition day (hero tail + "at HH:MM it turns" line) and the new
  // moon (its own copy plus the unfavorable eclipse warning).
  layoutMatrix(
    'moon/day-sheet (transition)',
    overrides: moonOverrides,
    build: () => _SheetOpener(date: _moonTransitionDate()),
    after: _openSheet,
  );

  layoutMatrix(
    'moon/day-sheet (new moon)',
    overrides: moonOverrides,
    build: () => _SheetOpener(date: _kNewMoonDate),
    after: _openSheet,
  );

  // A transition day is the row's longest text ("… day · until 14:20").
  layoutMatrix(
    'entry/when-badge',
    overrides: _dbOverrides,
    build: () => MoonDayBadgeRow(date: _moonTransitionDate()),
  );

  layoutMatrix(
    'task/moon-section',
    overrides: _dbOverrides,
    build: () => MoonTaskSectionCard(date: _moonTransitionDate()),
  );

  // The journal grid with the moon layer on (T4.4). Through the public core
  // (DayCell + moonDay), not JournalScreen: the flag gate is const-false until
  // T7. August 2026 carries phase markers on two-digit days — the row's worst
  // case at 320 px.
  layoutMatrix(
    'journal/moon-layer',
    overrides: _taskWorldOverrides,
    build: () => const _JournalMoonGrid(),
  );

  // The Tendask+ screen through its public body (the route is flag-guarded).
  // Both states, because they differ where it matters: the active one is a
  // tinted icon+text row, the inactive one adds the tagline above the list.
  layoutMatrix(
    'plus/screen (active)',
    build: () => PlusScreenBody(
      status: PlusStatus.active(
        until: DateTime.utc(2027, 8, 12),
        kind: 'granted',
      ),
    ),
  );

  layoutMatrix(
    'plus/screen (inactive)',
    build: () => const PlusScreenBody(status: PlusStatus.none()),
  );

  // The Settings entry card, not its gate (const-false until T7).
  layoutMatrix(
    'settings/plus-card',
    build: () => const PlusEntryCard(),
  );
}

/// New moon of August 2026 — also a solar eclipse, so the sheet carries the
/// unfavorable warning on top of the new-moon copy (fixture T1.10).
final _kNewMoonDate = DateTime(2026, 8, 12);

/// Opens the day sheet of a fixed date, which the calendar itself cannot do
/// (it only ever shows the current month).
class _SheetOpener extends StatelessWidget {
  const _SheetOpener({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => showMoonDaySheet(context, date),
      child: const Text('OPEN'),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('OPEN'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  // Guard against measuring the empty opener when the tap missed.
  expect(find.byType(SheetHandle), findsOneWidget);
}

/// The plant-detail hero row (avatar, name, chip row) with the moon chip next
/// to the area chip — placement A, decided 2026-08-02.
class _PlantChipRow extends StatelessWidget {
  const _PlantChipRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: const Text('🍅', style: TextStyle(fontSize: 26)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'paradižnik',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Solanum lycopersicum',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ActionChip(
                    avatar: Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text('${_area().name} · ${t.plant_detail.move}'),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                  const PlantMoonChipButton(plantId: 'tomato'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A fruit-day plant for the finder: the catalog entry the screen resolves
/// `?plant=tomato` to.
Plant _plant() => Plant(
  id: 'tomato',
  labels: jsonEncode({'sl': 'paradižnik', 'en': 'tomato', 'de': 'Tomate'}),
  scientificName: 'Solanum lycopersicum',
  category: 'vegetable',
  icon: '🍅',
);

/// The journal month grid of August 2026 with the moon layer applied.
class _JournalMoonGrid extends StatelessWidget {
  const _JournalMoonGrid();

  @override
  Widget build(BuildContext context) {
    final ml = MaterialLocalizations.of(context);
    final month = DateTime(2026, 8);
    final cells = monthCells(month, ml.firstDayOfWeekIndex);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: cells.length,
          itemBuilder: (context, i) {
            final day = cells[i];
            if (day == null) return const SizedBox.shrink();
            return DayCell(
              day: day,
              count: day.day % 3,
              isToday: day.day == 12,
              selected: day.day == 28,
              onTap: () {},
              moonDay: moonMonthDayFor(day, CalendarSystem.sidereal),
            );
          },
        ),
      ],
    );
  }
}

/// First August 2026 day with an element transition (sidereal).
DateTime _moonTransitionDate() {
  for (var d = 2; d < 26; d++) {
    final date = DateTime(2026, 8, d);
    if (dayFor(date, CalendarSystem.sidereal).transitionAt != null) return date;
  }
  throw StateError('no transition day in Aug 2026');
}
