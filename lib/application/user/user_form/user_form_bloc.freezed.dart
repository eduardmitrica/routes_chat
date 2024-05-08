// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_form_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserFormEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Option<User> userOption) initialized,
    required TResult Function(String imagePath) profilePictureChanged,
    required TResult Function(String username) usernameChanged,
    required TResult Function(String description) descriptionChanged,
    required TResult Function() saved,
    required TResult Function() rolledBackChanges,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Option<User> userOption)? initialized,
    TResult? Function(String imagePath)? profilePictureChanged,
    TResult? Function(String username)? usernameChanged,
    TResult? Function(String description)? descriptionChanged,
    TResult? Function()? saved,
    TResult? Function()? rolledBackChanges,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Option<User> userOption)? initialized,
    TResult Function(String imagePath)? profilePictureChanged,
    TResult Function(String username)? usernameChanged,
    TResult Function(String description)? descriptionChanged,
    TResult Function()? saved,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initialized value) initialized,
    required TResult Function(_ProfilePictureChanged value)
        profilePictureChanged,
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_DescriptionChanged value) descriptionChanged,
    required TResult Function(_Saved value) saved,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initialized value)? initialized,
    TResult? Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_DescriptionChanged value)? descriptionChanged,
    TResult? Function(_Saved value)? saved,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initialized value)? initialized,
    TResult Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_DescriptionChanged value)? descriptionChanged,
    TResult Function(_Saved value)? saved,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserFormEventCopyWith<$Res> {
  factory $UserFormEventCopyWith(
          UserFormEvent value, $Res Function(UserFormEvent) then) =
      _$UserFormEventCopyWithImpl<$Res, UserFormEvent>;
}

/// @nodoc
class _$UserFormEventCopyWithImpl<$Res, $Val extends UserFormEvent>
    implements $UserFormEventCopyWith<$Res> {
  _$UserFormEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitializedImplCopyWith<$Res> {
  factory _$$InitializedImplCopyWith(
          _$InitializedImpl value, $Res Function(_$InitializedImpl) then) =
      __$$InitializedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Option<User> userOption});
}

/// @nodoc
class __$$InitializedImplCopyWithImpl<$Res>
    extends _$UserFormEventCopyWithImpl<$Res, _$InitializedImpl>
    implements _$$InitializedImplCopyWith<$Res> {
  __$$InitializedImplCopyWithImpl(
      _$InitializedImpl _value, $Res Function(_$InitializedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userOption = null,
  }) {
    return _then(_$InitializedImpl(
      null == userOption
          ? _value.userOption
          : userOption // ignore: cast_nullable_to_non_nullable
              as Option<User>,
    ));
  }
}

/// @nodoc

class _$InitializedImpl implements _Initialized {
  const _$InitializedImpl(this.userOption);

  @override
  final Option<User> userOption;

  @override
  String toString() {
    return 'UserFormEvent.initialized(userOption: $userOption)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InitializedImpl &&
            (identical(other.userOption, userOption) ||
                other.userOption == userOption));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userOption);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InitializedImplCopyWith<_$InitializedImpl> get copyWith =>
      __$$InitializedImplCopyWithImpl<_$InitializedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Option<User> userOption) initialized,
    required TResult Function(String imagePath) profilePictureChanged,
    required TResult Function(String username) usernameChanged,
    required TResult Function(String description) descriptionChanged,
    required TResult Function() saved,
    required TResult Function() rolledBackChanges,
  }) {
    return initialized(userOption);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Option<User> userOption)? initialized,
    TResult? Function(String imagePath)? profilePictureChanged,
    TResult? Function(String username)? usernameChanged,
    TResult? Function(String description)? descriptionChanged,
    TResult? Function()? saved,
    TResult? Function()? rolledBackChanges,
  }) {
    return initialized?.call(userOption);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Option<User> userOption)? initialized,
    TResult Function(String imagePath)? profilePictureChanged,
    TResult Function(String username)? usernameChanged,
    TResult Function(String description)? descriptionChanged,
    TResult Function()? saved,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (initialized != null) {
      return initialized(userOption);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initialized value) initialized,
    required TResult Function(_ProfilePictureChanged value)
        profilePictureChanged,
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_DescriptionChanged value) descriptionChanged,
    required TResult Function(_Saved value) saved,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return initialized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initialized value)? initialized,
    TResult? Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_DescriptionChanged value)? descriptionChanged,
    TResult? Function(_Saved value)? saved,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return initialized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initialized value)? initialized,
    TResult Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_DescriptionChanged value)? descriptionChanged,
    TResult Function(_Saved value)? saved,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (initialized != null) {
      return initialized(this);
    }
    return orElse();
  }
}

