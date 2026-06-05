// Seams are named for a clear public contract, so they are assigned in the
// initializer list rather than as initializing formals (which would force the
// private `_name:` at call sites).
// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_service.dart';
import '../auth/local_row_claim.dart';
import '../database/database_provider.dart';
import 'catalog_sync_service.dart';
import 'sync_pull_service.dart';
import 'sync_push_service.dart';

part 'sync_service.g.dart';

/// Orchestrates one sync cycle and serialises the overlapping triggers (startup,
/// reconnect, periodic) so they never run concurrently. Collaborators arrive as
/// function seams (like [RemoteUpsert]/[RemoteFetch]) so the orchestration is
/// testable without Supabase; a null seam = that step is unavailable (offline
/// build) and is skipped.
class SyncService {
  SyncService({
    required bool Function() hasSession,
    required Future<void> Function() ensureSession,
    Future<void> Function()? push,
    Future<void> Function()? pull,
    Future<void> Function()? catalog,
  })  : _hasSession = hasSession,
        _ensureSession = ensureSession,
        _push = push,
        _pull = pull,
        _catalog = catalog;

  final bool Function() _hasSession;
  final Future<void> Function() _ensureSession;
  final Future<void> Function()? _push;
  final Future<void> Function()? _pull;
  final Future<void> Function()? _catalog;

  bool _running = false;

  /// One cycle: ensure session (+ claim local rows) → push → pull → catalog
  /// (only when [includeCatalog], since the catalog rarely changes).
  ///
  /// Re-entrant calls are skipped while a cycle is in flight — the running cycle
  /// already covers the work the new trigger asked for. Each phase is isolated:
  /// a failure in one (offline is a normal state, not an error path) never
  /// blocks the others, and the affected rows stay pending for the next trigger.
  Future<void> sync({bool includeCatalog = false}) async {
    if (_running) return;
    _running = true;
    try {
      await _phase('session', _ensureSession);
      // Push/pull need a real auth.uid() for RLS; without a session there is
      // nothing to scope to. The catalog is public-read, so it still runs.
      if (_hasSession()) {
        await _phase('push', _push);
        await _phase('pull', _pull);
      }
      if (includeCatalog) await _phase('catalog', _catalog);
    } finally {
      _running = false;
    }
  }

  /// Flushes pending rows to the cloud and reports whether the local data is now
  /// safely uploaded. Unlike [sync] this surfaces failure, so a caller can avoid
  /// a destructive local wipe (logout / account switch) while offline. Returns
  /// true when there is no cloud to flush to (offline build) or the push
  /// succeeded; false when a configured cloud is unreachable.
  Future<bool> flushPush() async {
    final push = _push;
    if (push == null) return true; // offline build: no cloud, nothing to lose
    try {
      await _ensureSession();
      if (!_hasSession()) return false;
      await push();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _phase(String name, Future<void> Function()? op) async {
    if (op == null) return;
    try {
      await op();
    } catch (e) {
      // Offline / transient cloud error is expected — log (stripped in release)
      // and move on; the affected rows wait for the next trigger.
      debugPrint('sync $name failed: $e');
    }
  }
}

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  final db = ref.watch(databaseProvider);
  final auth = ref.watch(authServiceProvider);
  final push = ref.watch(syncPushServiceProvider);
  final pull = ref.watch(syncPullServiceProvider);
  final catalog = ref.watch(catalogSyncServiceProvider);
  return SyncService(
    hasSession: () => auth.hasSession,
    // Bring up the anonymous session, then re-own any rows created offline so
    // the cloud RLS with-check accepts them on the push that follows.
    ensureSession: () async {
      if (!auth.hasSession) await auth.ensureAnonymousSession();
      if (auth.hasSession) await claimLocalRows(db, auth.userId);
    },
    push: push == null ? null : () async => push.push(),
    pull: pull == null ? null : () async => pull.pull(),
    catalog: catalog == null ? null : () async => catalog.pull(),
  );
}
