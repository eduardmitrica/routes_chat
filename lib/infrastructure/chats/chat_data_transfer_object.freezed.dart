// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_data_transfer_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatDataTransferObject {

@JsonKey(includeToJson: false, includeFromJson: false) String? get id; List<Map<String, String>> get participants;/// Flat mirror of the participant ids in [participants].
///
/// [participants] is a list of maps (participant id -> last seen message
/// id) and Firestore security rules cannot iterate that shape, so
/// "the writer must be a participant" is not expressible over it. This
/// duplicated field exists purely so the rules can enforce it, and is
/// always derived in [fromDomain] rather than set by callers.
///
/// Stored sorted, so the rules can require the chat id to equal
/// `participantIds.join('_')`, the format compositeId produces.
 List<String> get participantIds;@MessageDataTransferObjectConverter() MessageDataTransferObject get lastMessage;@ServerTimestampConverter() FieldValue get serverTimeStamp;
/// Create a copy of ChatDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDataTransferObjectCopyWith<ChatDataTransferObject> get copyWith => _$ChatDataTransferObjectCopyWithImpl<ChatDataTransferObject>(this as ChatDataTransferObject, _$identity);

  /// Serializes this ChatDataTransferObject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChatDataTransferObject;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatDataTransferObject&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.participants, _this.participants)&&const DeepCollectionEquality().equals(other.participantIds, _this.participantIds)&&(identical(other.lastMessage, _this.lastMessage) || other.lastMessage == _this.lastMessage)&&(identical(other.serverTimeStamp, _this.serverTimeStamp) || other.serverTimeStamp == _this.serverTimeStamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChatDataTransferObject;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.participants),const DeepCollectionEquality().hash(_this.participantIds),_this.lastMessage,_this.serverTimeStamp);
}

@override
String toString() {
  final _this = this as ChatDataTransferObject;
  return 'ChatDataTransferObject(id: ${_this.id}, participants: ${_this.participants}, participantIds: ${_this.participantIds}, lastMessage: ${_this.lastMessage}, serverTimeStamp: ${_this.serverTimeStamp})';
}


}

/// @nodoc
abstract mixin class $ChatDataTransferObjectCopyWith<$Res>  {
  factory $ChatDataTransferObjectCopyWith(ChatDataTransferObject value, $Res Function(ChatDataTransferObject) _then) = _$ChatDataTransferObjectCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) String? id, List<Map<String, String>> participants, List<String> participantIds,@MessageDataTransferObjectConverter() MessageDataTransferObject lastMessage,@ServerTimestampConverter() FieldValue serverTimeStamp
});


$MessageDataTransferObjectCopyWith<$Res> get lastMessage;

}
/// @nodoc
class _$ChatDataTransferObjectCopyWithImpl<$Res>
    implements $ChatDataTransferObjectCopyWith<$Res> {
  _$ChatDataTransferObjectCopyWithImpl(this._self, this._then);

  final ChatDataTransferObject _self;
  final $Res Function(ChatDataTransferObject) _then;

/// Create a copy of ChatDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? participants = null,Object? participantIds = null,Object? lastMessage = null,Object? serverTimeStamp = null,}) {
  return _then(ChatDataTransferObject(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as MessageDataTransferObject,serverTimeStamp: null == serverTimeStamp ? _self.serverTimeStamp : serverTimeStamp // ignore: cast_nullable_to_non_nullable
as FieldValue,
  ));
}
/// Create a copy of ChatDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageDataTransferObjectCopyWith<$Res> get lastMessage {
  
  return $MessageDataTransferObjectCopyWith<$Res>(_self.lastMessage, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatDataTransferObject].
