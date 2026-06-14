import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/notifications/notification_settings.dart';
import 'package:tendask/features/settings/data/profile_repository.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration d) => _now = _now.add(d);
}

void main() {
  late AppDatabase db;
  late _FakeClock clock;
  late ProfileRepository repo;

  final t0 = DateTime.utc(2026, 6, 2, 8);
  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = _FakeClock(t0);
    repo = ProfileRepository(db, clock: clock);
  });

  tearDown(() async => db.close());

  test('getLang returns null on an empty profile', () async {
    expect(await repo.getLang(userId), isNull);
  });

  test('setLang inserts the row and marks it pending', () async {
    await repo.setLang(userId, 'en');

    expect(await repo.getLang(userId), 'en');
    final row = await db.select(db.profiles).getSingle();
    expect(row.userId, userId);
    expect(row.syncStatus, 'pending');
  });

  test('setLang twice updates in place (single row, no duplicate)', () async {
    await repo.setLang(userId, 'en');
    clock.advance(const Duration(minutes: 5));
    await repo.setLang(userId, 'de');

    expect(await repo.getLang(userId), 'de');
    final rows = await db.select(db.profiles).get();
    expect(rows.length, 1);
  });

  test('setLang waits for an in-flight pull, then merges (no clobber)', () async {
    // Simulate the cloud profile landing via pull shortly after the write begins.
    unawaited(
      Future(
        () => db
            .into(db.profiles)
            .insert(
              ProfilesCompanion.insert(
                userId: userId,
                h3R7: const Value('abc'),
                notificationSettings: const Value('{"weather_hints":true}'),
                updatedAt: t0,
                syncStatus: const Value('synced'),
              ),
            ),
      ),
    );
    final onlineRepo = ProfileRepository(
      db,
      clock: clock,
      isOnline: () async => true,
    );
    await onlineRepo.setLang(userId, 'de');

    final rows = await db.select(db.profiles).get();
    expect(rows.length, 1); // merged into the pulled row, not a second insert
    expect(rows.single.lang, 'de'); // our write
    expect(rows.single.h3R7, 'abc'); // cloud field preserved (no clobber)
    expect(rows.single.notificationSettings, '{"weather_hints":true}');
  });

  test('setLang offline inserts immediately (no grace hang)', () async {
    final offlineRepo = ProfileRepository(
      db,
      clock: clock,
      isOnline: () async => false,
    );
    // Must NOT block on the grace window when there is no cloud to wait for.
    await offlineRepo
        .setLang(userId, 'sl')
        .timeout(const Duration(seconds: 1));
    expect(await offlineRepo.getLang(userId), 'sl');
  });

  test('notificationSettings returns defaults on an empty profile', () async {
    final s = await repo.notificationSettings(userId);
    expect(s.taskRemindersEnabled, true);
    expect(s.defaultReminderOffset, isNot(0));
  });

  test(
    'setNotificationSettings inserts the row and marks it pending',
    () async {
      await repo.setNotificationSettings(
        userId,
        const NotificationSettings(taskRemindersEnabled: false),
      );

      final s = await repo.notificationSettings(userId);
      expect(s.taskRemindersEnabled, false);
      final rows = await db.select(db.profiles).get();
      expect(rows.length, 1);
      expect(rows.single.syncStatus, 'pending');
    },
  );

  test('updateFcmToken writes the token into an existing row', () async {
    await repo.setLang(userId, 'sl');
    await repo.updateFcmToken(userId, 'tok-1');

    final row = await db.select(db.profiles).getSingle();
    expect(row.fcmToken, 'tok-1');
    // drift returns local-time DateTime — compare the instant in UTC.
    expect(row.fcmTokenUpdatedAt?.toUtc(), t0);
    expect(row.syncStatus, 'pending');
  });

  test('updateFcmToken with the same token is a no-op write', () async {
    await repo.setLang(userId, 'sl');
    await repo.updateFcmToken(userId, 'tok-1');
    clock.advance(const Duration(hours: 1));
    await repo.updateFcmToken(userId, 'tok-1');

    final row = await db.select(db.profiles).getSingle();
    // updated_at untouched → no pointless push on every app start.
    expect(row.updatedAt.toUtc(), t0);
    expect(row.fcmTokenUpdatedAt?.toUtc(), t0);
  });

  test('updateFcmToken(null) clears the token and marks pending', () async {
    await repo.setLang(userId, 'sl');
    await repo.updateFcmToken(userId, 'tok-1');
    clock.advance(const Duration(hours: 1));
    await repo.updateFcmToken(userId, null);

    final row = await db.select(db.profiles).getSingle();
    expect(row.fcmToken, isNull);
    expect(row.fcmTokenUpdatedAt?.toUtc(), t0.add(const Duration(hours: 1)));
    expect(row.syncStatus, 'pending');
  });

  test('updateFcmToken never inserts a bare row (LWW safety)', () async {
    await repo.updateFcmToken(userId, 'tok-1');
    expect(await db.select(db.profiles).get(), isEmpty);
  });

  test('waitForProfile completes once the row appears', () async {
    final wait = repo.waitForProfile(userId);
    await repo.setLang(userId, 'sl');
    await expectLater(wait, completes);
  });

  test('updateFcmToken does not clobber lang or settings', () async {
    await repo.setLang(userId, 'de');
    await repo.setNotificationSettings(
      userId,
      const NotificationSettings(weatherHintsEnabled: true),
    );
    await repo.updateFcmToken(userId, 'tok-1');

    expect(await repo.getLang(userId), 'de');
    expect((await repo.notificationSettings(userId)).weatherHintsEnabled, true);
    final rows = await db.select(db.profiles).get();
    expect(rows.length, 1);
  });

  test('settings and lang do not clobber each other', () async {
    await repo.setLang(userId, 'de');
    await repo.setNotificationSettings(
      userId,
      const NotificationSettings(quietHoursEnabled: true),
    );

    // Writing settings must not wipe lang …
    expect(await repo.getLang(userId), 'de');
    // … and writing lang must not wipe settings.
    await repo.setLang(userId, 'sl');
    final s = await repo.notificationSettings(userId);
    expect(s.quietHoursEnabled, true);

    final rows = await db.select(db.profiles).get();
    expect(rows.length, 1);
  });
}
