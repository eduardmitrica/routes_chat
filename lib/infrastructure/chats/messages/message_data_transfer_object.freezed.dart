// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_data_transfer_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageDataTransferObject {

@JsonKey(includeToJson: false, includeFromJson: false) String? get id; String get senderId; List<String> get imageUrls; List<String> get reactions; String get content; String get repliedMessageId; bool get isEdited;@JsonKey(includeToJson: false, includeFromJson: false) DateTime? get timeStamp;@ServerTimestampConverter() FieldValue get serverTimeStamp;
/// Create a copy of MessageDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageDataTransferObjectCopyWith<MessageDataTransferObject> get copyWith => _$MessageDataTransferObjectCopyWithImpl<MessageDataTransferObject>(this as MessageDataTransferObject, _$identity);

  /// Serializes this MessageDataTransferObject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MessageDataTransferObject;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageDataTransferObject&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&const DeepCollectionEquality().equals(other.imageUrls, _this.imageUrls)&&const DeepCollectionEquality().equals(other.reactions, _this.reactions)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.repliedMessageId, _this.repliedMessageId) || other.repliedMessageId == _this.repliedMessageId)&&(identical(other.isEdited, _this.isEdited) || other.isEdited == _this.isEdited)&&(identical(other.timeStamp, _this.timeStamp) || other.timeStamp == _this.timeStamp)&&(identical(other.serverTimeStamp, _this.serverTimeStamp) || other.serverTimeStamp == _this.serverTimeStamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MessageDataTransferObject;
  return Object.hash(runtimeType,_this.id,_this.senderId,const DeepCollectionEquality().hash(_this.imageUrls),const DeepCollectionEquality().hash(_this.reactions),_this.content,_this.repliedMessageId,_this.isEdited,_this.timeStamp,_this.serverTimeStamp);
}

@override
String toString() {
  final _this = this as MessageDataTransferObject;
  return 'MessageDataTransferObject(id: ${_this.id}, senderId: ${_this.senderId}, imageUrls: ${_this.imageUrls}, reactions: ${_this.reactions}, content: ${_this.content}, repliedMessageId: ${_this.repliedMessageId}, isEdited: ${_this.isEdited}, timeStamp: ${_this.timeStamp}, serverTimeStamp: ${_this.serverTimeStamp})';
}


}