abstract class _Initialized implements UserFormEvent {
  const factory _Initialized(final Option<User> userOption) = _$InitializedImpl;

  Option<User> get userOption;
  @JsonKey(ignore: true)
  _$$InitializedImplCopyWith<_$InitializedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProfilePictureChangedImplCopyWith<$Res> {
  factory _$$ProfilePictureChangedImplCopyWith(
          _$ProfilePictureChangedImpl value,
          $Res Function(_$ProfilePictureChangedImpl) then) =
      __$$ProfilePictureChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imagePath});
}

/// @nodoc
class __$$ProfilePictureChangedImplCopyWithImpl<$Res>
    extends _$UserFormEventCopyWithImpl<$Res, _$ProfilePictureChangedImpl>
    implements _$$ProfilePictureChangedImplCopyWith<$Res> {
  __$$ProfilePictureChangedImplCopyWithImpl(_$ProfilePictureChangedImpl _value,
      $Res Function(_$ProfilePictureChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
  }) {
    return _then(_$ProfilePictureChangedImpl(
      null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ProfilePictureChangedImpl implements _ProfilePictureChanged {
  const _$ProfilePictureChangedImpl(this.imagePath);

  @override
  final String imagePath;

  @override
  String toString() {
    return 'UserFormEvent.profilePictureChanged(imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfilePictureChangedImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imagePath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfilePictureChangedImplCopyWith<_$ProfilePictureChangedImpl>
      get copyWith => __$$ProfilePictureChangedImplCopyWithImpl<
          _$ProfilePictureChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Option<User> userOption) initialized,
    required TResult Function(String imagePath) profilePictureChanged,
    required TResult Function(String username) usernameChanged,
    required TResult Function(String description) descriptionChanged,
    required TResult Function() saved,
    required TResult Function() rolledBackChanges,
  }) {
    return profilePictureChanged(imagePath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Option<User> userOption)? initialized,
    TResult? Function(String imagePath)? profilePictureChanged,
    TResult? Function(String username)? usernameChanged,
    TResult? Function(String description)? descriptionChanged,
    TResult? Function()? saved,
    TResult? Function()? rolledBackChanges,
  }) {
    return profilePictureChanged?.call(imagePath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Option<User> userOption)? initialized,
    TResult Function(String imagePath)? profilePictureChanged,
    TResult Function(String username)? usernameChanged,
    TResult Function(String description)? descriptionChanged,
    TResult Function()? saved,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (profilePictureChanged != null) {
      return profilePictureChanged(imagePath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initialized value) initialized,
    required TResult Function(_ProfilePictureChanged value)
        profilePictureChanged,
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_DescriptionChanged value) descriptionChanged,
    required TResult Function(_Saved value) saved,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return profilePictureChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initialized value)? initialized,
    TResult? Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_DescriptionChanged value)? descriptionChanged,
    TResult? Function(_Saved value)? saved,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return profilePictureChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initialized value)? initialized,
    TResult Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_DescriptionChanged value)? descriptionChanged,
    TResult Function(_Saved value)? saved,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (profilePictureChanged != null) {
      return profilePictureChanged(this);
    }
    return orElse();
  }
}

