// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_data_transfer_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatDataTransferObject _$ChatDataTransferObjectFromJson(
    Map<String, dynamic> json) {
  return _ChatDataTransferObject.fromJson(json);
}

/// @nodoc
mixin _$ChatDataTransferObject {
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get id => throw _privateConstructorUsedError;
  List<Map<String, String>> get participants =>
      throw _privateConstructorUsedError;
  @MessageDataTransferObjectConverter()
  MessageDataTransferObject get lastMessage =>
      throw _privateConstructorUsedError;
  @ServerTimestampConverter()
  FieldValue get serverTimeStamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatDataTransferObjectCopyWith<ChatDataTransferObject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatDataTransferObjectCopyWith<$Res> {
  factory $ChatDataTransferObjectCopyWith(ChatDataTransferObject value,
          $Res Function(ChatDataTransferObject) then) =
      _$ChatDataTransferObjectCopyWithImpl<$Res, ChatDataTransferObject>;
  @useResult
  $Res call(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      List<Map<String, String>> participants,
      @MessageDataTransferObjectConverter()
      MessageDataTransferObject lastMessage,
      @ServerTimestampConverter() FieldValue serverTimeStamp});

  $MessageDataTransferObjectCopyWith<$Res> get lastMessage;
}

/// @nodoc
class _$ChatDataTransferObjectCopyWithImpl<$Res,
        $Val extends ChatDataTransferObject>
    implements $ChatDataTransferObjectCopyWith<$Res> {
  _$ChatDataTransferObjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? participants = null,
    Object? lastMessage = null,
    Object? serverTimeStamp = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<Map<String, String>>,
      lastMessage: null == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as MessageDataTransferObject,
      serverTimeStamp: null == serverTimeStamp
          ? _value.serverTimeStamp
          : serverTimeStamp // ignore: cast_nullable_to_non_nullable
              as FieldValue,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MessageDataTransferObjectCopyWith<$Res> get lastMessage {
    return $MessageDataTransferObjectCopyWith<$Res>(_value.lastMessage,
        (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatDataTransferObjectImplCopyWith<$Res>
    implements $ChatDataTransferObjectCopyWith<$Res> {
  factory _$$ChatDataTransferObjectImplCopyWith(
          _$ChatDataTransferObjectImpl value,
          $Res Function(_$ChatDataTransferObjectImpl) then) =
      __$$ChatDataTransferObjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      List<Map<String, String>> participants,
      @MessageDataTransferObjectConverter()
      MessageDataTransferObject lastMessage,
      @ServerTimestampConverter() FieldValue serverTimeStamp});

  @override
  $MessageDataTransferObjectCopyWith<$Res> get lastMessage;
}

/// @nodoc
class __$$ChatDataTransferObjectImplCopyWithImpl<$Res>
    extends _$ChatDataTransferObjectCopyWithImpl<$Res,
        _$ChatDataTransferObjectImpl>
    implements _$$ChatDataTransferObjectImplCopyWith<$Res> {
  __$$ChatDataTransferObjectImplCopyWithImpl(
      _$ChatDataTransferObjectImpl _value,
      $Res Function(_$ChatDataTransferObjectImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? participants = null,
    Object? lastMessage = null,
    Object? serverTimeStamp = null,
  }) {
    return _then(_$ChatDataTransferObjectImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<Map<String, String>>,
      lastMessage: null == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as MessageDataTransferObject,
      serverTimeStamp: null == serverTimeStamp
          ? _value.serverTimeStamp
          : serverTimeStamp // ignore: cast_nullable_to_non_nullable
              as FieldValue,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatDataTransferObjectImpl extends _ChatDataTransferObject {
  const _$ChatDataTransferObjectImpl(
      {@JsonKey(includeToJson: false, includeFromJson: false) this.id,
      required final List<Map<String, String>> participants,
      @MessageDataTransferObjectConverter() required this.lastMessage,
      @ServerTimestampConverter() required this.serverTimeStamp})
      : _participants = participants,
        super._();

  factory _$ChatDataTransferObjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatDataTransferObjectImplFromJson(json);

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? id;
  final List<Map<String, String>> _participants;
  @override
  List<Map<String, String>> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  @MessageDataTransferObjectConverter()
  final MessageDataTransferObject lastMessage;
  @override
  @ServerTimestampConverter()
  final FieldValue serverTimeStamp;

  @override
  String toString() {
    return 'ChatDataTransferObject(id: $id, participants: $participants, lastMessage: $lastMessage, serverTimeStamp: $serverTimeStamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatDataTransferObjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.serverTimeStamp, serverTimeStamp) ||
                other.serverTimeStamp == serverTimeStamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_participants),
      lastMessage,
      serverTimeStamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatDataTransferObjectImplCopyWith<_$ChatDataTransferObjectImpl>
      get copyWith => __$$ChatDataTransferObjectImplCopyWithImpl<
          _$ChatDataTransferObjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatDataTransferObjectImplToJson(
      this,
    );
  }
}

abstract class _ChatDataTransferObject extends ChatDataTransferObject {
  const factory _ChatDataTransferObject(
      {@JsonKey(includeToJson: false, includeFromJson: false) final String? id,
      required final List<Map<String, String>> participants,
      @MessageDataTransferObjectConverter()
      required final MessageDataTransferObject lastMessage,
      @ServerTimestampConverter()
      required final FieldValue
          serverTimeStamp}) = _$ChatDataTransferObjectImpl;
  const _ChatDataTransferObject._() : super._();

  factory _ChatDataTransferObject.fromJson(Map<String, dynamic> json) =
      _$ChatDataTransferObjectImpl.fromJson;

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get id;
  @override
  List<Map<String, String>> get participants;
  @override
  @MessageDataTransferObjectConverter()
  MessageDataTransferObject get lastMessage;
  @override
  @ServerTimestampConverter()
  FieldValue get serverTimeStamp;
  @override
  @JsonKey(ignore: true)
  _$$ChatDataTransferObjectImplCopyWith<_$ChatDataTransferObjectImpl>
      get copyWith => throw _privateConstructorUsedError;
}
