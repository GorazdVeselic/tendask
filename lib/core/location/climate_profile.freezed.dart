// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'climate_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClimateProfile {

@JsonKey(name: 'elevation_m') double? get elevationM;@JsonKey(name: 't_annual_mean_c') double get tAnnualMeanC;@JsonKey(name: 'temp_monthly_normals_c') List<double> get tempMonthlyNormalsC;@JsonKey(name: 'frost_last_spring_doy') int? get frostLastSpringDoy;@JsonKey(name: 'frost_first_autumn_doy') int? get frostFirstAutumnDoy;@JsonKey(name: 'growing_season_days') int? get growingSeasonDays;@JsonKey(name: 'precip_annual_mm') double? get precipAnnualMm; String? get koppen;@JsonKey(name: 'captured_at') DateTime get capturedAt; String get source;@JsonKey(includeIfNull: false) String? get hemisphere;
/// Create a copy of ClimateProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClimateProfileCopyWith<ClimateProfile> get copyWith => _$ClimateProfileCopyWithImpl<ClimateProfile>(this as ClimateProfile, _$identity);

  /// Serializes this ClimateProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClimateProfile&&(identical(other.elevationM, elevationM) || other.elevationM == elevationM)&&(identical(other.tAnnualMeanC, tAnnualMeanC) || other.tAnnualMeanC == tAnnualMeanC)&&const DeepCollectionEquality().equals(other.tempMonthlyNormalsC, tempMonthlyNormalsC)&&(identical(other.frostLastSpringDoy, frostLastSpringDoy) || other.frostLastSpringDoy == frostLastSpringDoy)&&(identical(other.frostFirstAutumnDoy, frostFirstAutumnDoy) || other.frostFirstAutumnDoy == frostFirstAutumnDoy)&&(identical(other.growingSeasonDays, growingSeasonDays) || other.growingSeasonDays == growingSeasonDays)&&(identical(other.precipAnnualMm, precipAnnualMm) || other.precipAnnualMm == precipAnnualMm)&&(identical(other.koppen, koppen) || other.koppen == koppen)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.source, source) || other.source == source)&&(identical(other.hemisphere, hemisphere) || other.hemisphere == hemisphere));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,elevationM,tAnnualMeanC,const DeepCollectionEquality().hash(tempMonthlyNormalsC),frostLastSpringDoy,frostFirstAutumnDoy,growingSeasonDays,precipAnnualMm,koppen,capturedAt,source,hemisphere);

@override
String toString() {
  return 'ClimateProfile(elevationM: $elevationM, tAnnualMeanC: $tAnnualMeanC, tempMonthlyNormalsC: $tempMonthlyNormalsC, frostLastSpringDoy: $frostLastSpringDoy, frostFirstAutumnDoy: $frostFirstAutumnDoy, growingSeasonDays: $growingSeasonDays, precipAnnualMm: $precipAnnualMm, koppen: $koppen, capturedAt: $capturedAt, source: $source, hemisphere: $hemisphere)';
}


}

