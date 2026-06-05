import 'package:drift/drift.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../clock.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../sync/sync_status.dart';
import 'h3_cells.dart';

part 'location_repository.g.dart';

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
      await _db.into(_db.deviceLocations).insertOnConflictUpdate(
            DeviceLocationsCompanion.insert(
              latitude: latitude,
              longitude: longitude,
              updatedAt: now,
            ),
          );
      final exists = await (_db.select(_db.profiles)
            ..where((p) => p.userId.equals(userId)))
          .getSingleOrNull();
      if (exists == null) {
        await _db.into(_db.profiles).insert(ProfilesCompanion.insert(
              userId: userId,
              h3R7: Value(cells.r7),
              h3R6: Value(cells.r6),
              h3R5: Value(cells.r5),
              updatedAt: now,
              syncStatus: const Value(kSyncPending),
            ));
      } else {
        await (_db.update(_db.profiles)..where((p) => p.userId.equals(userId)))
            .write(ProfilesCompanion(
          h3R7: Value(cells.r7),
          h3R6: Value(cells.r6),
          h3R5: Value(cells.r5),
          updatedAt: Value(now),
          syncStatus: const Value(kSyncPending),
        ));
      }
    });
  }

  /// The stored garden coordinates for the weather lookup, or null if unset.
  Future<({double latitude, double longitude})?> gardenCoordinates() async {
    final row = await _db.select(_db.deviceLocations).getSingleOrNull();
    if (row == null) return null;
    return (latitude: row.latitude, longitude: row.longitude);
  }
}

/// Loads the native H3 library once per session (FFI load is not free).
@Riverpod(keepAlive: true)
H3 h3(Ref ref) => const H3Factory().load();

@riverpod
LocationRepository locationRepository(Ref ref) => LocationRepository(
      ref.watch(databaseProvider),
      ref.watch(h3Provider),
    );
