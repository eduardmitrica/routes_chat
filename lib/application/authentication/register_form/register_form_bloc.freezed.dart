// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_form_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RegisterFormEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterFormEventCopyWith<$Res> {
  factory $RegisterFormEventCopyWith(
          RegisterFormEvent value, $Res Function(RegisterFormEvent) then) =
      _$RegisterFormEventCopyWithImpl<$Res, RegisterFormEvent>;
}

/// @nodoc
class _$RegisterFormEventCopyWithImpl<$Res, $Val extends RegisterFormEvent>
    implements $RegisterFormEventCopyWith<$Res> {
  _$RegisterFormEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$UserImagePlaceholderRequestedImplCopyWith<$Res> {
  factory _$$UserImagePlaceholderRequestedImplCopyWith(
          _$UserImagePlaceholderRequestedImpl value,
          $Res Function(_$UserImagePlaceholderRequestedImpl) then) =
      __$$UserImagePlaceholderRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UserImagePlaceholderRequestedImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res,
        _$UserImagePlaceholderRequestedImpl>
    implements _$$UserImagePlaceholderRequestedImplCopyWith<$Res> {
  __$$UserImagePlaceholderRequestedImplCopyWithImpl(
      _$UserImagePlaceholderRequestedImpl _value,
      $Res Function(_$UserImagePlaceholderRequestedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UserImagePlaceholderRequestedImpl
    implements UserImagePlaceholderRequested {
  const _$UserImagePlaceholderRequestedImpl();

  @override
  String toString() {
    return 'RegisterFormEvent.userImagePlaceholderRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImagePlaceholderRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return userImagePlaceholderRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return userImagePlaceholderRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (userImagePlaceholderRequested != null) {
      return userImagePlaceholderRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return userImagePlaceholderRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return userImagePlaceholderRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (userImagePlaceholderRequested != null) {
      return userImagePlaceholderRequested(this);
    }
    return orElse();
  }
}

abstract class UserImagePlaceholderRequested implements RegisterFormEvent {
  const factory UserImagePlaceholderRequested() =
      _$UserImagePlaceholderRequestedImpl;
}

/// @nodoc
abstract class _$$ImageChangedImplCopyWith<$Res> {
  factory _$$ImageChangedImplCopyWith(
          _$ImageChangedImpl value, $Res Function(_$ImageChangedImpl) then) =
      __$$ImageChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imagePathString});
}

/// @nodoc
class __$$ImageChangedImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res, _$ImageChangedImpl>
    implements _$$ImageChangedImplCopyWith<$Res> {
  __$$ImageChangedImplCopyWithImpl(
      _$ImageChangedImpl _value, $Res Function(_$ImageChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePathString = null,
  }) {
    return _then(_$ImageChangedImpl(
      null == imagePathString
          ? _value.imagePathString
          : imagePathString // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ImageChangedImpl implements ImageChanged {
  const _$ImageChangedImpl(this.imagePathString);

  @override
  final String imagePathString;

  @override
  String toString() {
    return 'RegisterFormEvent.imageChanged(imagePathString: $imagePathString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageChangedImpl &&
            (identical(other.imagePathString, imagePathString) ||
                other.imagePathString == imagePathString));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imagePathString);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageChangedImplCopyWith<_$ImageChangedImpl> get copyWith =>
      __$$ImageChangedImplCopyWithImpl<_$ImageChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return imageChanged(imagePathString);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return imageChanged?.call(imagePathString);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (imageChanged != null) {
      return imageChanged(imagePathString);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return imageChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return imageChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (imageChanged != null) {
      return imageChanged(this);
    }
    return orElse();
  }
}

abstract class ImageChanged implements RegisterFormEvent {
  const factory ImageChanged(final String imagePathString) = _$ImageChangedImpl;

  String get imagePathString;
  @JsonKey(ignore: true)
  _$$ImageChangedImplCopyWith<_$ImageChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ImageFetchedFromDbImplCopyWith<$Res> {
  factory _$$ImageFetchedFromDbImplCopyWith(_$ImageFetchedFromDbImpl value,
          $Res Function(_$ImageFetchedFromDbImpl) then) =
      __$$ImageFetchedFromDbImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imagePathString});
}

/// @nodoc
class __$$ImageFetchedFromDbImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res, _$ImageFetchedFromDbImpl>
    implements _$$ImageFetchedFromDbImplCopyWith<$Res> {
  __$$ImageFetchedFromDbImplCopyWithImpl(_$ImageFetchedFromDbImpl _value,
      $Res Function(_$ImageFetchedFromDbImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePathString = null,
  }) {
    return _then(_$ImageFetchedFromDbImpl(
      null == imagePathString
          ? _value.imagePathString
          : imagePathString // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ImageFetchedFromDbImpl implements ImageFetchedFromDb {
  const _$ImageFetchedFromDbImpl(this.imagePathString);

  @override
  final String imagePathString;

  @override
  String toString() {
    return 'RegisterFormEvent.imageFetchedFromDb(imagePathString: $imagePathString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageFetchedFromDbImpl &&
            (identical(other.imagePathString, imagePathString) ||
                other.imagePathString == imagePathString));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imagePathString);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageFetchedFromDbImplCopyWith<_$ImageFetchedFromDbImpl> get copyWith =>
      __$$ImageFetchedFromDbImplCopyWithImpl<_$ImageFetchedFromDbImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return imageFetchedFromDb(imagePathString);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return imageFetchedFromDb?.call(imagePathString);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (imageFetchedFromDb != null) {
      return imageFetchedFromDb(imagePathString);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return imageFetchedFromDb(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return imageFetchedFromDb?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (imageFetchedFromDb != null) {
      return imageFetchedFromDb(this);
    }
    return orElse();
  }
}

abstract class ImageFetchedFromDb implements RegisterFormEvent {
  const factory ImageFetchedFromDb(final String imagePathString) =
      _$ImageFetchedFromDbImpl;

  String get imagePathString;
  @JsonKey(ignore: true)
  _$$ImageFetchedFromDbImplCopyWith<_$ImageFetchedFromDbImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmailChangedImplCopyWith<$Res> {
  factory _$$EmailChangedImplCopyWith(
          _$EmailChangedImpl value, $Res Function(_$EmailChangedImpl) then) =
      __$$EmailChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String emailString});
}

/// @nodoc
class __$$EmailChangedImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res, _$EmailChangedImpl>
    implements _$$EmailChangedImplCopyWith<$Res> {
  __$$EmailChangedImplCopyWithImpl(
      _$EmailChangedImpl _value, $Res Function(_$EmailChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailString = null,
  }) {
    return _then(_$EmailChangedImpl(
      null == emailString
          ? _value.emailString
          : emailString // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$EmailChangedImpl implements EmailChanged {
  const _$EmailChangedImpl(this.emailString);

  @override
  final String emailString;

  @override
  String toString() {
    return 'RegisterFormEvent.emailChanged(emailString: $emailString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailChangedImpl &&
            (identical(other.emailString, emailString) ||
                other.emailString == emailString));
  }

  @override
  int get hashCode => Object.hash(runtimeType, emailString);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailChangedImplCopyWith<_$EmailChangedImpl> get copyWith =>
      __$$EmailChangedImplCopyWithImpl<_$EmailChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return emailChanged(emailString);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return emailChanged?.call(emailString);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (emailChanged != null) {
      return emailChanged(emailString);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return emailChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return emailChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (emailChanged != null) {
      return emailChanged(this);
    }
    return orElse();
  }
}

abstract class EmailChanged implements RegisterFormEvent {
  const factory EmailChanged(final String emailString) = _$EmailChangedImpl;

  String get emailString;
  @JsonKey(ignore: true)
  _$$EmailChangedImplCopyWith<_$EmailChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UsernameChangedImplCopyWith<$Res> {
  factory _$$UsernameChangedImplCopyWith(_$UsernameChangedImpl value,
          $Res Function(_$UsernameChangedImpl) then) =
      __$$UsernameChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String usernameString});
}

/// @nodoc
class __$$UsernameChangedImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res, _$UsernameChangedImpl>
    implements _$$UsernameChangedImplCopyWith<$Res> {
  __$$UsernameChangedImplCopyWithImpl(
      _$UsernameChangedImpl _value, $Res Function(_$UsernameChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usernameString = null,
  }) {
    return _then(_$UsernameChangedImpl(
      null == usernameString
          ? _value.usernameString
          : usernameString // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UsernameChangedImpl implements UsernameChanged {
  const _$UsernameChangedImpl(this.usernameString);

  @override
  final String usernameString;

  @override
  String toString() {
    return 'RegisterFormEvent.usernameChanged(usernameString: $usernameString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsernameChangedImpl &&
            (identical(other.usernameString, usernameString) ||
                other.usernameString == usernameString));
  }

  @override
  int get hashCode => Object.hash(runtimeType, usernameString);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UsernameChangedImplCopyWith<_$UsernameChangedImpl> get copyWith =>
      __$$UsernameChangedImplCopyWithImpl<_$UsernameChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return usernameChanged(usernameString);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return usernameChanged?.call(usernameString);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (usernameChanged != null) {
      return usernameChanged(usernameString);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return usernameChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return usernameChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (usernameChanged != null) {
      return usernameChanged(this);
    }
    return orElse();
  }
}

abstract class UsernameChanged implements RegisterFormEvent {
  const factory UsernameChanged(final String usernameString) =
      _$UsernameChangedImpl;

  String get usernameString;
  @JsonKey(ignore: true)
  _$$UsernameChangedImplCopyWith<_$UsernameChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DescriptionChangedImplCopyWith<$Res> {
  factory _$$DescriptionChangedImplCopyWith(_$DescriptionChangedImpl value,
          $Res Function(_$DescriptionChangedImpl) then) =
      __$$DescriptionChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String descriptionString});
}

/// @nodoc
class __$$DescriptionChangedImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res, _$DescriptionChangedImpl>
    implements _$$DescriptionChangedImplCopyWith<$Res> {
  __$$DescriptionChangedImplCopyWithImpl(_$DescriptionChangedImpl _value,
      $Res Function(_$DescriptionChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? descriptionString = null,
  }) {
    return _then(_$DescriptionChangedImpl(
      null == descriptionString
          ? _value.descriptionString
          : descriptionString // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DescriptionChangedImpl implements DescriptionChanged {
  const _$DescriptionChangedImpl(this.descriptionString);

  @override
  final String descriptionString;

  @override
  String toString() {
    return 'RegisterFormEvent.descriptionChanged(descriptionString: $descriptionString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DescriptionChangedImpl &&
            (identical(other.descriptionString, descriptionString) ||
                other.descriptionString == descriptionString));
  }

  @override
  int get hashCode => Object.hash(runtimeType, descriptionString);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DescriptionChangedImplCopyWith<_$DescriptionChangedImpl> get copyWith =>
      __$$DescriptionChangedImplCopyWithImpl<_$DescriptionChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return descriptionChanged(descriptionString);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return descriptionChanged?.call(descriptionString);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (descriptionChanged != null) {
      return descriptionChanged(descriptionString);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return descriptionChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return descriptionChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (descriptionChanged != null) {
      return descriptionChanged(this);
    }
    return orElse();
  }
}

abstract class DescriptionChanged implements RegisterFormEvent {
  const factory DescriptionChanged(final String descriptionString) =
      _$DescriptionChangedImpl;

  String get descriptionString;
  @JsonKey(ignore: true)
  _$$DescriptionChangedImplCopyWith<_$DescriptionChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PasswordChangedImplCopyWith<$Res> {
  factory _$$PasswordChangedImplCopyWith(_$PasswordChangedImpl value,
          $Res Function(_$PasswordChangedImpl) then) =
      __$$PasswordChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String passwordString});
}

/// @nodoc
class __$$PasswordChangedImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res, _$PasswordChangedImpl>
    implements _$$PasswordChangedImplCopyWith<$Res> {
  __$$PasswordChangedImplCopyWithImpl(
      _$PasswordChangedImpl _value, $Res Function(_$PasswordChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? passwordString = null,
  }) {
    return _then(_$PasswordChangedImpl(
      null == passwordString
          ? _value.passwordString
          : passwordString // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PasswordChangedImpl implements PasswordChanged {
  const _$PasswordChangedImpl(this.passwordString);

  @override
  final String passwordString;

  @override
  String toString() {
    return 'RegisterFormEvent.passwordChanged(passwordString: $passwordString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordChangedImpl &&
            (identical(other.passwordString, passwordString) ||
                other.passwordString == passwordString));
  }

  @override
  int get hashCode => Object.hash(runtimeType, passwordString);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordChangedImplCopyWith<_$PasswordChangedImpl> get copyWith =>
      __$$PasswordChangedImplCopyWithImpl<_$PasswordChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return passwordChanged(passwordString);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return passwordChanged?.call(passwordString);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (passwordChanged != null) {
      return passwordChanged(passwordString);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return passwordChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return passwordChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (passwordChanged != null) {
      return passwordChanged(this);
    }
    return orElse();
  }
}

abstract class PasswordChanged implements RegisterFormEvent {
  const factory PasswordChanged(final String passwordString) =
      _$PasswordChangedImpl;

  String get passwordString;
  @JsonKey(ignore: true)
  _$$PasswordChangedImplCopyWith<_$PasswordChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegisterPressedImplCopyWith<$Res> {
  factory _$$RegisterPressedImplCopyWith(_$RegisterPressedImpl value,
          $Res Function(_$RegisterPressedImpl) then) =
      __$$RegisterPressedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RegisterPressedImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res, _$RegisterPressedImpl>
    implements _$$RegisterPressedImplCopyWith<$Res> {
  __$$RegisterPressedImplCopyWithImpl(
      _$RegisterPressedImpl _value, $Res Function(_$RegisterPressedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RegisterPressedImpl implements RegisterPressed {
  const _$RegisterPressedImpl();

  @override
  String toString() {
    return 'RegisterFormEvent.registerPressed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RegisterPressedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return registerPressed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return registerPressed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (registerPressed != null) {
      return registerPressed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return registerPressed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return registerPressed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (registerPressed != null) {
      return registerPressed(this);
    }
    return orElse();
  }
}

abstract class RegisterPressed implements RegisterFormEvent {
  const factory RegisterPressed() = _$RegisterPressedImpl;
}

/// @nodoc
abstract class _$$ReigsterWithGooglePressedImplCopyWith<$Res> {
  factory _$$ReigsterWithGooglePressedImplCopyWith(
          _$ReigsterWithGooglePressedImpl value,
          $Res Function(_$ReigsterWithGooglePressedImpl) then) =
      __$$ReigsterWithGooglePressedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imagePath});
}

/// @nodoc
class __$$ReigsterWithGooglePressedImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res,
        _$ReigsterWithGooglePressedImpl>
    implements _$$ReigsterWithGooglePressedImplCopyWith<$Res> {
  __$$ReigsterWithGooglePressedImplCopyWithImpl(
      _$ReigsterWithGooglePressedImpl _value,
      $Res Function(_$ReigsterWithGooglePressedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
  }) {
    return _then(_$ReigsterWithGooglePressedImpl(
      null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ReigsterWithGooglePressedImpl implements ReigsterWithGooglePressed {
  const _$ReigsterWithGooglePressedImpl(this.imagePath);

  @override
  final String imagePath;

  @override
  String toString() {
    return 'RegisterFormEvent.registerWithGooglePressed(imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReigsterWithGooglePressedImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imagePath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReigsterWithGooglePressedImplCopyWith<_$ReigsterWithGooglePressedImpl>
      get copyWith => __$$ReigsterWithGooglePressedImplCopyWithImpl<
          _$ReigsterWithGooglePressedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return registerWithGooglePressed(imagePath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return registerWithGooglePressed?.call(imagePath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (registerWithGooglePressed != null) {
      return registerWithGooglePressed(imagePath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return registerWithGooglePressed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return registerWithGooglePressed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (registerWithGooglePressed != null) {
      return registerWithGooglePressed(this);
    }
    return orElse();
  }
}

abstract class ReigsterWithGooglePressed implements RegisterFormEvent {
  const factory ReigsterWithGooglePressed(final String imagePath) =
      _$ReigsterWithGooglePressedImpl;

  String get imagePath;
  @JsonKey(ignore: true)
  _$$ReigsterWithGooglePressedImplCopyWith<_$ReigsterWithGooglePressedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ClearStateImplCopyWith<$Res> {
  factory _$$ClearStateImplCopyWith(
          _$ClearStateImpl value, $Res Function(_$ClearStateImpl) then) =
      __$$ClearStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imagePath});
}

/// @nodoc
class __$$ClearStateImplCopyWithImpl<$Res>
    extends _$RegisterFormEventCopyWithImpl<$Res, _$ClearStateImpl>
    implements _$$ClearStateImplCopyWith<$Res> {
  __$$ClearStateImplCopyWithImpl(
      _$ClearStateImpl _value, $Res Function(_$ClearStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
  }) {
    return _then(_$ClearStateImpl(
      null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ClearStateImpl implements ClearState {
  const _$ClearStateImpl(this.imagePath);

  @override
  final String imagePath;

  @override
  String toString() {
    return 'RegisterFormEvent.clearState(imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClearStateImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imagePath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClearStateImplCopyWith<_$ClearStateImpl> get copyWith =>
      __$$ClearStateImplCopyWithImpl<_$ClearStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() userImagePlaceholderRequested,
    required TResult Function(String imagePathString) imageChanged,
    required TResult Function(String imagePathString) imageFetchedFromDb,
    required TResult Function(String emailString) emailChanged,
    required TResult Function(String usernameString) usernameChanged,
    required TResult Function(String descriptionString) descriptionChanged,
    required TResult Function(String passwordString) passwordChanged,
    required TResult Function() registerPressed,
    required TResult Function(String imagePath) registerWithGooglePressed,
    required TResult Function(String imagePath) clearState,
  }) {
    return clearState(imagePath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? userImagePlaceholderRequested,
    TResult? Function(String imagePathString)? imageChanged,
    TResult? Function(String imagePathString)? imageFetchedFromDb,
    TResult? Function(String emailString)? emailChanged,
    TResult? Function(String usernameString)? usernameChanged,
    TResult? Function(String descriptionString)? descriptionChanged,
    TResult? Function(String passwordString)? passwordChanged,
    TResult? Function()? registerPressed,
    TResult? Function(String imagePath)? registerWithGooglePressed,
    TResult? Function(String imagePath)? clearState,
  }) {
    return clearState?.call(imagePath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? userImagePlaceholderRequested,
    TResult Function(String imagePathString)? imageChanged,
    TResult Function(String imagePathString)? imageFetchedFromDb,
    TResult Function(String emailString)? emailChanged,
    TResult Function(String usernameString)? usernameChanged,
    TResult Function(String descriptionString)? descriptionChanged,
    TResult Function(String passwordString)? passwordChanged,
    TResult Function()? registerPressed,
    TResult Function(String imagePath)? registerWithGooglePressed,
    TResult Function(String imagePath)? clearState,
    required TResult orElse(),
  }) {
    if (clearState != null) {
      return clearState(imagePath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserImagePlaceholderRequested value)
        userImagePlaceholderRequested,
    required TResult Function(ImageChanged value) imageChanged,
    required TResult Function(ImageFetchedFromDb value) imageFetchedFromDb,
    required TResult Function(EmailChanged value) emailChanged,
    required TResult Function(UsernameChanged value) usernameChanged,
    required TResult Function(DescriptionChanged value) descriptionChanged,
    required TResult Function(PasswordChanged value) passwordChanged,
    required TResult Function(RegisterPressed value) registerPressed,
    required TResult Function(ReigsterWithGooglePressed value)
        registerWithGooglePressed,
    required TResult Function(ClearState value) clearState,
  }) {
    return clearState(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult? Function(ImageChanged value)? imageChanged,
    TResult? Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult? Function(EmailChanged value)? emailChanged,
    TResult? Function(UsernameChanged value)? usernameChanged,
    TResult? Function(DescriptionChanged value)? descriptionChanged,
    TResult? Function(PasswordChanged value)? passwordChanged,
    TResult? Function(RegisterPressed value)? registerPressed,
    TResult? Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult? Function(ClearState value)? clearState,
  }) {
    return clearState?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserImagePlaceholderRequested value)?
        userImagePlaceholderRequested,
    TResult Function(ImageChanged value)? imageChanged,
    TResult Function(ImageFetchedFromDb value)? imageFetchedFromDb,
    TResult Function(EmailChanged value)? emailChanged,
    TResult Function(UsernameChanged value)? usernameChanged,
    TResult Function(DescriptionChanged value)? descriptionChanged,
    TResult Function(PasswordChanged value)? passwordChanged,
    TResult Function(RegisterPressed value)? registerPressed,
    TResult Function(ReigsterWithGooglePressed value)?
        registerWithGooglePressed,
    TResult Function(ClearState value)? clearState,
    required TResult orElse(),
  }) {
    if (clearState != null) {
      return clearState(this);
    }
    return orElse();
  }
}

abstract class ClearState implements RegisterFormEvent {
  const factory ClearState(final String imagePath) = _$ClearStateImpl;

  String get imagePath;
  @JsonKey(ignore: true)
  _$$ClearStateImplCopyWith<_$ClearStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RegisterFormState {
  ImagePath get imagePath => throw _privateConstructorUsedError;
  EmailAddress get emailAddress => throw _privateConstructorUsedError;
  Username get username => throw _privateConstructorUsedError;
  Description get description => throw _privateConstructorUsedError;
  Password get password => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get showErrorMessages => throw _privateConstructorUsedError;
  Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>>
      get registrationFailureOrSuccessOption =>
          throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RegisterFormStateCopyWith<RegisterFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterFormStateCopyWith<$Res> {
  factory $RegisterFormStateCopyWith(
          RegisterFormState value, $Res Function(RegisterFormState) then) =
      _$RegisterFormStateCopyWithImpl<$Res, RegisterFormState>;
  @useResult
  $Res call(
      {ImagePath imagePath,
      EmailAddress emailAddress,
      Username username,
      Description description,
      Password password,
      bool isSubmitting,
      bool showErrorMessages,
      Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>>
          registrationFailureOrSuccessOption});
}

/// @nodoc
class _$RegisterFormStateCopyWithImpl<$Res, $Val extends RegisterFormState>
    implements $RegisterFormStateCopyWith<$Res> {
  _$RegisterFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
    Object? emailAddress = null,
    Object? username = null,
    Object? description = null,
    Object? password = null,
    Object? isSubmitting = null,
    Object? showErrorMessages = null,
    Object? registrationFailureOrSuccessOption = null,
  }) {
    return _then(_value.copyWith(
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as ImagePath,
      emailAddress: null == emailAddress
          ? _value.emailAddress
          : emailAddress // ignore: cast_nullable_to_non_nullable
              as EmailAddress,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as Username,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as Description,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as Password,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      showErrorMessages: null == showErrorMessages
          ? _value.showErrorMessages
          : showErrorMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      registrationFailureOrSuccessOption: null ==
              registrationFailureOrSuccessOption
          ? _value.registrationFailureOrSuccessOption
          : registrationFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
              as Option<
                  Either<RegistrationFailure, Either<EmailAddress, Unit>>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterFormStateImplCopyWith<$Res>
    implements $RegisterFormStateCopyWith<$Res> {
  factory _$$RegisterFormStateImplCopyWith(_$RegisterFormStateImpl value,
          $Res Function(_$RegisterFormStateImpl) then) =
      __$$RegisterFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ImagePath imagePath,
      EmailAddress emailAddress,
      Username username,
      Description description,
      Password password,
      bool isSubmitting,
      bool showErrorMessages,
      Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>>
          registrationFailureOrSuccessOption});
}

/// @nodoc
class __$$RegisterFormStateImplCopyWithImpl<$Res>
    extends _$RegisterFormStateCopyWithImpl<$Res, _$RegisterFormStateImpl>
    implements _$$RegisterFormStateImplCopyWith<$Res> {
  __$$RegisterFormStateImplCopyWithImpl(_$RegisterFormStateImpl _value,
      $Res Function(_$RegisterFormStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
    Object? emailAddress = null,
    Object? username = null,
    Object? description = null,
    Object? password = null,
    Object? isSubmitting = null,
    Object? showErrorMessages = null,
    Object? registrationFailureOrSuccessOption = null,
  }) {
    return _then(_$RegisterFormStateImpl(
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as ImagePath,
      emailAddress: null == emailAddress
          ? _value.emailAddress
          : emailAddress // ignore: cast_nullable_to_non_nullable
              as EmailAddress,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as Username,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as Description,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as Password,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      showErrorMessages: null == showErrorMessages
          ? _value.showErrorMessages
          : showErrorMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      registrationFailureOrSuccessOption: null ==
              registrationFailureOrSuccessOption
          ? _value.registrationFailureOrSuccessOption
          : registrationFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
              as Option<
                  Either<RegistrationFailure, Either<EmailAddress, Unit>>>,
    ));
  }
}

/// @nodoc

class _$RegisterFormStateImpl implements _RegisterFormState {
  const _$RegisterFormStateImpl(
      {required this.imagePath,
      required this.emailAddress,
      required this.username,
      required this.description,
      required this.password,
      required this.isSubmitting,
      required this.showErrorMessages,
      required this.registrationFailureOrSuccessOption});

  @override
  final ImagePath imagePath;
  @override
  final EmailAddress emailAddress;
  @override
  final Username username;
  @override
  final Description description;
  @override
  final Password password;
  @override
  final bool isSubmitting;
  @override
  final bool showErrorMessages;
  @override
  final Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>>
      registrationFailureOrSuccessOption;

  @override
  String toString() {
    return 'RegisterFormState(imagePath: $imagePath, emailAddress: $emailAddress, username: $username, description: $description, password: $password, isSubmitting: $isSubmitting, showErrorMessages: $showErrorMessages, registrationFailureOrSuccessOption: $registrationFailureOrSuccessOption)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterFormStateImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.emailAddress, emailAddress) ||
                other.emailAddress == emailAddress) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.showErrorMessages, showErrorMessages) ||
                other.showErrorMessages == showErrorMessages) &&
            (identical(other.registrationFailureOrSuccessOption,
                    registrationFailureOrSuccessOption) ||
                other.registrationFailureOrSuccessOption ==
                    registrationFailureOrSuccessOption));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      imagePath,
      emailAddress,
      username,
      description,
      password,
      isSubmitting,
      showErrorMessages,
      registrationFailureOrSuccessOption);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterFormStateImplCopyWith<_$RegisterFormStateImpl> get copyWith =>
      __$$RegisterFormStateImplCopyWithImpl<_$RegisterFormStateImpl>(
          this, _$identity);
}

abstract class _RegisterFormState implements RegisterFormState {
  const factory _RegisterFormState(
      {required final ImagePath imagePath,
      required final EmailAddress emailAddress,
      required final Username username,
      required final Description description,
      required final Password password,
      required final bool isSubmitting,
      required final bool showErrorMessages,
      required final Option<
              Either<RegistrationFailure, Either<EmailAddress, Unit>>>
          registrationFailureOrSuccessOption}) = _$RegisterFormStateImpl;

  @override
  ImagePath get imagePath;
  @override
  EmailAddress get emailAddress;
  @override
  Username get username;
  @override
  Description get description;
  @override
  Password get password;
  @override
  bool get isSubmitting;
  @override
  bool get showErrorMessages;
  @override
  Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>>
      get registrationFailureOrSuccessOption;
  @override
  @JsonKey(ignore: true)
  _$$RegisterFormStateImplCopyWith<_$RegisterFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
