import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/notifications/notification_settings.dart';

void main() {
  test('round-trips through JSON', () {
    const s = NotificationSettings(
      taskRemindersEnabled: false,
      weatherHintsEnabled: true,
      communityHintsEnabled: true,
      defaultReminderOffset: 60,
      quietHoursEnabled: true,
      frequencyCapEnabled: true,
    );
    final back = NotificationSettings.fromJson(s.toJson());
    expect(back.taskRemindersEnabled, false);
    expect(back.weatherHintsEnabled, true);
    expect(back.communityHintsEnabled, true);
    expect(back.defaultReminderOffset, 60);
    expect(back.quietHoursEnabled, true);
    expect(back.frequencyCapEnabled, true);
  });

  test('tolerant: missing fields fall back to defaults', () {
    final s = NotificationSettings.fromJson(const {'weather_hints': true});
    expect(s.taskRemindersEnabled, true); // default on
    expect(s.weatherHintsEnabled, true); // from json
    expect(s.defaultReminderOffset, kDefaultReminderOffset);
    expect(s.quietHoursEnabled, false);
  });

  test('tolerant: unknown fields ignored', () {
    final s = NotificationSettings.fromJson(const {'unknown_future': 42});
    expect(s.taskRemindersEnabled, true);
    expect(s.defaultReminderOffset, kDefaultReminderOffset);
  });
}