abstract class _ProfilePictureChanged implements UserFormEvent {
  const factory _ProfilePictureChanged(final String imagePath) =
      _$ProfilePictureChangedImpl;

  String get imagePath;
  @JsonKey(ignore: true)
  _$$ProfilePictureChangedImplCopyWith<_$ProfilePictureChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UsernameChangedImplCopyWith<$Res> {
  factory _$$UsernameChangedImplCopyWith(_$UsernameChangedImpl value,
          $Res Function(_$UsernameChangedImpl) then) =
      __$$UsernameChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String username});
}

/// @nodoc
class __$$UsernameChangedImplCopyWithImpl<$Res>
    extends _$UserFormEventCopyWithImpl<$Res, _$UsernameChangedImpl>
    implements _$$UsernameChangedImplCopyWith<$Res> {
  __$$UsernameChangedImplCopyWithImpl(
      _$UsernameChangedImpl _value, $Res Function(_$UsernameChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
  }) {
    return _then(_$UsernameChangedImpl(
      null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UsernameChangedImpl implements _UsernameChanged {
  const _$UsernameChangedImpl(this.username);

  @override
  final String username;

  @override
  String toString() {
    return 'UserFormEvent.usernameChanged(username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsernameChangedImpl &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @override
  int get hashCode => Object.hash(runtimeType, username);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UsernameChangedImplCopyWith<_$UsernameChangedImpl> get copyWith =>
      __$$UsernameChangedImplCopyWithImpl<_$UsernameChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Option<User> userOption) initialized,
    required TResult Function(String imagePath) profilePictureChanged,
    required TResult Function(String username) usernameChanged,
    required TResult Function(String description) descriptionChanged,
    required TResult Function() saved,
    required TResult Function() rolledBackChanges,
  }) {
    return usernameChanged(username);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Option<User> userOption)? initialized,
    TResult? Function(String imagePath)? profilePictureChanged,
    TResult? Function(String username)? usernameChanged,
    TResult? Function(String description)? descriptionChanged,
    TResult? Function()? saved,
    TResult? Function()? rolledBackChanges,
  }) {
    return usernameChanged?.call(username);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Option<User> userOption)? initialized,
    TResult Function(String imagePath)? profilePictureChanged,
    TResult Function(String username)? usernameChanged,
    TResult Function(String description)? descriptionChanged,
    TResult Function()? saved,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (usernameChanged != null) {
      return usernameChanged(username);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initialized value) initialized,
    required TResult Function(_ProfilePictureChanged value)
        profilePictureChanged,
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_DescriptionChanged value) descriptionChanged,
    required TResult Function(_Saved value) saved,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return usernameChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initialized value)? initialized,
    TResult? Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_DescriptionChanged value)? descriptionChanged,
    TResult? Function(_Saved value)? saved,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return usernameChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initialized value)? initialized,
    TResult Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_DescriptionChanged value)? descriptionChanged,
    TResult Function(_Saved value)? saved,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (usernameChanged != null) {
      return usernameChanged(this);
    }
    return orElse();
  }
}

abstract class _UsernameChanged implements UserFormEvent {
  const factory _UsernameChanged(final String username) = _$UsernameChangedImpl;

  String get username;
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
  $Res call({String description});
}

