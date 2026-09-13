// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_form_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserFormState {

 User get user; ImagePath get imagePath; bool get showErrorMessages; bool get isSaving; Option<Either<UserFailure, Unit>> get saveFailureOrSuccessOption;
/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFormStateCopyWith<UserFormState> get copyWith => _$UserFormStateCopyWithImpl<UserFormState>(this as UserFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFormState&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.imagePath, _this.imagePath) || other.imagePath == _this.imagePath)&&(identical(other.showErrorMessages, _this.showErrorMessages) || other.showErrorMessages == _this.showErrorMessages)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.saveFailureOrSuccessOption, _this.saveFailureOrSuccessOption) || other.saveFailureOrSuccessOption == _this.saveFailureOrSuccessOption));
}


@override
int get hashCode {
  final _this = this as UserFormState;
  return Object.hash(runtimeType,_this.user,_this.imagePath,_this.showErrorMessages,_this.isSaving,_this.saveFailureOrSuccessOption);
}

@override
String toString() {
  final _this = this as UserFormState;
  return 'UserFormState(user: ${_this.user}, imagePath: ${_this.imagePath}, showErrorMessages: ${_this.showErrorMessages}, isSaving: ${_this.isSaving}, saveFailureOrSuccessOption: ${_this.saveFailureOrSuccessOption})';
}


}

/// @nodoc
abstract mixin class $UserFormStateCopyWith<$Res>  {
  factory $UserFormStateCopyWith(UserFormState value, $Res Function(UserFormState) _then) = _$UserFormStateCopyWithImpl;
@useResult
$Res call({
 User user, ImagePath imagePath, bool showErrorMessages, bool isSaving, Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$UserFormStateCopyWithImpl<$Res>
    implements $UserFormStateCopyWith<$Res> {
  _$UserFormStateCopyWithImpl(this._self, this._then);

  final UserFormState _self;
  final $Res Function(UserFormState) _then;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? imagePath = null,Object? showErrorMessages = null,Object? isSaving = null,Object? saveFailureOrSuccessOption = null,}) {
  return _then(UserFormState(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as ImagePath,showErrorMessages: null == showErrorMessages ? _self.showErrorMessages : showErrorMessages // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saveFailureOrSuccessOption: null == saveFailureOrSuccessOption ? _self.saveFailureOrSuccessOption : saveFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<UserFailure, Unit>>,
  ));
}
/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserFormState].
extension UserFormStatePatterns on UserFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFormState value)  $default,){
final _that = this;
switch (_that) {
case _UserFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFormState value)?  $default,){
final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user,  ImagePath imagePath,  bool showErrorMessages,  bool isSaving,  Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
return $default(_that.user,_that.imagePath,_that.showErrorMessages,_that.isSaving,_that.saveFailureOrSuccessOption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user,  ImagePath imagePath,  bool showErrorMessages,  bool isSaving,  Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption)  $default,) {final _that = this;
switch (_that) {
case _UserFormState():
return $default(_that.user,_that.imagePath,_that.showErrorMessages,_that.isSaving,_that.saveFailureOrSuccessOption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user,  ImagePath imagePath,  bool showErrorMessages,  bool isSaving,  Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption)?  $default,) {final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
return $default(_that.user,_that.imagePath,_that.showErrorMessages,_that.isSaving,_that.saveFailureOrSuccessOption);case _:
  return null;

}
}

}

/// @nodoc


class _UserFormState implements UserFormState {
  const _UserFormState({required this.user, required this.imagePath, required this.showErrorMessages, required this.isSaving, required this.saveFailureOrSuccessOption});
  

@override final  User user;
@override final  ImagePath imagePath;
@override final  bool showErrorMessages;
@override final  bool isSaving;
@override final  Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFormStateCopyWith<_UserFormState> get copyWith => __$UserFormStateCopyWithImpl<_UserFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFormState&&(identical(other.user, user) || other.user == user)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.showErrorMessages, showErrorMessages) || other.showErrorMessages == showErrorMessages)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.saveFailureOrSuccessOption, saveFailureOrSuccessOption) || other.saveFailureOrSuccessOption == saveFailureOrSuccessOption));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user,imagePath,showErrorMessages,isSaving,saveFailureOrSuccessOption);
}

@override
String toString() {
    return 'UserFormState(user: $user, imagePath: $imagePath, showErrorMessages: $showErrorMessages, isSaving: $isSaving, saveFailureOrSuccessOption: $saveFailureOrSuccessOption)';
}


}

/// @nodoc
abstract mixin class _$UserFormStateCopyWith<$Res> implements $UserFormStateCopyWith<$Res> {
  factory _$UserFormStateCopyWith(_UserFormState value, $Res Function(_UserFormState) _then) = __$UserFormStateCopyWithImpl;
@override @useResult
$Res call({
 User user, ImagePath imagePath, bool showErrorMessages, bool isSaving, Option<Either<UserFailure, Unit>> saveFailureOrSuccessOption
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$UserFormStateCopyWithImpl<$Res>
    implements _$UserFormStateCopyWith<$Res> {
  __$UserFormStateCopyWithImpl(this._self, this._then);

  final _UserFormState _self;
  final $Res Function(_UserFormState) _then;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? imagePath = null,Object? showErrorMessages = null,Object? isSaving = null,Object? saveFailureOrSuccessOption = null,}) {
  return _then(_UserFormState(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as ImagePath,showErrorMessages: null == showErrorMessages ? _self.showErrorMessages : showErrorMessages // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saveFailureOrSuccessOption: null == saveFailureOrSuccessOption ? _self.saveFailureOrSuccessOption : saveFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<UserFailure, Unit>>,
  ));
}

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
