// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_request_data_transfer_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FriendRequestDataTransferObject {

@JsonKey(includeToJson: false, includeFromJson: false) String? get id; String get senderId; String get receiverId;/// Both parties' uids, sorted. A list query can only be narrowed to the
/// caller's own requests through a field like this (`arrayContains`), and
/// that is what lets firestore.rules restrict reads to the participants.
/// Always derived in [fromDomain], never set by callers.
 List<String> get participantIds; String get status;@ServerTimestampConverter() FieldValue get serverTimeStamp;
/// Create a copy of FriendRequestDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendRequestDataTransferObjectCopyWith<FriendRequestDataTransferObject> get copyWith => _$FriendRequestDataTransferObjectCopyWithImpl<FriendRequestDataTransferObject>(this as FriendRequestDataTransferObject, _$identity);

  /// Serializes this FriendRequestDataTransferObject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FriendRequestDataTransferObject;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendRequestDataTransferObject&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.receiverId, _this.receiverId) || other.receiverId == _this.receiverId)&&const DeepCollectionEquality().equals(other.participantIds, _this.participantIds)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.serverTimeStamp, _this.serverTimeStamp) || other.serverTimeStamp == _this.serverTimeStamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FriendRequestDataTransferObject;
  return Object.hash(runtimeType,_this.id,_this.senderId,_this.receiverId,const DeepCollectionEquality().hash(_this.participantIds),_this.status,_this.serverTimeStamp);
}

@override
String toString() {
  final _this = this as FriendRequestDataTransferObject;
  return 'FriendRequestDataTransferObject(id: ${_this.id}, senderId: ${_this.senderId}, receiverId: ${_this.receiverId}, participantIds: ${_this.participantIds}, status: ${_this.status}, serverTimeStamp: ${_this.serverTimeStamp})';
}


}

/// @nodoc
abstract mixin class $FriendRequestDataTransferObjectCopyWith<$Res>  {
  factory $FriendRequestDataTransferObjectCopyWith(FriendRequestDataTransferObject value, $Res Function(FriendRequestDataTransferObject) _then) = _$FriendRequestDataTransferObjectCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) String? id, String senderId, String receiverId, List<String> participantIds, String status,@ServerTimestampConverter() FieldValue serverTimeStamp
});




}
/// @nodoc
class _$FriendRequestDataTransferObjectCopyWithImpl<$Res>
    implements $FriendRequestDataTransferObjectCopyWith<$Res> {
  _$FriendRequestDataTransferObjectCopyWithImpl(this._self, this._then);

  final FriendRequestDataTransferObject _self;
  final $Res Function(FriendRequestDataTransferObject) _then;

/// Create a copy of FriendRequestDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? senderId = null,Object? receiverId = null,Object? participantIds = null,Object? status = null,Object? serverTimeStamp = null,}) {
  return _then(FriendRequestDataTransferObject(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,serverTimeStamp: null == serverTimeStamp ? _self.serverTimeStamp : serverTimeStamp // ignore: cast_nullable_to_non_nullable
as FieldValue,
  ));
}

}


