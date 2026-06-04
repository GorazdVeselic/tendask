// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'open_meteo_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OpenMeteoResponse {

 double? get latitude; double? get longitude; OpenMeteoCurrent? get current; OpenMeteoHourly? get hourly; OpenMeteoDaily? get daily;
/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenMeteoResponseCopyWith<OpenMeteoResponse> get copyWith => _$OpenMeteoResponseCopyWithImpl<OpenMeteoResponse>(this as OpenMeteoResponse, _$identity);

  /// Serializes this OpenMeteoResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenMeteoResponse&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.current, current) || other.current == current)&&(identical(other.hourly, hourly) || other.hourly == hourly)&&(identical(other.daily, daily) || other.daily == daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,current,hourly,daily);

@override
String toString() {
  return 'OpenMeteoResponse(latitude: $latitude, longitude: $longitude, current: $current, hourly: $hourly, daily: $daily)';
}


}

/// @nodoc
abstract mixin class $OpenMeteoResponseCopyWith<$Res>  {
  factory $OpenMeteoResponseCopyWith(OpenMeteoResponse value, $Res Function(OpenMeteoResponse) _then) = _$OpenMeteoResponseCopyWithImpl;
@useResult
$Res call({
 double? latitude, double? longitude, OpenMeteoCurrent? current, OpenMeteoHourly? hourly, OpenMeteoDaily? daily
});


$OpenMeteoCurrentCopyWith<$Res>? get current;$OpenMeteoHourlyCopyWith<$Res>? get hourly;$OpenMeteoDailyCopyWith<$Res>? get daily;

}
/// @nodoc
class _$OpenMeteoResponseCopyWithImpl<$Res>
    implements $OpenMeteoResponseCopyWith<$Res> {
  _$OpenMeteoResponseCopyWithImpl(this._self, this._then);

  final OpenMeteoResponse _self;
  final $Res Function(OpenMeteoResponse) _then;

/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = freezed,Object? longitude = freezed,Object? current = freezed,Object? hourly = freezed,Object? daily = freezed,}) {
  return _then(_self.copyWith(
latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as OpenMeteoCurrent?,hourly: freezed == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as OpenMeteoHourly?,daily: freezed == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as OpenMeteoDaily?,
  ));
}
/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenMeteoCurrentCopyWith<$Res>? get current {
    if (_self.current == null) {
    return null;
  }

  return $OpenMeteoCurrentCopyWith<$Res>(_self.current!, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenMeteoHourlyCopyWith<$Res>? get hourly {
    if (_self.hourly == null) {
    return null;
  }

  return $OpenMeteoHourlyCopyWith<$Res>(_self.hourly!, (value) {
    return _then(_self.copyWith(hourly: value));
  });
}/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenMeteoDailyCopyWith<$Res>? get daily {
    if (_self.daily == null) {
    return null;
  }

  return $OpenMeteoDailyCopyWith<$Res>(_self.daily!, (value) {
    return _then(_self.copyWith(daily: value));
  });
}
}


/// Adds pattern-matching-related methods to [OpenMeteoResponse].
extension OpenMeteoResponsePatterns on OpenMeteoResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenMeteoResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenMeteoResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenMeteoResponse value)  $default,){
final _that = this;
switch (_that) {
case _OpenMeteoResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenMeteoResponse value)?  $default,){
final _that = this;
switch (_that) {
case _OpenMeteoResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? latitude,  double? longitude,  OpenMeteoCurrent? current,  OpenMeteoHourly? hourly,  OpenMeteoDaily? daily)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenMeteoResponse() when $default != null:
return $default(_that.latitude,_that.longitude,_that.current,_that.hourly,_that.daily);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? latitude,  double? longitude,  OpenMeteoCurrent? current,  OpenMeteoHourly? hourly,  OpenMeteoDaily? daily)  $default,) {final _that = this;
switch (_that) {
case _OpenMeteoResponse():
return $default(_that.latitude,_that.longitude,_that.current,_that.hourly,_that.daily);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? latitude,  double? longitude,  OpenMeteoCurrent? current,  OpenMeteoHourly? hourly,  OpenMeteoDaily? daily)?  $default,) {final _that = this;
switch (_that) {
case _OpenMeteoResponse() when $default != null:
return $default(_that.latitude,_that.longitude,_that.current,_that.hourly,_that.daily);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenMeteoResponse implements OpenMeteoResponse {
  const _OpenMeteoResponse({this.latitude, this.longitude, this.current, this.hourly, this.daily});
  factory _OpenMeteoResponse.fromJson(Map<String, dynamic> json) => _$OpenMeteoResponseFromJson(json);

@override final  double? latitude;
@override final  double? longitude;
@override final  OpenMeteoCurrent? current;
@override final  OpenMeteoHourly? hourly;
@override final  OpenMeteoDaily? daily;

/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenMeteoResponseCopyWith<_OpenMeteoResponse> get copyWith => __$OpenMeteoResponseCopyWithImpl<_OpenMeteoResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenMeteoResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenMeteoResponse&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.current, current) || other.current == current)&&(identical(other.hourly, hourly) || other.hourly == hourly)&&(identical(other.daily, daily) || other.daily == daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,current,hourly,daily);

@override
String toString() {
  return 'OpenMeteoResponse(latitude: $latitude, longitude: $longitude, current: $current, hourly: $hourly, daily: $daily)';
}


}

