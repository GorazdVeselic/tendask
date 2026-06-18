import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/features/weather/application/weather_service.dart';
import 'package:tendask/features/weather/data/open_meteo_client.dart';
import 'package:tendask/features/weather/data/open_meteo_response.dart';
import 'package:tendask/features/weather/data/weather_cache_repository.dart';
import 'package:tendask/features/weather/data/weather_snapshot.dart';

class _FakeClock implements Clock {
  _FakeClock(this._now);
  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration d) => _now = _now.add(d);
}

/// Stub transport: returns [next], or throws (offline) when it is null.
class _StubClient implements OpenMeteoClient {
  int calls = 0;
  OpenMeteoResponse? next;

  @override
  Future<OpenMeteoResponse> fetch({
    required double latitude,
    required double longitude,
  }) async {
    calls++;
    final r = next;
    if (r == null) {
      throw DioException(requestOptions: RequestOptions(path: '/forecast'));
    }
    return r;
  }

  @override
  Future<OpenMeteoResponse> fetchCurrent({
    required double latitude,
    required double longitude,
  }) => fetch(latitude: latitude, longitude: longitude);
}

/// In-memory cache standing in for the local_flag-backed repository, with the
/// two independent slots (light dashboard snapshot + full detail snapshot).
class _FakeCache implements WeatherCacheRepository {
  WeatherSnapshot? stored;
  WeatherSnapshot? storedFull;

  @override
  Future<WeatherSnapshot?> load({bool full = false}) async =>
      full ? storedFull : stored;

  @override
  Future<void> save(WeatherSnapshot snapshot, {bool full = false}) async {
    if (full) {
      storedFull = snapshot;
    } else {
      stored = snapshot;
    }
  }
}

WeatherService _service(
  _StubClient client,
  _FakeClock clock, {
  WeatherCacheRepository? cache,
}) => WeatherService(
  client,
  cache ?? _FakeCache(),
  clock: clock,
  retryDelays: const [], // no waiting in tests
);

OpenMeteoResponse _respWithTemp(double temp) =>
    OpenMeteoResponse(current: OpenMeteoCurrent(temperature2m: temp));

void main() {
  group('WeatherService.capture', () {
    test('returns null (no throw) when the client fails', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient(); // next == null → throws
      final result = await _service(
        client,
        clock,
      ).capture(latitude: 46, longitude: 14.5);
      expect(result, isNull);
    });
  });

  group('WeatherService.captureCached', () {
    test('caches within the TTL and re-fetches after it', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient()..next = _respWithTemp(20);
      final service = _service(client, clock);

      final first = await service.captureCached(latitude: 46, longitude: 14.5);
      expect(first?.temperature, 20);
      expect(client.calls, 1);

      // Within TTL → cached, no new fetch even though the source changed.
      clock.advance(const Duration(minutes: 10));
      client.next = _respWithTemp(25);
      final cached = await service.captureCached(latitude: 46, longitude: 14.5);
      expect(cached?.temperature, 20);
      expect(client.calls, 1);

      // Past TTL (35 min total) → re-fetch.
      clock.advance(const Duration(minutes: 25));
      final fresh = await service.captureCached(latitude: 46, longitude: 14.5);
      expect(fresh?.temperature, 25);
      expect(client.calls, 2);
    });

    test('falls back to the last known snapshot when a re-fetch fails', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient()..next = _respWithTemp(20);
      final service = _service(client, clock);

      await service.captureCached(latitude: 46, longitude: 14.5);

      // TTL expired and now offline — keep showing the last snapshot, not null.
      clock.advance(const Duration(minutes: 40));
      client.next = null;
      final degraded = await service.captureCached(
        latitude: 46,
        longitude: 14.5,
      );
      expect(degraded?.temperature, 20);
      expect(client.calls, 2);
    });

    test('keeps a day-old snapshot when offline (within the stale TTL)', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient()..next = _respWithTemp(20);
      final service = _service(client, clock);

      await service.captureCached(latitude: 46, longitude: 14.5);

      // Next morning (24 h later) and offline: still show yesterday's snapshot
      // rather than a blank card.
      clock.advance(const Duration(hours: 24));
      client.next = null;
      final degraded = await service.captureCached(
        latitude: 46,
        longitude: 14.5,
      );
      expect(degraded?.temperature, 20);
    });

    test('drops the stale snapshot once past the stale TTL', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient()..next = _respWithTemp(20);
      final service = _service(client, clock);

      await service.captureCached(latitude: 46, longitude: 14.5);

      // 49 h later and offline: beyond the 48 h stale window → unavailable.
      clock.advance(const Duration(hours: 49));
      client.next = null;
      final result = await service.captureCached(latitude: 46, longitude: 14.5);
      expect(result, isNull);
    });

    test(
      'reuses the persisted snapshot across a new service (restart)',
      () async {
        final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
        final cache = _FakeCache();
        final client = _StubClient()..next = _respWithTemp(20);

        await _service(
          client,
          clock,
          cache: cache,
        ).captureCached(latitude: 46, longitude: 14.5);

        // New service instance (app restart), offline within the fresh TTL →
        // serves the persisted snapshot without any network call.
        final offline = _StubClient(); // always throws
        final restarted = _service(offline, clock, cache: cache);
        final result = await restarted.captureCached(
          latitude: 46,
          longitude: 14.5,
        );
        expect(result?.temperature, 20);
        expect(offline.calls, 0);
      },
    );

    test('returns null when offline with no prior snapshot', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient(); // always throws
      final service = _service(client, clock);

      final result = await service.captureCached(latitude: 46, longitude: 14.5);
      expect(result, isNull);
    });
  });

  group('WeatherService.captureCachedFull', () {
    test('caches in its own slot and re-fetches after the TTL', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final cache = _FakeCache();
      final client = _StubClient()..next = _respWithTemp(20);
      final service = _service(client, clock, cache: cache);

      final first = await service.captureCachedFull(
        latitude: 46,
        longitude: 14.5,
      );
      expect(first?.temperature, 20);
      expect(client.calls, 1);
      // Stored in the full slot, leaving the light slot untouched.
      expect(cache.storedFull?.temperature, 20);
      expect(cache.stored, isNull);

      // Within TTL → served from cache, no new fetch.
      clock.advance(const Duration(minutes: 10));
      client.next = _respWithTemp(25);
      final cached = await service.captureCachedFull(
        latitude: 46,
        longitude: 14.5,
      );
      expect(cached?.temperature, 20);
      expect(client.calls, 1);

      // Past TTL → re-fetch.
      clock.advance(const Duration(minutes: 25));
      final fresh = await service.captureCachedFull(
        latitude: 46,
        longitude: 14.5,
      );
      expect(fresh?.temperature, 25);
      expect(client.calls, 2);
    });

    test('falls back to the last full snapshot when a re-fetch fails', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient()..next = _respWithTemp(20);
      final service = _service(client, clock);

      await service.captureCachedFull(latitude: 46, longitude: 14.5);

      clock.advance(const Duration(minutes: 40));
      client.next = null; // offline
      final degraded = await service.captureCachedFull(
        latitude: 46,
        longitude: 14.5,
      );
      expect(degraded?.temperature, 20);
    });
  });
}
