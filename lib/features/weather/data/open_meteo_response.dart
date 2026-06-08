import 'package:freezed_annotation/freezed_annotation.dart';

part 'open_meteo_response.freezed.dart';
part 'open_meteo_response.g.dart';

/// Raw Open-Meteo forecast response (transport DTO). Every field is optional so
/// a partial or evolving payload never crashes the parser; the domain snapshot
/// (M4.2) is assembled from this. Field names map the API's snake_case keys.
@freezed
abstract class OpenMeteoResponse with _$OpenMeteoResponse {
  const factory OpenMeteoResponse({
    double? latitude,
    double? longitude,
    OpenMeteoCurrent? current,
    OpenMeteoHourly? hourly,
    OpenMeteoDaily? daily,
  }) = _OpenMeteoResponse;

  factory OpenMeteoResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenMeteoResponseFromJson(json);
}

/// Conditions at the moment of the request — weather band 1 ("ob izvedbi").
@freezed
abstract class OpenMeteoCurrent with _$OpenMeteoCurrent {
  const factory OpenMeteoCurrent({
    String? time,
    @JsonKey(name: 'temperature_2m') double? temperature2m,
    @JsonKey(name: 'relative_humidity_2m') double? relativeHumidity2m,
    double? precipitation,
    @JsonKey(name: 'weather_code') int? weatherCode,
    @JsonKey(name: 'wind_speed_10m') double? windSpeed10m,
  }) = _OpenMeteoCurrent;

  factory OpenMeteoCurrent.fromJson(Map<String, dynamic> json) =>
      _$OpenMeteoCurrentFromJson(json);
}

/// Hourly series covering past_days (band 2, the 24–48 h rain look-back) plus
/// soil temperature. Lists are parallel-indexed with [time].
@freezed
abstract class OpenMeteoHourly with _$OpenMeteoHourly {
  const factory OpenMeteoHourly({
    @Default(<String>[]) List<String> time,
    @JsonKey(name: 'precipitation')
    @Default(<double?>[])
    List<double?> precipitation,
    @JsonKey(name: 'soil_temperature_6cm')
    @Default(<double?>[])
    List<double?> soilTemperature6cm,
  }) = _OpenMeteoHourly;

  factory OpenMeteoHourly.fromJson(Map<String, dynamic> json) =>
      _$OpenMeteoHourlyFromJson(json);
}

/// Daily series for the forecast window (band 3, 24–72 h ahead) plus ET₀.
/// Lists are parallel-indexed with [time].
@freezed
abstract class OpenMeteoDaily with _$OpenMeteoDaily {
  const factory OpenMeteoDaily({
    @Default(<String>[]) List<String> time,
    @JsonKey(name: 'weather_code') @Default(<int?>[]) List<int?> weatherCode,
    @JsonKey(name: 'temperature_2m_max')
    @Default(<double?>[])
    List<double?> temperature2mMax,
    @JsonKey(name: 'temperature_2m_min')
    @Default(<double?>[])
    List<double?> temperature2mMin,
    @JsonKey(name: 'precipitation_sum')
    @Default(<double?>[])
    List<double?> precipitationSum,
    @JsonKey(name: 'et0_fao_evapotranspiration')
    @Default(<double?>[])
    List<double?> et0FaoEvapotranspiration,
  }) = _OpenMeteoDaily;

  factory OpenMeteoDaily.fromJson(Map<String, dynamic> json) =>
      _$OpenMeteoDailyFromJson(json);
}
