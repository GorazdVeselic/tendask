import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry/sentry.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/single_flight.dart';
import '../../../i18n/translations.g.dart';
import '../../notifications/application/journal_nudge_schedule.dart';
import '../../notifications/application/reminder_schedule.dart';
import '../../plus/application/plus_provider.dart';
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
  late final SingleFlight _flight = SingleFlight(_reschedule);

  @override
  void build() {
    // The garden decides which days are worth a hint and the settings decide
    // the system; both are streams, so a first arming during bootstrap can land
    // before they resolve — these listeners arm it again once they do.
    ref.listen(gardenElementsProvider, (_, _) => _scheduleSoon());
    ref.listen(moonSettingsControllerProvider, (_, _) => _scheduleSoon());
    // The hint is a paid surface (spec §6.5), so an entitlement that arrives or
    // lapses must arm or silence it. Listening also keeps the stream subscribed,
    // so the read inside [armHints] sees a resolved value.
    ref.listen(plusProvider, (_, _) => _scheduleSoon());

    // The 🔔 opt-in and the anti-spam switches live in the profile.
    final db = ref.watch(databaseProvider);
    final sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.profiles]))
        .listen((_) => _scheduleSoon());

    ref.onDispose(() {
      _flight.dispose();
      sub.cancel();
    });
  }

  /// Arms the hints for the first time. Call once after the bootstrap.
  void start() => unawaited(_flight.run());

  /// Re-arm on app resume — the app may have been backgrounded for days, and
  /// the horizon has moved on with them.
  void onResume() => unawaited(_flight.run());

  void _scheduleSoon() => _flight.runSoon(kReminderDebounce);

  /// Arms the hints again, unless the feature is dark. Idempotent: fixed ids.
  Future<void> _reschedule() async {
    // Dark until T7: nothing was ever scheduled, so there is nothing to clean
    // up either — leave the OS queue untouched.
    if (!kMoonCalendarEnabled) return;
    try {
      await armHints(_clock.now().toLocal());
    } catch (error, stack) {
      debugPrint('moon hint reschedule failed: $error');
      if (kSentryDsn.isNotEmpty) {
        unawaited(Sentry.captureException(error, stackTrace: stack));
      }
    }
  }

  /// Clears the reserved ids and posts the hints due after [nowLocal], unless
  /// the user opted out. Free of both the feature gate and the ambient clock on
  /// purpose — the gate belongs to the entry points above and the time comes
  /// from the caller — so the real arming path stays reachable while the
  /// calendar is dark.
  @visibleForTesting
  Future<void> armHints(DateTime nowLocal) async {
    final notif = ref.read(notificationServiceProvider);
    final userId = ref.read(authServiceProvider).userId;
    final settings = await ref
        .read(profileRepositoryProvider)
        .notificationSettings(userId);
    final moon = await ref.read(moonSettingsControllerProvider.future);

    // Clear first so an opt-out (or a system switch) never leaves a stale hint
    // behind.
    for (final id in kMoonHintNotificationIds) {
      await notif.cancel(id);
    }
    // An expired gift silences the hint by itself (owner, 2026-08-03) — the
    // stored opt-in is left alone, so it returns with the entitlement. Read,
    // not awaited: an entitlement that has not resolved yet reads as "no Plus"
    // and the listener in [build] arms again the moment it does — the same
    // pattern the garden and the settings streams already use.
    if (!ref.read(plusActiveProvider)) return;
    if (!moon.enabled || !settings.moonHintEnabled) return;

    // The journal nudge is the senior hint: the moon hint yields to its days
    // (one gentle hint per day). An explicit task reminder does not take a day
    // (decision B1) — it only moves the nudge, hence the reminder days here.
    final repo = ref.read(tasksRepositoryProvider);
    final nudgeDays = journalNudgeDays(
      fromLocal: nowLocal,
      settings: settings,
      taskReminderDays: settings.taskRemindersEnabled
          ? await futureTaskReminderDays(repo, nowLocal)
          : const {},
    );

    final hints = planMoonHints(
      nowLocal: nowLocal,
      settings: settings,
      // The one system that drives every moon surface (spec §11.6).
      system: moon.system,
      gardenElements: ref.read(gardenElementsProvider),
      takenDays: nudgeDays,
      maxHints: kMoonHintNotificationIds.length,
      horizonDays: kMoonHintHorizonDays,
      hour: kMoonHintHour,
    );

    for (var slot = 0; slot < hints.length; slot++) {
      final hint = hints[slot];
      await notif.scheduleNudge(
        id: kMoonHintNotificationIds[slot],
        when: hint.fireTime,
        title: t.moon.hint.title(day: t.moon.day_for[hint.element.name]!),
        body: hint.isNewMoon
            ? t.moon.activity_new_moon
            : t.moon.activity[hint.element.name]!,
      );
    }
  }
}
