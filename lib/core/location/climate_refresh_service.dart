import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/auth_service.dart';
import '../database/database_provider.dart';
import '../sync/connectivity.dart';
import '../sync/profile_write_guard.dart';
import 'location_repository.dart';

part 'climate_refresh_service.g.dart';

/// Keeps `profile.timezone` + `climate_*` filled for whoever is signed in
/// (docs/m11/07 §7.5). Runs at start AND on every auth change.
///
/// Both halves matter, and both were missing (findings N14 + N1):
///
///  * it used to sit behind `kSuggestionsEnabled`, a define production does not
///    set — so on production it never ran at all, and *every* profile had a null
///    timezone. The binding was wrong on its own terms: the timezone also bins
///    `agg_event.local_day` for the community aggregates and picks the
///    `engine_dispatch` send window, neither of which is a suggestion;
///  * it ran once at boot with whatever user id existed then. Set the garden up
///    as a guest, sign in, and the refresh never ran for the new id.
///
/// A sign-in claims (or pulls) the profile row moments later, so this waits
/// briefly for the row before looking — otherwise it reads an empty table and
/// silently does nothing until the next cold start.
@Riverpod(keepAlive: true)
class ClimateRefreshService extends _$ClimateRefreshService {
  @override
  Future<void> build() async {
    // authService never notifies — auth state changes arrive via this stream.
    ref.watch(authStateChangesProvider);
    final userId = ref.read(authServiceProvider).userId;
    try {
      // False = no profile row at all (a guest who never saved a garden, or a
      // pull that did not land) → nothing to refresh; the next auth change or
      // cold start retries.
      final ready = await profileRowReadyForWrite(
        ref.read(databaseProvider),
        userId,
        isOnline: checkOnline,
      );
      if (!ready) return;
      await ref.read(locationRepositoryProvider).refreshClimateIfStale(userId);
    } catch (e) {
      // Silent by design: this is a background top-up, and the garden has no
      // signal often enough that a visible failure would be noise.
      debugPrint('Climate refresh failed (non-fatal): $e');
    }
  }
}
