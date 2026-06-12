// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'climate_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClimateProfile _$ClimateProfileFromJson(Map<String, dynamic> json) =>
    _ClimateProfile(
      elevationM: (json['elevation_m'] as num?)?.toDouble(),
      tAnnualMeanC: (json['t_annual_mean_c'] as num).toDouble(),
      tempMonthlyNormalsC: (json['temp_monthly_normals_c'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      frostLastSpringDoy: (json['frost_last_spring_doy'] as num?)?.toInt(),
      frostFirstAutumnDoy: (json['frost_first_autumn_doy'] as num?)?.toInt(),
      growingSeasonDays: (json['growing_season_days'] as num?)?.toInt(),
      precipAnnualMm: (json['precip_annual_mm'] as num?)?.toDouble(),
      koppen: json['koppen'] as String?,
      capturedAt: DateTime.parse(json['captured_at'] as String),
      source: json['source'] as String,
      hemisphere: json['hemisphere'] as String?,
    );

Map<String, dynamic> _$ClimateProfileToJson(_ClimateProfile instance) =>
    <String, dynamic>{
      'elevation_m': instance.elevationM,
      't_annual_mean_c': instance.tAnnualMeanC,
      'temp_monthly_normals_c': instance.tempMonthlyNormalsC,
      'frost_last_spring_doy': instance.frostLastSpringDoy,
      'frost_first_autumn_doy': instance.frostFirstAutumnDoy,
      'growing_season_days': instance.growingSeasonDays,
      'precip_annual_mm': instance.precipAnnualMm,
      'koppen': instance.koppen,
      'captured_at': instance.capturedAt.toIso8601String(),
      'source': instance.source,
      'hemisphere': ?instance.hemisphere,
    };
