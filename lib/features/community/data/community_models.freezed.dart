// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Bucket {

 CommunityResolution get resolution; String get key;
/// Create a copy of Bucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BucketCopyWith<Bucket> get copyWith => _$BucketCopyWithImpl<Bucket>(this as Bucket, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bucket&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,resolution,key);

@override
String toString() {
  return 'Bucket(resolution: $resolution, key: $key)';
}


}

/// @nodoc
abstract mixin class $BucketCopyWith<$Res>  {
  factory $BucketCopyWith(Bucket value, $Res Function(Bucket) _then) = _$BucketCopyWithImpl;
@useResult
$Res call({
 CommunityResolution resolution, String key
});




}
/// @nodoc
class _$BucketCopyWithImpl<$Res>
    implements $BucketCopyWith<$Res> {
  _$BucketCopyWithImpl(this._self, this._then);

  final Bucket _self;
  final $Res Function(Bucket) _then;

/// Create a copy of Bucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resolution = null,Object? key = null,}) {
  return _then(_self.copyWith(
resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as CommunityResolution,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Bucket].
extension BucketPatterns on Bucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bucket value)  $default,){
final _that = this;
switch (_that) {
case _Bucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bucket value)?  $default,){
final _that = this;
switch (_that) {
case _Bucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommunityResolution resolution,  String key)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bucket() when $default != null:
return $default(_that.resolution,_that.key);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommunityResolution resolution,  String key)  $default,) {final _that = this;
switch (_that) {
case _Bucket():
return $default(_that.resolution,_that.key);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommunityResolution resolution,  String key)?  $default,) {final _that = this;
switch (_that) {
case _Bucket() when $default != null:
return $default(_that.resolution,_that.key);case _:
  return null;

}
}

}

/// @nodoc


class _Bucket implements Bucket {
  const _Bucket({required this.resolution, required this.key});
  

@override final  CommunityResolution resolution;
@override final  String key;

/// Create a copy of Bucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BucketCopyWith<_Bucket> get copyWith => __$BucketCopyWithImpl<_Bucket>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bucket&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,resolution,key);

@override
String toString() {
  return 'Bucket(resolution: $resolution, key: $key)';
}


}

