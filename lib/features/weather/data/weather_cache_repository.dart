import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import 'weather_snapshot.dart';

part 'weather_cache_repository.g.dart';

const _kWeatherSnapshot = 'weather_snapshot';

/// Persists the dashboard's last weather snapshot (device-local, never synced)
/// in the local_flag store, so it survives app restarts and can be shown stale
/// when an offline re-fetch fails (CLAUDE.md §"Network & offline").
class WeatherCacheRepository {
  WeatherCacheRepository(this._db);

  final AppDatabase _db;

  /// The last persisted snapshot, or null when none/unparseable.
  Future<WeatherSnapshot?> load() async {
    final row = await (_db.select(_db.localFlags)
          ..where((f) => f.key.equals(_kWeatherSnapshot)))
        .getSingleOrNull();
    return decodeWeatherSnapshot(row?.value);
  }

  Future<void> save(WeatherSnapshot snapshot) =>
      _db.into(_db.localFlags).insertOnConflictUpdate(
            LocalFlagsCompanion.insert(
              key: _kWeatherSnapshot,
              value: jsonEncode(snapshot.toJson()),
            ),
          );
}

@riverpod
WeatherCacheRepository weatherCacheRepository(Ref ref) =>
    WeatherCacheRepository(ref.watch(databaseProvider));
