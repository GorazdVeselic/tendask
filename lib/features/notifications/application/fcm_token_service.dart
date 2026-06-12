import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_service.dart';
import '../../settings/application/profile_providers.dart';

part 'fcm_token_service.g.dart';

/// Keeps profile.fcm_token in sync with the device's FCM registration token
/// (docs/m11/06-fcm.md §6.2). The token is acquired only after sign-in (the
/// engine never pushes to guests) and once POST_NOTIFICATIONS is granted —
/// before that getToken() on A13+ returns a token nothing can display.
/// Re-runs on auth changes; screen 22 invalidates it after the permission flow.
@Riverpod(keepAlive: true)
class FcmTokenService extends _$FcmTokenService {
  StreamSubscription<String>? _refreshSub;

  @override
  Future<void> build() async {
    // authService never notifies — auth state changes arrive via this stream.
    ref.watch(authStateChangesProvider);
    unawaited(_refreshSub?.cancel());
    _refreshSub = null;
    ref.onDispose(() => _refreshSub?.cancel());

    final auth = ref.read(authServiceProvider);
    if (!auth.hasSession) return;
    // Captured once: a later auth change rebuilds this provider, so the
    // listener below must never write under a different user's id.
    final userId = auth.userId;

    // FCM is only a bell: a failed Firebase init or an offline registration
    // must never surface — suggestions still arrive via sync pull.
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return;
      }
      // Subscribe before getToken so a registration that completes late
      // (offline boot) still lands in the profile.
      _refreshSub = messaging.onTokenRefresh.listen((t) => _store(userId, t));
      final token = await messaging.getToken();
      if (token == null) return;
      // The profile row is born via claim/pull moments after sign-in; writing
      // before it exists would race the pull (updateFcmToken is update-only).
      await ref.read(profileRepositoryProvider).waitForProfile(userId);
      await _store(userId, token);
    } catch (e) {
      debugPrint('FCM token sync failed (non-fatal): $e');
    }
  }

  Future<void> _store(String userId, String token) =>
      ref.read(profileRepositoryProvider).updateFcmToken(userId, token);
}
