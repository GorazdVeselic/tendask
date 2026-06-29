import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../i18n/translations.g.dart';
import '../../settings/application/profile_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import '../../tasks/data/tasks_repository.dart';
import 'journal_nudge_schedule.dart';
import 'reminder_schedule.dart';

part 'journal_nudge_coordinator.g.dart';

/// Keeps the local re-engagement journal nudge (FR-16) armed. Reschedules the
/// decaying chain once at startup, on every (debounced) task/note/profile write,
/// and on app resume — every such "touch" pushes the nudge forward, so an active
/// user never sees it. Lives for the whole session; call [start] after bootstrap.
@Riverpod(keepAlive: true)
class JournalNudgeCoordinator extends _$JournalNudgeCoordinator {
  static const Clock _clock = SystemClock();
  Timer? _debounce;
  bool _running = false;
  bool _dirty = false;

  @override
  void build() {
    final db = ref.watch(databaseProvider);

    // Any activity (a task or note write) or an opt-out (profile) re-arms the
    // nudge, pushing it forward. Debounced to coalesce rapid edits.
    final sub = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([db.tasks, db.notes, db.profiles]),
        )
        .listen((_) {
          _debounce?.cancel();
          _debounce = Timer(kReminderDebounce, () => unawaited(_reschedule()));
        });

    ref.onDispose(() {
      _debounce?.cancel();
      sub.cancel();
    });
  }

  /// Arms the chain for the first time. Call once after the bootstrap.
  void start() => unawaited(_reschedule());

  /// Re-arm on app resume (a foreground return counts as activity, FR-16 §3.3).
  void onResume() => unawaited(_reschedule());

  /// Cancels the existing chain and (re)schedules it [kJournalNudgeDayOffsets]
  /// days out, unless the user opted out. Idempotent: reuses the fixed ids.
  Future<void> _reschedule() async {
    if (_running) {
      _dirty = true;
      return;
    }
    _running = true;
    try {
      final notif = ref.read(notificationServiceProvider);
      final userId = ref.read(authServiceProvider).userId;
      final settings = await ref
          .read(profileRepositoryProvider)
          .notificationSettings(userId);

      // Clear first so a fresh schedule (or an opt-out) never leaves a stale
      // nudge behind.
      for (final id in kJournalNudgeNotificationIds) {
        await notif.cancel(id);
      }
      if (!settings.journalNudgeEnabled) return;

      final repo = ref.read(tasksRepositoryProvider);
      final nowLocal = _clock.now().toLocal();
      final fireTimes = journalNudgeFireTimes(
        fromLocal: nowLocal,
        dayOffsets: kJournalNudgeDayOffsets,
        hour: kJournalNudgeHour,
        taskReminderDays: await _taskReminderDays(repo, nowLocal),
      );

      // Segment A (never entered a task) vs B (lapsed) — copy chosen now; a
      // later first entry is itself a write that re-arms with the B copy.
      final segmentA = (await repo.totalCount()) == 0;
      final title = segmentA ? t.journal_nudge.title_a : t.journal_nudge.title_b;
      final body = segmentA ? t.journal_nudge.body_a : t.journal_nudge.body_b;

      final steps = fireTimes.length < kJournalNudgeNotificationIds.length
          ? fireTimes.length
          : kJournalNudgeNotificationIds.length;
      for (var i = 0; i < steps; i++) {
        // Defensive: never schedule a past time (e.g. a debug-shortened offset
        // or a DST edge) — it would fire immediately. Production offsets are
        // always days out, so this is a no-op there.
        if (!fireTimes[i].isAfter(nowLocal)) continue;
        await notif.scheduleNudge(
          id: kJournalNudgeNotificationIds[i],
          when: fireTimes[i],
          title: title,
          body: body,
        );
      }
    } catch (e) {
      debugPrint('journal nudge reschedule failed: $e');
    } finally {
      _running = false;
      if (_dirty) {
        _dirty = false;
        unawaited(_reschedule());
      }
    }
  }

  /// Local days that already carry a future task reminder, so the nudge can skip
  /// them (FR-16 §3.5). Reuses [reminderFireTime] — the same fire-time logic the
  /// reminder coordinator schedules with.
  Future<Set<DateTime>> _taskReminderDays(
    TasksRepository repo,
    DateTime nowLocal,
  ) async {
    final days = <DateTime>{};
    for (final task in await repo.pendingTasks()) {
      final reminders = await repo.remindersForTask(task.id);
      if (reminders.isEmpty) continue;
      final taskDateLocal = task.date.toLocal();
      for (final r in reminders) {
        final fire = reminderFireTime(
          taskDateLocal: taskDateLocal,
          offsetMinutes: r.offset,
          reminderTime: r.reminderTime,
        );
        if (fire.isAfter(nowLocal)) days.add(startOfDay(fire));
      }
    }
    return days;
  }
}
