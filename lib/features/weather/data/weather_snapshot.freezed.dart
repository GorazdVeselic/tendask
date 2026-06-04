// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherSnapshot {

 DateTime get capturedAt; double? get temperature; double? get humidity; double? get precipitation; double? get windSpeed; int? get weatherCode; double? get soilTemperature; double? get et0; double? get rainPast48h; List<WeatherDay> get forecast;
/// Create a copy of WeatherSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherSnapshotCopyWith<WeatherSnapshot> get copyWith => _$WeatherSnapshotCopyWithImpl<WeatherSnapshot>(this as WeatherSnapshot, _$identity);

  /// Serializes this WeatherSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherSnapshot&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.soilTemperature, soilTemperature) || other.soilTemperature == soilTemperature)&&(identical(other.et0, et0) || other.et0 == et0)&&(identical(other.rainPast48h, rainPast48h) || other.rainPast48h == rainPast48h)&&const DeepCollectionEquality().equals(other.forecast, forecast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,capturedAt,temperature,humidity,precipitation,windSpeed,weatherCode,soilTemperature,et0,rainPast48h,const DeepCollectionEquality().hash(forecast));

@override
String toString() {
  return 'WeatherSnapshot(capturedAt: $capturedAt, temperature: $temperature, humidity: $humidity, precipitation: $precipitation, windSpeed: $windSpeed, weatherCode: $weatherCode, soilTemperature: $soilTemperature, et0: $et0, rainPast48h: $rainPast48h, forecast: $forecast)';
}


}

