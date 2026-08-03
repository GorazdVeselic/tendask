import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/database/database_provider.dart';
import '../data/plus_repository.dart';
import 'plus_token.dart';

part 'plus_provider.g.dart';

@Riverpod(keepAlive: true)
PlusRepository plusRepository(Ref ref) {
  return PlusRepository(ref.watch(databaseProvider));
}

/// Clock behind [plusProvider]; tests override it to travel past expiry.
@Riverpod(keepAlive: true)
Clock plusClock(Ref ref) => const SystemClock();

/// The bundled verification key, as one overridable seam: tests sign with their
/// own key pair, so [kPlusPublicKey] stays the single untested constant.
@Riverpod(keepAlive: true)
String plusPublicKey(Ref ref) => kPlusPublicKey;

/// Tendask+ entitlement of the current user — the single gate every locked
/// surface reads (T6.6). Recomputed whenever the pulled profile row changes and
/// re-resolved on sign-in/out, so the entitlement follows the account.
///
/// A guest has no cloud session and therefore no token: the stream simply
/// yields [PlusStatus.none], never an error. Expiry that falls while the app is
/// open is picked up on the next row change or app start — the token is checked
/// against the clock on every recompute, not frozen at boot.
final plusProvider = StreamProvider<PlusStatus>((ref) {
  ref.watch(authStateChangesProvider);
  final userId = ref.read(authServiceProvider).userId;
  final clock = ref.watch(plusClockProvider);
  final publicKey = ref.watch(plusPublicKeyProvider);
  return ref
      .watch(plusRepositoryProvider)
      .watch(userId)
      .map(
        (record) => verifyPlusToken(
          token: record?.token,
          userId: userId,
          nowUtc: clock.now(),
          publicKeyBase64: publicKey,
          kind: record?.kind,
        ),
      );
});
