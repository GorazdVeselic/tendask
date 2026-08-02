import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/notifications/hint_rules.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/single_flight.dart';
import '../../../i18n/translations.g.dart';
import '../../settings/application/profile_providers.dart';
import '../../tasks/application/tasks_providers.dart';
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
  late final SingleFlight _flight = SingleFlight(_reschedule);

  @override
  void build() {
    final db = ref.watch(databaseProvider);

    // Any activity (a task or note write) or an opt-out (profile) re-arms the
    // nudge, pushing it forward. Debounced to coalesce rapid edits.
    final sub = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([db.tasks, db.notes, db.profiles]),
        )
        .listen((_) => _flight.runSoon(kReminderDebounce));

    ref.onDispose(() {
      _flight.dispose();
      sub.cancel();
    });
  }

  /// Arms the chain for the first time. Call once after the bootstrap.
  void start() => unawaited(_flight.run());

  /// Re-arm on app resume (a foreground return counts as activity, FR-16 §3.3).
  void onResume() => unawaited(_flight.run());

  /// Cancels the existing chain and (re)schedules it [kJournalNudgeDayOffsets]
  /// days out, unless the user opted out. Idempotent: reuses the fixed ids.
  Future<void> _reschedule() async {
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
        // Only avoid reminder days when reminders are actually scheduled; with
        // the master switch off there are none to clash with.
        taskReminderDays: settings.taskRemindersEnabled
            ? await futureTaskReminderDays(repo, nowLocal)
            : const {},
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
        // The nudge is a gentle hint, so quiet hours apply (a no-op at
        // [kJournalNudgeHour] by design, live if that hour ever moves). No
        // frequency-cap peers: this is the senior hint — the moon hint yields
        // to it, not the other way round.
        final when = hintFireTime(
          desiredLocal: fireTimes[i],
          settings: settings,
        );
        // Defensive: never schedule a past time (e.g. a debug-shortened offset
        // or a DST edge) — it would fire immediately. Production offsets are
        // always days out, so this is a no-op there.
        if (when == null || !when.isAfter(nowLocal)) continue;
        await notif.scheduleNudge(
          id: kJournalNudgeNotificationIds[i],
          when: when,
          title: title,
          body: body,
        );
      }
    } catch (error, stack) {
      debugPrint('journal nudge reschedule failed: $error');
      if (kSentryDsn.isNotEmpty) {
        unawaited(Sentry.captureException(error, stackTrace: stack));
      }
    }
  }
}
