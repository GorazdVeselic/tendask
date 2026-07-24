import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/area_type.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/notifications/notification_settings.dart';
import 'package:tendask/core/notifications/reminder_audio.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/areas/presentation/areas_screen.dart';
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
}
