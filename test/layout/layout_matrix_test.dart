import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/app/router/main_shell.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/notifications/notification_settings.dart';
import 'package:tendask/core/notifications/reminder_audio.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/areas/presentation/areas_screen.dart';
import 'package:tendask/features/community/application/community_providers.dart';
import 'package:tendask/features/community/data/community_models.dart';
import 'package:tendask/features/suggestions/application/suggestion_providers.dart';
import 'package:tendask/features/suggestions/presentation/suggestion_band.dart';
import 'package:tendask/features/suggestions/presentation/suggestion_history_screen.dart';
import 'package:tendask/features/community/data/community_stats.dart';
import 'package:tendask/features/community/presentation/community_landing_screen.dart';
import 'package:tendask/features/community/presentation/community_task_screen.dart';
import 'package:tendask/features/community/presentation/widgets/community_home_section.dart';
import 'package:tendask/features/community/presentation/widgets/community_standing_list.dart';
import 'package:tendask/features/community/presentation/widgets/community_task_link_card.dart';
import 'package:tendask/features/journal/application/notes_providers.dart';
import 'package:tendask/features/journal/presentation/journal_screen.dart';
import 'package:tendask/features/journal/presentation/note_form_screen.dart';
import 'package:tendask/features/notifications/presentation/notification_settings_screen.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
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
import 'package:tendask/i18n/translations.g.dart';

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
  seasonal: true,
  defaultCadence: null,
);

Suggestion _suggestion(String id, String messageKey, String params) => Suggestion(
  id: id,
  userId: 'local',
  ruleId: 'R5',
  taskTypeId: 'prune',
  subjectKey: 'up:p1',
  userPlantId: 'p1',
  messageKey: messageKey,
  messageParams: params,
  score: 3,
  status: 'new',
  dismissScope: 'season',
  validUntil: DateTime(2026, 7, 1),
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
  deleted: false,
  syncStatus: 'synced',
);

/// A full band: the three cards it caps at, with the params that make the
/// sentences their longest (a named subject, a date, a low-supply nudge).
List<Override> _suggestionOverrides() {
  final rows = [
    // A real key: 'suggestions.season.window_open' never existed, so this card
    // rendered a bare fallback title and the matrix measured nothing (N26).
    _suggestion('s1', 'suggestions.vegetable.plant_out',
        '{"subject_label_key":"tomato","suggested_date":"2026-06-20",'
        '"window_end_date":"2026-07-15","frost_date":"2026-05-15",'
        '"dry_window":true,"dry_hours":30}'),
    _suggestion('s2', 'suggestions.cadence.overdue',
        '{"subject_label_raw":"Babičina vrtnica","days_overdue":21,"cadence_days":14,'
        '"suggested_date":"2026-06-20","low_supply":true,"supply_name":"Kompost"}'),
    _suggestion('s3', 'suggestions.community.most_started',
        '{"subject_label_key":"tomato","task_type_id":"prune","percent":70,"scope":"r6"}'),
  ];
  return [
    taskTypesMapProvider.overrideWith(
      (ref) => Stream.value({'prune': _seasonalTaskType()}),
    ),
    plantsMapProvider.overrideWith((ref) => Stream.value({'tomato': _plant()})),
    // Left live, these open real drift streams (and leave their timers behind).
    userPlantsMapProvider.overrideWith(
      (ref) => Stream.value(<String, UserPlant>{}),
    ),
    areasMapProvider.overrideWith((ref) => Stream.value(<String, Area>{})),
    activeSuggestionsProvider.overrideWith((ref) => Stream.value(rows)),
    suggestionHistoryProvider.overrideWith((ref) => Stream.value(rows)),
  ];
}

/// The detail template needs a seasonal act: a season curve for watering is a
/// state the engine cannot produce (§7.5), so a layout drawn from it would be
/// exercising a screen that never ships.
TaskType _seasonalTaskType() => TaskType(
  id: 'prune',
  labels: jsonEncode({'sl': 'Obrez', 'en': 'Pruning', 'de': 'Schnitt'}),
  icon: '✂️',
  category: 'care',
  requiresSubject: true,
  weatherSensitive: false,
  consumesSupplies: false,
  seasonal: true,
  defaultCadence: null,
);

