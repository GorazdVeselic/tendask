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
  });

  final OpenMeteoClient _client;
  final Clock _clock;
  final List<Duration> _retryDelays;

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
}

@riverpod
WeatherService weatherService(Ref ref) =>
    WeatherService(ref.watch(openMeteoClientProvider));
