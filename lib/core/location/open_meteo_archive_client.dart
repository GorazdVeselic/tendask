import 'package:dio/dio.dart';

/// One parsed Open-Meteo Historical Weather (ERA5) response: daily minimum and
/// mean temperatures over the requested years, plus the cell's elevation and
/// IANA timezone. Tolerant: missing fields become null, array gaps stay null.
class ArchiveResponse {
  const ArchiveResponse({
    required this.latitude,
    required this.elevationM,
    required this.timezone,
    required this.days,
    required this.tMin,
    required this.tMean,
  });

  /// Parses the raw archive JSON. Throws [FormatException] when the daily
  /// arrays are absent or misaligned — the caller treats that as a failed fetch.
  factory ArchiveResponse.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'];
    if (daily is! Map<String, dynamic>) {
      throw const FormatException('archive response has no daily block');
    }
    final time = daily['time'];
    if (time is! List) {
      throw const FormatException('archive response has no daily.time');
    }
    List<double?> numbers(Object? v) => [
      if (v is List)
        for (final e in v) (e as num?)?.toDouble(),
    ];
    final days = [for (final t in time) DateTime.parse(t as String)];
    final tMin = numbers(daily['temperature_2m_min']);
    final tMean = numbers(daily['temperature_2m_mean']);
    if (tMin.length != days.length || tMean.length != days.length) {
      throw const FormatException('archive daily arrays misaligned');
    }
    return ArchiveResponse(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      elevationM: (json['elevation'] as num?)?.toDouble(),
      timezone: json['timezone'] as String?,
      days: days,
      tMin: tMin,
      tMean: tMean,
    );
  }

  final double latitude;
  final double? elevationM;
  final String? timezone;
  final List<DateTime> days;
  final List<double?> tMin;
  final List<double?> tMean;
}

/// Thin Open-Meteo Historical Weather API client (ERA5 reanalysis, no key).
/// Transport layer only: throws on network/parse failure; retry/backoff and
/// graceful offline degradation are [ClimateService]'s job (same split as
/// OpenMeteoClient ↔ WeatherService).
class OpenMeteoArchiveClient {
  OpenMeteoArchiveClient(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://archive-api.open-meteo.com/v1/archive';

  /// Fetches [years] full calendar years of daily data ending with [lastYear]
  /// (ERA5 lags ~5 days, so the caller passes last year for stable, complete
  /// seasons year-round — docs/m11/07 §7.1).
  Future<ArchiveResponse> fetch({
    required double latitude,
    required double longitude,
    required int lastYear,
    required int years,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _baseUrl,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'start_date': '${lastYear - years + 1}-01-01',
        'end_date': '$lastYear-12-31',
        'daily': 'temperature_2m_min,temperature_2m_mean',
        'timezone': 'auto',
      },
    );
    final data = res.data;
    if (data == null) {
      throw const FormatException('empty archive response body');
    }
    return ArchiveResponse.fromJson(data);
  }
}
