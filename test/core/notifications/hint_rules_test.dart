import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/notifications/hint_rules.dart';
import 'package:tendask/core/notifications/notification_settings.dart';

void main() {
  const off = NotificationSettings();
  const quiet = NotificationSettings(quietHoursEnabled: true);
  const capped = NotificationSettings(frequencyCapEnabled: true);

  group('inQuietHours', () {
    test('covers the night window across midnight (22:00 – 07:00)', () {
      expect(inQuietHours(DateTime(2026, 8, 5, 21, 59)), isFalse);
      expect(inQuietHours(DateTime(2026, 8, 5, 22)), isTrue);
      expect(inQuietHours(DateTime(2026, 8, 5, 23, 59)), isTrue);
      expect(inQuietHours(DateTime(2026, 8, 5, 0)), isTrue);
      expect(inQuietHours(DateTime(2026, 8, 5, 6, 59)), isTrue);
      expect(inQuietHours(DateTime(2026, 8, 5, 7)), isFalse);
      expect(inQuietHours(DateTime(2026, 8, 5, 17)), isFalse);
    });
  });

  group('hintFireTime — quiet hours', () {
    test('leaves a daytime hint alone', () {
      final desired = DateTime(2026, 8, 5, 18, 30);
      expect(hintFireTime(desiredLocal: desired, settings: quiet), desired);
    });

    test('moves an evening hint to the next morning', () {
      expect(
        hintFireTime(desiredLocal: DateTime(2026, 8, 5, 22, 30), settings: quiet),
        DateTime(2026, 8, 6, 7),
      );
    });

    test('moves a pre-dawn hint to the same morning', () {
      expect(
        hintFireTime(desiredLocal: DateTime(2026, 8, 5, 3), settings: quiet),
        DateTime(2026, 8, 5, 7),
      );
    });

    test('crosses a month boundary when shifting forward', () {
      expect(
        hintFireTime(desiredLocal: DateTime(2026, 8, 31, 23), settings: quiet),
        DateTime(2026, 9, 1, 7),
      );
    });

    test('does not shift while the toggle is off', () {
      final night = DateTime(2026, 8, 5, 23);
      expect(hintFireTime(desiredLocal: night, settings: off), night);
    });
  });

  group('hintFireTime — frequency cap', () {
    test('drops a hint on a day that already carries one', () {
      expect(
        hintFireTime(
          desiredLocal: DateTime(2026, 8, 5, 18),
          settings: capped,
          otherHintDays: {DateTime(2026, 8, 5)},
        ),
        isNull,
      );
    });

    test('keeps a hint on a free day', () {
      final desired = DateTime(2026, 8, 5, 18);
      expect(
        hintFireTime(
          desiredLocal: desired,
          settings: capped,
          otherHintDays: {DateTime(2026, 8, 6)},
        ),
        desired,
      );
    });

    test('lets a second hint through while the toggle is off', () {
      final desired = DateTime(2026, 8, 5, 18);
      expect(
        hintFireTime(
          desiredLocal: desired,
          settings: off,
          otherHintDays: {DateTime(2026, 8, 5)},
        ),
        desired,
      );
    });

    test('judges the cap on the shifted day, not the wanted one', () {
      const both = NotificationSettings(
        quietHoursEnabled: true,
        frequencyCapEnabled: true,
      );
      // Wanted late on the 5th, moved to the 6th — where a hint already sits.
      expect(
        hintFireTime(
          desiredLocal: DateTime(2026, 8, 5, 23),
          settings: both,
          otherHintDays: {DateTime(2026, 8, 6)},
        ),
        isNull,
      );
      // The wanted day being taken no longer matters once the hint moved off it.
      expect(
        hintFireTime(
          desiredLocal: DateTime(2026, 8, 5, 23),
          settings: both,
          otherHintDays: {DateTime(2026, 8, 5)},
        ),
        DateTime(2026, 8, 6, 7),
      );
    });
  });
}
