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

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

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

  /// Ensures exact-alarm scheduling is allowed (Android 13+). When not granted,
  /// opens the system "Alarms & reminders" page. Reminders use exact alarms so
  /// they fire on time even in Doze. Returns whether exact alarms can be used.
  Future<bool> ensureExactAlarms() async {
    final android = _android;
    if (android == null) return false;
    if (await android.canScheduleExactNotifications() ?? false) return true;
    await android.requestExactAlarmsPermission();
    return await android.canScheduleExactNotifications() ?? false;
  }

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
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      payload: payload,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _reminderDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

  // ── M8.1 smoke-test helpers ────────────────────────────────────────────────
  // Temporary: drive the notification pipeline by hand from a debug button to
  // verify it works on-device (incl. Samsung Doze timing) before the real,
  // task_reminder-driven scheduling lands in M8.2. Remove with the debug button.

  Future<void> showNow({required String title, required String body}) async {
    await init();
    await _plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: _reminderDetails,
    );
  }

  Future<void> scheduleIn(
    Duration delay, {
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: 1,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
      notificationDetails: _reminderDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService();