Plant _plant() => Plant(
  id: 'tomato',
  labels: jsonEncode({'sl': 'Paradižnik', 'en': 'Tomato', 'de': 'Tomate'}),
  category: 'vegetable',
  icon: '🍅',
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
  taskIdsWithRemindersProvider.overrideWith(
    (ref) => Stream.value({_taskId}),
  ),
  allTaskSubjectsProvider.overrideWith((ref) => Stream.value([_subject()])),
  taskTypesMapProvider.overrideWith((ref) => Stream.value({'water': _taskType()})),
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
  userPlantsMapProvider.overrideWith((ref) => Stream.value(<String, UserPlant>{})),
  plantsMapProvider.overrideWith((ref) => Stream.value(<String, Plant>{})),
  plantsListProvider.overrideWith((ref) => Stream.value(<Plant>[])),
  suppliesListProvider.overrideWith((ref) => Stream.value(<Supply>[])),
  notesProvider.overrideWith((ref) => Stream.value(<Note>[])),
];

/// The community landing reads its aggregate slice through a provider, so the
/// matrix feeds it a resolved feed instead of a database.
List<Override> _communityOverrides({required bool hasPlus}) => [
  taskTypesMapProvider.overrideWith((ref) => Stream.value({'water': _taskType()})),
  plantsMapProvider.overrideWith(
    (ref) => Stream.value({'tomato': _plant()}),
  ),
  hasPlusProvider.overrideWithValue(hasPlus),
  communityReachedProvider.overrideWith((ref) async => true),
  communityFeedProvider.overrideWith(
    (ref) async => CommunityFeed(
      bucket: const Bucket(resolution: CommunityResolution.r6, key: 'cellB'),
      population: 40,
      // Stale on purpose: draws the "data from {date}" line in every locale.
      fetchedAt: DateTime(2026, 7, 24),
      items: const [
        CommunityFeedItem(
          taskTypeId: 'water',
          cohort: kCommunityCohortSite,
          distinctUsers7d: 20,
          intensity: CommunityIntensity.often,
        ),
        CommunityFeedItem(
          taskTypeId: 'water',
          cohort: 'tomato',
          distinctUsers7d: 4,
          intensity: CommunityIntensity.rare,
        ),
      ],
    ),
  ),
];