/// @nodoc
abstract mixin class $WeatherSnapshotCopyWith<$Res>  {
  factory $WeatherSnapshotCopyWith(WeatherSnapshot value, $Res Function(WeatherSnapshot) _then) = _$WeatherSnapshotCopyWithImpl;
@useResult
$Res call({
 DateTime capturedAt, double? temperature, double? humidity, double? precipitation, double? windSpeed, int? weatherCode, double? soilTemperature, double? et0, double? rainPast48h, List<WeatherDay> forecast
});




}
/// @nodoc
class _$WeatherSnapshotCopyWithImpl<$Res>
    implements $WeatherSnapshotCopyWith<$Res> {
  _$WeatherSnapshotCopyWithImpl(this._self, this._then);

  final WeatherSnapshot _self;
  final $Res Function(WeatherSnapshot) _then;

/// Create a copy of WeatherSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capturedAt = null,Object? temperature = freezed,Object? humidity = freezed,Object? precipitation = freezed,Object? windSpeed = freezed,Object? weatherCode = freezed,Object? soilTemperature = freezed,Object? et0 = freezed,Object? rainPast48h = freezed,Object? forecast = null,}) {
  return _then(_self.copyWith(
capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as double?,precipitation: freezed == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double?,windSpeed: freezed == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double?,weatherCode: freezed == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int?,soilTemperature: freezed == soilTemperature ? _self.soilTemperature : soilTemperature // ignore: cast_nullable_to_non_nullable
as double?,et0: freezed == et0 ? _self.et0 : et0 // ignore: cast_nullable_to_non_nullable
as double?,rainPast48h: freezed == rainPast48h ? _self.rainPast48h : rainPast48h // ignore: cast_nullable_to_non_nullable
as double?,forecast: null == forecast ? _self.forecast : forecast // ignore: cast_nullable_to_non_nullable
as List<WeatherDay>,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherSnapshot].
extension WeatherSnapshotPatterns on WeatherSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _WeatherSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime capturedAt,  double? temperature,  double? humidity,  double? precipitation,  double? windSpeed,  int? weatherCode,  double? soilTemperature,  double? et0,  double? rainPast48h,  List<WeatherDay> forecast)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherSnapshot() when $default != null:
return $default(_that.capturedAt,_that.temperature,_that.humidity,_that.precipitation,_that.windSpeed,_that.weatherCode,_that.soilTemperature,_that.et0,_that.rainPast48h,_that.forecast);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime capturedAt,  double? temperature,  double? humidity,  double? precipitation,  double? windSpeed,  int? weatherCode,  double? soilTemperature,  double? et0,  double? rainPast48h,  List<WeatherDay> forecast)  $default,) {final _that = this;
switch (_that) {
case _WeatherSnapshot():
return $default(_that.capturedAt,_that.temperature,_that.humidity,_that.precipitation,_that.windSpeed,_that.weatherCode,_that.soilTemperature,_that.et0,_that.rainPast48h,_that.forecast);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime capturedAt,  double? temperature,  double? humidity,  double? precipitation,  double? windSpeed,  int? weatherCode,  double? soilTemperature,  double? et0,  double? rainPast48h,  List<WeatherDay> forecast)?  $default,) {final _that = this;
switch (_that) {
case _WeatherSnapshot() when $default != null:
return $default(_that.capturedAt,_that.temperature,_that.humidity,_that.precipitation,_that.windSpeed,_that.weatherCode,_that.soilTemperature,_that.et0,_that.rainPast48h,_that.forecast);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeatherSnapshot implements WeatherSnapshot {
  const _WeatherSnapshot({required this.capturedAt, this.temperature, this.humidity, this.precipitation, this.windSpeed, this.weatherCode, this.soilTemperature, this.et0, this.rainPast48h, final  List<WeatherDay> forecast = const <WeatherDay>[]}): _forecast = forecast;
  factory _WeatherSnapshot.fromJson(Map<String, dynamic> json) => _$WeatherSnapshotFromJson(json);

@override final  DateTime capturedAt;
@override final  double? temperature;
@override final  double? humidity;
@override final  double? precipitation;
@override final  double? windSpeed;
@override final  int? weatherCode;
@override final  double? soilTemperature;
@override final  double? et0;
@override final  double? rainPast48h;
 final  List<WeatherDay> _forecast;
@override@JsonKey() List<WeatherDay> get forecast {
  if (_forecast is EqualUnmodifiableListView) return _forecast;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_forecast);
}


/// Create a copy of WeatherSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherSnapshotCopyWith<_WeatherSnapshot> get copyWith => __$WeatherSnapshotCopyWithImpl<_WeatherSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherSnapshot&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.soilTemperature, soilTemperature) || other.soilTemperature == soilTemperature)&&(identical(other.et0, et0) || other.et0 == et0)&&(identical(other.rainPast48h, rainPast48h) || other.rainPast48h == rainPast48h)&&const DeepCollectionEquality().equals(other._forecast, _forecast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,capturedAt,temperature,humidity,precipitation,windSpeed,weatherCode,soilTemperature,et0,rainPast48h,const DeepCollectionEquality().hash(_forecast));

@override
String toString() {
  return 'WeatherSnapshot(capturedAt: $capturedAt, temperature: $temperature, humidity: $humidity, precipitation: $precipitation, windSpeed: $windSpeed, weatherCode: $weatherCode, soilTemperature: $soilTemperature, et0: $et0, rainPast48h: $rainPast48h, forecast: $forecast)';
}


}

/// @nodoc
abstract mixin class _$WeatherSnapshotCopyWith<$Res> implements $WeatherSnapshotCopyWith<$Res> {
  factory _$WeatherSnapshotCopyWith(_WeatherSnapshot value, $Res Function(_WeatherSnapshot) _then) = __$WeatherSnapshotCopyWithImpl;
@override @useResult
$Res call({
 DateTime capturedAt, double? temperature, double? humidity, double? precipitation, double? windSpeed, int? weatherCode, double? soilTemperature, double? et0, double? rainPast48h, List<WeatherDay> forecast
});




}
/// @nodoc
class __$WeatherSnapshotCopyWithImpl<$Res>
    implements _$WeatherSnapshotCopyWith<$Res> {
  __$WeatherSnapshotCopyWithImpl(this._self, this._then);

  final _WeatherSnapshot _self;
  final $Res Function(_WeatherSnapshot) _then;

/// Create a copy of WeatherSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capturedAt = null,Object? temperature = freezed,Object? humidity = freezed,Object? precipitation = freezed,Object? windSpeed = freezed,Object? weatherCode = freezed,Object? soilTemperature = freezed,Object? et0 = freezed,Object? rainPast48h = freezed,Object? forecast = null,}) {
  return _then(_WeatherSnapshot(
capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as double?,precipitation: freezed == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double?,windSpeed: freezed == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double?,weatherCode: freezed == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int?,soilTemperature: freezed == soilTemperature ? _self.soilTemperature : soilTemperature // ignore: cast_nullable_to_non_nullable
as double?,et0: freezed == et0 ? _self.et0 : et0 // ignore: cast_nullable_to_non_nullable
as double?,rainPast48h: freezed == rainPast48h ? _self.rainPast48h : rainPast48h // ignore: cast_nullable_to_non_nullable
as double?,forecast: null == forecast ? _self._forecast : forecast // ignore: cast_nullable_to_non_nullable
as List<WeatherDay>,
  ));
}


}


/// @nodoc
mixin _$WeatherDay {

 DateTime get date; int? get weatherCode; double? get tempMax; double? get tempMin; double? get precipitationSum; double? get et0;
/// Create a copy of WeatherDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherDayCopyWith<WeatherDay> get copyWith => _$WeatherDayCopyWithImpl<WeatherDay>(this as WeatherDay, _$identity);

  /// Serializes this WeatherDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherDay&&(identical(other.date, date) || other.date == date)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.tempMax, tempMax) || other.tempMax == tempMax)&&(identical(other.tempMin, tempMin) || other.tempMin == tempMin)&&(identical(other.precipitationSum, precipitationSum) || other.precipitationSum == precipitationSum)&&(identical(other.et0, et0) || other.et0 == et0));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,weatherCode,tempMax,tempMin,precipitationSum,et0);

@override
String toString() {
  return 'WeatherDay(date: $date, weatherCode: $weatherCode, tempMax: $tempMax, tempMin: $tempMin, precipitationSum: $precipitationSum, et0: $et0)';
}


}

