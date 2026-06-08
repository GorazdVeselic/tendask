import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/weather/data/open_meteo_client.dart';

/// Returns a canned body for any request, so client parsing is tested offline.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body, {this.status = 200});

  final String body;
  final int status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

OpenMeteoClient _clientWith(String body, {int status = 200}) {
  final dio = Dio()..httpClientAdapter = _FakeAdapter(body, status: status);
  return OpenMeteoClient(dio);
}

void main() {
  group('OpenMeteoClient.fetch', () {
    test('parses current/hourly/daily into the DTO', () async {
      final client = _clientWith('''
        {
          "latitude": 46.0,
          "longitude": 14.5,
          "current": {"temperature_2m": 20.0, "weather_code": 1, "wind_speed_10m": 7.0},
          "hourly": {"time": ["2026-06-04T12:00"], "precipitation": [0.2]},
          "daily": {"time": ["2026-06-04"], "temperature_2m_max": [24.0]}
        }
      ''');

      final res = await client.fetch(latitude: 46, longitude: 14.5);
      expect(res.latitude, 46.0);
      expect(res.current?.temperature2m, 20.0);
      expect(res.current?.weatherCode, 1);
      expect(res.hourly?.precipitation, [0.2]);
      expect(res.daily?.temperature2mMax, [24.0]);
    });

    test('ignores unknown fields and defaults missing optionals', () async {
      final client = _clientWith(
        '{"latitude": 46.0, "longitude": 14.5, "surprise": 123, '
        '"current": {"temperature_2m": 18.0, "unknown_metric": 5}}',
      );

      final res = await client.fetch(latitude: 46, longitude: 14.5);
      expect(res.current?.temperature2m, 18.0);
      expect(res.hourly, isNull);
      expect(res.daily, isNull);
    });

    test('throws OpenMeteoException on a null body', () async {
      final client = _clientWith('null');
      expect(
        () => client.fetch(latitude: 46, longitude: 14.5),
        throwsA(isA<OpenMeteoException>()),
      );
    });
  });
}
