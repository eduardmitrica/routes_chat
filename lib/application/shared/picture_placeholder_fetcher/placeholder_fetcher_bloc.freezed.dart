// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'placeholder_fetcher_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaceholderFetcherState {

 ImagePath get imagePath;
/// Create a copy of PlaceholderFetcherState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceholderFetcherStateCopyWith<PlaceholderFetcherState> get copyWith => _$PlaceholderFetcherStateCopyWithImpl<PlaceholderFetcherState>(this as PlaceholderFetcherState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlaceholderFetcherState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceholderFetcherState&&(identical(other.imagePath, _this.imagePath) || other.imagePath == _this.imagePath));
}


@override
int get hashCode {
  final _this = this as PlaceholderFetcherState;
  return Object.hash(runtimeType,_this.imagePath);
}

@override
String toString() {
  final _this = this as PlaceholderFetcherState;
  return 'PlaceholderFetcherState(imagePath: ${_this.imagePath})';
}


}

/// @nodoc
abstract mixin class $PlaceholderFetcherStateCopyWith<$Res>  {
  factory $PlaceholderFetcherStateCopyWith(PlaceholderFetcherState value, $Res Function(PlaceholderFetcherState) _then) = _$PlaceholderFetcherStateCopyWithImpl;
@useResult
$Res call({
 ImagePath imagePath
});




}
/// @nodoc
class _$PlaceholderFetcherStateCopyWithImpl<$Res>
    implements $PlaceholderFetcherStateCopyWith<$Res> {
  _$PlaceholderFetcherStateCopyWithImpl(this._self, this._then);

  final PlaceholderFetcherState _self;
  final $Res Function(PlaceholderFetcherState) _then;

/// Create a copy of PlaceholderFetcherState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imagePath = null,}) {
  return _then(PlaceholderFetcherState(
imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as ImagePath,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceholderFetcherState].
extension PlaceholderFetcherStatePatterns on PlaceholderFetcherState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceholderFetcherState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceholderFetcherState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceholderFetcherState value)  $default,){
final _that = this;
switch (_that) {
case _PlaceholderFetcherState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceholderFetcherState value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceholderFetcherState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ImagePath imagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceholderFetcherState() when $default != null:
return $default(_that.imagePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ImagePath imagePath)  $default,) {final _that = this;
switch (_that) {
case _PlaceholderFetcherState():
return $default(_that.imagePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ImagePath imagePath)?  $default,) {final _that = this;
switch (_that) {
case _PlaceholderFetcherState() when $default != null:
return $default(_that.imagePath);case _:
  return null;

}
}

}

/// @nodoc


class _PlaceholderFetcherState implements PlaceholderFetcherState {
  const _PlaceholderFetcherState({required this.imagePath});
  

@override final  ImagePath imagePath;

/// Create a copy of PlaceholderFetcherState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceholderFetcherStateCopyWith<_PlaceholderFetcherState> get copyWith => __$PlaceholderFetcherStateCopyWithImpl<_PlaceholderFetcherState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceholderFetcherState&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}


@override
int get hashCode {
    return Object.hash(runtimeType,imagePath);
}

@override
String toString() {
    return 'PlaceholderFetcherState(imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$PlaceholderFetcherStateCopyWith<$Res> implements $PlaceholderFetcherStateCopyWith<$Res> {
  factory _$PlaceholderFetcherStateCopyWith(_PlaceholderFetcherState value, $Res Function(_PlaceholderFetcherState) _then) = __$PlaceholderFetcherStateCopyWithImpl;
@override @useResult
$Res call({
 ImagePath imagePath
});




}
/// @nodoc
class __$PlaceholderFetcherStateCopyWithImpl<$Res>
    implements _$PlaceholderFetcherStateCopyWith<$Res> {
  __$PlaceholderFetcherStateCopyWithImpl(this._self, this._then);

  final _PlaceholderFetcherState _self;
  final $Res Function(_PlaceholderFetcherState) _then;

/// Create a copy of PlaceholderFetcherState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imagePath = null,}) {
  return _then(_PlaceholderFetcherState(
imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as ImagePath,
  ));
}


}

// dart format on
