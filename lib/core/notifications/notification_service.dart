import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

/// Channel for deterministic, offline task reminders (tech-stack §4, layer A).
const _kReminderChannelId = 'task_reminders';
const _kReminderChannelName = 'Opomniki opravil';

const _reminderDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    _kReminderChannelId,
    _kReminderChannelName,
    importance: Importance.high,
    priority: Priority.high,
  ),
);

/// Separate channel for the gentle re-engagement journal nudge (FR-16) so the
/// user can mute it in system settings without touching task reminders, and so
/// cancelling one never touches the other. Default importance — it must never
/// feel as urgent as a task reminder.
const _kNudgeChannelId = 'journal_nudge';
const _kNudgeChannelName = 'Nežna povabila k dnevniku';

const _nudgeDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    _kNudgeChannelId,
    _kNudgeChannelName,
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  ),
);

/// Thin wrapper around flutter_local_notifications for local task reminders.
/// [init] runs at bootstrap (timezone + plugin); the permission prompt is
/// deferred to the priming screen (21) and never fired at startup. Taps deep-link
/// to the task detail (17): live taps via [taps], cold-start via [initialPayload].
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  // Task ids of tapped reminders, consumed by the app layer to navigate. The
  // service stays decoupled from the router (core/ must not call features/).
  final _taps = StreamController<String>.broadcast();

  /// Task ids from reminders tapped while the app is alive (foreground or
  /// background). Cold-start launches are resolved via [initialPayload] instead.
  Stream<String> get taps => _taps.stream;

  /// Loads the timezone database, resolves the device's local zone, and
  /// initializes the plugin. Idempotent. Safe to fire-and-forget at bootstrap.
  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_notify'),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
    );
    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Whether the OS currently allows posting notifications. Used to skip the
  /// priming screen (21) once the user has already granted the permission.
  Future<bool> areNotificationsEnabled() async =>
      await _android?.areNotificationsEnabled() ?? false;

  /// Requests POST_NOTIFICATIONS (Android 13+). Asked in context when the user
  /// adds a reminder (not at startup). Returns whether granted.
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  /// Whether the OS currently allows exact alarms (Android 13+). Reminders use
  /// exact alarms so they fire on time even in Doze; without this they throw.
  Future<bool> canScheduleExactAlarms() async =>
      await _android?.canScheduleExactNotifications() ?? false;

  /// Opens the system "Alarms & reminders" settings so the user can allow exact
  /// alarms. Returns after launching settings — the grant happens out-of-app, so
  /// the caller re-checks [canScheduleExactAlarms] on the next attempt.
  Future<void> openExactAlarmSettings() async =>
      _android?.requestExactAlarmsPermission();

  /// Schedules an exact notification at [when] (a local wall-clock time).
  /// Reusing the same [id] replaces a previously scheduled one. [payload] carries
  /// the task id for the deep-link (M8.3). Exact + allow-while-idle so it fires
  /// on time even in Doze (verified on-device, M8.1).
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    String? payload,
  }) => _schedule(
    id: id,
    when: when,
    title: title,
    body: body,
    payload: payload,
    details: _reminderDetails,
    mode: AndroidScheduleMode.exactAllowWhileIdle,
  );

  /// Schedules a re-engagement journal nudge (FR-16) on its own channel. Inexact
  /// (and so it needs no exact-alarm permission): a few minutes' drift around
  /// 17:00 is irrelevant for a gentle nudge, and inexact is easier on the
  /// battery. Reusing the same [id] replaces a previously scheduled one.
  Future<void> scheduleNudge({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) => _schedule(
    id: id,
    when: when,
    title: title,
    body: body,
    details: _nudgeDetails,
    mode: AndroidScheduleMode.inexactAllowWhileIdle,
  );

  Future<void> _schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required NotificationDetails details,
    required AndroidScheduleMode mode,
    String? payload,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      payload: payload,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: mode,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  /// Ids of notifications currently scheduled (pending) with the OS — used to
  /// cancel orphaned reminders without touching already-delivered ones.
  Future<Set<int>> pendingIds() async =>
      (await _plugin.pendingNotificationRequests()).map((r) => r.id).toSet();

  /// Payload (task id) of the reminder that cold-started the app, or null when
  /// the app was launched normally. Checked once at startup — the [_onTap]
  /// callback does not fire for the launch notification.
  Future<String?> initialPayload() async {
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (!(details?.didNotificationLaunchApp ?? false)) return null;
    final payload = details!.notificationResponse?.payload;
    return (payload != null && payload.isNotEmpty) ? payload : null;
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) _taps.add(payload);
  }
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService();
