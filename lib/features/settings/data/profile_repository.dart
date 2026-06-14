import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_settings.dart';
import '../../../core/sync/profile_write_guard.dart';
import '../../../core/sync/sync_status.dart';

class ProfileRepository {
  ProfileRepository(this._db, {this._clock = const SystemClock(), this._isOnline});

  final AppDatabase _db;
  final Clock _clock;

  /// One-shot online check (see [profileRowReadyForWrite]); null in tests.
  final OnlineCheck? _isOnline;

  /// Stored UI language code ('sl'/'en'/'de') for [userId], or null if unset.
  Future<String?> getLang(String userId) async {
    final row = await (_db.select(
      _db.profiles,
    )..where((p) => p.userId.equals(userId))).getSingleOrNull();
    return row?.lang;
  }

  Future<void> setLang(String userId, String lang) async {
    // Let an in-flight first pull land the cloud profile first, so this write
    // merges instead of inserting a partial row that clobbers it (LWW).
    final exists = await profileRowReadyForWrite(
      _db,
      userId,
      isOnline: _isOnline,
    );
    final now = _clock.now();
    if (!exists) {
      await _db
          .into(_db.profiles)
          .insert(
            ProfilesCompanion.insert(
              userId: userId,
              lang: Value(lang),
              updatedAt: now,
              syncStatus: const Value(kSyncPending),
            ),
          );
    } else {
      // Update only lang — never clobber future h3* cells (M7).
      await (_db.update(
        _db.profiles,
      )..where((p) => p.userId.equals(userId))).write(
        ProfilesCompanion(
          lang: Value(lang),
          updatedAt: Value(now),
          syncStatus: const Value(kSyncPending),
        ),
      );
    }
  }

  /// Reactive notification preferences for [userId] — drives screen 22. Missing
  /// row or unset column → defaults.
  Stream<NotificationSettings> watchNotificationSettings(String userId) =>
      (_db.select(_db.profiles)..where((p) => p.userId.equals(userId)))
          .watchSingleOrNull()
          .map((row) => _decode(row?.notificationSettings));

  /// One-shot read — for the reminder coordinator and the reminder edit sheet.
  Future<NotificationSettings> notificationSettings(String userId) async {
    final row = await (_db.select(
      _db.profiles,
    )..where((p) => p.userId.equals(userId))).getSingleOrNull();
    return _decode(row?.notificationSettings);
  }

  Future<void> setNotificationSettings(
    String userId,
    NotificationSettings settings,
  ) async {
    final json = jsonEncode(settings.toJson());
    // Same first-pull grace as setLang — never insert a partial profile that
    // would clobber the cloud's lang / h3* on push.
    final exists = await profileRowReadyForWrite(
      _db,
      userId,
      isOnline: _isOnline,
    );
    final now = _clock.now();
    if (!exists) {
      await _db
          .into(_db.profiles)
          .insert(
            ProfilesCompanion.insert(
              userId: userId,
              notificationSettings: Value(json),
              updatedAt: now,
              syncStatus: const Value(kSyncPending),
            ),
          );
    } else {
      // Update only the settings — never clobber lang / h3* cells.
      await (_db.update(
        _db.profiles,
      )..where((p) => p.userId.equals(userId))).write(
        ProfilesCompanion(
          notificationSettings: Value(json),
          updatedAt: Value(now),
          syncStatus: const Value(kSyncPending),
        ),
      );
    }
  }

  /// Mirrors the device's FCM registration token into the profile (null on
  /// sign-out); the pending row rides the existing push to the cloud.
  ///
  /// Update-only: inserting a bare row here (a sign-in races the first pull)
  /// would beat the cloud row on LWW and permanently wipe its other fields.
  /// Callers gate on [waitForProfile] instead.
  Future<void> updateFcmToken(String userId, String? token) async {
    final exists = await (_db.select(
      _db.profiles,
    )..where((p) => p.userId.equals(userId))).getSingleOrNull();
    // getToken() yields the same value on every app start — skip the no-op
    // write so boot doesn't bump updated_at and trigger a pointless push.
    if (exists == null || exists.fcmToken == token) return;
    final now = _clock.now();
    // Update only the token fields — never clobber lang / settings / h3*.
    await (_db.update(
      _db.profiles,
    )..where((p) => p.userId.equals(userId))).write(
      ProfilesCompanion(
        fcmToken: Value(token),
        fcmTokenUpdatedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }

  /// Completes once the profile row for [userId] exists — born via the sign-in
  /// claim, the first pull, or a first local write (lang/settings/location).
  /// Bounded so a never-arriving profile (permanent offline, RLS quirk) can't
  /// hang the caller forever; on timeout it throws TimeoutException and the
  /// caller (FCM token sync) retries on the next auth change / cold start.
  Future<void> waitForProfile(
    String userId, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    await (_db.select(_db.profiles)..where((p) => p.userId.equals(userId)))
        .watchSingleOrNull()
        .firstWhere((row) => row != null)
        .timeout(timeout);
  }

  NotificationSettings _decode(String? json) {
    if (json == null || json.isEmpty) return const NotificationSettings();
    return NotificationSettings.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
}
