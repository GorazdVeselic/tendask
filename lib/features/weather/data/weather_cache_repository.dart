import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import 'weather_snapshot.dart';

part 'weather_cache_repository.g.dart';

const _kWeatherSnapshot = 'weather_snapshot';
const _kWeatherSnapshotFull = 'weather_snapshot_full';

/// Persists the last weather snapshot (device-local, never synced) in the
/// local_flag store, so it survives app restarts and can be shown stale when an
/// offline re-fetch fails (CLAUDE.md §"Network & offline"). Two slots: the light
/// dashboard snapshot ([full] = false) and the richer detail-sheet snapshot
/// ([full] = true), cached independently.
class WeatherCacheRepository {
  WeatherCacheRepository(this._db);

  final AppDatabase _db;

  /// The last persisted snapshot for the slot, or null when none/unparseable.
  Future<WeatherSnapshot?> load({bool full = false}) async {
    final key = full ? _kWeatherSnapshotFull : _kWeatherSnapshot;
    final row = await (_db.select(
      _db.localFlags,
    )..where((f) => f.key.equals(key))).getSingleOrNull();
    return decodeWeatherSnapshot(row?.value);
  }

  Future<void> save(WeatherSnapshot snapshot, {bool full = false}) => _db
      .into(_db.localFlags)
      .insertOnConflictUpdate(
        LocalFlagsCompanion.insert(
          key: full ? _kWeatherSnapshotFull : _kWeatherSnapshot,
          value: jsonEncode(snapshot.toJson()),
        ),
      );
}

@riverpod
WeatherCacheRepository weatherCacheRepository(Ref ref) =>
    WeatherCacheRepository(ref.watch(databaseProvider));
