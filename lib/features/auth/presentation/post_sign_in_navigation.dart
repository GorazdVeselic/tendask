import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_repository.dart';

/// How long routing waits for the first post-sign-in pull before falling back
/// to the local profile cell. Long enough for a quick pull, short enough that a
/// slow/offline network never leaves the user staring at a spinner.
const _kPullWait = Duration(seconds: 5);

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
      await syncFuture.timeout(_kPullWait);
    } on Object {
      /* ignore — degrade to the local cell below */
    }
  }
  final cell = await ref.read(locationRepositoryProvider).gardenCell();
  if (!context.mounted) return;
  context.go(cell != null ? '/home' : '/location');
}
