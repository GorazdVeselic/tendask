import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_snapshot.freezed.dart';
part 'weather_snapshot.g.dart';

/// Frozen weather snapshot stored on a task/note (`weather` JSON column). Holds
/// the three bands of §7.10: conditions at capture, the 48 h rain look-back, and
/// the short forecast. Set once on completion and never overwritten.
@freezed
abstract class WeatherSnapshot with _$WeatherSnapshot {
  const factory WeatherSnapshot({
    required DateTime capturedAt,
    // Band 1 — conditions at capture.
    double? temperature,
    double? humidity,
    double? precipitation,
    double? windSpeed,
    int? weatherCode,
    double? soilTemperature,
    double? et0,
    // Band 2 — rain accumulated over the past ~48 h (key for spraying).
    double? rainPast48h,
    // Band 3 — short forecast (up to 3 days ahead).
    @Default(<WeatherDay>[]) List<WeatherDay> forecast,
  }) = _WeatherSnapshot;

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) =>
      _$WeatherSnapshotFromJson(json);
}

/// One forecast day (band 3).
@freezed
abstract class WeatherDay with _$WeatherDay {
  const factory WeatherDay({
    required DateTime date,
    int? weatherCode,
    double? tempMax,
    double? tempMin,
    double? precipitationSum,
    double? et0,
  }) = _WeatherDay;

  factory WeatherDay.fromJson(Map<String, dynamic> json) =>
      _$WeatherDayFromJson(json);
}
