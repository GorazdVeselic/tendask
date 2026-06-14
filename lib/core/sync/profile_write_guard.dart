import 'dart:async';

import '../auth/auth_service.dart';
import '../config.dart';
import '../database/app_database.dart';

/// One-shot online check, injected so a first profile write can decide whether
/// to wait for the initial pull (real impl: connectivity_plus; tests: a stub).
typedef OnlineCheck = Future<bool> Function();

/// Whether a profile row for [userId] already exists, giving an in-flight first
/// pull a brief [grace] window to land the cloud copy when one could exist (real
/// session + online). This lets a first local field-write merge (UPDATE) instead
/// of inserting a partial row that would clobber the cloud profile's other fields
/// on the next LWW push.
///
/// Returns false immediately for a guest ([kLocalUserId] has no cloud account)
/// or when offline (the pull cannot land) — the caller then inserts, which is
/// correct in both cases (nothing to clobber, or unavoidable offline).
Future<bool> profileRowReadyForWrite(
  AppDatabase db,
  String userId, {
  OnlineCheck? isOnline,
  Duration grace = kProfilePullGrace,
}) async {
  Future<bool> exists() async =>
      await (db.select(db.profiles)..where((p) => p.userId.equals(userId)))
          .getSingleOrNull() !=
      null;

  if (await exists()) return true;

  final remotePossible =
      userId != kLocalUserId && (await isOnline?.call() ?? false);
  if (!remotePossible) return false;

  try {
    await (db.select(db.profiles)..where((p) => p.userId.equals(userId)))
        .watchSingleOrNull()
        .firstWhere((row) => row != null)
        .timeout(grace);
    return true;
  } on TimeoutException {
    return false; // pull did not land in time — the caller inserts
  }
}
