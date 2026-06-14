import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../clock.dart';
import '../config.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../sync/connectivity.dart';
import '../sync/profile_write_guard.dart';
import '../sync/sync_status.dart';
import 'climate_profile.dart';
import 'climate_service.dart';
import 'h3_cells.dart';

part 'location_repository.g.dart';

/// A garden coordinate pair — stored device-local, used only for the weather
/// lookup. Never synced.
typedef GardenCoords = ({double latitude, double longitude});

/// The garden location, split by privacy: raw coordinates stay device-local
/// (for the weather lookup), only the derived H3 cells reach profile → cloud.
class LocationRepository {
  LocationRepository(
    this._db,
    this._h3, {
    this._clock = const SystemClock(),
    this._climate,
    this._deviceTimezone,
    this._isOnline,
  });

  final AppDatabase _db;
  final H3 _h3;
  final Clock _clock;
  final ClimateService? _climate;

  /// One-shot online check (see [profileRowReadyForWrite]); null in tests.
  final OnlineCheck? _isOnline;

  /// IANA timezone of the device — an offline-capable first guess for the
  /// garden's timezone, refined by the archive response when the network is up.
  final Future<String?> Function()? _deviceTimezone;

  /// Persists the garden location for [userId]. Coordinates go to the local-only
  /// device_location table (never synced); the derived H3 cells upsert into
  /// profile (pending → synced by the next push) without clobbering lang.
  Future<void> saveGardenLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    final cells = deriveH3Cells(_h3, latitude, longitude);
    // Offline-capable: the device timezone is saved with the location right
    // away; the climate fetch below refines it asynchronously (docs/m11/07 §7.6).
    final timezone = await _deviceTimezone?.call();
    final now = _clock.now();
    // Decide the merge-vs-insert path BEFORE the transaction: the grace wait
    // uses a watch stream, which must not run inside a write transaction. Lets a
    // first pull land the cloud profile so this write merges (UPDATE) instead of
    // inserting a partial row that clobbers cloud lang / notification_settings.
    final exists = await profileRowReadyForWrite(
      _db,
      userId,
      isOnline: _isOnline,
    );
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
      if (!exists) {
        await _db
            .into(_db.profiles)
            .insert(
              ProfilesCompanion.insert(
                userId: userId,
                h3R7: Value(cells.r7),
                h3R6: Value(cells.r6),
                h3R5: Value(cells.r5),
                timezone: Value(timezone),
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
            // Keep a previously known timezone if the device lookup failed.
            timezone: timezone == null ? const Value.absent() : Value(timezone),
            updatedAt: Value(now),
            syncStatus: const Value(kSyncPending),
          ),
        );
      }
    });
    // Fire-and-forget: never blocks saving the location (garden = no signal is
    // normal); on failure the profile stays null and the next app start with a
    // network silently fills it in (refreshClimateIfStale).
    unawaited(_refreshClimate(userId, cells.r7));
  }

  /// Removes the garden location: deletes the device-local coordinates and
  /// clears the profile H3 cells and the location-derived climate fields
  /// (pending → push). Weather falls back to the default region
  /// (gardenLocation emits the default when coordinates are null).
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
          timezone: const Value(null),
          climateBucket: const Value(null),
          climateProfile: const Value(null),
          updatedAt: Value(now),
          syncStatus: const Value(kSyncPending),
        ),
      );
    });
  }

  /// Silent yearly climate refresh on app start (docs/m11/07 §7.5): re-fetches
  /// when a location is set but the profile is missing (offline onboarding) or
  /// older than [kClimateProfileMaxAge]. Never throws — fire-and-forget caller.
  Future<void> refreshClimateIfStale(String userId) async {
    try {
      final profile = await (_db.select(
        _db.profiles,
      )..where((p) => p.userId.equals(userId))).getSingleOrNull();
      final r7 = profile?.h3R7;
      if (profile == null || r7 == null) return;
      final captured = decodeClimateProfile(profile.climateProfile)?.capturedAt;
      if (captured != null &&
          _clock.now().toUtc().difference(captured) < kClimateProfileMaxAge) {
        return;
      }
      await _refreshClimate(userId, r7);
    } catch (e) {
      debugPrint('Climate refresh failed (non-fatal): $e');
    }
  }

  /// Fetches the climate for the r7 cell CENTROID (raw GPS never leaves the
  /// device — docs/m11/07 §7.1) and writes profile.climate_* + timezone.
  Future<void> _refreshClimate(String userId, String r7) async {
    final climate = _climate;
    if (climate == null) return;
    final centroid = _h3.cellToGeo(BigInt.parse(r7, radix: 16));
    final result = await climate.fetchFor(
      latitude: centroid.lat,
      longitude: centroid.lon,
    );
    if (result == null) return;
    await (_db.update(_db.profiles)..where((p) => p.userId.equals(userId)))
        .write(
          ProfilesCompanion(
            climateProfile: Value(jsonEncode(result.profile.toJson())),
            climateBucket: Value(result.bucket),
            // The archive's timezone is the garden's, finer than the device's.
            timezone: result.timezone == null
                ? const Value.absent()
                : Value(result.timezone),
            updatedAt: Value(_clock.now()),
            syncStatus: const Value(kSyncPending),
          ),
        );
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
LocationRepository locationRepository(Ref ref) => LocationRepository(
  ref.watch(databaseProvider),
  ref.watch(h3Provider),
  climate: ref.watch(climateServiceProvider),
  isOnline: checkOnline,
  deviceTimezone: () async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (e) {
      // A platform-channel failure must never block saving the location.
      debugPrint('Device timezone lookup failed: $e');
      return null;
    }
  },
);

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
