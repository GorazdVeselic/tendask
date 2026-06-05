import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config.dart';
import 'connectivity.dart';
import 'sync_service.dart';

part 'sync_coordinator.g.dart';

/// Wires the three sync triggers (tech-stack §2): startup, reconnect, periodic.
/// keepAlive — lives for the whole app session. Instantiate once after the
/// bootstrap via `ref.read(syncCoordinatorProvider.notifier).start()`.
@Riverpod(keepAlive: true)
class SyncCoordinator extends _$SyncCoordinator {
  Timer? _timer;

  @override
  void build() {
    final service = ref.watch(syncServiceProvider);

    // Reconnect trigger: fire only on the transition into online — the startup
    // run already covers the first cycle, and offline↔offline noise is ignored.
    ref.listen(onlineStatusProvider, (prev, next) {
      if (next.asData?.value == true && prev?.asData?.value != true) {
        unawaited(service.sync(includeCatalog: true));
      }
    });

    _timer?.cancel();
    _timer = Timer.periodic(kSyncInterval, (_) => unawaited(service.sync()));
    ref.onDispose(() => _timer?.cancel());
  }

  /// Runs the first cycle (with catalog). Call once after the bootstrap; the
  /// reconnect/periodic triggers are wired in [build].
  void start() =>
      unawaited(ref.read(syncServiceProvider).sync(includeCatalog: true));
}