/// The detail template with everything present: curve + frequency + this week,
/// which is the widest the screen ever gets.
List<Override> _communityTaskOverrides({required bool hasPlus}) => [
  communityReachedProvider.overrideWith((ref) async => true),
  taskTypesMapProvider.overrideWith((ref) => Stream.value({'prune': _seasonalTaskType()})),
  plantsMapProvider.overrideWith((ref) => Stream.value({'tomato': _plant()})),
  hasPlusProvider.overrideWithValue(hasPlus),
  communitySeasonCurveProvider('prune', 'tomato').overrideWith(
    (ref) async => buildSeasonCurve(
      const [
        {'year': 2025, 'iso_week': 18, 'first_user_count': 12},
        {'year': 2025, 'iso_week': 20, 'first_user_count': 28},
        {'year': 2025, 'iso_week': 22, 'first_user_count': 10},
      ],
      bucket: const Bucket(resolution: CommunityResolution.r6, key: 'cellB'),
      currentYear: 2026,
    ),
  ),
  communityFrequencyProvider('prune', 'tomato').overrideWith(
    (ref) async => const FrequencyStats(
      bucket: Bucket(resolution: CommunityResolution.r6, key: 'cellB'),
      p25: 2,
      p50: 3,
      p75: 4,
      unit: 'per_season',
      nUsers: 40,
      hist: {'1': 4, '2': 9, '3': 12, '4': 7, '5+': 3},
    ),
  ),
  communityWeeklyProvider('prune', 'tomato').overrideWith(
    (ref) async => const CommunityWeekly(
      bucket: Bucket(resolution: CommunityResolution.r5, key: 'cellC'),
      distinctUsers7d: 9,
      intensity: CommunityIntensity.some,
    ),
  ),
  mySeasonProvider('prune', 'tomato').overrideWith(
    (ref) => Stream.value(MySeason(first: DateTime(2026, 5, 11), count: 3)),
  ),
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

  // ── community (Okolica) ────────────────────────────────────────────────────

  layoutMatrix(
    'community/landing',
    overrides: () => _communityOverrides(hasPlus: true),
    build: () => const CommunityLandingScreen(),
  );

  // Teased: the extra card pushes the tightest wording (German, text×1.3).
  layoutMatrix(
    'community/landing (tease)',
    overrides: () => _communityOverrides(hasPlus: false),
    build: () => const CommunityLandingScreen(),
  );

  layoutMatrix(
    'community/task',
    overrides: () => _communityTaskOverrides(hasPlus: true),
    build: () =>
        const CommunityTaskScreen(taskTypeId: 'prune', plantId: 'tomato'),
  );

  layoutMatrix(
    'community/task (tease)',
    overrides: () => _communityTaskOverrides(hasPlus: false),
    build: () =>
        const CommunityTaskScreen(taskTypeId: 'prune', plantId: 'tomato'),
  );

  // ---- smart suggestions (M11) ----
  // The band and the history list were outside the matrix entirely, and they
  // carry the longest generated sentences in the app: a rule message plus a
  // subject label plus a date, in German, at text×1.3.
  layoutMatrix(
    'suggestions/band',
    overrides: _suggestionOverrides,
    // The card's 400 ms highlight animation is still running when the
    // harness disposes the tree; settle it or every case fails on a timer.
    after: (tester) => tester.pumpAndSettle(),
    build: () => const _EntryHost(child: SuggestionBand()),
  );

  layoutMatrix(
    'suggestions/history',
    overrides: _suggestionOverrides,
    // The card's 400 ms highlight animation is still running when the
    // harness disposes the tree; settle it or every case fails on a timer.
    after: (tester) => tester.pumpAndSettle(),
    build: () => const SuggestionHistoryScreen(),
  );

  // The two entry points live inside other screens, so they get the host a
  // dashboard section gets: a padded scrolling column at the same width.
  layoutMatrix(
    'community/home entry',
    overrides: () => [
      ..._communityOverrides(hasPlus: true),
      userPlantsMapProvider.overrideWith(
        (ref) => Stream.value(<String, UserPlant>{}),
      ),
    ],
    build: () => const _EntryHost(child: CommunityHomeSection()),
  );

  layoutMatrix(
    'community/task entry',
    overrides: () => _communityTaskOverrides(hasPlus: true),
    build: () => const _EntryHost(
      child: CommunityTaskLinkCard(taskTypeId: 'prune', cohort: 'tomato'),
    ),
  );

  // The landing's second segment. Built directly: the matrix never taps, and
  // the list is what has to survive long German band words at text×1.3.
  layoutMatrix(
    'community/standing',
    overrides: () => [
      plantsMapProvider.overrideWith((ref) => Stream.value({'tomato': _plant()})),
    ],
    build: () => const _StandingHost(hasPlus: true),
  );

  layoutMatrix(
    'community/standing (tease)',
    overrides: () => [
      plantsMapProvider.overrideWith((ref) => Stream.value({'tomato': _plant()})),
    ],
    build: () => const _StandingHost(hasPlus: false),
  );

  // The bottom nav with Okolica on: five German words on a 320 dp bar at
  // text×1.3 is the tightest row in the app, and it is only reachable once
  // kCommunityEnabled flips.
  layoutMatrix('nav (five tabs)', build: () => const _NavBarHost());
}

/// Renders the real destinations, so a relabelled tab is caught here.
class _NavBarHost extends StatelessWidget {
  const _NavBarHost();

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      destinations: mainShellDestinations(context.t, community: true),
    ),
  );
}

class _StandingHost extends StatelessWidget {
  const _StandingHost({required this.hasPlus});

  final bool hasPlus;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CommunityStandingList(
      standings: const [
        CommunityStanding(
          taskTypeId: 'water',
          cohort: 'tomato',
          band: CommunityTiming.early,
          scope: CommunityResolution.r6,
        ),
        CommunityStanding(
          taskTypeId: 'water',
          cohort: kCommunityCohortSite,
          band: CommunityTiming.typical,
          scope: CommunityResolution.climate,
        ),
      ],
      catalog: {'water': _taskType()},
      plants: {'tomato': _plant()},
      hasPlus: hasPlus,
    ),
  );
}

class _EntryHost extends StatelessWidget {
  const _EntryHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [child],
    ),
  );
}
