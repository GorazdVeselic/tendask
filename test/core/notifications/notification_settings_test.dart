import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/notifications/notification_settings.dart';

void main() {
  test('round-trips through JSON', () {
    const s = NotificationSettings(
      taskRemindersEnabled: false,
      journalNudgeEnabled: false,
      weatherHintsEnabled: true,
      communityHintsEnabled: true,
      defaultReminderOffset: 60,
      quietHoursEnabled: true,
      frequencyCapEnabled: true,
    );
    final back = NotificationSettings.fromJson(s.toJson());
    expect(back.taskRemindersEnabled, false);
    expect(back.journalNudgeEnabled, false);
    expect(back.weatherHintsEnabled, true);
    expect(back.communityHintsEnabled, true);
    expect(back.defaultReminderOffset, 60);
    expect(back.quietHoursEnabled, true);
    expect(back.frequencyCapEnabled, true);
  });

  test('tolerant: missing fields fall back to defaults', () {
    final s = NotificationSettings.fromJson(const {'weather_hints': true});
    expect(s.taskRemindersEnabled, true); // default on
    expect(s.journalNudgeEnabled, true); // default on
    expect(s.weatherHintsEnabled, true); // from json
    expect(s.defaultReminderOffset, kDefaultReminderOffset);
    expect(s.quietHoursEnabled, false);
  });

  test('journal nudge opt-out survives a round-trip on an old payload', () {
    // A payload written before the nudge field existed defaults to on; an
    // explicit opt-out must persist.
    expect(
      NotificationSettings.fromJson(const {
        'task_reminders': true,
      }).journalNudgeEnabled,
      true,
    );
    expect(
      NotificationSettings.fromJson(const {
        'journal_nudge': false,
      }).journalNudgeEnabled,
      false,
    );
  });

  test('tolerant: unknown fields ignored', () {
    final s = NotificationSettings.fromJson(const {'unknown_future': 42});
    expect(s.taskRemindersEnabled, true);
    expect(s.defaultReminderOffset, kDefaultReminderOffset);
  });
}