/// @nodoc
class __$$DescriptionChangedImplCopyWithImpl<$Res>
    extends _$UserFormEventCopyWithImpl<$Res, _$DescriptionChangedImpl>
    implements _$$DescriptionChangedImplCopyWith<$Res> {
  __$$DescriptionChangedImplCopyWithImpl(_$DescriptionChangedImpl _value,
      $Res Function(_$DescriptionChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
  }) {
    return _then(_$DescriptionChangedImpl(
      null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DescriptionChangedImpl implements _DescriptionChanged {
  const _$DescriptionChangedImpl(this.description);

  @override
  final String description;

  @override
  String toString() {
    return 'UserFormEvent.descriptionChanged(description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DescriptionChangedImpl &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(runtimeType, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DescriptionChangedImplCopyWith<_$DescriptionChangedImpl> get copyWith =>
      __$$DescriptionChangedImplCopyWithImpl<_$DescriptionChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Option<User> userOption) initialized,
    required TResult Function(String imagePath) profilePictureChanged,
    required TResult Function(String username) usernameChanged,
    required TResult Function(String description) descriptionChanged,
    required TResult Function() saved,
    required TResult Function() rolledBackChanges,
  }) {
    return descriptionChanged(description);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Option<User> userOption)? initialized,
    TResult? Function(String imagePath)? profilePictureChanged,
    TResult? Function(String username)? usernameChanged,
    TResult? Function(String description)? descriptionChanged,
    TResult? Function()? saved,
    TResult? Function()? rolledBackChanges,
  }) {
    return descriptionChanged?.call(description);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Option<User> userOption)? initialized,
    TResult Function(String imagePath)? profilePictureChanged,
    TResult Function(String username)? usernameChanged,
    TResult Function(String description)? descriptionChanged,
    TResult Function()? saved,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (descriptionChanged != null) {
      return descriptionChanged(description);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initialized value) initialized,
    required TResult Function(_ProfilePictureChanged value)
        profilePictureChanged,
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_DescriptionChanged value) descriptionChanged,
    required TResult Function(_Saved value) saved,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return descriptionChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initialized value)? initialized,
    TResult? Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_DescriptionChanged value)? descriptionChanged,
    TResult? Function(_Saved value)? saved,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return descriptionChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initialized value)? initialized,
    TResult Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_DescriptionChanged value)? descriptionChanged,
    TResult Function(_Saved value)? saved,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (descriptionChanged != null) {
      return descriptionChanged(this);
    }
    return orElse();
  }
}

abstract class _DescriptionChanged implements UserFormEvent {
  const factory _DescriptionChanged(final String description) =
      _$DescriptionChangedImpl;

  String get description;
  @JsonKey(ignore: true)
  _$$DescriptionChangedImplCopyWith<_$DescriptionChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SavedImplCopyWith<$Res> {
  factory _$$SavedImplCopyWith(
          _$SavedImpl value, $Res Function(_$SavedImpl) then) =
      __$$SavedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SavedImplCopyWithImpl<$Res>
    extends _$UserFormEventCopyWithImpl<$Res, _$SavedImpl>
    implements _$$SavedImplCopyWith<$Res> {
  __$$SavedImplCopyWithImpl(
      _$SavedImpl _value, $Res Function(_$SavedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SavedImpl implements _Saved {
  const _$SavedImpl();

  @override
  String toString() {
    return 'UserFormEvent.saved()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SavedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Option<User> userOption) initialized,
    required TResult Function(String imagePath) profilePictureChanged,
    required TResult Function(String username) usernameChanged,
    required TResult Function(String description) descriptionChanged,
    required TResult Function() saved,
    required TResult Function() rolledBackChanges,
  }) {
    return saved();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Option<User> userOption)? initialized,
    TResult? Function(String imagePath)? profilePictureChanged,
    TResult? Function(String username)? usernameChanged,
    TResult? Function(String description)? descriptionChanged,
    TResult? Function()? saved,
    TResult? Function()? rolledBackChanges,
  }) {
    return saved?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Option<User> userOption)? initialized,
    TResult Function(String imagePath)? profilePictureChanged,
    TResult Function(String username)? usernameChanged,
    TResult Function(String description)? descriptionChanged,
    TResult Function()? saved,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (saved != null) {
      return saved();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initialized value) initialized,
    required TResult Function(_ProfilePictureChanged value)
        profilePictureChanged,
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_DescriptionChanged value) descriptionChanged,
    required TResult Function(_Saved value) saved,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return saved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initialized value)? initialized,
    TResult? Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_DescriptionChanged value)? descriptionChanged,
    TResult? Function(_Saved value)? saved,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return saved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initialized value)? initialized,
    TResult Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_DescriptionChanged value)? descriptionChanged,
    TResult Function(_Saved value)? saved,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (saved != null) {
      return saved(this);
    }
    return orElse();
  }
}