/// Adds pattern-matching-related methods to [FriendRequestDataTransferObject].
extension FriendRequestDataTransferObjectPatterns on FriendRequestDataTransferObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendRequestDataTransferObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendRequestDataTransferObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendRequestDataTransferObject value)  $default,){
final _that = this;
switch (_that) {
case _FriendRequestDataTransferObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendRequestDataTransferObject value)?  $default,){
final _that = this;
switch (_that) {
case _FriendRequestDataTransferObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String senderId,  String receiverId,  List<String> participantIds,  String status, @ServerTimestampConverter()  FieldValue serverTimeStamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendRequestDataTransferObject() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.participantIds,_that.status,_that.serverTimeStamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String senderId,  String receiverId,  List<String> participantIds,  String status, @ServerTimestampConverter()  FieldValue serverTimeStamp)  $default,) {final _that = this;
switch (_that) {
case _FriendRequestDataTransferObject():
return $default(_that.id,_that.senderId,_that.receiverId,_that.participantIds,_that.status,_that.serverTimeStamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String senderId,  String receiverId,  List<String> participantIds,  String status, @ServerTimestampConverter()  FieldValue serverTimeStamp)?  $default,) {final _that = this;
switch (_that) {
case _FriendRequestDataTransferObject() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.participantIds,_that.status,_that.serverTimeStamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendRequestDataTransferObject extends FriendRequestDataTransferObject {
  const _FriendRequestDataTransferObject({@JsonKey(includeToJson: false, includeFromJson: false) this.id, required this.senderId, required this.receiverId, required  List<String> participantIds, required this.status, @ServerTimestampConverter() required this.serverTimeStamp}): _participantIds = participantIds,super._();
  factory _FriendRequestDataTransferObject.fromJson(Map<String, dynamic> json) => _$FriendRequestDataTransferObjectFromJson(json);

@override@JsonKey(includeToJson: false, includeFromJson: false) final  String? id;
@override final  String senderId;
@override final  String receiverId;
/// Both parties' uids, sorted. A list query can only be narrowed to the
/// caller's own requests through a field like this (`arrayContains`), and
/// that is what lets firestore.rules restrict reads to the participants.
/// Always derived in [fromDomain], never set by callers.
 final  List<String> _participantIds;
/// Both parties' uids, sorted. A list query can only be narrowed to the
/// caller's own requests through a field like this (`arrayContains`), and
/// that is what lets firestore.rules restrict reads to the participants.
/// Always derived in [fromDomain], never set by callers.
@override List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

@override final  String status;
@override@ServerTimestampConverter() final  FieldValue serverTimeStamp;

/// Create a copy of FriendRequestDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendRequestDataTransferObjectCopyWith<_FriendRequestDataTransferObject> get copyWith => __$FriendRequestDataTransferObjectCopyWithImpl<_FriendRequestDataTransferObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendRequestDataTransferObjectToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendRequestDataTransferObject&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&const DeepCollectionEquality().equals(other.participantIds, _participantIds)&&(identical(other.status, status) || other.status == status)&&(identical(other.serverTimeStamp, serverTimeStamp) || other.serverTimeStamp == serverTimeStamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,senderId,receiverId,const DeepCollectionEquality().hash(_participantIds),status,serverTimeStamp);
}

@override
String toString() {
    return 'FriendRequestDataTransferObject(id: $id, senderId: $senderId, receiverId: $receiverId, participantIds: $participantIds, status: $status, serverTimeStamp: $serverTimeStamp)';
}


}

/// @nodoc
abstract mixin class _$FriendRequestDataTransferObjectCopyWith<$Res> implements $FriendRequestDataTransferObjectCopyWith<$Res> {
  factory _$FriendRequestDataTransferObjectCopyWith(_FriendRequestDataTransferObject value, $Res Function(_FriendRequestDataTransferObject) _then) = __$FriendRequestDataTransferObjectCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) String? id, String senderId, String receiverId, List<String> participantIds, String status,@ServerTimestampConverter() FieldValue serverTimeStamp
});




}
/// @nodoc
class __$FriendRequestDataTransferObjectCopyWithImpl<$Res>
    implements _$FriendRequestDataTransferObjectCopyWith<$Res> {
  __$FriendRequestDataTransferObjectCopyWithImpl(this._self, this._then);

  final _FriendRequestDataTransferObject _self;
  final $Res Function(_FriendRequestDataTransferObject) _then;

/// Create a copy of FriendRequestDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? senderId = null,Object? receiverId = null,Object? participantIds = null,Object? status = null,Object? serverTimeStamp = null,}) {
  return _then(_FriendRequestDataTransferObject(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,serverTimeStamp: null == serverTimeStamp ? _self.serverTimeStamp : serverTimeStamp // ignore: cast_nullable_to_non_nullable
as FieldValue,
  ));
}


}

// dart format on
