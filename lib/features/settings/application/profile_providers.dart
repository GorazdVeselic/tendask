import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_settings.dart';
import '../../../core/sync/connectivity.dart';
import '../data/profile_repository.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(databaseProvider), isOnline: checkOnline);
}

/// Reactive notification settings for the current user — watched by screen 22.
/// Re-resolves the user id on sign-in/out so settings follow the account.
final notificationSettingsProvider =
    StreamProvider.autoDispose<NotificationSettings>((ref) {
      ref.watch(authStateChangesProvider);
      final userId = ref.read(authServiceProvider).userId;
      return ref
          .watch(profileRepositoryProvider)
          .watchNotificationSettings(userId);
    });