extension ChatDataTransferObjectPatterns on ChatDataTransferObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatDataTransferObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatDataTransferObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatDataTransferObject value)  $default,){
final _that = this;
switch (_that) {
case _ChatDataTransferObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatDataTransferObject value)?  $default,){
final _that = this;
switch (_that) {
case _ChatDataTransferObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  List<Map<String, String>> participants,  List<String> participantIds, @MessageDataTransferObjectConverter()  MessageDataTransferObject lastMessage, @ServerTimestampConverter()  FieldValue serverTimeStamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatDataTransferObject() when $default != null:
return $default(_that.id,_that.participants,_that.participantIds,_that.lastMessage,_that.serverTimeStamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  List<Map<String, String>> participants,  List<String> participantIds, @MessageDataTransferObjectConverter()  MessageDataTransferObject lastMessage, @ServerTimestampConverter()  FieldValue serverTimeStamp)  $default,) {final _that = this;
switch (_that) {
case _ChatDataTransferObject():
return $default(_that.id,_that.participants,_that.participantIds,_that.lastMessage,_that.serverTimeStamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  List<Map<String, String>> participants,  List<String> participantIds, @MessageDataTransferObjectConverter()  MessageDataTransferObject lastMessage, @ServerTimestampConverter()  FieldValue serverTimeStamp)?  $default,) {final _that = this;
switch (_that) {
case _ChatDataTransferObject() when $default != null:
return $default(_that.id,_that.participants,_that.participantIds,_that.lastMessage,_that.serverTimeStamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatDataTransferObject extends ChatDataTransferObject {
  const _ChatDataTransferObject({@JsonKey(includeToJson: false, includeFromJson: false) this.id, required  List<Map<String, String>> participants, required  List<String> participantIds, @MessageDataTransferObjectConverter() required this.lastMessage, @ServerTimestampConverter() required this.serverTimeStamp}): _participants = participants,_participantIds = participantIds,super._();
  factory _ChatDataTransferObject.fromJson(Map<String, dynamic> json) => _$ChatDataTransferObjectFromJson(json);

@override@JsonKey(includeToJson: false, includeFromJson: false) final  String? id;
 final  List<Map<String, String>> _participants;
@override List<Map<String, String>> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

/// Flat mirror of the participant ids in [participants].
///
/// [participants] is a list of maps (participant id -> last seen message
/// id) and Firestore security rules cannot iterate that shape, so
/// "the writer must be a participant" is not expressible over it. This
/// duplicated field exists purely so the rules can enforce it, and is
/// always derived in [fromDomain] rather than set by callers.
///
/// Stored sorted, so the rules can require the chat id to equal
/// `participantIds.join('_')`, the format compositeId produces.
 final  List<String> _participantIds;
/// Flat mirror of the participant ids in [participants].
///
/// [participants] is a list of maps (participant id -> last seen message
/// id) and Firestore security rules cannot iterate that shape, so
/// "the writer must be a participant" is not expressible over it. This
/// duplicated field exists purely so the rules can enforce it, and is
/// always derived in [fromDomain] rather than set by callers.
///
/// Stored sorted, so the rules can require the chat id to equal
/// `participantIds.join('_')`, the format compositeId produces.
@override List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

@override@MessageDataTransferObjectConverter() final  MessageDataTransferObject lastMessage;
@override@ServerTimestampConverter() final  FieldValue serverTimeStamp;

/// Create a copy of ChatDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatDataTransferObjectCopyWith<_ChatDataTransferObject> get copyWith => __$ChatDataTransferObjectCopyWithImpl<_ChatDataTransferObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatDataTransferObjectToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatDataTransferObject&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.participants, _participants)&&const DeepCollectionEquality().equals(other.participantIds, _participantIds)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.serverTimeStamp, serverTimeStamp) || other.serverTimeStamp == serverTimeStamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_participants),const DeepCollectionEquality().hash(_participantIds),lastMessage,serverTimeStamp);
}

@override
String toString() {
    return 'ChatDataTransferObject(id: $id, participants: $participants, participantIds: $participantIds, lastMessage: $lastMessage, serverTimeStamp: $serverTimeStamp)';
}


}

/// @nodoc
abstract mixin class _$ChatDataTransferObjectCopyWith<$Res> implements $ChatDataTransferObjectCopyWith<$Res> {
  factory _$ChatDataTransferObjectCopyWith(_ChatDataTransferObject value, $Res Function(_ChatDataTransferObject) _then) = __$ChatDataTransferObjectCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) String? id, List<Map<String, String>> participants, List<String> participantIds,@MessageDataTransferObjectConverter() MessageDataTransferObject lastMessage,@ServerTimestampConverter() FieldValue serverTimeStamp
});


@override $MessageDataTransferObjectCopyWith<$Res> get lastMessage;

}
/// @nodoc
class __$ChatDataTransferObjectCopyWithImpl<$Res>
    implements _$ChatDataTransferObjectCopyWith<$Res> {
  __$ChatDataTransferObjectCopyWithImpl(this._self, this._then);

  final _ChatDataTransferObject _self;
  final $Res Function(_ChatDataTransferObject) _then;

/// Create a copy of ChatDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? participants = null,Object? participantIds = null,Object? lastMessage = null,Object? serverTimeStamp = null,}) {
  return _then(_ChatDataTransferObject(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as MessageDataTransferObject,serverTimeStamp: null == serverTimeStamp ? _self.serverTimeStamp : serverTimeStamp // ignore: cast_nullable_to_non_nullable
as FieldValue,
  ));
}

/// Create a copy of ChatDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageDataTransferObjectCopyWith<$Res> get lastMessage {
  
  return $MessageDataTransferObjectCopyWith<$Res>(_self.lastMessage, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}

// dart format on
