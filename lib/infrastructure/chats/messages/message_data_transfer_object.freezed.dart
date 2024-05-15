// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_data_transfer_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageDataTransferObject _$MessageDataTransferObjectFromJson(
    Map<String, dynamic> json) {
  return _MessageDataTransferObject.fromJson(json);
}

/// @nodoc
mixin _$MessageDataTransferObject {
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  List<String> get reactions => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get repliedMessageId => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false, includeFromJson: true)
  DateTime? get timeStamp => throw _privateConstructorUsedError;
  @ServerTimestampConverter()
  FieldValue get serverTimeStamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageDataTransferObjectCopyWith<MessageDataTransferObject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageDataTransferObjectCopyWith<$Res> {
  factory $MessageDataTransferObjectCopyWith(MessageDataTransferObject value,
          $Res Function(MessageDataTransferObject) then) =
      _$MessageDataTransferObjectCopyWithImpl<$Res, MessageDataTransferObject>;
  @useResult
  $Res call(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      String senderId,
      List<String> imageUrls,
      List<String> reactions,
      String content,
      String repliedMessageId,
      bool isEdited,
      @JsonKey(includeToJson: false, includeFromJson: true) DateTime? timeStamp,
      @ServerTimestampConverter() FieldValue serverTimeStamp});
}

/// @nodoc
class _$MessageDataTransferObjectCopyWithImpl<$Res,
        $Val extends MessageDataTransferObject>
    implements $MessageDataTransferObjectCopyWith<$Res> {
  _$MessageDataTransferObjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? senderId = null,
    Object? imageUrls = null,
    Object? reactions = null,
    Object? content = null,
    Object? repliedMessageId = null,
    Object? isEdited = null,
    Object? timeStamp = freezed,
    Object? serverTimeStamp = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      repliedMessageId: null == repliedMessageId
          ? _value.repliedMessageId
          : repliedMessageId // ignore: cast_nullable_to_non_nullable
              as String,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      timeStamp: freezed == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverTimeStamp: null == serverTimeStamp
          ? _value.serverTimeStamp
          : serverTimeStamp // ignore: cast_nullable_to_non_nullable
              as FieldValue,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageDataTransferObjectImplCopyWith<$Res>
    implements $MessageDataTransferObjectCopyWith<$Res> {
  factory _$$MessageDataTransferObjectImplCopyWith(
          _$MessageDataTransferObjectImpl value,
          $Res Function(_$MessageDataTransferObjectImpl) then) =
      __$$MessageDataTransferObjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      String senderId,
      List<String> imageUrls,
      List<String> reactions,
      String content,
      String repliedMessageId,
      bool isEdited,
      @JsonKey(includeToJson: false, includeFromJson: true) DateTime? timeStamp,
      @ServerTimestampConverter() FieldValue serverTimeStamp});
}

/// @nodoc
class __$$MessageDataTransferObjectImplCopyWithImpl<$Res>
    extends _$MessageDataTransferObjectCopyWithImpl<$Res,
        _$MessageDataTransferObjectImpl>
    implements _$$MessageDataTransferObjectImplCopyWith<$Res> {
  __$$MessageDataTransferObjectImplCopyWithImpl(
      _$MessageDataTransferObjectImpl _value,
      $Res Function(_$MessageDataTransferObjectImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? senderId = null,
    Object? imageUrls = null,
    Object? reactions = null,
    Object? content = null,
    Object? repliedMessageId = null,
    Object? isEdited = null,
    Object? timeStamp = freezed,
    Object? serverTimeStamp = null,
  }) {
    return _then(_$MessageDataTransferObjectImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reactions: null == reactions
          ? _value._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      repliedMessageId: null == repliedMessageId
          ? _value.repliedMessageId
          : repliedMessageId // ignore: cast_nullable_to_non_nullable
              as String,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      timeStamp: freezed == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverTimeStamp: null == serverTimeStamp
          ? _value.serverTimeStamp
          : serverTimeStamp // ignore: cast_nullable_to_non_nullable
              as FieldValue,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageDataTransferObjectImpl extends _MessageDataTransferObject {
  const _$MessageDataTransferObjectImpl(
      {@JsonKey(includeToJson: false, includeFromJson: false) this.id,
      required this.senderId,
      required final List<String> imageUrls,
      required final List<String> reactions,
      required this.content,
      required this.repliedMessageId,
      required this.isEdited,
      @JsonKey(includeToJson: false, includeFromJson: true) this.timeStamp,
      @ServerTimestampConverter() required this.serverTimeStamp})
      : _imageUrls = imageUrls,
        _reactions = reactions,
        super._();

  factory _$MessageDataTransferObjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageDataTransferObjectImplFromJson(json);

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? id;
  @override
  final String senderId;
  final List<String> _imageUrls;
  @override
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  final List<String> _reactions;
  @override
  List<String> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  @override
  final String content;
  @override
  final String repliedMessageId;
  @override
  final bool isEdited;
  @override
  @JsonKey(includeToJson: false, includeFromJson: true)
  final DateTime? timeStamp;
  @override
  @ServerTimestampConverter()
  final FieldValue serverTimeStamp;

  @override
  String toString() {
    return 'MessageDataTransferObject(id: $id, senderId: $senderId, imageUrls: $imageUrls, reactions: $reactions, content: $content, repliedMessageId: $repliedMessageId, isEdited: $isEdited, timeStamp: $timeStamp, serverTimeStamp: $serverTimeStamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageDataTransferObjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.repliedMessageId, repliedMessageId) ||
                other.repliedMessageId == repliedMessageId) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.timeStamp, timeStamp) ||
                other.timeStamp == timeStamp) &&
            (identical(other.serverTimeStamp, serverTimeStamp) ||
                other.serverTimeStamp == serverTimeStamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      senderId,
      const DeepCollectionEquality().hash(_imageUrls),
      const DeepCollectionEquality().hash(_reactions),
      content,
      repliedMessageId,
      isEdited,
      timeStamp,
      serverTimeStamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageDataTransferObjectImplCopyWith<_$MessageDataTransferObjectImpl>
      get copyWith => __$$MessageDataTransferObjectImplCopyWithImpl<
          _$MessageDataTransferObjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageDataTransferObjectImplToJson(
      this,
    );
  }
}

abstract class _MessageDataTransferObject extends MessageDataTransferObject {
  const factory _MessageDataTransferObject(
      {@JsonKey(includeToJson: false, includeFromJson: false) final String? id,
      required final String senderId,
      required final List<String> imageUrls,
      required final List<String> reactions,
      required final String content,
      required final String repliedMessageId,
      required final bool isEdited,
      @JsonKey(includeToJson: false, includeFromJson: true)
      final DateTime? timeStamp,
      @ServerTimestampConverter()
      required final FieldValue
          serverTimeStamp}) = _$MessageDataTransferObjectImpl;
  const _MessageDataTransferObject._() : super._();

  factory _MessageDataTransferObject.fromJson(Map<String, dynamic> json) =
      _$MessageDataTransferObjectImpl.fromJson;

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get id;
  @override
  String get senderId;
  @override
  List<String> get imageUrls;
  @override
  List<String> get reactions;
  @override
  String get content;
  @override
  String get repliedMessageId;
  @override
  bool get isEdited;
  @override
  @JsonKey(includeToJson: false, includeFromJson: true)
  DateTime? get timeStamp;
  @override
  @ServerTimestampConverter()
  FieldValue get serverTimeStamp;
  @override
  @JsonKey(ignore: true)
  _$$MessageDataTransferObjectImplCopyWith<_$MessageDataTransferObjectImpl>
      get copyWith => throw _privateConstructorUsedError;
}
