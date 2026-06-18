import 'package:drift/drift.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../clock.dart';
import '../config.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../sync/sync_status.dart';
import 'h3_cells.dart';

part 'location_repository.g.dart';

/// The garden location. Privacy by design (FR-8): raw coordinates never leave —
/// or are even stored on — the device; only the derived H3 cells reach profile
/// → cloud, and the weather lookup uses the cell's centroid (see [cellCentroid]).
class LocationRepository {
  LocationRepository(this._db, this._h3, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final H3 _h3;
  final Clock _clock;

  /// Persists the garden location for [userId]: derives the H3 cells on-device
  /// and upserts them into profile (pending → synced by the next push), without
  /// clobbering lang. The passed coordinates are used only to derive the cells
  /// and are then discarded — never stored.
  Future<void> saveGardenLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    final cells = deriveH3Cells(_h3, latitude, longitude);
    final now = _clock.now();
    await _db.transaction(() async {
      final exists = await (_db.select(
        _db.profiles,
      )..where((p) => p.userId.equals(userId))).getSingleOrNull();
      if (exists == null) {
        await _db
            .into(_db.profiles)
            .insert(
              ProfilesCompanion.insert(
                userId: userId,
                h3R7: Value(cells.r7),
                h3R6: Value(cells.r6),
                h3R5: Value(cells.r5),
                updatedAt: now,
                syncStatus: const Value(kSyncPending),
              ),
            );
      } else {
        await (_db.update(
          _db.profiles,
        )..where((p) => p.userId.equals(userId))).write(
          ProfilesCompanion(
            h3R7: Value(cells.r7),
            h3R6: Value(cells.r6),
            h3R5: Value(cells.r5),
            updatedAt: Value(now),
            syncStatus: const Value(kSyncPending),
          ),
        );
      }
    });
  }

  /// Removes the garden location: clears the profile H3 cells (pending → push).
  /// Weather falls back to the default region (gardenLocation emits the default
  /// when the cell is null).
  Future<void> clearGardenLocation(String userId) async {
    final now = _clock.now();
    await (_db.update(
      _db.profiles,
    )..where((p) => p.userId.equals(userId))).write(
      ProfilesCompanion(
        h3R7: const Value(null),
        h3R6: const Value(null),
        h3R5: const Value(null),
        updatedAt: Value(now),
        syncStatus: const Value(kSyncPending),
      ),
    );
  }

  /// The stored r7 cell (hex), or null if unset. The local db holds a single
  /// profile row (cleared on account switch, re-owned in place on sign-in), so
  /// reading the newest row is correct without scoping to a userId.
  Future<String?> gardenCell() async =>
      (await _latestProfileQuery().getSingleOrNull())?.h3R7;

  /// Reactive r7 cell: emits whenever the profile changes (save / clear / pull),
  /// so the weather provider re-derives the centroid.
  Stream<String?> watchGardenCell() =>
      _latestProfileQuery().watchSingleOrNull().map((p) => p?.h3R7);

  /// Reads at most the newest profile row, so the single-row consumers never
  /// throw even if a stray duplicate were ever present.
  SimpleSelectStatement<$ProfilesTable, Profile> _latestProfileQuery() =>
      _db.select(_db.profiles)
        ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])
        ..limit(1);
}

/// Loads the native H3 library once per session (FFI load is not free).
@Riverpod(keepAlive: true)
H3 h3(Ref ref) => const H3Factory().load();

@riverpod
LocationRepository locationRepository(Ref ref) =>
    LocationRepository(ref.watch(databaseProvider), ref.watch(h3Provider));

/// The stored r7 cell (hex), reactive — null until a location is set. Used both
/// to derive the weather centroid and to key the place-label cache (FR-12).
@Riverpod(keepAlive: true)
Stream<String?> gardenCell(Ref ref) =>
    ref.watch(locationRepositoryProvider).watchGardenCell();

/// The garden location for the weather lookup: the centroid of the stored r7
/// cell, or [kDefaultLatitude]/[kDefaultLongitude] until one is set. Reactive —
/// weather re-fetches when the user picks or clears a location.
@Riverpod(keepAlive: true)
Stream<GardenCoords> gardenLocation(Ref ref) {
  final h3 = ref.watch(h3Provider);
  return ref.watch(locationRepositoryProvider).watchGardenCell().map(
        (cell) =>
            cellCentroid(h3, cell) ??
            (latitude: kDefaultLatitude, longitude: kDefaultLongitude),
      );
}
