import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config.dart';

part 'geocoding_client.g.dart';

/// A place match from Open-Meteo's geocoding API (free, no key). Used when the
/// gardener types a place name instead of granting GPS; the resolved lat/lon
/// feeds the same on-device H3 derivation — raw coordinates never leave the
/// device.
class GeoPlace {
  const GeoPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.admin1,
    this.country,
  });

  final String name;
  final double latitude;
  final double longitude;

  /// Region/state (e.g. "Savinjska"), null when the API omits it.
  final String? admin1;
  final String? country;
}

/// Thin Open-Meteo geocoding client (transport layer). Throws [DioException] on
/// network failure — the caller degrades gracefully (offline is expected).
class GeocodingClient {
  GeocodingClient(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  /// Resolves a place query to candidate coordinates (best matches first).
  /// Returns [] for a blank query or when nothing matches. [language] localizes
  /// the returned names (sl/en/de).
  Future<List<GeoPlace>> search(String query, {String language = 'en'}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final res = await _dio.get<Map<String, dynamic>>(
      _baseUrl,
      queryParameters: {
        'name': q,
        'count': 5,
        'language': language,
        'format': 'json',
      },
    );
    final results = res.data?['results'];
    if (results is! List) return const [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(_fromJson)
        .toList(growable: false);
  }

  GeoPlace _fromJson(Map<String, dynamic> j) => GeoPlace(
    name: j['name'] as String? ?? '',
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    admin1: j['admin1'] as String?,
    country: j['country'] as String?,
  );
}

@riverpod
GeocodingClient geocodingClient(Ref ref) => GeocodingClient(
  Dio(
    BaseOptions(
      connectTimeout: kWeatherConnectTimeout,
      receiveTimeout: kWeatherReceiveTimeout,
    ),
  ),
);
