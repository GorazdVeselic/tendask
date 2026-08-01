import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/notifications/hint_rules.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../i18n/translations.g.dart';
import '../../notifications/application/journal_nudge_schedule.dart';
import '../../notifications/application/reminder_schedule.dart';
import '../../settings/application/profile_providers.dart';
import '../../tasks/application/tasks_providers.dart';
import 'garden_elements_provider.dart';
import 'moon_hint_schedule.dart';
import 'moon_settings_controller.dart';

part 'moon_hint_coordinator.g.dart';

/// Keeps the moon "tomorrow is a X day" hint armed (FR-19 T4b): a device-local
/// notification the evening before a day the user's garden can use. Re-arms at
/// startup, on resume, and whenever the moon settings, the garden or the
/// profile change — so the copy is re-derived (never frozen) and a zodiac
/// system switch is honoured immediately. Lives for the whole session; call
/// [start] after bootstrap.
@Riverpod(keepAlive: true)
class MoonHintCoordinator extends _$MoonHintCoordinator {
  static const Clock _clock = SystemClock();
  Timer? _debounce;
  bool _running = false;
  bool _dirty = false;

  @override
  void build() {
    // The garden decides which days are worth a hint and the settings decide
    // the system; both are streams, so a first arming during bootstrap can land
    // before they resolve — these listeners arm it again once they do.
    ref.listen(gardenElementsProvider, (_, _) => _scheduleSoon());
    ref.listen(moonSettingsControllerProvider, (_, _) => _scheduleSoon());

    // The 🔔 opt-in and the anti-spam switches live in the profile.
    final db = ref.watch(databaseProvider);
    final sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.profiles]))
        .listen((_) => _scheduleSoon());

    ref.onDispose(() {
      _debounce?.cancel();
      sub.cancel();
    });
  }

  /// Arms the hints for the first time. Call once after the bootstrap.
  void start() => unawaited(_reschedule());

  /// Re-arm on app resume — the app may have been backgrounded for days, and
  /// the horizon has moved on with them.
  void onResume() => unawaited(_reschedule());

  void _scheduleSoon() {
    _debounce?.cancel();
    _debounce = Timer(kReminderDebounce, () => unawaited(_reschedule()));
  }

  /// Cancels the reserved ids and schedules the upcoming hints again, unless
  /// the feature is dark or the user opted out. Idempotent: fixed ids.
  Future<void> _reschedule() async {
    // Dark until T7: nothing was ever scheduled, so there is nothing to clean
    // up either — leave the OS queue untouched.
    if (!kMoonCalendarEnabled) return;
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
      final moon = await ref.read(moonSettingsControllerProvider.future);

      // Clear first so an opt-out (or a system switch) never leaves a stale
      // hint behind.
      for (final id in kMoonHintNotificationIds) {
        await notif.cancel(id);
      }
      if (!moon.enabled || !settings.moonHintEnabled) return;

      final nowLocal = _clock.now().toLocal();
      final candidates = moonHintCandidates(
        fromLocal: nowLocal,
        horizonDays: kMoonHintHorizonDays,
        hour: kMoonHintHour,
        // The one system that drives every moon surface (spec §11.6).
        system: moon.system,
        gardenElements: ref.read(gardenElementsProvider),
      );

      // The journal nudge is the senior hint: the moon hint yields to its days
      // (one gentle hint per day) and then to its own already-taken days. An
      // explicit task reminder does not take a day (decision B1) — it only
      // moves the nudge, hence the reminder days here.
      final repo = ref.read(tasksRepositoryProvider);
      final taken = journalNudgeDays(
        fromLocal: nowLocal,
        settings: settings,
        taskReminderDays: settings.taskRemindersEnabled
            ? await futureTaskReminderDays(repo, nowLocal)
            : const {},
      ).toSet();

      var slot = 0;
      for (final hint in candidates) {
        if (slot == kMoonHintNotificationIds.length) break;
        final when = hintFireTime(
          desiredLocal: hint.fireTime,
          settings: settings,
          otherHintDays: taken,
        );
        if (when == null || !when.isAfter(nowLocal)) continue;
        // A hint that says "tomorrow" has to arrive the day before: if quiet
        // hours ever pushed it past midnight it would be wrong, so drop it.
        // With kMoonHintHour outside the window this cannot happen today.
        if (startOfDay(when) != startOfDay(hint.fireTime)) continue;

        taken.add(startOfDay(when));
        await notif.scheduleNudge(
          id: kMoonHintNotificationIds[slot++],
          when: when,
          title: t.moon.hint.title(day: t.moon.day_for[hint.element.name]!),
          body: hint.isNewMoon
              ? t.moon.activity_new_moon
              : t.moon.activity[hint.element.name]!,
        );
      }
    } catch (error, stack) {
      debugPrint('moon hint reschedule failed: $error');
      if (kSentryDsn.isNotEmpty) {
        unawaited(Sentry.captureException(error, stackTrace: stack));
      }
    } finally {
      _running = false;
      if (_dirty) {
        _dirty = false;
        unawaited(_reschedule());
      }
    }
  }
}