abstract class _Saved implements UserFormEvent {
  const factory _Saved() = _$SavedImpl;
}

/// @nodoc
abstract class _$$RolledBackChangesImplCopyWith<$Res> {
  factory _$$RolledBackChangesImplCopyWith(_$RolledBackChangesImpl value,
          $Res Function(_$RolledBackChangesImpl) then) =
      __$$RolledBackChangesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RolledBackChangesImplCopyWithImpl<$Res>
    extends _$UserFormEventCopyWithImpl<$Res, _$RolledBackChangesImpl>
    implements _$$RolledBackChangesImplCopyWith<$Res> {
  __$$RolledBackChangesImplCopyWithImpl(_$RolledBackChangesImpl _value,
      $Res Function(_$RolledBackChangesImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RolledBackChangesImpl implements _RolledBackChanges {
  const _$RolledBackChangesImpl();

  @override
  String toString() {
    return 'UserFormEvent.rolledBackChanges()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RolledBackChangesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Option<User> userOption) initialized,
    required TResult Function(String imagePath) profilePictureChanged,
    required TResult Function(String username) usernameChanged,
    required TResult Function(String description) descriptionChanged,
    required TResult Function() saved,
    required TResult Function() rolledBackChanges,
  }) {
    return rolledBackChanges();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Option<User> userOption)? initialized,
    TResult? Function(String imagePath)? profilePictureChanged,
    TResult? Function(String username)? usernameChanged,
    TResult? Function(String description)? descriptionChanged,
    TResult? Function()? saved,
    TResult? Function()? rolledBackChanges,
  }) {
    return rolledBackChanges?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Option<User> userOption)? initialized,
    TResult Function(String imagePath)? profilePictureChanged,
    TResult Function(String username)? usernameChanged,
    TResult Function(String description)? descriptionChanged,
    TResult Function()? saved,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (rolledBackChanges != null) {
      return rolledBackChanges();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initialized value) initialized,
    required TResult Function(_ProfilePictureChanged value)
        profilePictureChanged,
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_DescriptionChanged value) descriptionChanged,
    required TResult Function(_Saved value) saved,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return rolledBackChanges(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initialized value)? initialized,
    TResult? Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_DescriptionChanged value)? descriptionChanged,
    TResult? Function(_Saved value)? saved,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return rolledBackChanges?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initialized value)? initialized,
    TResult Function(_ProfilePictureChanged value)? profilePictureChanged,
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_DescriptionChanged value)? descriptionChanged,
    TResult Function(_Saved value)? saved,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (rolledBackChanges != null) {
      return rolledBackChanges(this);
    }
    return orElse();
  }
}

abstract class _RolledBackChanges implements UserFormEvent {
  const factory _RolledBackChanges() = _$RolledBackChangesImpl;
}

