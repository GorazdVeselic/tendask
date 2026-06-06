import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../../../core/location/location_repository.dart';
import '../data/open_meteo_client.dart';
import '../data/weather_cache_repository.dart';
import '../data/weather_snapshot.dart';
import '../data/weather_snapshot_builder.dart';

part 'weather_service.g.dart';

/// Fetches a weather snapshot for a coordinate, with bounded retry/backoff.
/// Offline is a normal state, not an error: after exhausting retries it returns
/// null instead of throwing, so the caller can save the task without weather.
class WeatherService {
  WeatherService(
    this._client,
    this._cache, {
    this._clock = const SystemClock(),
    this._retryDelays = kWeatherRetryDelays,
    this._freshTtl = kWeatherCacheTtl,
    this._staleTtl = kWeatherStaleTtl,
  });

  final OpenMeteoClient _client;
  final WeatherCacheRepository _cache;
  final Clock _clock;
  final List<Duration> _retryDelays;
  final Duration _freshTtl;
  final Duration _staleTtl;

  Future<WeatherSnapshot?> capture({
    required double latitude,
    required double longitude,
  }) async {
    for (var attempt = 0;; attempt++) {
      try {
        final res =
            await _client.fetch(latitude: latitude, longitude: longitude);
        return buildSnapshot(res, at: _clock.now());
      } on Exception catch (e) {
        if (attempt >= _retryDelays.length) {
          debugPrint('Weather capture failed after ${attempt + 1} attempts: $e');
          return null;
        }
        await Future<void>.delayed(_retryDelays[attempt]);
      }
    }
  }

  /// Cached variant for the dashboard, backed by a device-local persistent cache
  /// (survives app restarts). Returns the stored snapshot while it is younger
  /// than [_freshTtl]; otherwise re-fetches. On a failed re-fetch it falls back
  /// to the stored snapshot while it is still within [_staleTtl], else null.
  Future<WeatherSnapshot?> captureCached({
    required double latitude,
    required double longitude,
  }) async {
    final cached = await _cache.load();
    final now = _clock.now();
    if (cached != null && now.difference(cached.capturedAt) < _freshTtl) {
      return cached;
    }
    final fresh = await capture(latitude: latitude, longitude: longitude);
    if (fresh != null) {
      await _cache.save(fresh);
      return fresh;
    }
    // Re-fetch failed (offline): show the last snapshot while it is still recent
    // enough, otherwise degrade to "unavailable".
    if (cached != null && now.difference(cached.capturedAt) < _staleTtl) {
      return cached;
    }
    return null;
  }
}

// keepAlive so the service (and its cache reads) survive between visits to Home.
@Riverpod(keepAlive: true)
WeatherService weatherService(Ref ref) => WeatherService(
      ref.watch(openMeteoClientProvider),
      ref.watch(weatherCacheRepositoryProvider),
    );

/// Live weather for the dashboard (current conditions + short forecast) at the
/// garden location, cached for [kWeatherCacheTtl]. Null when offline with no
/// prior snapshot — the UI degrades to a quiet hint.
@riverpod
Future<WeatherSnapshot?> currentWeather(Ref ref) async {
  final loc = await ref.watch(gardenLocationProvider.future);
  return ref.watch(weatherServiceProvider).captureCached(
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
}
