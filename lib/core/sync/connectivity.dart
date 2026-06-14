import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

/// True when any network interface is up (wifi/mobile/ethernet/vpn).
/// connectivity_plus reports interface presence, NOT actual internet
/// reachability — enough to trigger a sync flush; the sync service still has to
/// handle request failures (offline is a normal state, not an error path).
bool _isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// One-shot online check (no stream) — for code paths that need the current
/// status once, e.g. deciding whether to wait for the first pull before a
/// profile write. Same interface-presence caveat as [onlineStatus].
Future<bool> checkOnline() async =>
    _isOnline(await Connectivity().checkConnectivity());

/// Emits the device's online/offline status, de-duplicated so an unchanged
/// state never triggers a needless rebuild/flush. keepAlive: the sync service
/// listens for the whole app lifetime.
@Riverpod(keepAlive: true)
Stream<bool> onlineStatus(Ref ref) async* {
  final connectivity = Connectivity();
  var online = _isOnline(await connectivity.checkConnectivity());
  yield online;
  await for (final results in connectivity.onConnectivityChanged) {
    final next = _isOnline(results);
    if (next != online) {
      online = next;
      yield online;
    }
  }
}