/// @nodoc
mixin _$UserFormState {
  User get user => throw _privateConstructorUsedError;
  ImagePath get imagePath => throw _privateConstructorUsedError;
  bool get showErrorMessages => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  Option<Either<UserFailure, Unit>> get saveFailureOrSuccessOption =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserFormStateCopyWith<UserFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserFormStateCopyWith<$Res> {
  factory $UserFormStateCopyWith(
          UserFormState value, $Res Function(UserFormState) then) =
      _$UserFormStateCopyWithImpl<$Res, UserFormState>;
  @useResult
  $Res call(
      {User user,
      ImagePath imagePath,
      bool showErrorMessages,
      bool isSaving,
      Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$UserFormStateCopyWithImpl<$Res, $Val extends UserFormState>
    implements $UserFormStateCopyWith<$Res> {
  _$UserFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? imagePath = null,
    Object? showErrorMessages = null,
    Object? isSaving = null,
    Object? saveFailureOrSuccessOption = null,
  }) {
    return _then(_value.copyWith(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as ImagePath,
      showErrorMessages: null == showErrorMessages
          ? _value.showErrorMessages
          : showErrorMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      saveFailureOrSuccessOption: null == saveFailureOrSuccessOption
          ? _value.saveFailureOrSuccessOption
          : saveFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
              as Option<Either<UserFailure, Unit>>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserFormStateImplCopyWith<$Res>
    implements $UserFormStateCopyWith<$Res> {
  factory _$$UserFormStateImplCopyWith(
          _$UserFormStateImpl value, $Res Function(_$UserFormStateImpl) then) =
      __$$UserFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {User user,
      ImagePath imagePath,
      bool showErrorMessages,
      bool isSaving,
      Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$UserFormStateImplCopyWithImpl<$Res>
    extends _$UserFormStateCopyWithImpl<$Res, _$UserFormStateImpl>
    implements _$$UserFormStateImplCopyWith<$Res> {
  __$$UserFormStateImplCopyWithImpl(
      _$UserFormStateImpl _value, $Res Function(_$UserFormStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? imagePath = null,
    Object? showErrorMessages = null,
    Object? isSaving = null,
    Object? saveFailureOrSuccessOption = null,
  }) {
    return _then(_$UserFormStateImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as ImagePath,
      showErrorMessages: null == showErrorMessages
          ? _value.showErrorMessages
          : showErrorMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      saveFailureOrSuccessOption: null == saveFailureOrSuccessOption
          ? _value.saveFailureOrSuccessOption
          : saveFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
              as Option<Either<UserFailure, Unit>>,
    ));
  }
}

/// @nodoc

class _$UserFormStateImpl implements _UserFormState {
  const _$UserFormStateImpl(
      {required this.user,
      required this.imagePath,
      required this.showErrorMessages,
      required this.isSaving,
      required this.saveFailureOrSuccessOption});

  @override
  final User user;
  @override
  final ImagePath imagePath;
  @override
  final bool showErrorMessages;
  @override
  final bool isSaving;
  @override
  final Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption;

  @override
  String toString() {
    return 'UserFormState(user: $user, imagePath: $imagePath, showErrorMessages: $showErrorMessages, isSaving: $isSaving, saveFailureOrSuccessOption: $saveFailureOrSuccessOption)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserFormStateImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.showErrorMessages, showErrorMessages) ||
                other.showErrorMessages == showErrorMessages) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.saveFailureOrSuccessOption,
                    saveFailureOrSuccessOption) ||
                other.saveFailureOrSuccessOption ==
                    saveFailureOrSuccessOption));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user, imagePath,
      showErrorMessages, isSaving, saveFailureOrSuccessOption);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserFormStateImplCopyWith<_$UserFormStateImpl> get copyWith =>
      __$$UserFormStateImplCopyWithImpl<_$UserFormStateImpl>(this, _$identity);
}

abstract class _UserFormState implements UserFormState {
  const factory _UserFormState(
      {required final User user,
      required final ImagePath imagePath,
      required final bool showErrorMessages,
      required final bool isSaving,
      required final Option<Either<UserFailure, Unit>>
          saveFailureOrSuccessOption}) = _$UserFormStateImpl;

  @override
  User get user;
  @override
  ImagePath get imagePath;
  @override
  bool get showErrorMessages;
  @override
  bool get isSaving;
  @override
  Option<Either<UserFailure, Unit>> get saveFailureOrSuccessOption;
  @override
  @JsonKey(ignore: true)
  _$$UserFormStateImplCopyWith<_$UserFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
