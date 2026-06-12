import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'climate_profile.freezed.dart';
part 'climate_profile.g.dart';

/// Decodes a stored `climate_profile` JSON column, or null when empty or
/// unparseable (tolerant — a malformed/legacy payload must never crash).
ClimateProfile? decodeClimateProfile(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    return ClimateProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

/// Rich owner-only climate profile (docs/m11/07 §7.4), computed on-device from
/// the Open-Meteo ERA5 archive and stored as `profile.climate_profile` jsonb.
/// JSON keys are snake_case by contract — the server engine reads them.
@freezed
abstract class ClimateProfile with _$ClimateProfile {
  const factory ClimateProfile({
    @JsonKey(name: 'elevation_m') double? elevationM,
    @JsonKey(name: 't_annual_mean_c') required double tAnnualMeanC,
    @JsonKey(name: 'temp_monthly_normals_c')
    required List<double> tempMonthlyNormalsC,
    @JsonKey(name: 'frost_last_spring_doy') int? frostLastSpringDoy,
    @JsonKey(name: 'frost_first_autumn_doy') int? frostFirstAutumnDoy,
    @JsonKey(name: 'growing_season_days') int? growingSeasonDays,
    // Reserved null fields — filled in later without a migration (§7.4).
    @JsonKey(name: 'precip_annual_mm') double? precipAnnualMm,
    String? koppen,
    @JsonKey(name: 'captured_at') required DateTime capturedAt,
    required String source,
    // 'south' only; northern hemisphere = key absent (tolerant parser).
    @JsonKey(includeIfNull: false) String? hemisphere,
  }) = _ClimateProfile;

  factory ClimateProfile.fromJson(Map<String, dynamic> json) =>
      _$ClimateProfileFromJson(json);
}
