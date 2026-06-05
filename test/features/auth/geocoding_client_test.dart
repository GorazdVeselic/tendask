import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/location/geocoding_client.dart';

/// Returns a canned body for any request, so parsing is tested offline.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final String body;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(body, 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

(GeocodingClient, _FakeAdapter) _clientWith(String body) {
  final adapter = _FakeAdapter(body);
  final dio = Dio()..httpClientAdapter = adapter;
  return (GeocodingClient(dio), adapter);
}

void main() {
  group('GeocodingClient.search', () {
    test('parses matches with all fields', () async {
      final (client, _) = _clientWith('''
        {"results": [
          {"name": "Šentjur", "latitude": 46.21, "longitude": 15.39,
           "admin1": "Savinjska", "country": "Slovenija"}
        ]}
      ''');

      final places = await client.search('Šentjur', language: 'sl');
      expect(places, hasLength(1));
      expect(places.first.name, 'Šentjur');
      expect(places.first.latitude, 46.21);
      expect(places.first.longitude, 15.39);
      expect(places.first.admin1, 'Savinjska');
      expect(places.first.country, 'Slovenija');
    });

    test('is tolerant: missing optionals default, int coords become double',
        () async {
      // No admin1/country, no name, integer latitude/longitude.
      final (client, _) = _clientWith('''
        {"results": [{"latitude": 46, "longitude": 15}]}
      ''');

      final places = await client.search('x');
      expect(places, hasLength(1));
      expect(places.first.name, ''); // missing name → empty, not a crash
      expect(places.first.admin1, isNull);
      expect(places.first.country, isNull);
      expect(places.first.latitude, 46.0);
      expect(places.first.longitude, 15.0);
    });

    test('returns [] when the API omits results', () async {
      final (client, _) = _clientWith('{}');
      expect(await client.search('nowhere'), isEmpty);
    });

    test('blank query returns [] without a network call', () async {
      final (client, adapter) = _clientWith('{"results": []}');
      expect(await client.search('   '), isEmpty);
      expect(adapter.calls, 0); // short-circuits before hitting the network
    });
  });
}
