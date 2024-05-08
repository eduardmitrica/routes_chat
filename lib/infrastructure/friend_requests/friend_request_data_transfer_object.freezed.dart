// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_request_data_transfer_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FriendRequestDataTransferObject _$FriendRequestDataTransferObjectFromJson(
    Map<String, dynamic> json) {
  return _FriendRequestDataTransferObject.fromJson(json);
}

/// @nodoc
mixin _$FriendRequestDataTransferObject {
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @ServerTimestampConverter()
  FieldValue get serverTimeStamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FriendRequestDataTransferObjectCopyWith<FriendRequestDataTransferObject>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendRequestDataTransferObjectCopyWith<$Res> {
  factory $FriendRequestDataTransferObjectCopyWith(
          FriendRequestDataTransferObject value,
          $Res Function(FriendRequestDataTransferObject) then) =
      _$FriendRequestDataTransferObjectCopyWithImpl<$Res,
          FriendRequestDataTransferObject>;
  @useResult
  $Res call(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      String senderId,
      String receiverId,
      String status,
      @ServerTimestampConverter() FieldValue serverTimeStamp});
}

/// @nodoc
class _$FriendRequestDataTransferObjectCopyWithImpl<$Res,
        $Val extends FriendRequestDataTransferObject>
    implements $FriendRequestDataTransferObjectCopyWith<$Res> {
  _$FriendRequestDataTransferObjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? senderId = null,
    Object? receiverId = null,
    Object? status = null,
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
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      serverTimeStamp: null == serverTimeStamp
          ? _value.serverTimeStamp
          : serverTimeStamp // ignore: cast_nullable_to_non_nullable
              as FieldValue,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FriendRequestDataTransferObjectImplCopyWith<$Res>
    implements $FriendRequestDataTransferObjectCopyWith<$Res> {
  factory _$$FriendRequestDataTransferObjectImplCopyWith(
          _$FriendRequestDataTransferObjectImpl value,
          $Res Function(_$FriendRequestDataTransferObjectImpl) then) =
      __$$FriendRequestDataTransferObjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      String senderId,
      String receiverId,
      String status,
      @ServerTimestampConverter() FieldValue serverTimeStamp});
}

/// @nodoc
class __$$FriendRequestDataTransferObjectImplCopyWithImpl<$Res>
    extends _$FriendRequestDataTransferObjectCopyWithImpl<$Res,
        _$FriendRequestDataTransferObjectImpl>
    implements _$$FriendRequestDataTransferObjectImplCopyWith<$Res> {
  __$$FriendRequestDataTransferObjectImplCopyWithImpl(
      _$FriendRequestDataTransferObjectImpl _value,
      $Res Function(_$FriendRequestDataTransferObjectImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? senderId = null,
    Object? receiverId = null,
    Object? status = null,
    Object? serverTimeStamp = null,
  }) {
    return _then(_$FriendRequestDataTransferObjectImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      serverTimeStamp: null == serverTimeStamp
          ? _value.serverTimeStamp
          : serverTimeStamp // ignore: cast_nullable_to_non_nullable
              as FieldValue,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendRequestDataTransferObjectImpl
    extends _FriendRequestDataTransferObject {
  const _$FriendRequestDataTransferObjectImpl(
      {@JsonKey(includeToJson: false, includeFromJson: false) this.id,
      required this.senderId,
      required this.receiverId,
      required this.status,
      @ServerTimestampConverter() required this.serverTimeStamp})
      : super._();

  factory _$FriendRequestDataTransferObjectImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$FriendRequestDataTransferObjectImplFromJson(json);

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? id;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final String status;
  @override
  @ServerTimestampConverter()
  final FieldValue serverTimeStamp;

  @override
  String toString() {
    return 'FriendRequestDataTransferObject(id: $id, senderId: $senderId, receiverId: $receiverId, status: $status, serverTimeStamp: $serverTimeStamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestDataTransferObjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.serverTimeStamp, serverTimeStamp) ||
                other.serverTimeStamp == serverTimeStamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, senderId, receiverId, status, serverTimeStamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestDataTransferObjectImplCopyWith<
          _$FriendRequestDataTransferObjectImpl>
      get copyWith => __$$FriendRequestDataTransferObjectImplCopyWithImpl<
          _$FriendRequestDataTransferObjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendRequestDataTransferObjectImplToJson(
      this,
    );
  }
}

abstract class _FriendRequestDataTransferObject
    extends FriendRequestDataTransferObject {
  const factory _FriendRequestDataTransferObject(
      {@JsonKey(includeToJson: false, includeFromJson: false) final String? id,
      required final String senderId,
      required final String receiverId,
      required final String status,
      @ServerTimestampConverter()
      required final FieldValue
          serverTimeStamp}) = _$FriendRequestDataTransferObjectImpl;
  const _FriendRequestDataTransferObject._() : super._();

  factory _FriendRequestDataTransferObject.fromJson(Map<String, dynamic> json) =
      _$FriendRequestDataTransferObjectImpl.fromJson;

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get id;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  String get status;
  @override
  @ServerTimestampConverter()
  FieldValue get serverTimeStamp;
  @override
  @JsonKey(ignore: true)
  _$$FriendRequestDataTransferObjectImplCopyWith<
          _$FriendRequestDataTransferObjectImpl>
      get copyWith => throw _privateConstructorUsedError;
}