/// @nodoc
abstract mixin class _$OpenMeteoResponseCopyWith<$Res> implements $OpenMeteoResponseCopyWith<$Res> {
  factory _$OpenMeteoResponseCopyWith(_OpenMeteoResponse value, $Res Function(_OpenMeteoResponse) _then) = __$OpenMeteoResponseCopyWithImpl;
@override @useResult
$Res call({
 double? latitude, double? longitude, OpenMeteoCurrent? current, OpenMeteoHourly? hourly, OpenMeteoDaily? daily
});


@override $OpenMeteoCurrentCopyWith<$Res>? get current;@override $OpenMeteoHourlyCopyWith<$Res>? get hourly;@override $OpenMeteoDailyCopyWith<$Res>? get daily;

}
/// @nodoc
class __$OpenMeteoResponseCopyWithImpl<$Res>
    implements _$OpenMeteoResponseCopyWith<$Res> {
  __$OpenMeteoResponseCopyWithImpl(this._self, this._then);

  final _OpenMeteoResponse _self;
  final $Res Function(_OpenMeteoResponse) _then;

/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = freezed,Object? longitude = freezed,Object? current = freezed,Object? hourly = freezed,Object? daily = freezed,}) {
  return _then(_OpenMeteoResponse(
latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as OpenMeteoCurrent?,hourly: freezed == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as OpenMeteoHourly?,daily: freezed == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as OpenMeteoDaily?,
  ));
}

