import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../i18n/translations.g.dart';
import '../../areas/application/areas_providers.dart';
import '../../plants/application/plants_providers.dart';
import '../../settings/application/profile_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/presentation/subject_labels.dart';
import 'reminder_schedule.dart';

part 'reminder_coordinator.g.dart';

/// Keeps OS-scheduled reminders in sync with the `task_reminder` rows. Reconciles
/// once at startup and on every (debounced) write to task/task_reminder. Lives
/// for the whole app session; call `start()` after the bootstrap (M8.2).
@Riverpod(keepAlive: true)
class ReminderCoordinator extends _$ReminderCoordinator {
  static const Clock _clock = SystemClock();
  Timer? _debounce;
  bool _running = false;
  bool _dirty = false;

  @override
  void build() {
    final db = ref.watch(databaseProvider);

    // Keep the label sources alive for our whole lifetime. They are autoDispose,
    // so without a listener `ref.read(.future)` in _reconcile would dispose them
    // mid-load (when no screen watches them, e.g. app backgrounded) and throw —
    // aborting the reschedule. listen (not watch) keeps them alive without
    // rebuilding us; their changes are cosmetic so the empty callback is fine.
    ref.listen(taskTypesMapProvider, (_, _) {});
    ref.listen(areasMapProvider, (_, _) {});
    ref.listen(userPlantsMapProvider, (_, _) {});
    ref.listen(plantsMapProvider, (_, _) {});

    final sub = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            db.tasks,
            db.taskReminders,
            db.profiles,
          ]),
        )
        .listen((_) {
          _debounce?.cancel();
          _debounce = Timer(kReminderDebounce, () => unawaited(_reconcile()));
        });

    ref.onDispose(() {
      _debounce?.cancel();
      sub.cancel();
    });
  }

  /// Runs the first reconcile. Call once after the bootstrap.
  void start() => unawaited(_reconcile());

  /// Cancels stale OS notifications and (re)schedules every future reminder of a
  /// waiting task. Idempotent: rescheduling reuses the reminder's stable id.
  Future<void> _reconcile() async {
    if (_running) {
      _dirty = true;
      return;
    }
    _running = true;
    try {
      final notif = ref.read(notificationServiceProvider);
      final repo = ref.read(tasksRepositoryProvider);

      // Master switch off: cancel everything we scheduled, schedule nothing —
      // but never the journal nudge (FR-16), which has its own switch and owner.
      final userId = ref.read(authServiceProvider).userId;
      final settings = await ref
          .read(profileRepositoryProvider)
          .notificationSettings(userId);
      if (!settings.taskRemindersEnabled) {
        final ours = (await notif.pendingIds()).difference(
          kJournalNudgeNotificationIds.toSet(),
        );
        for (final id in ours) {
          await notif.cancel(id);
        }
        return;
      }

      final types = await ref.read(taskTypesMapProvider.future);
      final areas = await ref.read(areasMapProvider.future);
      final userPlants = await ref.read(userPlantsMapProvider.future);
      final plants = await ref.read(plantsMapProvider.future);
      final nowLocal = _clock.now().toLocal();

      final desired = <int>{};
      for (final task in await repo.pendingTasks()) {
        final reminders = await repo.remindersForTask(task.id);
        if (reminders.isEmpty) continue;
        final taskDateLocal = task.date.toLocal();
        final title = _title(task, types);
        final body = _body(
          task,
          await repo.subjectsForTask(task.id),
          areas: areas,
          userPlants: userPlants,
          plants: plants,
          nowLocal: nowLocal,
        );
        for (final r in reminders) {
          final fire = reminderFireTime(
            taskDateLocal: taskDateLocal,
            offsetMinutes: r.offset,
            reminderTime: r.reminderTime,
          );
          if (!fire.isAfter(nowLocal)) continue;
          final id = reminderNotificationId(r.id);
          await notif.scheduleAt(
            id: id,
            when: fire,
            title: title,
            body: body,
            payload: task.id,
          );
          desired.add(id);
        }
      }

      // Drop reminders that no longer exist / moved to the past (only pending,
      // never already-delivered notifications). The journal nudge (FR-16) lives
      // in the same OS queue but is owned by its own coordinator — never cancel
      // its reserved ids here.
      final orphans = (await notif.pendingIds())
          .difference(desired)
          .difference(kJournalNudgeNotificationIds.toSet());
      for (final id in orphans) {
        await notif.cancel(id);
      }
    } catch (e) {
      debugPrint('reminder reconcile failed: $e');
    } finally {
      _running = false;
      if (_dirty) {
        _dirty = false;
        unawaited(_reconcile());
      }
    }
  }

  String _title(Task task, Map<String, TaskType> types) {
    final type = types[task.taskTypeId];
    if (type == null) return '🔔';
    final label = catalogLabel(type.labels);
    return type.icon.isNotEmpty ? '${type.icon} $label' : label;
  }

  String _body(
    Task task,
    List<TaskSubject> subjects, {
    required Map<String, Area> areas,
    required Map<String, UserPlant> userPlants,
    required Map<String, Plant> plants,
    required DateTime nowLocal,
  }) {
    final names = [
      for (final s in subjects)
        subjectLabel(s, areas: areas, userPlants: userPlants, plants: plants),
    ].where((l) => l.isNotEmpty).join(', ');
    final date = _dateLabel(task.date.toLocal(), nowLocal);
    return names.isEmpty ? date : '$names · $date';
  }

  String _dateLabel(DateTime dateLocal, DateTime nowLocal) {
    final day = startOfDay(dateLocal);
    final today = startOfDay(nowLocal);
    if (day == today) return t.notifications.today;
    if (day == today.add(const Duration(days: 1))) {
      return t.notifications.tomorrow;
    }
    return formatDmy(dateLocal);
  }
}
