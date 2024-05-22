// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Message {
  UniqueId get id => throw _privateConstructorUsedError;
  UniqueId get senderId => throw _privateConstructorUsedError;
  KtList<ImageUrl> get imageUrls => throw _privateConstructorUsedError;
  KtList<UniqueId> get reactions => throw _privateConstructorUsedError;
  Content get content => throw _privateConstructorUsedError;
  UniqueId get repliedMessageId => throw _privateConstructorUsedError;
  DateTime? get lastUpdatedAt => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {UniqueId id,
      UniqueId senderId,
      KtList<ImageUrl> imageUrls,
      KtList<UniqueId> reactions,
      Content content,
      UniqueId repliedMessageId,
      DateTime? lastUpdatedAt,
      bool isEdited});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? imageUrls = null,
    Object? reactions = null,
    Object? content = null,
    Object? repliedMessageId = null,
    Object? lastUpdatedAt = freezed,
    Object? isEdited = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UniqueId,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as UniqueId,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as KtList<ImageUrl>,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as KtList<UniqueId>,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Content,
      repliedMessageId: null == repliedMessageId
          ? _value.repliedMessageId
          : repliedMessageId // ignore: cast_nullable_to_non_nullable
              as UniqueId,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {UniqueId id,
      UniqueId senderId,
      KtList<ImageUrl> imageUrls,
      KtList<UniqueId> reactions,
      Content content,
      UniqueId repliedMessageId,
      DateTime? lastUpdatedAt,
      bool isEdited});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? imageUrls = null,
    Object? reactions = null,
    Object? content = null,
    Object? repliedMessageId = null,
    Object? lastUpdatedAt = freezed,
    Object? isEdited = null,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UniqueId,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as UniqueId,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as KtList<ImageUrl>,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as KtList<UniqueId>,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Content,
      repliedMessageId: null == repliedMessageId
          ? _value.repliedMessageId
          : repliedMessageId // ignore: cast_nullable_to_non_nullable
              as UniqueId,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.senderId,
      required this.imageUrls,
      required this.reactions,
      required this.content,
      required this.repliedMessageId,
      required this.lastUpdatedAt,
      required this.isEdited});

  @override
  final UniqueId id;
  @override
  final UniqueId senderId;
  @override
  final KtList<ImageUrl> imageUrls;
  @override
  final KtList<UniqueId> reactions;
  @override
  final Content content;
  @override
  final UniqueId repliedMessageId;
  @override
  final DateTime? lastUpdatedAt;
  @override
  final bool isEdited;

  @override
  String toString() {
    return 'Message(id: $id, senderId: $senderId, imageUrls: $imageUrls, reactions: $reactions, content: $content, repliedMessageId: $repliedMessageId, lastUpdatedAt: $lastUpdatedAt, isEdited: $isEdited)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.imageUrls, imageUrls) ||
                other.imageUrls == imageUrls) &&
            (identical(other.reactions, reactions) ||
                other.reactions == reactions) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.repliedMessageId, repliedMessageId) ||
                other.repliedMessageId == repliedMessageId) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, senderId, imageUrls,
      reactions, content, repliedMessageId, lastUpdatedAt, isEdited);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);
}

abstract class _Message implements Message {
  const factory _Message(
      {required final UniqueId id,
      required final UniqueId senderId,
      required final KtList<ImageUrl> imageUrls,
      required final KtList<UniqueId> reactions,
      required final Content content,
      required final UniqueId repliedMessageId,
      required final DateTime? lastUpdatedAt,
      required final bool isEdited}) = _$MessageImpl;

  @override
  UniqueId get id;
  @override
  UniqueId get senderId;
  @override
  KtList<ImageUrl> get imageUrls;
  @override
  KtList<UniqueId> get reactions;
  @override
  Content get content;
  @override
  UniqueId get repliedMessageId;
  @override
  DateTime? get lastUpdatedAt;
  @override
  bool get isEdited;
  @override
  @JsonKey(ignore: true)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