/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenMeteoCurrentCopyWith<$Res>? get current {
    if (_self.current == null) {
    return null;
  }

  return $OpenMeteoCurrentCopyWith<$Res>(_self.current!, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenMeteoHourlyCopyWith<$Res>? get hourly {
    if (_self.hourly == null) {
    return null;
  }

  return $OpenMeteoHourlyCopyWith<$Res>(_self.hourly!, (value) {
    return _then(_self.copyWith(hourly: value));
  });
}/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenMeteoDailyCopyWith<$Res>? get daily {
    if (_self.daily == null) {
    return null;
  }

  return $OpenMeteoDailyCopyWith<$Res>(_self.daily!, (value) {
    return _then(_self.copyWith(daily: value));
  });
}
}


/// @nodoc
mixin _$OpenMeteoCurrent {

 String? get time;@JsonKey(name: 'temperature_2m') double? get temperature2m;@JsonKey(name: 'relative_humidity_2m') double? get relativeHumidity2m; double? get precipitation;@JsonKey(name: 'weather_code') int? get weatherCode;@JsonKey(name: 'wind_speed_10m') double? get windSpeed10m;
/// Create a copy of OpenMeteoCurrent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenMeteoCurrentCopyWith<OpenMeteoCurrent> get copyWith => _$OpenMeteoCurrentCopyWithImpl<OpenMeteoCurrent>(this as OpenMeteoCurrent, _$identity);

  /// Serializes this OpenMeteoCurrent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenMeteoCurrent&&(identical(other.time, time) || other.time == time)&&(identical(other.temperature2m, temperature2m) || other.temperature2m == temperature2m)&&(identical(other.relativeHumidity2m, relativeHumidity2m) || other.relativeHumidity2m == relativeHumidity2m)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.windSpeed10m, windSpeed10m) || other.windSpeed10m == windSpeed10m));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,time,temperature2m,relativeHumidity2m,precipitation,weatherCode,windSpeed10m);

@override
String toString() {
  return 'OpenMeteoCurrent(time: $time, temperature2m: $temperature2m, relativeHumidity2m: $relativeHumidity2m, precipitation: $precipitation, weatherCode: $weatherCode, windSpeed10m: $windSpeed10m)';
}


}

/// @nodoc
abstract mixin class $OpenMeteoCurrentCopyWith<$Res>  {
  factory $OpenMeteoCurrentCopyWith(OpenMeteoCurrent value, $Res Function(OpenMeteoCurrent) _then) = _$OpenMeteoCurrentCopyWithImpl;
@useResult
$Res call({
 String? time,@JsonKey(name: 'temperature_2m') double? temperature2m,@JsonKey(name: 'relative_humidity_2m') double? relativeHumidity2m, double? precipitation,@JsonKey(name: 'weather_code') int? weatherCode,@JsonKey(name: 'wind_speed_10m') double? windSpeed10m
});




}
/// @nodoc
class _$OpenMeteoCurrentCopyWithImpl<$Res>
    implements $OpenMeteoCurrentCopyWith<$Res> {
  _$OpenMeteoCurrentCopyWithImpl(this._self, this._then);

  final OpenMeteoCurrent _self;
  final $Res Function(OpenMeteoCurrent) _then;

/// Create a copy of OpenMeteoCurrent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = freezed,Object? temperature2m = freezed,Object? relativeHumidity2m = freezed,Object? precipitation = freezed,Object? weatherCode = freezed,Object? windSpeed10m = freezed,}) {
  return _then(_self.copyWith(
time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,temperature2m: freezed == temperature2m ? _self.temperature2m : temperature2m // ignore: cast_nullable_to_non_nullable
as double?,relativeHumidity2m: freezed == relativeHumidity2m ? _self.relativeHumidity2m : relativeHumidity2m // ignore: cast_nullable_to_non_nullable
as double?,precipitation: freezed == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double?,weatherCode: freezed == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int?,windSpeed10m: freezed == windSpeed10m ? _self.windSpeed10m : windSpeed10m // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenMeteoCurrent].
extension OpenMeteoCurrentPatterns on OpenMeteoCurrent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenMeteoCurrent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenMeteoCurrent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenMeteoCurrent value)  $default,){
final _that = this;
switch (_that) {
case _OpenMeteoCurrent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenMeteoCurrent value)?  $default,){
final _that = this;
switch (_that) {
case _OpenMeteoCurrent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? time, @JsonKey(name: 'temperature_2m')  double? temperature2m, @JsonKey(name: 'relative_humidity_2m')  double? relativeHumidity2m,  double? precipitation, @JsonKey(name: 'weather_code')  int? weatherCode, @JsonKey(name: 'wind_speed_10m')  double? windSpeed10m)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenMeteoCurrent() when $default != null:
return $default(_that.time,_that.temperature2m,_that.relativeHumidity2m,_that.precipitation,_that.weatherCode,_that.windSpeed10m);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? time, @JsonKey(name: 'temperature_2m')  double? temperature2m, @JsonKey(name: 'relative_humidity_2m')  double? relativeHumidity2m,  double? precipitation, @JsonKey(name: 'weather_code')  int? weatherCode, @JsonKey(name: 'wind_speed_10m')  double? windSpeed10m)  $default,) {final _that = this;
switch (_that) {
case _OpenMeteoCurrent():
return $default(_that.time,_that.temperature2m,_that.relativeHumidity2m,_that.precipitation,_that.weatherCode,_that.windSpeed10m);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? time, @JsonKey(name: 'temperature_2m')  double? temperature2m, @JsonKey(name: 'relative_humidity_2m')  double? relativeHumidity2m,  double? precipitation, @JsonKey(name: 'weather_code')  int? weatherCode, @JsonKey(name: 'wind_speed_10m')  double? windSpeed10m)?  $default,) {final _that = this;
switch (_that) {
case _OpenMeteoCurrent() when $default != null:
return $default(_that.time,_that.temperature2m,_that.relativeHumidity2m,_that.precipitation,_that.weatherCode,_that.windSpeed10m);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenMeteoCurrent implements OpenMeteoCurrent {
  const _OpenMeteoCurrent({this.time, @JsonKey(name: 'temperature_2m') this.temperature2m, @JsonKey(name: 'relative_humidity_2m') this.relativeHumidity2m, this.precipitation, @JsonKey(name: 'weather_code') this.weatherCode, @JsonKey(name: 'wind_speed_10m') this.windSpeed10m});
  factory _OpenMeteoCurrent.fromJson(Map<String, dynamic> json) => _$OpenMeteoCurrentFromJson(json);

@override final  String? time;
@override@JsonKey(name: 'temperature_2m') final  double? temperature2m;
@override@JsonKey(name: 'relative_humidity_2m') final  double? relativeHumidity2m;
@override final  double? precipitation;
@override@JsonKey(name: 'weather_code') final  int? weatherCode;
@override@JsonKey(name: 'wind_speed_10m') final  double? windSpeed10m;

/// Create a copy of OpenMeteoCurrent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenMeteoCurrentCopyWith<_OpenMeteoCurrent> get copyWith => __$OpenMeteoCurrentCopyWithImpl<_OpenMeteoCurrent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenMeteoCurrentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenMeteoCurrent&&(identical(other.time, time) || other.time == time)&&(identical(other.temperature2m, temperature2m) || other.temperature2m == temperature2m)&&(identical(other.relativeHumidity2m, relativeHumidity2m) || other.relativeHumidity2m == relativeHumidity2m)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.windSpeed10m, windSpeed10m) || other.windSpeed10m == windSpeed10m));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,time,temperature2m,relativeHumidity2m,precipitation,weatherCode,windSpeed10m);

@override
String toString() {
  return 'OpenMeteoCurrent(time: $time, temperature2m: $temperature2m, relativeHumidity2m: $relativeHumidity2m, precipitation: $precipitation, weatherCode: $weatherCode, windSpeed10m: $windSpeed10m)';
}


}

/// @nodoc
abstract mixin class _$OpenMeteoCurrentCopyWith<$Res> implements $OpenMeteoCurrentCopyWith<$Res> {
  factory _$OpenMeteoCurrentCopyWith(_OpenMeteoCurrent value, $Res Function(_OpenMeteoCurrent) _then) = __$OpenMeteoCurrentCopyWithImpl;
@override @useResult
$Res call({
 String? time,@JsonKey(name: 'temperature_2m') double? temperature2m,@JsonKey(name: 'relative_humidity_2m') double? relativeHumidity2m, double? precipitation,@JsonKey(name: 'weather_code') int? weatherCode,@JsonKey(name: 'wind_speed_10m') double? windSpeed10m
});




}
/// @nodoc
class __$OpenMeteoCurrentCopyWithImpl<$Res>
    implements _$OpenMeteoCurrentCopyWith<$Res> {
  __$OpenMeteoCurrentCopyWithImpl(this._self, this._then);

  final _OpenMeteoCurrent _self;
  final $Res Function(_OpenMeteoCurrent) _then;

/// Create a copy of OpenMeteoCurrent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = freezed,Object? temperature2m = freezed,Object? relativeHumidity2m = freezed,Object? precipitation = freezed,Object? weatherCode = freezed,Object? windSpeed10m = freezed,}) {
  return _then(_OpenMeteoCurrent(
time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,temperature2m: freezed == temperature2m ? _self.temperature2m : temperature2m // ignore: cast_nullable_to_non_nullable
as double?,relativeHumidity2m: freezed == relativeHumidity2m ? _self.relativeHumidity2m : relativeHumidity2m // ignore: cast_nullable_to_non_nullable
as double?,precipitation: freezed == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double?,weatherCode: freezed == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int?,windSpeed10m: freezed == windSpeed10m ? _self.windSpeed10m : windSpeed10m // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$OpenMeteoHourly {

 List<String> get time;@JsonKey(name: 'precipitation') List<double?> get precipitation;@JsonKey(name: 'soil_temperature_6cm') List<double?> get soilTemperature6cm;
/// Create a copy of OpenMeteoHourly
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenMeteoHourlyCopyWith<OpenMeteoHourly> get copyWith => _$OpenMeteoHourlyCopyWithImpl<OpenMeteoHourly>(this as OpenMeteoHourly, _$identity);

  /// Serializes this OpenMeteoHourly to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenMeteoHourly&&const DeepCollectionEquality().equals(other.time, time)&&const DeepCollectionEquality().equals(other.precipitation, precipitation)&&const DeepCollectionEquality().equals(other.soilTemperature6cm, soilTemperature6cm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(time),const DeepCollectionEquality().hash(precipitation),const DeepCollectionEquality().hash(soilTemperature6cm));

@override
String toString() {
  return 'OpenMeteoHourly(time: $time, precipitation: $precipitation, soilTemperature6cm: $soilTemperature6cm)';
}


}

/// @nodoc
abstract mixin class $OpenMeteoHourlyCopyWith<$Res>  {
  factory $OpenMeteoHourlyCopyWith(OpenMeteoHourly value, $Res Function(OpenMeteoHourly) _then) = _$OpenMeteoHourlyCopyWithImpl;
@useResult
$Res call({
 List<String> time,@JsonKey(name: 'precipitation') List<double?> precipitation,@JsonKey(name: 'soil_temperature_6cm') List<double?> soilTemperature6cm
});




}
/// @nodoc
class _$OpenMeteoHourlyCopyWithImpl<$Res>
    implements $OpenMeteoHourlyCopyWith<$Res> {
  _$OpenMeteoHourlyCopyWithImpl(this._self, this._then);

  final OpenMeteoHourly _self;
  final $Res Function(OpenMeteoHourly) _then;

/// Create a copy of OpenMeteoHourly
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? precipitation = null,Object? soilTemperature6cm = null,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as List<String>,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as List<double?>,soilTemperature6cm: null == soilTemperature6cm ? _self.soilTemperature6cm : soilTemperature6cm // ignore: cast_nullable_to_non_nullable
as List<double?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenMeteoHourly].
extension OpenMeteoHourlyPatterns on OpenMeteoHourly {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenMeteoHourly value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenMeteoHourly() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenMeteoHourly value)  $default,){
final _that = this;
switch (_that) {
case _OpenMeteoHourly():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenMeteoHourly value)?  $default,){
final _that = this;
switch (_that) {
case _OpenMeteoHourly() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> time, @JsonKey(name: 'precipitation')  List<double?> precipitation, @JsonKey(name: 'soil_temperature_6cm')  List<double?> soilTemperature6cm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenMeteoHourly() when $default != null:
return $default(_that.time,_that.precipitation,_that.soilTemperature6cm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> time, @JsonKey(name: 'precipitation')  List<double?> precipitation, @JsonKey(name: 'soil_temperature_6cm')  List<double?> soilTemperature6cm)  $default,) {final _that = this;
switch (_that) {
case _OpenMeteoHourly():
return $default(_that.time,_that.precipitation,_that.soilTemperature6cm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> time, @JsonKey(name: 'precipitation')  List<double?> precipitation, @JsonKey(name: 'soil_temperature_6cm')  List<double?> soilTemperature6cm)?  $default,) {final _that = this;
switch (_that) {
case _OpenMeteoHourly() when $default != null:
return $default(_that.time,_that.precipitation,_that.soilTemperature6cm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenMeteoHourly implements OpenMeteoHourly {
  const _OpenMeteoHourly({final  List<String> time = const <String>[], @JsonKey(name: 'precipitation') final  List<double?> precipitation = const <double?>[], @JsonKey(name: 'soil_temperature_6cm') final  List<double?> soilTemperature6cm = const <double?>[]}): _time = time,_precipitation = precipitation,_soilTemperature6cm = soilTemperature6cm;
  factory _OpenMeteoHourly.fromJson(Map<String, dynamic> json) => _$OpenMeteoHourlyFromJson(json);

 final  List<String> _time;
@override@JsonKey() List<String> get time {
  if (_time is EqualUnmodifiableListView) return _time;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_time);
}

 final  List<double?> _precipitation;
@override@JsonKey(name: 'precipitation') List<double?> get precipitation {
  if (_precipitation is EqualUnmodifiableListView) return _precipitation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_precipitation);
}

 final  List<double?> _soilTemperature6cm;
@override@JsonKey(name: 'soil_temperature_6cm') List<double?> get soilTemperature6cm {
  if (_soilTemperature6cm is EqualUnmodifiableListView) return _soilTemperature6cm;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_soilTemperature6cm);
}


/// Create a copy of OpenMeteoHourly
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenMeteoHourlyCopyWith<_OpenMeteoHourly> get copyWith => __$OpenMeteoHourlyCopyWithImpl<_OpenMeteoHourly>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenMeteoHourlyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenMeteoHourly&&const DeepCollectionEquality().equals(other._time, _time)&&const DeepCollectionEquality().equals(other._precipitation, _precipitation)&&const DeepCollectionEquality().equals(other._soilTemperature6cm, _soilTemperature6cm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_time),const DeepCollectionEquality().hash(_precipitation),const DeepCollectionEquality().hash(_soilTemperature6cm));

@override
String toString() {
  return 'OpenMeteoHourly(time: $time, precipitation: $precipitation, soilTemperature6cm: $soilTemperature6cm)';
}


}

/// @nodoc
abstract mixin class _$OpenMeteoHourlyCopyWith<$Res> implements $OpenMeteoHourlyCopyWith<$Res> {
  factory _$OpenMeteoHourlyCopyWith(_OpenMeteoHourly value, $Res Function(_OpenMeteoHourly) _then) = __$OpenMeteoHourlyCopyWithImpl;
@override @useResult
$Res call({
 List<String> time,@JsonKey(name: 'precipitation') List<double?> precipitation,@JsonKey(name: 'soil_temperature_6cm') List<double?> soilTemperature6cm
});




}
/// @nodoc
class __$OpenMeteoHourlyCopyWithImpl<$Res>
    implements _$OpenMeteoHourlyCopyWith<$Res> {
  __$OpenMeteoHourlyCopyWithImpl(this._self, this._then);

  final _OpenMeteoHourly _self;
  final $Res Function(_OpenMeteoHourly) _then;

/// Create a copy of OpenMeteoHourly
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? precipitation = null,Object? soilTemperature6cm = null,}) {
  return _then(_OpenMeteoHourly(
time: null == time ? _self._time : time // ignore: cast_nullable_to_non_nullable
as List<String>,precipitation: null == precipitation ? _self._precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as List<double?>,soilTemperature6cm: null == soilTemperature6cm ? _self._soilTemperature6cm : soilTemperature6cm // ignore: cast_nullable_to_non_nullable
as List<double?>,
  ));
}


}


/// @nodoc
mixin _$OpenMeteoDaily {

 List<String> get time;@JsonKey(name: 'weather_code') List<int?> get weatherCode;@JsonKey(name: 'temperature_2m_max') List<double?> get temperature2mMax;@JsonKey(name: 'temperature_2m_min') List<double?> get temperature2mMin;@JsonKey(name: 'precipitation_sum') List<double?> get precipitationSum;@JsonKey(name: 'et0_fao_evapotranspiration') List<double?> get et0FaoEvapotranspiration;
/// Create a copy of OpenMeteoDaily
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenMeteoDailyCopyWith<OpenMeteoDaily> get copyWith => _$OpenMeteoDailyCopyWithImpl<OpenMeteoDaily>(this as OpenMeteoDaily, _$identity);

  /// Serializes this OpenMeteoDaily to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenMeteoDaily&&const DeepCollectionEquality().equals(other.time, time)&&const DeepCollectionEquality().equals(other.weatherCode, weatherCode)&&const DeepCollectionEquality().equals(other.temperature2mMax, temperature2mMax)&&const DeepCollectionEquality().equals(other.temperature2mMin, temperature2mMin)&&const DeepCollectionEquality().equals(other.precipitationSum, precipitationSum)&&const DeepCollectionEquality().equals(other.et0FaoEvapotranspiration, et0FaoEvapotranspiration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(time),const DeepCollectionEquality().hash(weatherCode),const DeepCollectionEquality().hash(temperature2mMax),const DeepCollectionEquality().hash(temperature2mMin),const DeepCollectionEquality().hash(precipitationSum),const DeepCollectionEquality().hash(et0FaoEvapotranspiration));

@override
String toString() {
  return 'OpenMeteoDaily(time: $time, weatherCode: $weatherCode, temperature2mMax: $temperature2mMax, temperature2mMin: $temperature2mMin, precipitationSum: $precipitationSum, et0FaoEvapotranspiration: $et0FaoEvapotranspiration)';
}


}

/// @nodoc
abstract mixin class $OpenMeteoDailyCopyWith<$Res>  {
  factory $OpenMeteoDailyCopyWith(OpenMeteoDaily value, $Res Function(OpenMeteoDaily) _then) = _$OpenMeteoDailyCopyWithImpl;
@useResult
$Res call({
 List<String> time,@JsonKey(name: 'weather_code') List<int?> weatherCode,@JsonKey(name: 'temperature_2m_max') List<double?> temperature2mMax,@JsonKey(name: 'temperature_2m_min') List<double?> temperature2mMin,@JsonKey(name: 'precipitation_sum') List<double?> precipitationSum,@JsonKey(name: 'et0_fao_evapotranspiration') List<double?> et0FaoEvapotranspiration
});




}
/// @nodoc
class _$OpenMeteoDailyCopyWithImpl<$Res>
    implements $OpenMeteoDailyCopyWith<$Res> {
  _$OpenMeteoDailyCopyWithImpl(this._self, this._then);

  final OpenMeteoDaily _self;
  final $Res Function(OpenMeteoDaily) _then;

/// Create a copy of OpenMeteoDaily
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? weatherCode = null,Object? temperature2mMax = null,Object? temperature2mMin = null,Object? precipitationSum = null,Object? et0FaoEvapotranspiration = null,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as List<String>,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as List<int?>,temperature2mMax: null == temperature2mMax ? _self.temperature2mMax : temperature2mMax // ignore: cast_nullable_to_non_nullable
as List<double?>,temperature2mMin: null == temperature2mMin ? _self.temperature2mMin : temperature2mMin // ignore: cast_nullable_to_non_nullable
as List<double?>,precipitationSum: null == precipitationSum ? _self.precipitationSum : precipitationSum // ignore: cast_nullable_to_non_nullable
as List<double?>,et0FaoEvapotranspiration: null == et0FaoEvapotranspiration ? _self.et0FaoEvapotranspiration : et0FaoEvapotranspiration // ignore: cast_nullable_to_non_nullable
as List<double?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenMeteoDaily].
extension OpenMeteoDailyPatterns on OpenMeteoDaily {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenMeteoDaily value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenMeteoDaily() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenMeteoDaily value)  $default,){
final _that = this;
switch (_that) {
case _OpenMeteoDaily():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenMeteoDaily value)?  $default,){
final _that = this;
switch (_that) {
case _OpenMeteoDaily() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> time, @JsonKey(name: 'weather_code')  List<int?> weatherCode, @JsonKey(name: 'temperature_2m_max')  List<double?> temperature2mMax, @JsonKey(name: 'temperature_2m_min')  List<double?> temperature2mMin, @JsonKey(name: 'precipitation_sum')  List<double?> precipitationSum, @JsonKey(name: 'et0_fao_evapotranspiration')  List<double?> et0FaoEvapotranspiration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenMeteoDaily() when $default != null:
return $default(_that.time,_that.weatherCode,_that.temperature2mMax,_that.temperature2mMin,_that.precipitationSum,_that.et0FaoEvapotranspiration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> time, @JsonKey(name: 'weather_code')  List<int?> weatherCode, @JsonKey(name: 'temperature_2m_max')  List<double?> temperature2mMax, @JsonKey(name: 'temperature_2m_min')  List<double?> temperature2mMin, @JsonKey(name: 'precipitation_sum')  List<double?> precipitationSum, @JsonKey(name: 'et0_fao_evapotranspiration')  List<double?> et0FaoEvapotranspiration)  $default,) {final _that = this;
switch (_that) {
case _OpenMeteoDaily():
return $default(_that.time,_that.weatherCode,_that.temperature2mMax,_that.temperature2mMin,_that.precipitationSum,_that.et0FaoEvapotranspiration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> time, @JsonKey(name: 'weather_code')  List<int?> weatherCode, @JsonKey(name: 'temperature_2m_max')  List<double?> temperature2mMax, @JsonKey(name: 'temperature_2m_min')  List<double?> temperature2mMin, @JsonKey(name: 'precipitation_sum')  List<double?> precipitationSum, @JsonKey(name: 'et0_fao_evapotranspiration')  List<double?> et0FaoEvapotranspiration)?  $default,) {final _that = this;
switch (_that) {
case _OpenMeteoDaily() when $default != null:
return $default(_that.time,_that.weatherCode,_that.temperature2mMax,_that.temperature2mMin,_that.precipitationSum,_that.et0FaoEvapotranspiration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenMeteoDaily implements OpenMeteoDaily {
  const _OpenMeteoDaily({final  List<String> time = const <String>[], @JsonKey(name: 'weather_code') final  List<int?> weatherCode = const <int?>[], @JsonKey(name: 'temperature_2m_max') final  List<double?> temperature2mMax = const <double?>[], @JsonKey(name: 'temperature_2m_min') final  List<double?> temperature2mMin = const <double?>[], @JsonKey(name: 'precipitation_sum') final  List<double?> precipitationSum = const <double?>[], @JsonKey(name: 'et0_fao_evapotranspiration') final  List<double?> et0FaoEvapotranspiration = const <double?>[]}): _time = time,_weatherCode = weatherCode,_temperature2mMax = temperature2mMax,_temperature2mMin = temperature2mMin,_precipitationSum = precipitationSum,_et0FaoEvapotranspiration = et0FaoEvapotranspiration;
  factory _OpenMeteoDaily.fromJson(Map<String, dynamic> json) => _$OpenMeteoDailyFromJson(json);

 final  List<String> _time;
@override@JsonKey() List<String> get time {
  if (_time is EqualUnmodifiableListView) return _time;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_time);
}

 final  List<int?> _weatherCode;
@override@JsonKey(name: 'weather_code') List<int?> get weatherCode {
  if (_weatherCode is EqualUnmodifiableListView) return _weatherCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weatherCode);
}

 final  List<double?> _temperature2mMax;
@override@JsonKey(name: 'temperature_2m_max') List<double?> get temperature2mMax {
  if (_temperature2mMax is EqualUnmodifiableListView) return _temperature2mMax;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_temperature2mMax);
}

 final  List<double?> _temperature2mMin;
@override@JsonKey(name: 'temperature_2m_min') List<double?> get temperature2mMin {
  if (_temperature2mMin is EqualUnmodifiableListView) return _temperature2mMin;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_temperature2mMin);
}

 final  List<double?> _precipitationSum;
@override@JsonKey(name: 'precipitation_sum') List<double?> get precipitationSum {
  if (_precipitationSum is EqualUnmodifiableListView) return _precipitationSum;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_precipitationSum);
}

 final  List<double?> _et0FaoEvapotranspiration;
@override@JsonKey(name: 'et0_fao_evapotranspiration') List<double?> get et0FaoEvapotranspiration {
  if (_et0FaoEvapotranspiration is EqualUnmodifiableListView) return _et0FaoEvapotranspiration;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_et0FaoEvapotranspiration);
}


/// Create a copy of OpenMeteoDaily
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenMeteoDailyCopyWith<_OpenMeteoDaily> get copyWith => __$OpenMeteoDailyCopyWithImpl<_OpenMeteoDaily>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenMeteoDailyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenMeteoDaily&&const DeepCollectionEquality().equals(other._time, _time)&&const DeepCollectionEquality().equals(other._weatherCode, _weatherCode)&&const DeepCollectionEquality().equals(other._temperature2mMax, _temperature2mMax)&&const DeepCollectionEquality().equals(other._temperature2mMin, _temperature2mMin)&&const DeepCollectionEquality().equals(other._precipitationSum, _precipitationSum)&&const DeepCollectionEquality().equals(other._et0FaoEvapotranspiration, _et0FaoEvapotranspiration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_time),const DeepCollectionEquality().hash(_weatherCode),const DeepCollectionEquality().hash(_temperature2mMax),const DeepCollectionEquality().hash(_temperature2mMin),const DeepCollectionEquality().hash(_precipitationSum),const DeepCollectionEquality().hash(_et0FaoEvapotranspiration));

@override
String toString() {
  return 'OpenMeteoDaily(time: $time, weatherCode: $weatherCode, temperature2mMax: $temperature2mMax, temperature2mMin: $temperature2mMin, precipitationSum: $precipitationSum, et0FaoEvapotranspiration: $et0FaoEvapotranspiration)';
}


}