/// @nodoc
abstract mixin class $MessageDataTransferObjectCopyWith<$Res>  {
  factory $MessageDataTransferObjectCopyWith(MessageDataTransferObject value, $Res Function(MessageDataTransferObject) _then) = _$MessageDataTransferObjectCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) String? id, String senderId, List<String> imageUrls, List<String> reactions, String content, String repliedMessageId, bool isEdited,@JsonKey(includeToJson: false, includeFromJson: false) DateTime? timeStamp,@ServerTimestampConverter() FieldValue serverTimeStamp
});




}
/// @nodoc
class _$MessageDataTransferObjectCopyWithImpl<$Res>
    implements $MessageDataTransferObjectCopyWith<$Res> {
  _$MessageDataTransferObjectCopyWithImpl(this._self, this._then);

  final MessageDataTransferObject _self;
  final $Res Function(MessageDataTransferObject) _then;

/// Create a copy of MessageDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? senderId = null,Object? imageUrls = null,Object? reactions = null,Object? content = null,Object? repliedMessageId = null,Object? isEdited = null,Object? timeStamp = freezed,Object? serverTimeStamp = null,}) {
  return _then(MessageDataTransferObject(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<String>,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,repliedMessageId: null == repliedMessageId ? _self.repliedMessageId : repliedMessageId // ignore: cast_nullable_to_non_nullable
as String,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,timeStamp: freezed == timeStamp ? _self.timeStamp : timeStamp // ignore: cast_nullable_to_non_nullable
as DateTime?,serverTimeStamp: null == serverTimeStamp ? _self.serverTimeStamp : serverTimeStamp // ignore: cast_nullable_to_non_nullable
as FieldValue,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageDataTransferObject].
extension MessageDataTransferObjectPatterns on MessageDataTransferObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageDataTransferObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageDataTransferObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageDataTransferObject value)  $default,){
final _that = this;
switch (_that) {
case _MessageDataTransferObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageDataTransferObject value)?  $default,){
final _that = this;
switch (_that) {
case _MessageDataTransferObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String senderId,  List<String> imageUrls,  List<String> reactions,  String content,  String repliedMessageId,  bool isEdited, @JsonKey(includeToJson: false, includeFromJson: false)  DateTime? timeStamp, @ServerTimestampConverter()  FieldValue serverTimeStamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageDataTransferObject() when $default != null:
return $default(_that.id,_that.senderId,_that.imageUrls,_that.reactions,_that.content,_that.repliedMessageId,_that.isEdited,_that.timeStamp,_that.serverTimeStamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String senderId,  List<String> imageUrls,  List<String> reactions,  String content,  String repliedMessageId,  bool isEdited, @JsonKey(includeToJson: false, includeFromJson: false)  DateTime? timeStamp, @ServerTimestampConverter()  FieldValue serverTimeStamp)  $default,) {final _that = this;
switch (_that) {
case _MessageDataTransferObject():
return $default(_that.id,_that.senderId,_that.imageUrls,_that.reactions,_that.content,_that.repliedMessageId,_that.isEdited,_that.timeStamp,_that.serverTimeStamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false, includeFromJson: false)  String? id,  String senderId,  List<String> imageUrls,  List<String> reactions,  String content,  String repliedMessageId,  bool isEdited, @JsonKey(includeToJson: false, includeFromJson: false)  DateTime? timeStamp, @ServerTimestampConverter()  FieldValue serverTimeStamp)?  $default,) {final _that = this;
switch (_that) {
case _MessageDataTransferObject() when $default != null:
return $default(_that.id,_that.senderId,_that.imageUrls,_that.reactions,_that.content,_that.repliedMessageId,_that.isEdited,_that.timeStamp,_that.serverTimeStamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageDataTransferObject extends MessageDataTransferObject {
  const _MessageDataTransferObject({@JsonKey(includeToJson: false, includeFromJson: false) this.id, required this.senderId, required  List<String> imageUrls, required  List<String> reactions, required this.content, required this.repliedMessageId, required this.isEdited, @JsonKey(includeToJson: false, includeFromJson: false) this.timeStamp, @ServerTimestampConverter() required this.serverTimeStamp}): _imageUrls = imageUrls,_reactions = reactions,super._();
  factory _MessageDataTransferObject.fromJson(Map<String, dynamic> json) => _$MessageDataTransferObjectFromJson(json);

@override@JsonKey(includeToJson: false, includeFromJson: false) final  String? id;
@override final  String senderId;
 final  List<String> _imageUrls;
@override List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

 final  List<String> _reactions;
@override List<String> get reactions {
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactions);
}

@override final  String content;
@override final  String repliedMessageId;
@override final  bool isEdited;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  DateTime? timeStamp;
@override@ServerTimestampConverter() final  FieldValue serverTimeStamp;

/// Create a copy of MessageDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageDataTransferObjectCopyWith<_MessageDataTransferObject> get copyWith => __$MessageDataTransferObjectCopyWithImpl<_MessageDataTransferObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageDataTransferObjectToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageDataTransferObject&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&const DeepCollectionEquality().equals(other.imageUrls, _imageUrls)&&const DeepCollectionEquality().equals(other.reactions, _reactions)&&(identical(other.content, content) || other.content == content)&&(identical(other.repliedMessageId, repliedMessageId) || other.repliedMessageId == repliedMessageId)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.timeStamp, timeStamp) || other.timeStamp == timeStamp)&&(identical(other.serverTimeStamp, serverTimeStamp) || other.serverTimeStamp == serverTimeStamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,senderId,const DeepCollectionEquality().hash(_imageUrls),const DeepCollectionEquality().hash(_reactions),content,repliedMessageId,isEdited,timeStamp,serverTimeStamp);
}

@override
String toString() {
    return 'MessageDataTransferObject(id: $id, senderId: $senderId, imageUrls: $imageUrls, reactions: $reactions, content: $content, repliedMessageId: $repliedMessageId, isEdited: $isEdited, timeStamp: $timeStamp, serverTimeStamp: $serverTimeStamp)';
}


}

/// @nodoc
abstract mixin class _$MessageDataTransferObjectCopyWith<$Res> implements $MessageDataTransferObjectCopyWith<$Res> {
  factory _$MessageDataTransferObjectCopyWith(_MessageDataTransferObject value, $Res Function(_MessageDataTransferObject) _then) = __$MessageDataTransferObjectCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) String? id, String senderId, List<String> imageUrls, List<String> reactions, String content, String repliedMessageId, bool isEdited,@JsonKey(includeToJson: false, includeFromJson: false) DateTime? timeStamp,@ServerTimestampConverter() FieldValue serverTimeStamp
});




}
/// @nodoc
class __$MessageDataTransferObjectCopyWithImpl<$Res>
    implements _$MessageDataTransferObjectCopyWith<$Res> {
  __$MessageDataTransferObjectCopyWithImpl(this._self, this._then);

  final _MessageDataTransferObject _self;
  final $Res Function(_MessageDataTransferObject) _then;

/// Create a copy of MessageDataTransferObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? senderId = null,Object? imageUrls = null,Object? reactions = null,Object? content = null,Object? repliedMessageId = null,Object? isEdited = null,Object? timeStamp = freezed,Object? serverTimeStamp = null,}) {
  return _then(_MessageDataTransferObject(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<String>,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,repliedMessageId: null == repliedMessageId ? _self.repliedMessageId : repliedMessageId // ignore: cast_nullable_to_non_nullable
as String,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,timeStamp: freezed == timeStamp ? _self.timeStamp : timeStamp // ignore: cast_nullable_to_non_nullable
as DateTime?,serverTimeStamp: null == serverTimeStamp ? _self.serverTimeStamp : serverTimeStamp // ignore: cast_nullable_to_non_nullable
as FieldValue,
  ));
}


}

// dart format on