/// @nodoc
abstract mixin class $WeatherDayCopyWith<$Res>  {
  factory $WeatherDayCopyWith(WeatherDay value, $Res Function(WeatherDay) _then) = _$WeatherDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, int? weatherCode, double? tempMax, double? tempMin, double? precipitationSum, double? et0
});




}
/// @nodoc
class _$WeatherDayCopyWithImpl<$Res>
    implements $WeatherDayCopyWith<$Res> {
  _$WeatherDayCopyWithImpl(this._self, this._then);

  final WeatherDay _self;
  final $Res Function(WeatherDay) _then;

/// Create a copy of WeatherDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? weatherCode = freezed,Object? tempMax = freezed,Object? tempMin = freezed,Object? precipitationSum = freezed,Object? et0 = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,weatherCode: freezed == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int?,tempMax: freezed == tempMax ? _self.tempMax : tempMax // ignore: cast_nullable_to_non_nullable
as double?,tempMin: freezed == tempMin ? _self.tempMin : tempMin // ignore: cast_nullable_to_non_nullable
as double?,precipitationSum: freezed == precipitationSum ? _self.precipitationSum : precipitationSum // ignore: cast_nullable_to_non_nullable
as double?,et0: freezed == et0 ? _self.et0 : et0 // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherDay].
extension WeatherDayPatterns on WeatherDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherDay value)  $default,){
final _that = this;
switch (_that) {
case _WeatherDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherDay value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int? weatherCode,  double? tempMax,  double? tempMin,  double? precipitationSum,  double? et0)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherDay() when $default != null:
return $default(_that.date,_that.weatherCode,_that.tempMax,_that.tempMin,_that.precipitationSum,_that.et0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int? weatherCode,  double? tempMax,  double? tempMin,  double? precipitationSum,  double? et0)  $default,) {final _that = this;
switch (_that) {
case _WeatherDay():
return $default(_that.date,_that.weatherCode,_that.tempMax,_that.tempMin,_that.precipitationSum,_that.et0);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int? weatherCode,  double? tempMax,  double? tempMin,  double? precipitationSum,  double? et0)?  $default,) {final _that = this;
switch (_that) {
case _WeatherDay() when $default != null:
return $default(_that.date,_that.weatherCode,_that.tempMax,_that.tempMin,_that.precipitationSum,_that.et0);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeatherDay implements WeatherDay {
  const _WeatherDay({required this.date, this.weatherCode, this.tempMax, this.tempMin, this.precipitationSum, this.et0});
  factory _WeatherDay.fromJson(Map<String, dynamic> json) => _$WeatherDayFromJson(json);

@override final  DateTime date;
@override final  int? weatherCode;
@override final  double? tempMax;
@override final  double? tempMin;
@override final  double? precipitationSum;
@override final  double? et0;

/// Create a copy of WeatherDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherDayCopyWith<_WeatherDay> get copyWith => __$WeatherDayCopyWithImpl<_WeatherDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherDay&&(identical(other.date, date) || other.date == date)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.tempMax, tempMax) || other.tempMax == tempMax)&&(identical(other.tempMin, tempMin) || other.tempMin == tempMin)&&(identical(other.precipitationSum, precipitationSum) || other.precipitationSum == precipitationSum)&&(identical(other.et0, et0) || other.et0 == et0));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,weatherCode,tempMax,tempMin,precipitationSum,et0);

@override
String toString() {
  return 'WeatherDay(date: $date, weatherCode: $weatherCode, tempMax: $tempMax, tempMin: $tempMin, precipitationSum: $precipitationSum, et0: $et0)';
}


}

/// @nodoc
abstract mixin class _$WeatherDayCopyWith<$Res> implements $WeatherDayCopyWith<$Res> {
  factory _$WeatherDayCopyWith(_WeatherDay value, $Res Function(_WeatherDay) _then) = __$WeatherDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int? weatherCode, double? tempMax, double? tempMin, double? precipitationSum, double? et0
});




}
/// @nodoc
class __$WeatherDayCopyWithImpl<$Res>
    implements _$WeatherDayCopyWith<$Res> {
  __$WeatherDayCopyWithImpl(this._self, this._then);

  final _WeatherDay _self;
  final $Res Function(_WeatherDay) _then;

/// Create a copy of WeatherDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? weatherCode = freezed,Object? tempMax = freezed,Object? tempMin = freezed,Object? precipitationSum = freezed,Object? et0 = freezed,}) {
  return _then(_WeatherDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,weatherCode: freezed == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int?,tempMax: freezed == tempMax ? _self.tempMax : tempMax // ignore: cast_nullable_to_non_nullable
as double?,tempMin: freezed == tempMin ? _self.tempMin : tempMin // ignore: cast_nullable_to_non_nullable
as double?,precipitationSum: freezed == precipitationSum ? _self.precipitationSum : precipitationSum // ignore: cast_nullable_to_non_nullable
as double?,et0: freezed == et0 ? _self.et0 : et0 // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