/// @nodoc
abstract mixin class _$BucketCopyWith<$Res> implements $BucketCopyWith<$Res> {
  factory _$BucketCopyWith(_Bucket value, $Res Function(_Bucket) _then) = __$BucketCopyWithImpl;
@override @useResult
$Res call({
 CommunityResolution resolution, String key
});




}
/// @nodoc
class __$BucketCopyWithImpl<$Res>
    implements _$BucketCopyWith<$Res> {
  __$BucketCopyWithImpl(this._self, this._then);

  final _Bucket _self;
  final $Res Function(_Bucket) _then;

/// Create a copy of Bucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resolution = null,Object? key = null,}) {
  return _then(_Bucket(
resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as CommunityResolution,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CommunityFeedItem {

 String get taskTypeId;/// [kCommunityCohortSite] for site work, else the catalog plant id.
 String get cohort; int get distinctUsers7d; CommunityIntensity get intensity;
/// Create a copy of CommunityFeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityFeedItemCopyWith<CommunityFeedItem> get copyWith => _$CommunityFeedItemCopyWithImpl<CommunityFeedItem>(this as CommunityFeedItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityFeedItem&&(identical(other.taskTypeId, taskTypeId) || other.taskTypeId == taskTypeId)&&(identical(other.cohort, cohort) || other.cohort == cohort)&&(identical(other.distinctUsers7d, distinctUsers7d) || other.distinctUsers7d == distinctUsers7d)&&(identical(other.intensity, intensity) || other.intensity == intensity));
}


@override
int get hashCode => Object.hash(runtimeType,taskTypeId,cohort,distinctUsers7d,intensity);

@override
String toString() {
  return 'CommunityFeedItem(taskTypeId: $taskTypeId, cohort: $cohort, distinctUsers7d: $distinctUsers7d, intensity: $intensity)';
}


}

/// @nodoc
abstract mixin class $CommunityFeedItemCopyWith<$Res>  {
  factory $CommunityFeedItemCopyWith(CommunityFeedItem value, $Res Function(CommunityFeedItem) _then) = _$CommunityFeedItemCopyWithImpl;
@useResult
$Res call({
 String taskTypeId, String cohort, int distinctUsers7d, CommunityIntensity intensity
});




}
/// @nodoc
class _$CommunityFeedItemCopyWithImpl<$Res>
    implements $CommunityFeedItemCopyWith<$Res> {
  _$CommunityFeedItemCopyWithImpl(this._self, this._then);

  final CommunityFeedItem _self;
  final $Res Function(CommunityFeedItem) _then;

/// Create a copy of CommunityFeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskTypeId = null,Object? cohort = null,Object? distinctUsers7d = null,Object? intensity = null,}) {
  return _then(_self.copyWith(
taskTypeId: null == taskTypeId ? _self.taskTypeId : taskTypeId // ignore: cast_nullable_to_non_nullable
as String,cohort: null == cohort ? _self.cohort : cohort // ignore: cast_nullable_to_non_nullable
as String,distinctUsers7d: null == distinctUsers7d ? _self.distinctUsers7d : distinctUsers7d // ignore: cast_nullable_to_non_nullable
as int,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as CommunityIntensity,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityFeedItem].
extension CommunityFeedItemPatterns on CommunityFeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityFeedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityFeedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityFeedItem value)  $default,){
final _that = this;
switch (_that) {
case _CommunityFeedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityFeedItem value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityFeedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskTypeId,  String cohort,  int distinctUsers7d,  CommunityIntensity intensity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityFeedItem() when $default != null:
return $default(_that.taskTypeId,_that.cohort,_that.distinctUsers7d,_that.intensity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskTypeId,  String cohort,  int distinctUsers7d,  CommunityIntensity intensity)  $default,) {final _that = this;
switch (_that) {
case _CommunityFeedItem():
return $default(_that.taskTypeId,_that.cohort,_that.distinctUsers7d,_that.intensity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskTypeId,  String cohort,  int distinctUsers7d,  CommunityIntensity intensity)?  $default,) {final _that = this;
switch (_that) {
case _CommunityFeedItem() when $default != null:
return $default(_that.taskTypeId,_that.cohort,_that.distinctUsers7d,_that.intensity);case _:
  return null;

}
}

}

/// @nodoc


class _CommunityFeedItem implements CommunityFeedItem {
  const _CommunityFeedItem({required this.taskTypeId, required this.cohort, required this.distinctUsers7d, required this.intensity});
  

@override final  String taskTypeId;
/// [kCommunityCohortSite] for site work, else the catalog plant id.
@override final  String cohort;
@override final  int distinctUsers7d;
@override final  CommunityIntensity intensity;

/// Create a copy of CommunityFeedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityFeedItemCopyWith<_CommunityFeedItem> get copyWith => __$CommunityFeedItemCopyWithImpl<_CommunityFeedItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityFeedItem&&(identical(other.taskTypeId, taskTypeId) || other.taskTypeId == taskTypeId)&&(identical(other.cohort, cohort) || other.cohort == cohort)&&(identical(other.distinctUsers7d, distinctUsers7d) || other.distinctUsers7d == distinctUsers7d)&&(identical(other.intensity, intensity) || other.intensity == intensity));
}


@override
int get hashCode => Object.hash(runtimeType,taskTypeId,cohort,distinctUsers7d,intensity);

@override
String toString() {
  return 'CommunityFeedItem(taskTypeId: $taskTypeId, cohort: $cohort, distinctUsers7d: $distinctUsers7d, intensity: $intensity)';
}


}

/// @nodoc
abstract mixin class _$CommunityFeedItemCopyWith<$Res> implements $CommunityFeedItemCopyWith<$Res> {
  factory _$CommunityFeedItemCopyWith(_CommunityFeedItem value, $Res Function(_CommunityFeedItem) _then) = __$CommunityFeedItemCopyWithImpl;
@override @useResult
$Res call({
 String taskTypeId, String cohort, int distinctUsers7d, CommunityIntensity intensity
});




}
/// @nodoc
class __$CommunityFeedItemCopyWithImpl<$Res>
    implements _$CommunityFeedItemCopyWith<$Res> {
  __$CommunityFeedItemCopyWithImpl(this._self, this._then);

  final _CommunityFeedItem _self;
  final $Res Function(_CommunityFeedItem) _then;

/// Create a copy of CommunityFeedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskTypeId = null,Object? cohort = null,Object? distinctUsers7d = null,Object? intensity = null,}) {
  return _then(_CommunityFeedItem(
taskTypeId: null == taskTypeId ? _self.taskTypeId : taskTypeId // ignore: cast_nullable_to_non_nullable
as String,cohort: null == cohort ? _self.cohort : cohort // ignore: cast_nullable_to_non_nullable
as String,distinctUsers7d: null == distinctUsers7d ? _self.distinctUsers7d : distinctUsers7d // ignore: cast_nullable_to_non_nullable
as int,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as CommunityIntensity,
  ));
}


}

/// @nodoc
mixin _$CommunityFeed {

 Bucket get bucket; int get population; List<CommunityFeedItem> get items; DateTime get fetchedAt;
/// Create a copy of CommunityFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityFeedCopyWith<CommunityFeed> get copyWith => _$CommunityFeedCopyWithImpl<CommunityFeed>(this as CommunityFeed, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityFeed&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.population, population) || other.population == population)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,population,const DeepCollectionEquality().hash(items),fetchedAt);

@override
String toString() {
  return 'CommunityFeed(bucket: $bucket, population: $population, items: $items, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class $CommunityFeedCopyWith<$Res>  {
  factory $CommunityFeedCopyWith(CommunityFeed value, $Res Function(CommunityFeed) _then) = _$CommunityFeedCopyWithImpl;
@useResult
$Res call({
 Bucket bucket, int population, List<CommunityFeedItem> items, DateTime fetchedAt
});


$BucketCopyWith<$Res> get bucket;

}
/// @nodoc
class _$CommunityFeedCopyWithImpl<$Res>
    implements $CommunityFeedCopyWith<$Res> {
  _$CommunityFeedCopyWithImpl(this._self, this._then);

  final CommunityFeed _self;
  final $Res Function(CommunityFeed) _then;

/// Create a copy of CommunityFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? population = null,Object? items = null,Object? fetchedAt = null,}) {
  return _then(_self.copyWith(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,population: null == population ? _self.population : population // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CommunityFeedItem>,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of CommunityFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BucketCopyWith<$Res> get bucket {
  
  return $BucketCopyWith<$Res>(_self.bucket, (value) {
    return _then(_self.copyWith(bucket: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityFeed].
extension CommunityFeedPatterns on CommunityFeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityFeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityFeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityFeed value)  $default,){
final _that = this;
switch (_that) {
case _CommunityFeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityFeed value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityFeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Bucket bucket,  int population,  List<CommunityFeedItem> items,  DateTime fetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityFeed() when $default != null:
return $default(_that.bucket,_that.population,_that.items,_that.fetchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Bucket bucket,  int population,  List<CommunityFeedItem> items,  DateTime fetchedAt)  $default,) {final _that = this;
switch (_that) {
case _CommunityFeed():
return $default(_that.bucket,_that.population,_that.items,_that.fetchedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Bucket bucket,  int population,  List<CommunityFeedItem> items,  DateTime fetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunityFeed() when $default != null:
return $default(_that.bucket,_that.population,_that.items,_that.fetchedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CommunityFeed implements CommunityFeed {
  const _CommunityFeed({required this.bucket, required this.population, required final  List<CommunityFeedItem> items, required this.fetchedAt}): _items = items;
  

@override final  Bucket bucket;
@override final  int population;
 final  List<CommunityFeedItem> _items;
@override List<CommunityFeedItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  DateTime fetchedAt;

/// Create a copy of CommunityFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityFeedCopyWith<_CommunityFeed> get copyWith => __$CommunityFeedCopyWithImpl<_CommunityFeed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityFeed&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.population, population) || other.population == population)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,population,const DeepCollectionEquality().hash(_items),fetchedAt);

@override
String toString() {
  return 'CommunityFeed(bucket: $bucket, population: $population, items: $items, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class _$CommunityFeedCopyWith<$Res> implements $CommunityFeedCopyWith<$Res> {
  factory _$CommunityFeedCopyWith(_CommunityFeed value, $Res Function(_CommunityFeed) _then) = __$CommunityFeedCopyWithImpl;
@override @useResult
$Res call({
 Bucket bucket, int population, List<CommunityFeedItem> items, DateTime fetchedAt
});


@override $BucketCopyWith<$Res> get bucket;

}
/// @nodoc
class __$CommunityFeedCopyWithImpl<$Res>
    implements _$CommunityFeedCopyWith<$Res> {
  __$CommunityFeedCopyWithImpl(this._self, this._then);

  final _CommunityFeed _self;
  final $Res Function(_CommunityFeed) _then;

/// Create a copy of CommunityFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? population = null,Object? items = null,Object? fetchedAt = null,}) {
  return _then(_CommunityFeed(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,population: null == population ? _self.population : population // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CommunityFeedItem>,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of CommunityFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BucketCopyWith<$Res> get bucket {
  
  return $BucketCopyWith<$Res>(_self.bucket, (value) {
    return _then(_self.copyWith(bucket: value));
  });
}
}

/// @nodoc
mixin _$CommunityWeekly {

 Bucket get bucket; int get distinctUsers7d; CommunityIntensity get intensity;
/// Create a copy of CommunityWeekly
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityWeeklyCopyWith<CommunityWeekly> get copyWith => _$CommunityWeeklyCopyWithImpl<CommunityWeekly>(this as CommunityWeekly, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityWeekly&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.distinctUsers7d, distinctUsers7d) || other.distinctUsers7d == distinctUsers7d)&&(identical(other.intensity, intensity) || other.intensity == intensity));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,distinctUsers7d,intensity);

@override
String toString() {
  return 'CommunityWeekly(bucket: $bucket, distinctUsers7d: $distinctUsers7d, intensity: $intensity)';
}


}

/// @nodoc
abstract mixin class $CommunityWeeklyCopyWith<$Res>  {
  factory $CommunityWeeklyCopyWith(CommunityWeekly value, $Res Function(CommunityWeekly) _then) = _$CommunityWeeklyCopyWithImpl;
@useResult
$Res call({
 Bucket bucket, int distinctUsers7d, CommunityIntensity intensity
});


$BucketCopyWith<$Res> get bucket;

}
/// @nodoc
class _$CommunityWeeklyCopyWithImpl<$Res>
    implements $CommunityWeeklyCopyWith<$Res> {
  _$CommunityWeeklyCopyWithImpl(this._self, this._then);

  final CommunityWeekly _self;
  final $Res Function(CommunityWeekly) _then;

/// Create a copy of CommunityWeekly
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? distinctUsers7d = null,Object? intensity = null,}) {
  return _then(_self.copyWith(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,distinctUsers7d: null == distinctUsers7d ? _self.distinctUsers7d : distinctUsers7d // ignore: cast_nullable_to_non_nullable
as int,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as CommunityIntensity,
  ));
}
/// Create a copy of CommunityWeekly
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BucketCopyWith<$Res> get bucket {
  
  return $BucketCopyWith<$Res>(_self.bucket, (value) {
    return _then(_self.copyWith(bucket: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommunityWeekly].
extension CommunityWeeklyPatterns on CommunityWeekly {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityWeekly value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityWeekly() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityWeekly value)  $default,){
final _that = this;
switch (_that) {
case _CommunityWeekly():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityWeekly value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityWeekly() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Bucket bucket,  int distinctUsers7d,  CommunityIntensity intensity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityWeekly() when $default != null:
return $default(_that.bucket,_that.distinctUsers7d,_that.intensity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Bucket bucket,  int distinctUsers7d,  CommunityIntensity intensity)  $default,) {final _that = this;
switch (_that) {
case _CommunityWeekly():
return $default(_that.bucket,_that.distinctUsers7d,_that.intensity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Bucket bucket,  int distinctUsers7d,  CommunityIntensity intensity)?  $default,) {final _that = this;
switch (_that) {
case _CommunityWeekly() when $default != null:
return $default(_that.bucket,_that.distinctUsers7d,_that.intensity);case _:
  return null;

}
}

}

/// @nodoc


class _CommunityWeekly implements CommunityWeekly {
  const _CommunityWeekly({required this.bucket, required this.distinctUsers7d, required this.intensity});
  

@override final  Bucket bucket;
@override final  int distinctUsers7d;
@override final  CommunityIntensity intensity;

/// Create a copy of CommunityWeekly
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityWeeklyCopyWith<_CommunityWeekly> get copyWith => __$CommunityWeeklyCopyWithImpl<_CommunityWeekly>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityWeekly&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.distinctUsers7d, distinctUsers7d) || other.distinctUsers7d == distinctUsers7d)&&(identical(other.intensity, intensity) || other.intensity == intensity));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,distinctUsers7d,intensity);

@override
String toString() {
  return 'CommunityWeekly(bucket: $bucket, distinctUsers7d: $distinctUsers7d, intensity: $intensity)';
}


}

/// @nodoc
abstract mixin class _$CommunityWeeklyCopyWith<$Res> implements $CommunityWeeklyCopyWith<$Res> {
  factory _$CommunityWeeklyCopyWith(_CommunityWeekly value, $Res Function(_CommunityWeekly) _then) = __$CommunityWeeklyCopyWithImpl;
@override @useResult
$Res call({
 Bucket bucket, int distinctUsers7d, CommunityIntensity intensity
});


@override $BucketCopyWith<$Res> get bucket;

}
/// @nodoc
class __$CommunityWeeklyCopyWithImpl<$Res>
    implements _$CommunityWeeklyCopyWith<$Res> {
  __$CommunityWeeklyCopyWithImpl(this._self, this._then);

  final _CommunityWeekly _self;
  final $Res Function(_CommunityWeekly) _then;

/// Create a copy of CommunityWeekly
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? distinctUsers7d = null,Object? intensity = null,}) {
  return _then(_CommunityWeekly(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,distinctUsers7d: null == distinctUsers7d ? _self.distinctUsers7d : distinctUsers7d // ignore: cast_nullable_to_non_nullable
as int,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as CommunityIntensity,
  ));
}

/// Create a copy of CommunityWeekly
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BucketCopyWith<$Res> get bucket {
  
  return $BucketCopyWith<$Res>(_self.bucket, (value) {
    return _then(_self.copyWith(bucket: value));
  });
}
}

/// @nodoc
mixin _$MySeason {

 DateTime? get first; int get count;
/// Create a copy of MySeason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MySeasonCopyWith<MySeason> get copyWith => _$MySeasonCopyWithImpl<MySeason>(this as MySeason, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MySeason&&(identical(other.first, first) || other.first == first)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,first,count);

@override
String toString() {
  return 'MySeason(first: $first, count: $count)';
}


}

/// @nodoc
abstract mixin class $MySeasonCopyWith<$Res>  {
  factory $MySeasonCopyWith(MySeason value, $Res Function(MySeason) _then) = _$MySeasonCopyWithImpl;
@useResult
$Res call({
 DateTime? first, int count
});




}
/// @nodoc
class _$MySeasonCopyWithImpl<$Res>
    implements $MySeasonCopyWith<$Res> {
  _$MySeasonCopyWithImpl(this._self, this._then);

  final MySeason _self;
  final $Res Function(MySeason) _then;

/// Create a copy of MySeason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? first = freezed,Object? count = null,}) {
  return _then(_self.copyWith(
first: freezed == first ? _self.first : first // ignore: cast_nullable_to_non_nullable
as DateTime?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MySeason].
extension MySeasonPatterns on MySeason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MySeason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MySeason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MySeason value)  $default,){
final _that = this;
switch (_that) {
case _MySeason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MySeason value)?  $default,){
final _that = this;
switch (_that) {
case _MySeason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? first,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MySeason() when $default != null:
return $default(_that.first,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? first,  int count)  $default,) {final _that = this;
switch (_that) {
case _MySeason():
return $default(_that.first,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? first,  int count)?  $default,) {final _that = this;
switch (_that) {
case _MySeason() when $default != null:
return $default(_that.first,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _MySeason implements MySeason {
  const _MySeason({required this.first, required this.count});
  

@override final  DateTime? first;
@override final  int count;

/// Create a copy of MySeason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MySeasonCopyWith<_MySeason> get copyWith => __$MySeasonCopyWithImpl<_MySeason>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MySeason&&(identical(other.first, first) || other.first == first)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,first,count);

@override
String toString() {
  return 'MySeason(first: $first, count: $count)';
}


}

/// @nodoc
abstract mixin class _$MySeasonCopyWith<$Res> implements $MySeasonCopyWith<$Res> {
  factory _$MySeasonCopyWith(_MySeason value, $Res Function(_MySeason) _then) = __$MySeasonCopyWithImpl;
@override @useResult
$Res call({
 DateTime? first, int count
});




}
/// @nodoc
class __$MySeasonCopyWithImpl<$Res>
    implements _$MySeasonCopyWith<$Res> {
  __$MySeasonCopyWithImpl(this._self, this._then);

  final _MySeason _self;
  final $Res Function(_MySeason) _then;

/// Create a copy of MySeason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? first = freezed,Object? count = null,}) {
  return _then(_MySeason(
first: freezed == first ? _self.first : first // ignore: cast_nullable_to_non_nullable
as DateTime?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CommunityStanding {

 String get taskTypeId; String get cohort; CommunityTiming get band; CommunityResolution get scope;
/// Create a copy of CommunityStanding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityStandingCopyWith<CommunityStanding> get copyWith => _$CommunityStandingCopyWithImpl<CommunityStanding>(this as CommunityStanding, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityStanding&&(identical(other.taskTypeId, taskTypeId) || other.taskTypeId == taskTypeId)&&(identical(other.cohort, cohort) || other.cohort == cohort)&&(identical(other.band, band) || other.band == band)&&(identical(other.scope, scope) || other.scope == scope));
}


@override
int get hashCode => Object.hash(runtimeType,taskTypeId,cohort,band,scope);

@override
String toString() {
  return 'CommunityStanding(taskTypeId: $taskTypeId, cohort: $cohort, band: $band, scope: $scope)';
}


}

/// @nodoc
abstract mixin class $CommunityStandingCopyWith<$Res>  {
  factory $CommunityStandingCopyWith(CommunityStanding value, $Res Function(CommunityStanding) _then) = _$CommunityStandingCopyWithImpl;
@useResult
$Res call({
 String taskTypeId, String cohort, CommunityTiming band, CommunityResolution scope
});




}
/// @nodoc
class _$CommunityStandingCopyWithImpl<$Res>
    implements $CommunityStandingCopyWith<$Res> {
  _$CommunityStandingCopyWithImpl(this._self, this._then);

  final CommunityStanding _self;
  final $Res Function(CommunityStanding) _then;

/// Create a copy of CommunityStanding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskTypeId = null,Object? cohort = null,Object? band = null,Object? scope = null,}) {
  return _then(_self.copyWith(
taskTypeId: null == taskTypeId ? _self.taskTypeId : taskTypeId // ignore: cast_nullable_to_non_nullable
as String,cohort: null == cohort ? _self.cohort : cohort // ignore: cast_nullable_to_non_nullable
as String,band: null == band ? _self.band : band // ignore: cast_nullable_to_non_nullable
as CommunityTiming,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as CommunityResolution,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityStanding].
extension CommunityStandingPatterns on CommunityStanding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityStanding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityStanding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityStanding value)  $default,){
final _that = this;
switch (_that) {
case _CommunityStanding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityStanding value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityStanding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskTypeId,  String cohort,  CommunityTiming band,  CommunityResolution scope)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityStanding() when $default != null:
return $default(_that.taskTypeId,_that.cohort,_that.band,_that.scope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskTypeId,  String cohort,  CommunityTiming band,  CommunityResolution scope)  $default,) {final _that = this;
switch (_that) {
case _CommunityStanding():
return $default(_that.taskTypeId,_that.cohort,_that.band,_that.scope);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskTypeId,  String cohort,  CommunityTiming band,  CommunityResolution scope)?  $default,) {final _that = this;
switch (_that) {
case _CommunityStanding() when $default != null:
return $default(_that.taskTypeId,_that.cohort,_that.band,_that.scope);case _:
  return null;

}
}

}

/// @nodoc


class _CommunityStanding implements CommunityStanding {
  const _CommunityStanding({required this.taskTypeId, required this.cohort, required this.band, required this.scope});
  

@override final  String taskTypeId;
@override final  String cohort;
@override final  CommunityTiming band;
@override final  CommunityResolution scope;

/// Create a copy of CommunityStanding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityStandingCopyWith<_CommunityStanding> get copyWith => __$CommunityStandingCopyWithImpl<_CommunityStanding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityStanding&&(identical(other.taskTypeId, taskTypeId) || other.taskTypeId == taskTypeId)&&(identical(other.cohort, cohort) || other.cohort == cohort)&&(identical(other.band, band) || other.band == band)&&(identical(other.scope, scope) || other.scope == scope));
}


@override
int get hashCode => Object.hash(runtimeType,taskTypeId,cohort,band,scope);

@override
String toString() {
  return 'CommunityStanding(taskTypeId: $taskTypeId, cohort: $cohort, band: $band, scope: $scope)';
}


}

/// @nodoc
abstract mixin class _$CommunityStandingCopyWith<$Res> implements $CommunityStandingCopyWith<$Res> {
  factory _$CommunityStandingCopyWith(_CommunityStanding value, $Res Function(_CommunityStanding) _then) = __$CommunityStandingCopyWithImpl;
@override @useResult
$Res call({
 String taskTypeId, String cohort, CommunityTiming band, CommunityResolution scope
});




}
/// @nodoc
class __$CommunityStandingCopyWithImpl<$Res>
    implements _$CommunityStandingCopyWith<$Res> {
  __$CommunityStandingCopyWithImpl(this._self, this._then);

  final _CommunityStanding _self;
  final $Res Function(_CommunityStanding) _then;

/// Create a copy of CommunityStanding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskTypeId = null,Object? cohort = null,Object? band = null,Object? scope = null,}) {
  return _then(_CommunityStanding(
taskTypeId: null == taskTypeId ? _self.taskTypeId : taskTypeId // ignore: cast_nullable_to_non_nullable
as String,cohort: null == cohort ? _self.cohort : cohort // ignore: cast_nullable_to_non_nullable
as String,band: null == band ? _self.band : band // ignore: cast_nullable_to_non_nullable
as CommunityTiming,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as CommunityResolution,
  ));
}


}

/// @nodoc
mixin _$SeasonCurve {

 Bucket get bucket; List<double> get cdf; int get pooledTotal; bool get censored;
/// Create a copy of SeasonCurve
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCurveCopyWith<SeasonCurve> get copyWith => _$SeasonCurveCopyWithImpl<SeasonCurve>(this as SeasonCurve, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeasonCurve&&(identical(other.bucket, bucket) || other.bucket == bucket)&&const DeepCollectionEquality().equals(other.cdf, cdf)&&(identical(other.pooledTotal, pooledTotal) || other.pooledTotal == pooledTotal)&&(identical(other.censored, censored) || other.censored == censored));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,const DeepCollectionEquality().hash(cdf),pooledTotal,censored);

@override
String toString() {
  return 'SeasonCurve(bucket: $bucket, cdf: $cdf, pooledTotal: $pooledTotal, censored: $censored)';
}


}

/// @nodoc
abstract mixin class $SeasonCurveCopyWith<$Res>  {
  factory $SeasonCurveCopyWith(SeasonCurve value, $Res Function(SeasonCurve) _then) = _$SeasonCurveCopyWithImpl;
@useResult
$Res call({
 Bucket bucket, List<double> cdf, int pooledTotal, bool censored
});


$BucketCopyWith<$Res> get bucket;

}
/// @nodoc
class _$SeasonCurveCopyWithImpl<$Res>
    implements $SeasonCurveCopyWith<$Res> {
  _$SeasonCurveCopyWithImpl(this._self, this._then);

  final SeasonCurve _self;
  final $Res Function(SeasonCurve) _then;

/// Create a copy of SeasonCurve
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? cdf = null,Object? pooledTotal = null,Object? censored = null,}) {
  return _then(_self.copyWith(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,cdf: null == cdf ? _self.cdf : cdf // ignore: cast_nullable_to_non_nullable
as List<double>,pooledTotal: null == pooledTotal ? _self.pooledTotal : pooledTotal // ignore: cast_nullable_to_non_nullable
as int,censored: null == censored ? _self.censored : censored // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SeasonCurve
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BucketCopyWith<$Res> get bucket {
  
  return $BucketCopyWith<$Res>(_self.bucket, (value) {
    return _then(_self.copyWith(bucket: value));
  });
}
}


/// Adds pattern-matching-related methods to [SeasonCurve].
extension SeasonCurvePatterns on SeasonCurve {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeasonCurve value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeasonCurve() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeasonCurve value)  $default,){
final _that = this;
switch (_that) {
case _SeasonCurve():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeasonCurve value)?  $default,){
final _that = this;
switch (_that) {
case _SeasonCurve() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Bucket bucket,  List<double> cdf,  int pooledTotal,  bool censored)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeasonCurve() when $default != null:
return $default(_that.bucket,_that.cdf,_that.pooledTotal,_that.censored);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Bucket bucket,  List<double> cdf,  int pooledTotal,  bool censored)  $default,) {final _that = this;
switch (_that) {
case _SeasonCurve():
return $default(_that.bucket,_that.cdf,_that.pooledTotal,_that.censored);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Bucket bucket,  List<double> cdf,  int pooledTotal,  bool censored)?  $default,) {final _that = this;
switch (_that) {
case _SeasonCurve() when $default != null:
return $default(_that.bucket,_that.cdf,_that.pooledTotal,_that.censored);case _:
  return null;

}
}

}

/// @nodoc


class _SeasonCurve implements SeasonCurve {
  const _SeasonCurve({required this.bucket, required final  List<double> cdf, required this.pooledTotal, required this.censored}): _cdf = cdf;
  

@override final  Bucket bucket;
 final  List<double> _cdf;
@override List<double> get cdf {
  if (_cdf is EqualUnmodifiableListView) return _cdf;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cdf);
}

@override final  int pooledTotal;
@override final  bool censored;

/// Create a copy of SeasonCurve
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCurveCopyWith<_SeasonCurve> get copyWith => __$SeasonCurveCopyWithImpl<_SeasonCurve>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeasonCurve&&(identical(other.bucket, bucket) || other.bucket == bucket)&&const DeepCollectionEquality().equals(other._cdf, _cdf)&&(identical(other.pooledTotal, pooledTotal) || other.pooledTotal == pooledTotal)&&(identical(other.censored, censored) || other.censored == censored));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,const DeepCollectionEquality().hash(_cdf),pooledTotal,censored);

@override
String toString() {
  return 'SeasonCurve(bucket: $bucket, cdf: $cdf, pooledTotal: $pooledTotal, censored: $censored)';
}


}

/// @nodoc
abstract mixin class _$SeasonCurveCopyWith<$Res> implements $SeasonCurveCopyWith<$Res> {
  factory _$SeasonCurveCopyWith(_SeasonCurve value, $Res Function(_SeasonCurve) _then) = __$SeasonCurveCopyWithImpl;
@override @useResult
$Res call({
 Bucket bucket, List<double> cdf, int pooledTotal, bool censored
});


@override $BucketCopyWith<$Res> get bucket;

}
/// @nodoc
class __$SeasonCurveCopyWithImpl<$Res>
    implements _$SeasonCurveCopyWith<$Res> {
  __$SeasonCurveCopyWithImpl(this._self, this._then);

  final _SeasonCurve _self;
  final $Res Function(_SeasonCurve) _then;

/// Create a copy of SeasonCurve
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? cdf = null,Object? pooledTotal = null,Object? censored = null,}) {
  return _then(_SeasonCurve(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,cdf: null == cdf ? _self._cdf : cdf // ignore: cast_nullable_to_non_nullable
as List<double>,pooledTotal: null == pooledTotal ? _self.pooledTotal : pooledTotal // ignore: cast_nullable_to_non_nullable
as int,censored: null == censored ? _self.censored : censored // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SeasonCurve
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BucketCopyWith<$Res> get bucket {
  
  return $BucketCopyWith<$Res>(_self.bucket, (value) {
    return _then(_self.copyWith(bucket: value));
  });
}
}

/// @nodoc
mixin _$FrequencyStats {

 Bucket get bucket; double get p25; double get p50; double get p75; String get unit; int get nUsers; Map<String, int> get hist;
/// Create a copy of FrequencyStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FrequencyStatsCopyWith<FrequencyStats> get copyWith => _$FrequencyStatsCopyWithImpl<FrequencyStats>(this as FrequencyStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FrequencyStats&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.p25, p25) || other.p25 == p25)&&(identical(other.p50, p50) || other.p50 == p50)&&(identical(other.p75, p75) || other.p75 == p75)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.nUsers, nUsers) || other.nUsers == nUsers)&&const DeepCollectionEquality().equals(other.hist, hist));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,p25,p50,p75,unit,nUsers,const DeepCollectionEquality().hash(hist));

@override
String toString() {
  return 'FrequencyStats(bucket: $bucket, p25: $p25, p50: $p50, p75: $p75, unit: $unit, nUsers: $nUsers, hist: $hist)';
}


}

/// @nodoc
abstract mixin class $FrequencyStatsCopyWith<$Res>  {
  factory $FrequencyStatsCopyWith(FrequencyStats value, $Res Function(FrequencyStats) _then) = _$FrequencyStatsCopyWithImpl;
@useResult
$Res call({
 Bucket bucket, double p25, double p50, double p75, String unit, int nUsers, Map<String, int> hist
});


$BucketCopyWith<$Res> get bucket;

}
/// @nodoc
class _$FrequencyStatsCopyWithImpl<$Res>
    implements $FrequencyStatsCopyWith<$Res> {
  _$FrequencyStatsCopyWithImpl(this._self, this._then);

  final FrequencyStats _self;
  final $Res Function(FrequencyStats) _then;

/// Create a copy of FrequencyStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? p25 = null,Object? p50 = null,Object? p75 = null,Object? unit = null,Object? nUsers = null,Object? hist = null,}) {
  return _then(_self.copyWith(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,p25: null == p25 ? _self.p25 : p25 // ignore: cast_nullable_to_non_nullable
as double,p50: null == p50 ? _self.p50 : p50 // ignore: cast_nullable_to_non_nullable
as double,p75: null == p75 ? _self.p75 : p75 // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,nUsers: null == nUsers ? _self.nUsers : nUsers // ignore: cast_nullable_to_non_nullable
as int,hist: null == hist ? _self.hist : hist // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}
/// Create a copy of FrequencyStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BucketCopyWith<$Res> get bucket {
  
  return $BucketCopyWith<$Res>(_self.bucket, (value) {
    return _then(_self.copyWith(bucket: value));
  });
}
}


/// Adds pattern-matching-related methods to [FrequencyStats].
extension FrequencyStatsPatterns on FrequencyStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FrequencyStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FrequencyStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FrequencyStats value)  $default,){
final _that = this;
switch (_that) {
case _FrequencyStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FrequencyStats value)?  $default,){
final _that = this;
switch (_that) {
case _FrequencyStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Bucket bucket,  double p25,  double p50,  double p75,  String unit,  int nUsers,  Map<String, int> hist)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FrequencyStats() when $default != null:
return $default(_that.bucket,_that.p25,_that.p50,_that.p75,_that.unit,_that.nUsers,_that.hist);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Bucket bucket,  double p25,  double p50,  double p75,  String unit,  int nUsers,  Map<String, int> hist)  $default,) {final _that = this;
switch (_that) {
case _FrequencyStats():
return $default(_that.bucket,_that.p25,_that.p50,_that.p75,_that.unit,_that.nUsers,_that.hist);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Bucket bucket,  double p25,  double p50,  double p75,  String unit,  int nUsers,  Map<String, int> hist)?  $default,) {final _that = this;
switch (_that) {
case _FrequencyStats() when $default != null:
return $default(_that.bucket,_that.p25,_that.p50,_that.p75,_that.unit,_that.nUsers,_that.hist);case _:
  return null;

}
}

}

/// @nodoc


class _FrequencyStats implements FrequencyStats {
  const _FrequencyStats({required this.bucket, required this.p25, required this.p50, required this.p75, required this.unit, required this.nUsers, required final  Map<String, int> hist}): _hist = hist;
  

@override final  Bucket bucket;
@override final  double p25;
@override final  double p50;
@override final  double p75;
@override final  String unit;
@override final  int nUsers;
 final  Map<String, int> _hist;
@override Map<String, int> get hist {
  if (_hist is EqualUnmodifiableMapView) return _hist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hist);
}


/// Create a copy of FrequencyStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FrequencyStatsCopyWith<_FrequencyStats> get copyWith => __$FrequencyStatsCopyWithImpl<_FrequencyStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FrequencyStats&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.p25, p25) || other.p25 == p25)&&(identical(other.p50, p50) || other.p50 == p50)&&(identical(other.p75, p75) || other.p75 == p75)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.nUsers, nUsers) || other.nUsers == nUsers)&&const DeepCollectionEquality().equals(other._hist, _hist));
}


@override
int get hashCode => Object.hash(runtimeType,bucket,p25,p50,p75,unit,nUsers,const DeepCollectionEquality().hash(_hist));

@override
String toString() {
  return 'FrequencyStats(bucket: $bucket, p25: $p25, p50: $p50, p75: $p75, unit: $unit, nUsers: $nUsers, hist: $hist)';
}


}

/// @nodoc
abstract mixin class _$FrequencyStatsCopyWith<$Res> implements $FrequencyStatsCopyWith<$Res> {
  factory _$FrequencyStatsCopyWith(_FrequencyStats value, $Res Function(_FrequencyStats) _then) = __$FrequencyStatsCopyWithImpl;
@override @useResult
$Res call({
 Bucket bucket, double p25, double p50, double p75, String unit, int nUsers, Map<String, int> hist
});


@override $BucketCopyWith<$Res> get bucket;

}
/// @nodoc
class __$FrequencyStatsCopyWithImpl<$Res>
    implements _$FrequencyStatsCopyWith<$Res> {
  __$FrequencyStatsCopyWithImpl(this._self, this._then);

  final _FrequencyStats _self;
  final $Res Function(_FrequencyStats) _then;

/// Create a copy of FrequencyStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? p25 = null,Object? p50 = null,Object? p75 = null,Object? unit = null,Object? nUsers = null,Object? hist = null,}) {
  return _then(_FrequencyStats(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,p25: null == p25 ? _self.p25 : p25 // ignore: cast_nullable_to_non_nullable
as double,p50: null == p50 ? _self.p50 : p50 // ignore: cast_nullable_to_non_nullable
as double,p75: null == p75 ? _self.p75 : p75 // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,nUsers: null == nUsers ? _self.nUsers : nUsers // ignore: cast_nullable_to_non_nullable
as int,hist: null == hist ? _self._hist : hist // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

/// Create a copy of FrequencyStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BucketCopyWith<$Res> get bucket {
  
  return $BucketCopyWith<$Res>(_self.bucket, (value) {
    return _then(_self.copyWith(bucket: value));
  });
}
}

// dart format on
