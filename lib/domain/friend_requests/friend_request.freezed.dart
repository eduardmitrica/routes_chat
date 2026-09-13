// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FriendRequest {

 UniqueId get id; UniqueId get senderId; UniqueId get receiverId; Status get status;
/// Create a copy of FriendRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendRequestCopyWith<FriendRequest> get copyWith => _$FriendRequestCopyWithImpl<FriendRequest>(this as FriendRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FriendRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.receiverId, _this.receiverId) || other.receiverId == _this.receiverId)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as FriendRequest;
  return Object.hash(runtimeType,_this.id,_this.senderId,_this.receiverId,_this.status);
}

@override
String toString() {
  final _this = this as FriendRequest;
  return 'FriendRequest(id: ${_this.id}, senderId: ${_this.senderId}, receiverId: ${_this.receiverId}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $FriendRequestCopyWith<$Res>  {
  factory $FriendRequestCopyWith(FriendRequest value, $Res Function(FriendRequest) _then) = _$FriendRequestCopyWithImpl;
@useResult
$Res call({
 UniqueId id, UniqueId senderId, UniqueId receiverId, Status status
});




}
/// @nodoc
class _$FriendRequestCopyWithImpl<$Res>
    implements $FriendRequestCopyWith<$Res> {
  _$FriendRequestCopyWithImpl(this._self, this._then);

  final FriendRequest _self;
  final $Res Function(FriendRequest) _then;

/// Create a copy of FriendRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? status = null,}) {
  return _then(FriendRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as UniqueId,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as UniqueId,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as UniqueId,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,
  ));
}

}


/// Adds pattern-matching-related methods to [FriendRequest].
extension FriendRequestPatterns on FriendRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendRequest value)  $default,){
final _that = this;
switch (_that) {
case _FriendRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FriendRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UniqueId id,  UniqueId senderId,  UniqueId receiverId,  Status status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendRequest() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UniqueId id,  UniqueId senderId,  UniqueId receiverId,  Status status)  $default,) {final _that = this;
switch (_that) {
case _FriendRequest():
return $default(_that.id,_that.senderId,_that.receiverId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UniqueId id,  UniqueId senderId,  UniqueId receiverId,  Status status)?  $default,) {final _that = this;
switch (_that) {
case _FriendRequest() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _FriendRequest extends FriendRequest {
  const _FriendRequest({required this.id, required this.senderId, required this.receiverId, required this.status}): super._();
  

@override final  UniqueId id;
@override final  UniqueId senderId;
@override final  UniqueId receiverId;
@override final  Status status;

/// Create a copy of FriendRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendRequestCopyWith<_FriendRequest> get copyWith => __$FriendRequestCopyWithImpl<_FriendRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,senderId,receiverId,status);
}

@override
String toString() {
    return 'FriendRequest(id: $id, senderId: $senderId, receiverId: $receiverId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$FriendRequestCopyWith<$Res> implements $FriendRequestCopyWith<$Res> {
  factory _$FriendRequestCopyWith(_FriendRequest value, $Res Function(_FriendRequest) _then) = __$FriendRequestCopyWithImpl;
@override @useResult
$Res call({
 UniqueId id, UniqueId senderId, UniqueId receiverId, Status status
});




}
/// @nodoc
class __$FriendRequestCopyWithImpl<$Res>
    implements _$FriendRequestCopyWith<$Res> {
  __$FriendRequestCopyWithImpl(this._self, this._then);

  final _FriendRequest _self;
  final $Res Function(_FriendRequest) _then;

/// Create a copy of FriendRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? status = null,}) {
  return _then(_FriendRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as UniqueId,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as UniqueId,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as UniqueId,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,
  ));
}


}

// dart format on
