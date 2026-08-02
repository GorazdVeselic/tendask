import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config.dart';
import '../../../core/location/location_repository.dart';

/// Routes after sign-in or guest entry: to home when a garden location is set
/// (profile.h3_r7), otherwise to the location step.
///
/// On sign-in the local profile was wiped on the previous sign-out and is
/// restored only by the pull, so pass the [syncFuture] from `start()` and we
/// await it (bounded) before reading the cell — otherwise an existing user with
/// a cloud location would be wrongly sent to the location step (BUG-002). Guest
/// entry has no session (no pull); it passes no future and reads the local cell.
Future<void> goToLocationOrHome(
  BuildContext context,
  WidgetRef ref, {
  Future<void>? syncFuture,
}) async {
  if (syncFuture != null) {
    // Offline / slow / pull error → fall back to whatever cell is local.
    try {
      await syncFuture.timeout(kPostSignInPullWait);
    } on Object {
      /* ignore — degrade to the local cell below */
    }
  }
  final cell = await ref.read(locationRepositoryProvider).gardenCell();
  if (!context.mounted) return;
  context.go(cell != null ? '/home' : '/location');
}
