// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Message {

 UniqueId get id; UniqueId get senderId; KtList<ImageUrl> get imageUrls; KtList<UniqueId> get reactions; Content get content; UniqueId get repliedMessageId; DateTime? get lastUpdatedAt; bool get isEdited;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Message;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.imageUrls, _this.imageUrls) || other.imageUrls == _this.imageUrls)&&(identical(other.reactions, _this.reactions) || other.reactions == _this.reactions)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.repliedMessageId, _this.repliedMessageId) || other.repliedMessageId == _this.repliedMessageId)&&(identical(other.lastUpdatedAt, _this.lastUpdatedAt) || other.lastUpdatedAt == _this.lastUpdatedAt)&&(identical(other.isEdited, _this.isEdited) || other.isEdited == _this.isEdited));
}


@override
int get hashCode {
  final _this = this as Message;
  return Object.hash(runtimeType,_this.id,_this.senderId,_this.imageUrls,_this.reactions,_this.content,_this.repliedMessageId,_this.lastUpdatedAt,_this.isEdited);
}

@override
String toString() {
  final _this = this as Message;
  return 'Message(id: ${_this.id}, senderId: ${_this.senderId}, imageUrls: ${_this.imageUrls}, reactions: ${_this.reactions}, content: ${_this.content}, repliedMessageId: ${_this.repliedMessageId}, lastUpdatedAt: ${_this.lastUpdatedAt}, isEdited: ${_this.isEdited})';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 UniqueId id, UniqueId senderId, KtList<ImageUrl> imageUrls, KtList<UniqueId> reactions, Content content, UniqueId repliedMessageId, DateTime? lastUpdatedAt, bool isEdited
});




}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? imageUrls = null,Object? reactions = null,Object? content = null,Object? repliedMessageId = null,Object? lastUpdatedAt = freezed,Object? isEdited = null,}) {
  return _then(Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as UniqueId,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as UniqueId,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as KtList<ImageUrl>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as KtList<UniqueId>,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Content,repliedMessageId: null == repliedMessageId ? _self.repliedMessageId : repliedMessageId // ignore: cast_nullable_to_non_nullable
as UniqueId,lastUpdatedAt: freezed == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UniqueId id,  UniqueId senderId,  KtList<ImageUrl> imageUrls,  KtList<UniqueId> reactions,  Content content,  UniqueId repliedMessageId,  DateTime? lastUpdatedAt,  bool isEdited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.senderId,_that.imageUrls,_that.reactions,_that.content,_that.repliedMessageId,_that.lastUpdatedAt,_that.isEdited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UniqueId id,  UniqueId senderId,  KtList<ImageUrl> imageUrls,  KtList<UniqueId> reactions,  Content content,  UniqueId repliedMessageId,  DateTime? lastUpdatedAt,  bool isEdited)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.senderId,_that.imageUrls,_that.reactions,_that.content,_that.repliedMessageId,_that.lastUpdatedAt,_that.isEdited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UniqueId id,  UniqueId senderId,  KtList<ImageUrl> imageUrls,  KtList<UniqueId> reactions,  Content content,  UniqueId repliedMessageId,  DateTime? lastUpdatedAt,  bool isEdited)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.senderId,_that.imageUrls,_that.reactions,_that.content,_that.repliedMessageId,_that.lastUpdatedAt,_that.isEdited);case _:
  return null;

}
}

}

/// @nodoc


class _Message implements Message {
  const _Message({required this.id, required this.senderId, required this.imageUrls, required this.reactions, required this.content, required this.repliedMessageId, required this.lastUpdatedAt, required this.isEdited});
  

@override final  UniqueId id;
@override final  UniqueId senderId;
@override final  KtList<ImageUrl> imageUrls;
@override final  KtList<UniqueId> reactions;
@override final  Content content;
@override final  UniqueId repliedMessageId;
@override final  DateTime? lastUpdatedAt;
@override final  bool isEdited;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.imageUrls, imageUrls) || other.imageUrls == imageUrls)&&(identical(other.reactions, reactions) || other.reactions == reactions)&&(identical(other.content, content) || other.content == content)&&(identical(other.repliedMessageId, repliedMessageId) || other.repliedMessageId == repliedMessageId)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,senderId,imageUrls,reactions,content,repliedMessageId,lastUpdatedAt,isEdited);
}

@override
String toString() {
    return 'Message(id: $id, senderId: $senderId, imageUrls: $imageUrls, reactions: $reactions, content: $content, repliedMessageId: $repliedMessageId, lastUpdatedAt: $lastUpdatedAt, isEdited: $isEdited)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 UniqueId id, UniqueId senderId, KtList<ImageUrl> imageUrls, KtList<UniqueId> reactions, Content content, UniqueId repliedMessageId, DateTime? lastUpdatedAt, bool isEdited
});




}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? imageUrls = null,Object? reactions = null,Object? content = null,Object? repliedMessageId = null,Object? lastUpdatedAt = freezed,Object? isEdited = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as UniqueId,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as UniqueId,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as KtList<ImageUrl>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as KtList<UniqueId>,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Content,repliedMessageId: null == repliedMessageId ? _self.repliedMessageId : repliedMessageId // ignore: cast_nullable_to_non_nullable
as UniqueId,lastUpdatedAt: freezed == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
