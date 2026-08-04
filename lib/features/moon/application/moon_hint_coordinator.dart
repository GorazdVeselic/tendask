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

  void _scheduleSoon() => _flight.runSoon(kMoonHintDebounce);

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

  /// What the OS queue currently holds, or null when this session has not armed
  /// yet (a fresh process knows nothing about the queue it inherited). Every
  /// field the user can see is in here, so a rerun that produces the same list
  /// can skip the platform calls entirely — and most reruns do: the profile
  /// table also changes on a language switch, a location edit or a sync pull,
  /// none of which move the hints.
  List<_ArmedHint>? _armed;

  /// Brings the OS queue in line with the plan for [nowLocal]. Free of both the
  /// feature gate and the ambient clock on purpose — the gate belongs to the
  /// entry points above and the time comes from the caller — so the real arming
  /// path stays reachable while the calendar is dark.
  @visibleForTesting
  Future<void> armHints(DateTime nowLocal) async {
    final desired = await _plan(nowLocal);
    final armed = _armed;
    // Nothing the user would notice has moved — leave the OS alone. Each
    // cancel/schedule is a platform round trip, and 14 of them mid-tap is what
    // made the 🔔 row stutter.
    if (armed != null && listEquals(armed, desired)) return;

    final notif = ref.read(notificationServiceProvider);
    final keep = {for (final hint in desired) hint.id};
    for (final id in kMoonHintNotificationIds) {
      // Slots that keep a hint are overwritten by scheduling the same id; only
      // the ones falling out of the plan need clearing, so an opt-out or a
      // system switch still leaves nothing stale behind.
      if (keep.contains(id)) continue;
      if (armed == null || armed.any((hint) => hint.id == id)) {
        await notif.cancel(id);
      }
    }
    for (final hint in desired) {
      if (armed != null && armed.contains(hint)) continue;
      await notif.scheduleNudge(
        id: hint.id,
        when: hint.when,
        title: hint.title,
        body: hint.body,
      );
    }
    _armed = desired;
  }

  /// The hints that should sit in the OS queue right now, copy included — no
  /// platform calls, so it is cheap enough to run on every trigger.
  Future<List<_ArmedHint>> _plan(DateTime nowLocal) async {
    final userId = ref.read(authServiceProvider).userId;
    final settings = await ref
        .read(profileRepositoryProvider)
        .notificationSettings(userId);
    final moon = await ref.read(moonSettingsControllerProvider.future);

    // An expired gift silences the hint by itself (owner, 2026-08-03) — the
    // stored opt-in is left alone, so it returns with the entitlement. Read,
    // not awaited: an entitlement that has not resolved yet reads as "no Plus"
    // and the listener in [build] arms again the moment it does — the same
    // pattern the garden and the settings streams already use.
    if (!ref.read(plusActiveProvider)) return const [];
    if (!settings.moonHintEnabled) return const [];

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

    return [
      for (var slot = 0; slot < hints.length; slot++)
        (
          id: kMoonHintNotificationIds[slot],
          when: hints[slot].fireTime,
          // Carried in the record, not re-derived at send time: it is what
          // makes a language or system switch differ from the armed queue.
          title: t.moon.hint.title(
            day: t.moon.day_for[hints[slot].element.name]!,
          ),
          body: hints[slot].isNewMoon
              ? t.moon.activity_new_moon
              : t.moon.activity[hints[slot].element.name]!,
        ),
    ];
  }
}

/// One armed notification, compared by value (records) to tell "the plan moved"
/// from "something else in the profile changed".
typedef _ArmedHint = ({int id, DateTime when, String title, String body});
