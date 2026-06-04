import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../core/config.dart';
import '../data/open_meteo_client.dart';
import '../data/weather_snapshot.dart';
import '../data/weather_snapshot_builder.dart';

part 'weather_service.g.dart';

/// Fetches a weather snapshot for a coordinate, with bounded retry/backoff.
/// Offline is a normal state, not an error: after exhausting retries it returns
/// null instead of throwing, so the caller can save the task without weather.
class WeatherService {
  WeatherService(
    this._client, {
    this._clock = const SystemClock(),
    this._retryDelays = kWeatherRetryDelays,
    this._cacheTtl = kWeatherCacheTtl,
  });

  final OpenMeteoClient _client;
  final Clock _clock;
  final List<Duration> _retryDelays;
  final Duration _cacheTtl;

  WeatherSnapshot? _cached;
  DateTime? _cachedAt;

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

  /// Cached variant for the dashboard: returns the last snapshot while it is
  /// younger than the TTL, otherwise re-fetches. On a failed re-fetch it falls
  /// back to the last known snapshot (graceful degrade) rather than null.
  Future<WeatherSnapshot?> captureCached({
    required double latitude,
    required double longitude,
  }) async {
    final cached = _cached;
    final at = _cachedAt;
    if (cached != null && at != null &&
        _clock.now().difference(at) < _cacheTtl) {
      return cached;
    }
    final fresh = await capture(latitude: latitude, longitude: longitude);
    if (fresh != null) {
      _cached = fresh;
      _cachedAt = _clock.now();
      return fresh;
    }
    return cached;
  }
}

// keepAlive so the snapshot cache survives between visits to Home.
@Riverpod(keepAlive: true)
WeatherService weatherService(Ref ref) =>
    WeatherService(ref.watch(openMeteoClientProvider));

/// Live weather for the dashboard (current conditions + short forecast) at the
/// default location, cached for [kWeatherCacheTtl]. Null when offline with no
/// prior snapshot — the UI degrades to a quiet hint.
@riverpod
Future<WeatherSnapshot?> currentWeather(Ref ref) =>
    ref.watch(weatherServiceProvider).captureCached(
          latitude: kDefaultLatitude,
          longitude: kDefaultLongitude,
        );
