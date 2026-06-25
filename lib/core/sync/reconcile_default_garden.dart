import 'package:drift/drift.dart';

import '../auth/auth_service.dart';
import '../clock.dart';
import '../database/app_database.dart';
import '../local_prefs/local_prefs.dart';
import 'sync_status.dart';

/// Decides what becomes of the locally-seeded default garden once we know the
/// account's state — runs after each successful pull while signed in.
///
/// The garden was seeded owned by `local` (so push never uploaded it) and its id
/// recorded in [LocalPrefsRepository.defaultGardenLocalId]. With the freshly
/// pulled `profile.default_garden_seeded` in hand:
///   * **already seeded** → the account has its default garden (or deleted it on
///     purpose); the local guest garden is a duplicate. It was never synced, so a
///     hard delete leaves no cloud row and no tombstone — zero litter.
///   * **not seeded** → a brand-new account adopts the guest garden as its
///     default and we flag the account so a future reinstall never re-seeds.
///
/// Crash-safe and idempotent: an already-adopted garden (owner != `local`) just
/// clears the pending id and returns, so a partial run never deletes a kept
/// garden on the next pass. No-op without a session or a pending garden.
Future<void> reconcileDefaultGarden(
  AppDatabase db,
  LocalPrefsRepository prefs,
  String userId, {
  Clock clock = const SystemClock(),
}) async {
  if (userId == kLocalUserId) return;
  final localId = await prefs.defaultGardenLocalId();
  if (localId == null) return;

  final garden = await (db.select(
    db.areas,
  )..where((a) => a.id.equals(localId))).getSingleOrNull();
  // Gone (e.g. wiped on account switch) or already adopted by a prior pass —
  // nothing to reconcile; just drop the now-stale pending id.
  if (garden == null || garden.userId != kLocalUserId) {
    await prefs.clearDefaultGardenLocalId();
    return;
  }

  final profile = await (db.select(
    db.profiles,
  )..where((p) => p.userId.equals(userId))).getSingleOrNull();
  final seeded = profile?.defaultGardenSeeded ?? false;

  if (seeded) {
    await (db.delete(db.areas)..where((a) => a.id.equals(localId))).go();
  } else {
    await db.transaction(() async {
      // Adopt: claim ownership (pending → push). updated_at untouched — claiming
      // is not a content edit (same rule as claimLocalRows).
      await (db.update(db.areas)..where((a) => a.id.equals(localId))).write(
        AreasCompanion(
          userId: Value(userId),
          syncStatus: const Value(kSyncPending),
        ),
      );
      // Flag the account. insertOnConflictUpdate touches only these columns, so
      // a pulled profile's h3/lang/notification_settings are preserved; the
      // now() bump makes our pending flag win LWW and flush on the next push.
      await db
          .into(db.profiles)
          .insertOnConflictUpdate(
            ProfilesCompanion(
              userId: Value(userId),
              defaultGardenSeeded: const Value(true),
              updatedAt: Value(clock.now().toUtc()),
              syncStatus: const Value(kSyncPending),
            ),
          );
    });
  }
  await prefs.clearDefaultGardenLocalId();
}