/// @nodoc
abstract mixin class $ClimateProfileCopyWith<$Res>  {
  factory $ClimateProfileCopyWith(ClimateProfile value, $Res Function(ClimateProfile) _then) = _$ClimateProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'elevation_m') double? elevationM,@JsonKey(name: 't_annual_mean_c') double tAnnualMeanC,@JsonKey(name: 'temp_monthly_normals_c') List<double> tempMonthlyNormalsC,@JsonKey(name: 'frost_last_spring_doy') int? frostLastSpringDoy,@JsonKey(name: 'frost_first_autumn_doy') int? frostFirstAutumnDoy,@JsonKey(name: 'growing_season_days') int? growingSeasonDays,@JsonKey(name: 'precip_annual_mm') double? precipAnnualMm, String? koppen,@JsonKey(name: 'captured_at') DateTime capturedAt, String source,@JsonKey(includeIfNull: false) String? hemisphere
});




}
/// @nodoc
class _$ClimateProfileCopyWithImpl<$Res>
    implements $ClimateProfileCopyWith<$Res> {
  _$ClimateProfileCopyWithImpl(this._self, this._then);

  final ClimateProfile _self;
  final $Res Function(ClimateProfile) _then;

/// Create a copy of ClimateProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? elevationM = freezed,Object? tAnnualMeanC = null,Object? tempMonthlyNormalsC = null,Object? frostLastSpringDoy = freezed,Object? frostFirstAutumnDoy = freezed,Object? growingSeasonDays = freezed,Object? precipAnnualMm = freezed,Object? koppen = freezed,Object? capturedAt = null,Object? source = null,Object? hemisphere = freezed,}) {
  return _then(_self.copyWith(
elevationM: freezed == elevationM ? _self.elevationM : elevationM // ignore: cast_nullable_to_non_nullable
as double?,tAnnualMeanC: null == tAnnualMeanC ? _self.tAnnualMeanC : tAnnualMeanC // ignore: cast_nullable_to_non_nullable
as double,tempMonthlyNormalsC: null == tempMonthlyNormalsC ? _self.tempMonthlyNormalsC : tempMonthlyNormalsC // ignore: cast_nullable_to_non_nullable
as List<double>,frostLastSpringDoy: freezed == frostLastSpringDoy ? _self.frostLastSpringDoy : frostLastSpringDoy // ignore: cast_nullable_to_non_nullable
as int?,frostFirstAutumnDoy: freezed == frostFirstAutumnDoy ? _self.frostFirstAutumnDoy : frostFirstAutumnDoy // ignore: cast_nullable_to_non_nullable
as int?,growingSeasonDays: freezed == growingSeasonDays ? _self.growingSeasonDays : growingSeasonDays // ignore: cast_nullable_to_non_nullable
as int?,precipAnnualMm: freezed == precipAnnualMm ? _self.precipAnnualMm : precipAnnualMm // ignore: cast_nullable_to_non_nullable
as double?,koppen: freezed == koppen ? _self.koppen : koppen // ignore: cast_nullable_to_non_nullable
as String?,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,hemisphere: freezed == hemisphere ? _self.hemisphere : hemisphere // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClimateProfile].
extension ClimateProfilePatterns on ClimateProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClimateProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClimateProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClimateProfile value)  $default,){
final _that = this;
switch (_that) {
case _ClimateProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClimateProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ClimateProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'elevation_m')  double? elevationM, @JsonKey(name: 't_annual_mean_c')  double tAnnualMeanC, @JsonKey(name: 'temp_monthly_normals_c')  List<double> tempMonthlyNormalsC, @JsonKey(name: 'frost_last_spring_doy')  int? frostLastSpringDoy, @JsonKey(name: 'frost_first_autumn_doy')  int? frostFirstAutumnDoy, @JsonKey(name: 'growing_season_days')  int? growingSeasonDays, @JsonKey(name: 'precip_annual_mm')  double? precipAnnualMm,  String? koppen, @JsonKey(name: 'captured_at')  DateTime capturedAt,  String source, @JsonKey(includeIfNull: false)  String? hemisphere)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClimateProfile() when $default != null:
return $default(_that.elevationM,_that.tAnnualMeanC,_that.tempMonthlyNormalsC,_that.frostLastSpringDoy,_that.frostFirstAutumnDoy,_that.growingSeasonDays,_that.precipAnnualMm,_that.koppen,_that.capturedAt,_that.source,_that.hemisphere);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'elevation_m')  double? elevationM, @JsonKey(name: 't_annual_mean_c')  double tAnnualMeanC, @JsonKey(name: 'temp_monthly_normals_c')  List<double> tempMonthlyNormalsC, @JsonKey(name: 'frost_last_spring_doy')  int? frostLastSpringDoy, @JsonKey(name: 'frost_first_autumn_doy')  int? frostFirstAutumnDoy, @JsonKey(name: 'growing_season_days')  int? growingSeasonDays, @JsonKey(name: 'precip_annual_mm')  double? precipAnnualMm,  String? koppen, @JsonKey(name: 'captured_at')  DateTime capturedAt,  String source, @JsonKey(includeIfNull: false)  String? hemisphere)  $default,) {final _that = this;
switch (_that) {
case _ClimateProfile():
return $default(_that.elevationM,_that.tAnnualMeanC,_that.tempMonthlyNormalsC,_that.frostLastSpringDoy,_that.frostFirstAutumnDoy,_that.growingSeasonDays,_that.precipAnnualMm,_that.koppen,_that.capturedAt,_that.source,_that.hemisphere);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'elevation_m')  double? elevationM, @JsonKey(name: 't_annual_mean_c')  double tAnnualMeanC, @JsonKey(name: 'temp_monthly_normals_c')  List<double> tempMonthlyNormalsC, @JsonKey(name: 'frost_last_spring_doy')  int? frostLastSpringDoy, @JsonKey(name: 'frost_first_autumn_doy')  int? frostFirstAutumnDoy, @JsonKey(name: 'growing_season_days')  int? growingSeasonDays, @JsonKey(name: 'precip_annual_mm')  double? precipAnnualMm,  String? koppen, @JsonKey(name: 'captured_at')  DateTime capturedAt,  String source, @JsonKey(includeIfNull: false)  String? hemisphere)?  $default,) {final _that = this;
switch (_that) {
case _ClimateProfile() when $default != null:
return $default(_that.elevationM,_that.tAnnualMeanC,_that.tempMonthlyNormalsC,_that.frostLastSpringDoy,_that.frostFirstAutumnDoy,_that.growingSeasonDays,_that.precipAnnualMm,_that.koppen,_that.capturedAt,_that.source,_that.hemisphere);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClimateProfile implements ClimateProfile {
  const _ClimateProfile({@JsonKey(name: 'elevation_m') this.elevationM, @JsonKey(name: 't_annual_mean_c') required this.tAnnualMeanC, @JsonKey(name: 'temp_monthly_normals_c') required final  List<double> tempMonthlyNormalsC, @JsonKey(name: 'frost_last_spring_doy') this.frostLastSpringDoy, @JsonKey(name: 'frost_first_autumn_doy') this.frostFirstAutumnDoy, @JsonKey(name: 'growing_season_days') this.growingSeasonDays, @JsonKey(name: 'precip_annual_mm') this.precipAnnualMm, this.koppen, @JsonKey(name: 'captured_at') required this.capturedAt, required this.source, @JsonKey(includeIfNull: false) this.hemisphere}): _tempMonthlyNormalsC = tempMonthlyNormalsC;
  factory _ClimateProfile.fromJson(Map<String, dynamic> json) => _$ClimateProfileFromJson(json);

@override@JsonKey(name: 'elevation_m') final  double? elevationM;
@override@JsonKey(name: 't_annual_mean_c') final  double tAnnualMeanC;
 final  List<double> _tempMonthlyNormalsC;
@override@JsonKey(name: 'temp_monthly_normals_c') List<double> get tempMonthlyNormalsC {
  if (_tempMonthlyNormalsC is EqualUnmodifiableListView) return _tempMonthlyNormalsC;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tempMonthlyNormalsC);
}

@override@JsonKey(name: 'frost_last_spring_doy') final  int? frostLastSpringDoy;
@override@JsonKey(name: 'frost_first_autumn_doy') final  int? frostFirstAutumnDoy;
@override@JsonKey(name: 'growing_season_days') final  int? growingSeasonDays;
@override@JsonKey(name: 'precip_annual_mm') final  double? precipAnnualMm;
@override final  String? koppen;
@override@JsonKey(name: 'captured_at') final  DateTime capturedAt;
@override final  String source;
@override@JsonKey(includeIfNull: false) final  String? hemisphere;

/// Create a copy of ClimateProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClimateProfileCopyWith<_ClimateProfile> get copyWith => __$ClimateProfileCopyWithImpl<_ClimateProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClimateProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClimateProfile&&(identical(other.elevationM, elevationM) || other.elevationM == elevationM)&&(identical(other.tAnnualMeanC, tAnnualMeanC) || other.tAnnualMeanC == tAnnualMeanC)&&const DeepCollectionEquality().equals(other._tempMonthlyNormalsC, _tempMonthlyNormalsC)&&(identical(other.frostLastSpringDoy, frostLastSpringDoy) || other.frostLastSpringDoy == frostLastSpringDoy)&&(identical(other.frostFirstAutumnDoy, frostFirstAutumnDoy) || other.frostFirstAutumnDoy == frostFirstAutumnDoy)&&(identical(other.growingSeasonDays, growingSeasonDays) || other.growingSeasonDays == growingSeasonDays)&&(identical(other.precipAnnualMm, precipAnnualMm) || other.precipAnnualMm == precipAnnualMm)&&(identical(other.koppen, koppen) || other.koppen == koppen)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.source, source) || other.source == source)&&(identical(other.hemisphere, hemisphere) || other.hemisphere == hemisphere));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,elevationM,tAnnualMeanC,const DeepCollectionEquality().hash(_tempMonthlyNormalsC),frostLastSpringDoy,frostFirstAutumnDoy,growingSeasonDays,precipAnnualMm,koppen,capturedAt,source,hemisphere);

@override
String toString() {
  return 'ClimateProfile(elevationM: $elevationM, tAnnualMeanC: $tAnnualMeanC, tempMonthlyNormalsC: $tempMonthlyNormalsC, frostLastSpringDoy: $frostLastSpringDoy, frostFirstAutumnDoy: $frostFirstAutumnDoy, growingSeasonDays: $growingSeasonDays, precipAnnualMm: $precipAnnualMm, koppen: $koppen, capturedAt: $capturedAt, source: $source, hemisphere: $hemisphere)';
}


}

/// @nodoc
abstract mixin class _$ClimateProfileCopyWith<$Res> implements $ClimateProfileCopyWith<$Res> {
  factory _$ClimateProfileCopyWith(_ClimateProfile value, $Res Function(_ClimateProfile) _then) = __$ClimateProfileCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'elevation_m') double? elevationM,@JsonKey(name: 't_annual_mean_c') double tAnnualMeanC,@JsonKey(name: 'temp_monthly_normals_c') List<double> tempMonthlyNormalsC,@JsonKey(name: 'frost_last_spring_doy') int? frostLastSpringDoy,@JsonKey(name: 'frost_first_autumn_doy') int? frostFirstAutumnDoy,@JsonKey(name: 'growing_season_days') int? growingSeasonDays,@JsonKey(name: 'precip_annual_mm') double? precipAnnualMm, String? koppen,@JsonKey(name: 'captured_at') DateTime capturedAt, String source,@JsonKey(includeIfNull: false) String? hemisphere
});




}
/// @nodoc
class __$ClimateProfileCopyWithImpl<$Res>
    implements _$ClimateProfileCopyWith<$Res> {
  __$ClimateProfileCopyWithImpl(this._self, this._then);

  final _ClimateProfile _self;
  final $Res Function(_ClimateProfile) _then;

/// Create a copy of ClimateProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? elevationM = freezed,Object? tAnnualMeanC = null,Object? tempMonthlyNormalsC = null,Object? frostLastSpringDoy = freezed,Object? frostFirstAutumnDoy = freezed,Object? growingSeasonDays = freezed,Object? precipAnnualMm = freezed,Object? koppen = freezed,Object? capturedAt = null,Object? source = null,Object? hemisphere = freezed,}) {
  return _then(_ClimateProfile(
elevationM: freezed == elevationM ? _self.elevationM : elevationM // ignore: cast_nullable_to_non_nullable
as double?,tAnnualMeanC: null == tAnnualMeanC ? _self.tAnnualMeanC : tAnnualMeanC // ignore: cast_nullable_to_non_nullable
as double,tempMonthlyNormalsC: null == tempMonthlyNormalsC ? _self._tempMonthlyNormalsC : tempMonthlyNormalsC // ignore: cast_nullable_to_non_nullable
as List<double>,frostLastSpringDoy: freezed == frostLastSpringDoy ? _self.frostLastSpringDoy : frostLastSpringDoy // ignore: cast_nullable_to_non_nullable
as int?,frostFirstAutumnDoy: freezed == frostFirstAutumnDoy ? _self.frostFirstAutumnDoy : frostFirstAutumnDoy // ignore: cast_nullable_to_non_nullable
as int?,growingSeasonDays: freezed == growingSeasonDays ? _self.growingSeasonDays : growingSeasonDays // ignore: cast_nullable_to_non_nullable
as int?,precipAnnualMm: freezed == precipAnnualMm ? _self.precipAnnualMm : precipAnnualMm // ignore: cast_nullable_to_non_nullable
as double?,koppen: freezed == koppen ? _self.koppen : koppen // ignore: cast_nullable_to_non_nullable
as String?,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,hemisphere: freezed == hemisphere ? _self.hemisphere : hemisphere // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
