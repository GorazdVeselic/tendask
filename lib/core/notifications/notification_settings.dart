import '../config.dart';

/// User notification preferences (screen 22), stored in `profile` and synced
/// (LWW) so they follow the user across devices. Task reminders are local and
/// the only live type today; weather/community hints are server-side (FCM) and
/// deferred, so their opt-ins and the anti-spam controls (quiet hours, frequency
/// cap) are persisted but inert until FCM lands. Quiet hours never silence the
/// explicit task reminders (koncept §"Vodenje proti motečnosti").
class NotificationSettings {
  const NotificationSettings({
    this.taskRemindersEnabled = true,
    this.journalNudgeEnabled = true,
    this.weatherHintsEnabled = false,
    this.communityHintsEnabled = false,
    this.defaultReminderOffset = kDefaultReminderOffset,
    this.quietHoursEnabled = false,
    this.frequencyCapEnabled = false,
  });

  /// Master switch for local task reminders — when off, none are scheduled.
  final bool taskRemindersEnabled;

  /// Opt-in for the local re-engagement journal nudge (FR-16). On by default; a
  /// separate switch from task reminders (FR-16 §3.6). Local, works offline.
  final bool journalNudgeEnabled;

  /// Opt-in for weather hints (FCM, deferred — stored, not yet wired).
  final bool weatherHintsEnabled;

  /// Opt-in for community/nearby hints (V2, FCM — stored, not yet wired).
  final bool communityHintsEnabled;

  /// Offset in minutes prefilled when adding a new reminder.
  final int defaultReminderOffset;

  /// Quiet hours opt-in (governs future hints, not explicit task reminders).
  final bool quietHoursEnabled;

  /// Cap non-reminder hints to one per day (future hints — stored, not wired).
  final bool frequencyCapEnabled;

  NotificationSettings copyWith({
    bool? taskRemindersEnabled,
    bool? journalNudgeEnabled,
    bool? weatherHintsEnabled,
    bool? communityHintsEnabled,
    int? defaultReminderOffset,
    bool? quietHoursEnabled,
    bool? frequencyCapEnabled,
  }) => NotificationSettings(
    taskRemindersEnabled: taskRemindersEnabled ?? this.taskRemindersEnabled,
    journalNudgeEnabled: journalNudgeEnabled ?? this.journalNudgeEnabled,
    weatherHintsEnabled: weatherHintsEnabled ?? this.weatherHintsEnabled,
    communityHintsEnabled: communityHintsEnabled ?? this.communityHintsEnabled,
    defaultReminderOffset: defaultReminderOffset ?? this.defaultReminderOffset,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    frequencyCapEnabled: frequencyCapEnabled ?? this.frequencyCapEnabled,
  );

  Map<String, dynamic> toJson() => {
    'task_reminders': taskRemindersEnabled,
    'journal_nudge': journalNudgeEnabled,
    'weather_hints': weatherHintsEnabled,
    'community_hints': communityHintsEnabled,
    'default_offset': defaultReminderOffset,
    'quiet_hours': quietHoursEnabled,
    'frequency_cap': frequencyCapEnabled,
  };

  /// Tolerant: unknown fields ignored, missing fields fall back to defaults.
  factory NotificationSettings.fromJson(Map<String, dynamic> j) =>
      NotificationSettings(
        taskRemindersEnabled: j['task_reminders'] as bool? ?? true,
        journalNudgeEnabled: j['journal_nudge'] as bool? ?? true,
        weatherHintsEnabled: j['weather_hints'] as bool? ?? false,
        communityHintsEnabled: j['community_hints'] as bool? ?? false,
        defaultReminderOffset:
            (j['default_offset'] as num?)?.toInt() ?? kDefaultReminderOffset,
        quietHoursEnabled: j['quiet_hours'] as bool? ?? false,
        frequencyCapEnabled: j['frequency_cap'] as bool? ?? false,
      );
}
