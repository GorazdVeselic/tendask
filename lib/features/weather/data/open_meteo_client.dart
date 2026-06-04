import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'open_meteo_response.dart';

part 'open_meteo_client.g.dart';

/// Thin Open-Meteo forecast client. One request fetches all three weather bands
/// (current · past_days look-back · forecast) plus soil temperature and ET₀.
///
/// This is the transport layer: it throws [DioException] on network failure and
/// [OpenMeteoException] on a malformed body. Retry/backoff and graceful offline
/// degradation are the snapshot service's job (M4.2), not the client's.
class OpenMeteoClient {
  OpenMeteoClient(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const _current =
      'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m';
  static const _hourly = 'precipitation,soil_temperature_6cm';
  static const _daily =
      'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,'
      'et0_fao_evapotranspiration';

  /// Fetches the forecast for a coordinate. Covers §7.10's bands: 2 days back
  /// (rain look-back) and 3 days ahead (forecast).
  Future<OpenMeteoResponse> fetch({
    required double latitude,
    required double longitude,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _baseUrl,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current': _current,
        'hourly': _hourly,
        'daily': _daily,
        'past_days': 2,
        'forecast_days': 3,
        'timezone': 'auto',
      },
    );
    final data = res.data;
    if (data == null) {
      throw const OpenMeteoException('Empty Open-Meteo response body');
    }
    return OpenMeteoResponse.fromJson(data);
  }
}

/// Raised when Open-Meteo returns a response that cannot be parsed.
class OpenMeteoException implements Exception {
  const OpenMeteoException(this.message);
  final String message;

  @override
  String toString() => 'OpenMeteoException: $message';
}

@riverpod
Dio weatherDio(Ref ref) => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

@riverpod
OpenMeteoClient openMeteoClient(Ref ref) =>
    OpenMeteoClient(ref.watch(weatherDioProvider));
