import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config.dart';

part 'reverse_geocoding_client.g.dart';

/// Thin OSM Nominatim reverse-geocoding client (transport layer): turns the
/// garden cell centroid into a nearby place name for the weather card (FR-12).
/// Throws [DioException] on network failure — the caller degrades gracefully
/// (offline is expected; the last known label is shown instead).
///
/// Privacy: the centroid we send is the same approximate point already sent to
/// Open-Meteo (≤ ~1.4 km), never a raw GPS fix. The User-Agent identifies the
/// app as the OSM usage policy requires.
class ReverseGeocodingClient {
  ReverseGeocodingClient(this._dio);

  final Dio _dio;

  /// Resolves [latitude]/[longitude] to the name of the nearest settlement, or
  /// null when the response carries no usable place name. [language] localizes
  /// the returned name (sl/en/de).
  Future<String?> reverseName(
    double latitude,
    double longitude, {
    String language = 'en',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      kNominatimReverseUrl,
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'zoom': kReverseGeoZoom,
        'format': 'jsonv2',
        'accept-language': language,
      },
      options: Options(headers: {'User-Agent': kReverseGeoUserAgent}),
    );
    return pickPlaceName(res.data);
  }
}

/// The most specific settlement name in a Nominatim reverse response. Prefers a
/// village/town/city over coarser admin areas (a gardener wants "Trzin", not
/// "Domžale municipality"); falls back to the top-level `name`. Returns null when
/// nothing usable is present, so the caller shows no label rather than guessing.
/// Top-level so it is unit-testable without a live HTTP call.
String? pickPlaceName(Map<String, dynamic>? body) {
  if (body == null) return null;
  final address = body['address'];
  if (address is Map<String, dynamic>) {
    for (final key in _placeKeysBySpecificity) {
      final value = address[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }
  final name = body['name'];
  if (name is String && name.trim().isNotEmpty) return name.trim();
  return null;
}

/// Address keys from most to least specific settlement. Coarser admin levels
/// (municipality/county) are last resorts when no named settlement is returned.
const _placeKeysBySpecificity = <String>[
  'village',
  'town',
  'city',
  'hamlet',
  'suburb',
  'city_district',
  'municipality',
  'county',
];

@riverpod
ReverseGeocodingClient reverseGeocodingClient(Ref ref) => ReverseGeocodingClient(
  Dio(
    BaseOptions(
      connectTimeout: kWeatherConnectTimeout,
      receiveTimeout: kWeatherReceiveTimeout,
    ),
  ),
);