/// @nodoc
abstract mixin class _$OpenMeteoDailyCopyWith<$Res> implements $OpenMeteoDailyCopyWith<$Res> {
  factory _$OpenMeteoDailyCopyWith(_OpenMeteoDaily value, $Res Function(_OpenMeteoDaily) _then) = __$OpenMeteoDailyCopyWithImpl;
@override @useResult
$Res call({
 List<String> time,@JsonKey(name: 'weather_code') List<int?> weatherCode,@JsonKey(name: 'temperature_2m_max') List<double?> temperature2mMax,@JsonKey(name: 'temperature_2m_min') List<double?> temperature2mMin,@JsonKey(name: 'precipitation_sum') List<double?> precipitationSum,@JsonKey(name: 'et0_fao_evapotranspiration') List<double?> et0FaoEvapotranspiration
});




}
/// @nodoc
class __$OpenMeteoDailyCopyWithImpl<$Res>
    implements _$OpenMeteoDailyCopyWith<$Res> {
  __$OpenMeteoDailyCopyWithImpl(this._self, this._then);

  final _OpenMeteoDaily _self;
  final $Res Function(_OpenMeteoDaily) _then;

/// Create a copy of OpenMeteoDaily
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? weatherCode = null,Object? temperature2mMax = null,Object? temperature2mMin = null,Object? precipitationSum = null,Object? et0FaoEvapotranspiration = null,}) {
  return _then(_OpenMeteoDaily(
time: null == time ? _self._time : time // ignore: cast_nullable_to_non_nullable
as List<String>,weatherCode: null == weatherCode ? _self._weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as List<int?>,temperature2mMax: null == temperature2mMax ? _self._temperature2mMax : temperature2mMax // ignore: cast_nullable_to_non_nullable
as List<double?>,temperature2mMin: null == temperature2mMin ? _self._temperature2mMin : temperature2mMin // ignore: cast_nullable_to_non_nullable
as List<double?>,precipitationSum: null == precipitationSum ? _self._precipitationSum : precipitationSum // ignore: cast_nullable_to_non_nullable
as List<double?>,et0FaoEvapotranspiration: null == et0FaoEvapotranspiration ? _self._et0FaoEvapotranspiration : et0FaoEvapotranspiration // ignore: cast_nullable_to_non_nullable
as List<double?>,
  ));
}


}

// dart format on
