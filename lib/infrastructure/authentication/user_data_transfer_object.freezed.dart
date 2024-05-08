// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_data_transfer_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserDataTransferObject _$UserDataTransferObjectFromJson(
    Map<String, dynamic> json) {
  return _UserDataTransferObject.fromJson(json);
}

/// @nodoc
mixin _$UserDataTransferObject {
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get id => throw _privateConstructorUsedError;
  String get emailAddress => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserDataTransferObjectCopyWith<UserDataTransferObject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDataTransferObjectCopyWith<$Res> {
  factory $UserDataTransferObjectCopyWith(UserDataTransferObject value,
          $Res Function(UserDataTransferObject) then) =
      _$UserDataTransferObjectCopyWithImpl<$Res, UserDataTransferObject>;
  @useResult
  $Res call(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      String emailAddress,
      String username,
      String imageUrl,
      String description});
}

/// @nodoc
class _$UserDataTransferObjectCopyWithImpl<$Res,
        $Val extends UserDataTransferObject>
    implements $UserDataTransferObjectCopyWith<$Res> {
  _$UserDataTransferObjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? emailAddress = null,
    Object? username = null,
    Object? imageUrl = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      emailAddress: null == emailAddress
          ? _value.emailAddress
          : emailAddress // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserDataTransferObjectImplCopyWith<$Res>
    implements $UserDataTransferObjectCopyWith<$Res> {
  factory _$$UserDataTransferObjectImplCopyWith(
          _$UserDataTransferObjectImpl value,
          $Res Function(_$UserDataTransferObjectImpl) then) =
      __$$UserDataTransferObjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      String emailAddress,
      String username,
      String imageUrl,
      String description});
}

/// @nodoc
class __$$UserDataTransferObjectImplCopyWithImpl<$Res>
    extends _$UserDataTransferObjectCopyWithImpl<$Res,
        _$UserDataTransferObjectImpl>
    implements _$$UserDataTransferObjectImplCopyWith<$Res> {
  __$$UserDataTransferObjectImplCopyWithImpl(
      _$UserDataTransferObjectImpl _value,
      $Res Function(_$UserDataTransferObjectImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? emailAddress = null,
    Object? username = null,
    Object? imageUrl = null,
    Object? description = null,
  }) {
    return _then(_$UserDataTransferObjectImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      emailAddress: null == emailAddress
          ? _value.emailAddress
          : emailAddress // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDataTransferObjectImpl extends _UserDataTransferObject {
  const _$UserDataTransferObjectImpl(
      {@JsonKey(includeToJson: false, includeFromJson: false) this.id,
      required this.emailAddress,
      required this.username,
      required this.imageUrl,
      required this.description})
      : super._();

  factory _$UserDataTransferObjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDataTransferObjectImplFromJson(json);

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? id;
  @override
  final String emailAddress;
  @override
  final String username;
  @override
  final String imageUrl;
  @override
  final String description;

  @override
  String toString() {
    return 'UserDataTransferObject(id: $id, emailAddress: $emailAddress, username: $username, imageUrl: $imageUrl, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDataTransferObjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.emailAddress, emailAddress) ||
                other.emailAddress == emailAddress) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, emailAddress, username, imageUrl, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDataTransferObjectImplCopyWith<_$UserDataTransferObjectImpl>
      get copyWith => __$$UserDataTransferObjectImplCopyWithImpl<
          _$UserDataTransferObjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDataTransferObjectImplToJson(
      this,
    );
  }
}

abstract class _UserDataTransferObject extends UserDataTransferObject {
  const factory _UserDataTransferObject(
      {@JsonKey(includeToJson: false, includeFromJson: false) final String? id,
      required final String emailAddress,
      required final String username,
      required final String imageUrl,
      required final String description}) = _$UserDataTransferObjectImpl;
  const _UserDataTransferObject._() : super._();

  factory _UserDataTransferObject.fromJson(Map<String, dynamic> json) =
      _$UserDataTransferObjectImpl.fromJson;

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get id;
  @override
  String get emailAddress;
  @override
  String get username;
  @override
  String get imageUrl;
  @override
  String get description;
  @override
  @JsonKey(ignore: true)
  _$$UserDataTransferObjectImplCopyWith<_$UserDataTransferObjectImpl>
      get copyWith => throw _privateConstructorUsedError;
}
