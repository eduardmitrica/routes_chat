// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_data_transfer_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserDataTransferObject {

@JsonKey(includeToJson: false, includeFromJson: false) String? get id; String get username; String get imageUrl; String get description;
/// Create a copy of UserDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDataTransferObjectCopyWith<UserDataTransferObject> get copyWith => _$UserDataTransferObjectCopyWithImpl<UserDataTransferObject>(this as UserDataTransferObject, _$identity);

  /// Serializes this UserDataTransferObject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserDataTransferObject;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDataTransferObject&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserDataTransferObject;
  return Object.hash(runtimeType,_this.id,_this.username,_this.imageUrl,_this.description);
}

@override
String toString() {
  final _this = this as UserDataTransferObject;
  return 'UserDataTransferObject(id: ${_this.id}, username: ${_this.username}, imageUrl: ${_this.imageUrl}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $UserDataTransferObjectCopyWith<$Res>  {
  factory $UserDataTransferObjectCopyWith(UserDataTransferObject value, $Res Function(UserDataTransferObject) _then) = _$UserDataTransferObjectCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) String? id, String username, String imageUrl, String description
});




}
/// @nodoc
class _$UserDataTransferObjectCopyWithImpl<$Res>
    implements $UserDataTransferObjectCopyWith<$Res> {
  _$UserDataTransferObjectCopyWithImpl(this._self, this._then);

  final UserDataTransferObject _self;
  final $Res Function(UserDataTransferObject) _then;

/// Create a copy of UserDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? username = null,Object? imageUrl = null,Object? description = null,}) {
  return _then(UserDataTransferObject(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDataTransferObject].
extension UserDataTransferObjectPatterns on UserDataTransferObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDataTransferObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDataTransferObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDataTransferObject value)  $default,){
final _that = this;
switch (_that) {
case _UserDataTransferObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDataTransferObject value)?  $default,){
final _that = this;
switch (_that) {
case _UserDataTransferObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String username,  String imageUrl,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDataTransferObject() when $default != null:
return $default(_that.id,_that.username,_that.imageUrl,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String username,  String imageUrl,  String description)  $default,) {final _that = this;
switch (_that) {
case _UserDataTransferObject():
return $default(_that.id,_that.username,_that.imageUrl,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String username,  String imageUrl,  String description)?  $default,) {final _that = this;
switch (_that) {
case _UserDataTransferObject() when $default != null:
return $default(_that.id,_that.username,_that.imageUrl,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDataTransferObject extends UserDataTransferObject {
  const _UserDataTransferObject({@JsonKey(includeToJson: false, includeFromJson: false) this.id, required this.username, required this.imageUrl, required this.description}): super._();
  factory _UserDataTransferObject.fromJson(Map<String, dynamic> json) => _$UserDataTransferObjectFromJson(json);

@override@JsonKey(includeToJson: false, includeFromJson: false) final  String? id;
@override final  String username;
@override final  String imageUrl;
@override final  String description;

/// Create a copy of UserDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDataTransferObjectCopyWith<_UserDataTransferObject> get copyWith => __$UserDataTransferObjectCopyWithImpl<_UserDataTransferObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDataTransferObjectToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDataTransferObject&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,username,imageUrl,description);
}

@override
String toString() {
    return 'UserDataTransferObject(id: $id, username: $username, imageUrl: $imageUrl, description: $description)';
}


}

/// @nodoc
abstract mixin class _$UserDataTransferObjectCopyWith<$Res> implements $UserDataTransferObjectCopyWith<$Res> {
  factory _$UserDataTransferObjectCopyWith(_UserDataTransferObject value, $Res Function(_UserDataTransferObject) _then) = __$UserDataTransferObjectCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) String? id, String username, String imageUrl, String description
});




}
/// @nodoc
class __$UserDataTransferObjectCopyWithImpl<$Res>
    implements _$UserDataTransferObjectCopyWith<$Res> {
  __$UserDataTransferObjectCopyWithImpl(this._self, this._then);

  final _UserDataTransferObject _self;
  final $Res Function(_UserDataTransferObject) _then;

/// Create a copy of UserDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? username = null,Object? imageUrl = null,Object? description = null,}) {
  return _then(_UserDataTransferObject(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
