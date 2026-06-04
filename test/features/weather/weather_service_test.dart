import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/clock.dart';
import 'package:tendask/features/weather/application/weather_service.dart';
import 'package:tendask/features/weather/data/open_meteo_client.dart';
import 'package:tendask/features/weather/data/open_meteo_response.dart';

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
}

WeatherService _service(_StubClient client, _FakeClock clock) => WeatherService(
      client,
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
      final result =
          await _service(client, clock).capture(latitude: 46, longitude: 14.5);
      expect(result, isNull);
    });
  });

  group('WeatherService.captureCached', () {
    test('caches within the TTL and re-fetches after it', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient()..next = _respWithTemp(20);
      final service = _service(client, clock);

      final first =
          await service.captureCached(latitude: 46, longitude: 14.5);
      expect(first?.temperature, 20);
      expect(client.calls, 1);

      // Within TTL → cached, no new fetch even though the source changed.
      clock.advance(const Duration(minutes: 10));
      client.next = _respWithTemp(25);
      final cached =
          await service.captureCached(latitude: 46, longitude: 14.5);
      expect(cached?.temperature, 20);
      expect(client.calls, 1);

      // Past TTL (35 min total) → re-fetch.
      clock.advance(const Duration(minutes: 25));
      final fresh =
          await service.captureCached(latitude: 46, longitude: 14.5);
      expect(fresh?.temperature, 25);
      expect(client.calls, 2);
    });

    test('falls back to the last known snapshot when a re-fetch fails',
        () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient()..next = _respWithTemp(20);
      final service = _service(client, clock);

      await service.captureCached(latitude: 46, longitude: 14.5);

      // TTL expired and now offline — keep showing the last snapshot, not null.
      clock.advance(const Duration(minutes: 40));
      client.next = null;
      final degraded =
          await service.captureCached(latitude: 46, longitude: 14.5);
      expect(degraded?.temperature, 20);
      expect(client.calls, 2);
    });

    test('returns null when offline with no prior snapshot', () async {
      final clock = _FakeClock(DateTime.utc(2026, 6, 4, 12));
      final client = _StubClient(); // always throws
      final service = _service(client, clock);

      final result =
          await service.captureCached(latitude: 46, longitude: 14.5);
      expect(result, isNull);
    });
  });
}
