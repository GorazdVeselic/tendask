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

/// A garden coordinate pair — stored device-local, used only for the weather
/// lookup. Never synced.
typedef GardenCoords = ({double latitude, double longitude});

/// The garden location, split by privacy: raw coordinates stay device-local
/// (for the weather lookup), only the derived H3 cells reach profile → cloud.
class LocationRepository {
  LocationRepository(this._db, this._h3, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final H3 _h3;
  final Clock _clock;

  /// Persists the garden location for [userId]. Coordinates go to the local-only
  /// device_location table (never synced); the derived H3 cells upsert into
  /// profile (pending → synced by the next push) without clobbering lang.
  Future<void> saveGardenLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    final cells = deriveH3Cells(_h3, latitude, longitude);
    final now = _clock.now();
    await _db.transaction(() async {
      // Singleton table: wipe first so a stray duplicate left by an older
      // schema can't survive and crash the single-row read below.
      await _db.delete(_db.deviceLocations).go();
      await _db
          .into(_db.deviceLocations)
          .insert(
            DeviceLocationsCompanion.insert(
              latitude: latitude,
              longitude: longitude,
              updatedAt: now,
            ),
          );
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

  /// Removes the garden location: deletes the device-local coordinates and
  /// clears the profile H3 cells (pending → push). Weather falls back to the
  /// default region (gardenLocation emits the default when coordinates are null).
  Future<void> clearGardenLocation(String userId) async {
    final now = _clock.now();
    await _db.transaction(() async {
      await _db.delete(_db.deviceLocations).go();
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
    });
  }

  /// The stored garden coordinates for the weather lookup, or null if unset.
  Future<GardenCoords?> gardenCoordinates() async {
    final row = await _latestLocationQuery().getSingleOrNull();
    if (row == null) return null;
    return (latitude: row.latitude, longitude: row.longitude);
  }

  /// Reactive coordinates: emits whenever the stored location changes, so the
  /// weather provider re-fetches after onboarding/settings set it.
  Stream<GardenCoords?> watchGardenCoordinates() {
    return _latestLocationQuery().watchSingleOrNull().map(
      (row) => row == null
          ? null
          : (latitude: row.latitude, longitude: row.longitude),
    );
  }

  /// Reads at most the newest row: tolerant of a stray duplicate left by an
  /// older schema, so the single-row consumers never throw.
  SimpleSelectStatement<$DeviceLocationsTable, DeviceLocation>
  _latestLocationQuery() =>
      _db.select(_db.deviceLocations)
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
        ..limit(1);
}

/// Loads the native H3 library once per session (FFI load is not free).
@Riverpod(keepAlive: true)
H3 h3(Ref ref) => const H3Factory().load();

@riverpod
LocationRepository locationRepository(Ref ref) =>
    LocationRepository(ref.watch(databaseProvider), ref.watch(h3Provider));

/// The garden location for the weather lookup: the stored device-local
/// coordinates, or [kDefaultLatitude]/[kDefaultLongitude] until onboarding sets
/// one. Reactive — weather re-fetches when the user picks a location.
@Riverpod(keepAlive: true)
Stream<GardenCoords> gardenLocation(Ref ref) => ref
    .watch(locationRepositoryProvider)
    .watchGardenCoordinates()
    .map(
      (c) => c ?? (latitude: kDefaultLatitude, longitude: kDefaultLongitude),
    );
