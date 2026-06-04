// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_meteo_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OpenMeteoResponse _$OpenMeteoResponseFromJson(Map<String, dynamic> json) =>
    _OpenMeteoResponse(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      current: json['current'] == null
          ? null
          : OpenMeteoCurrent.fromJson(json['current'] as Map<String, dynamic>),
      hourly: json['hourly'] == null
          ? null
          : OpenMeteoHourly.fromJson(json['hourly'] as Map<String, dynamic>),
      daily: json['daily'] == null
          ? null
          : OpenMeteoDaily.fromJson(json['daily'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenMeteoResponseToJson(_OpenMeteoResponse instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'current': instance.current,
      'hourly': instance.hourly,
      'daily': instance.daily,
    };

_OpenMeteoCurrent _$OpenMeteoCurrentFromJson(Map<String, dynamic> json) =>
    _OpenMeteoCurrent(
      time: json['time'] as String?,
      temperature2m: (json['temperature_2m'] as num?)?.toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      weatherCode: (json['weather_code'] as num?)?.toInt(),
      windSpeed10m: (json['wind_speed_10m'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OpenMeteoCurrentToJson(_OpenMeteoCurrent instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature_2m': instance.temperature2m,
      'relative_humidity_2m': instance.relativeHumidity2m,
      'precipitation': instance.precipitation,
      'weather_code': instance.weatherCode,
      'wind_speed_10m': instance.windSpeed10m,
    };

_OpenMeteoHourly _$OpenMeteoHourlyFromJson(Map<String, dynamic> json) =>
    _OpenMeteoHourly(
      time:
          (json['time'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      precipitation:
          (json['precipitation'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble())
              .toList() ??
          const <double?>[],
      soilTemperature6cm:
          (json['soil_temperature_6cm'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble())
              .toList() ??
          const <double?>[],
    );

Map<String, dynamic> _$OpenMeteoHourlyToJson(_OpenMeteoHourly instance) =>
    <String, dynamic>{
      'time': instance.time,
      'precipitation': instance.precipitation,
      'soil_temperature_6cm': instance.soilTemperature6cm,
    };

_OpenMeteoDaily _$OpenMeteoDailyFromJson(Map<String, dynamic> json) =>
    _OpenMeteoDaily(
      time:
          (json['time'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      weatherCode:
          (json['weather_code'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toInt())
              .toList() ??
          const <int?>[],
      temperature2mMax:
          (json['temperature_2m_max'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble())
              .toList() ??
          const <double?>[],
      temperature2mMin:
          (json['temperature_2m_min'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble())
              .toList() ??
          const <double?>[],
      precipitationSum:
          (json['precipitation_sum'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble())
              .toList() ??
          const <double?>[],
      et0FaoEvapotranspiration:
          (json['et0_fao_evapotranspiration'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble())
              .toList() ??
          const <double?>[],
    );

Map<String, dynamic> _$OpenMeteoDailyToJson(_OpenMeteoDaily instance) =>
    <String, dynamic>{
      'time': instance.time,
      'weather_code': instance.weatherCode,
      'temperature_2m_max': instance.temperature2mMax,
      'temperature_2m_min': instance.temperature2mMin,
      'precipitation_sum': instance.precipitationSum,
      'et0_fao_evapotranspiration': instance.et0FaoEvapotranspiration,
    };
