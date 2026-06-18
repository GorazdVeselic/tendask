import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_service.dart';
import '../config.dart';
import '../database/database_provider.dart';
import 'connectivity.dart';
import 'sync_push_service.dart';
import 'sync_service.dart';

part 'sync_coordinator.g.dart';

/// Wires the sync triggers (tech-stack §2): startup, reconnect, periodic, plus
/// push-on-save. keepAlive — lives for the whole app session. Instantiate once
/// after the bootstrap via `ref.read(syncCoordinatorProvider.notifier).start()`.
@Riverpod(keepAlive: true)
class SyncCoordinator extends _$SyncCoordinator {
  Timer? _timer;
  Timer? _pushDebounce;

  @override
  void build() {
    final service = ref.watch(syncServiceProvider);
    final push = ref.watch(syncPushServiceProvider);
    final auth = ref.watch(authServiceProvider);
    final db = ref.watch(databaseProvider);

    // Reconnect trigger: fire only on the transition into online — the startup
    // run already covers the first cycle, and offline↔offline noise is ignored.
    ref.listen(onlineStatusProvider, (prev, next) {
      if (next.asData?.value == true && prev?.asData?.value != true) {
        unawaited(service.sync(includeCatalog: true));
      }
    });

    _timer?.cancel();
    _timer = Timer.periodic(kSyncInterval, (_) => unawaited(service.sync()));

    // Push-on-save: a write to a synced table schedules a debounced push so the
    // change reaches the cloud within seconds, not on the next periodic tick.
    // push() skips rows still owned by 'local' (no session yet), so this is a
    // safe no-op offline; startup/reconnect/periodic sync claims+pushes those.
    if (push != null) {
      final sub = db
          .tableUpdates(
            TableUpdateQuery.onAllTables([
              db.profiles,
              db.areas,
              db.supplies,
              db.recipes,
              db.userPlants,
              db.tasks,
              db.notes,
              db.taskSubjects,
              db.taskReminders,
              db.taskSupplies,
            ]),
          )
          .listen((_) {
            _pushDebounce?.cancel();
            _pushDebounce = Timer(kPushDebounce, () {
              if (auth.hasSession) unawaited(_safePush(push));
            });
          });
      ref.onDispose(sub.cancel);
    }

    ref.onDispose(() {
      _timer?.cancel();
      _pushDebounce?.cancel();
    });
  }

  Future<void> _safePush(SyncPushService push) async {
    try {
      await push.push();
    } catch (e) {
      // Offline / transient cloud error is expected — the rows stay pending for
      // the next trigger.
      debugPrint('push-on-save failed: $e');
    }
  }

  /// Runs the first cycle (with catalog) and returns its future so a caller can
  /// await the initial pull (e.g. post-sign-in routing needs the just-pulled
  /// profile before deciding the route). Call once after the bootstrap; the
  /// reconnect/periodic/push-on-save triggers are wired in [build].
  Future<void> start() =>
      ref.read(syncServiceProvider).sync(includeCatalog: true);
}
