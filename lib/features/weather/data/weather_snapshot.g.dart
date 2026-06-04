// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeatherSnapshot _$WeatherSnapshotFromJson(Map<String, dynamic> json) =>
    _WeatherSnapshot(
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble(),
      weatherCode: (json['weatherCode'] as num?)?.toInt(),
      soilTemperature: (json['soilTemperature'] as num?)?.toDouble(),
      et0: (json['et0'] as num?)?.toDouble(),
      rainPast48h: (json['rainPast48h'] as num?)?.toDouble(),
      forecast:
          (json['forecast'] as List<dynamic>?)
              ?.map((e) => WeatherDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WeatherDay>[],
    );

Map<String, dynamic> _$WeatherSnapshotToJson(_WeatherSnapshot instance) =>
    <String, dynamic>{
      'capturedAt': instance.capturedAt.toIso8601String(),
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'precipitation': instance.precipitation,
      'windSpeed': instance.windSpeed,
      'weatherCode': instance.weatherCode,
      'soilTemperature': instance.soilTemperature,
      'et0': instance.et0,
      'rainPast48h': instance.rainPast48h,
      'forecast': instance.forecast,
    };

_WeatherDay _$WeatherDayFromJson(Map<String, dynamic> json) => _WeatherDay(
  date: DateTime.parse(json['date'] as String),
  weatherCode: (json['weatherCode'] as num?)?.toInt(),
  tempMax: (json['tempMax'] as num?)?.toDouble(),
  tempMin: (json['tempMin'] as num?)?.toDouble(),
  precipitationSum: (json['precipitationSum'] as num?)?.toDouble(),
  et0: (json['et0'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WeatherDayToJson(_WeatherDay instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'weatherCode': instance.weatherCode,
      'tempMax': instance.tempMax,
      'tempMin': instance.tempMin,
      'precipitationSum': instance.precipitationSum,
      'et0': instance.et0,
    };
