// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_form_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterFormState {

 ImagePath get imagePath; EmailAddress get emailAddress; Username get username; Description get description; Password get password; bool get isSubmitting; bool get showErrorMessages; Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>> get registrationFailureOrSuccessOption;
/// Create a copy of RegisterFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterFormStateCopyWith<RegisterFormState> get copyWith => _$RegisterFormStateCopyWithImpl<RegisterFormState>(this as RegisterFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RegisterFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterFormState&&(identical(other.imagePath, _this.imagePath) || other.imagePath == _this.imagePath)&&(identical(other.emailAddress, _this.emailAddress) || other.emailAddress == _this.emailAddress)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.isSubmitting, _this.isSubmitting) || other.isSubmitting == _this.isSubmitting)&&(identical(other.showErrorMessages, _this.showErrorMessages) || other.showErrorMessages == _this.showErrorMessages)&&(identical(other.registrationFailureOrSuccessOption, _this.registrationFailureOrSuccessOption) || other.registrationFailureOrSuccessOption == _this.registrationFailureOrSuccessOption));
}


@override
int get hashCode {
  final _this = this as RegisterFormState;
  return Object.hash(runtimeType,_this.imagePath,_this.emailAddress,_this.username,_this.description,_this.password,_this.isSubmitting,_this.showErrorMessages,_this.registrationFailureOrSuccessOption);
}

@override
String toString() {
  final _this = this as RegisterFormState;
  return 'RegisterFormState(imagePath: ${_this.imagePath}, emailAddress: ${_this.emailAddress}, username: ${_this.username}, description: ${_this.description}, password: ${_this.password}, isSubmitting: ${_this.isSubmitting}, showErrorMessages: ${_this.showErrorMessages}, registrationFailureOrSuccessOption: ${_this.registrationFailureOrSuccessOption})';
}


}

/// @nodoc
abstract mixin class $RegisterFormStateCopyWith<$Res>  {
  factory $RegisterFormStateCopyWith(RegisterFormState value, $Res Function(RegisterFormState) _then) = _$RegisterFormStateCopyWithImpl;
@useResult
$Res call({
 ImagePath imagePath, EmailAddress emailAddress, Username username, Description description, Password password, bool isSubmitting, bool showErrorMessages, Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>> registrationFailureOrSuccessOption
});




}
/// @nodoc
class _$RegisterFormStateCopyWithImpl<$Res>
    implements $RegisterFormStateCopyWith<$Res> {
  _$RegisterFormStateCopyWithImpl(this._self, this._then);

  final RegisterFormState _self;
  final $Res Function(RegisterFormState) _then;

/// Create a copy of RegisterFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imagePath = null,Object? emailAddress = null,Object? username = null,Object? description = null,Object? password = null,Object? isSubmitting = null,Object? showErrorMessages = null,Object? registrationFailureOrSuccessOption = null,}) {
  return _then(RegisterFormState(
imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as ImagePath,emailAddress: null == emailAddress ? _self.emailAddress : emailAddress // ignore: cast_nullable_to_non_nullable
as EmailAddress,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as Username,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as Description,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as Password,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,showErrorMessages: null == showErrorMessages ? _self.showErrorMessages : showErrorMessages // ignore: cast_nullable_to_non_nullable
as bool,registrationFailureOrSuccessOption: null == registrationFailureOrSuccessOption ? _self.registrationFailureOrSuccessOption : registrationFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>>,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterFormState].
extension RegisterFormStatePatterns on RegisterFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterFormState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterFormState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ImagePath imagePath,  EmailAddress emailAddress,  Username username,  Description description,  Password password,  bool isSubmitting,  bool showErrorMessages,  Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>> registrationFailureOrSuccessOption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterFormState() when $default != null:
return $default(_that.imagePath,_that.emailAddress,_that.username,_that.description,_that.password,_that.isSubmitting,_that.showErrorMessages,_that.registrationFailureOrSuccessOption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ImagePath imagePath,  EmailAddress emailAddress,  Username username,  Description description,  Password password,  bool isSubmitting,  bool showErrorMessages,  Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>> registrationFailureOrSuccessOption)  $default,) {final _that = this;
switch (_that) {
case _RegisterFormState():
return $default(_that.imagePath,_that.emailAddress,_that.username,_that.description,_that.password,_that.isSubmitting,_that.showErrorMessages,_that.registrationFailureOrSuccessOption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ImagePath imagePath,  EmailAddress emailAddress,  Username username,  Description description,  Password password,  bool isSubmitting,  bool showErrorMessages,  Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>> registrationFailureOrSuccessOption)?  $default,) {final _that = this;
switch (_that) {
case _RegisterFormState() when $default != null:
return $default(_that.imagePath,_that.emailAddress,_that.username,_that.description,_that.password,_that.isSubmitting,_that.showErrorMessages,_that.registrationFailureOrSuccessOption);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterFormState implements RegisterFormState {
  const _RegisterFormState({required this.imagePath, required this.emailAddress, required this.username, required this.description, required this.password, required this.isSubmitting, required this.showErrorMessages, required this.registrationFailureOrSuccessOption});
  

@override final  ImagePath imagePath;
@override final  EmailAddress emailAddress;
@override final  Username username;
@override final  Description description;
@override final  Password password;
@override final  bool isSubmitting;
@override final  bool showErrorMessages;
@override final  Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>> registrationFailureOrSuccessOption;

/// Create a copy of RegisterFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterFormStateCopyWith<_RegisterFormState> get copyWith => __$RegisterFormStateCopyWithImpl<_RegisterFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterFormState&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.emailAddress, emailAddress) || other.emailAddress == emailAddress)&&(identical(other.username, username) || other.username == username)&&(identical(other.description, description) || other.description == description)&&(identical(other.password, password) || other.password == password)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.showErrorMessages, showErrorMessages) || other.showErrorMessages == showErrorMessages)&&(identical(other.registrationFailureOrSuccessOption, registrationFailureOrSuccessOption) || other.registrationFailureOrSuccessOption == registrationFailureOrSuccessOption));
}


@override
int get hashCode {
    return Object.hash(runtimeType,imagePath,emailAddress,username,description,password,isSubmitting,showErrorMessages,registrationFailureOrSuccessOption);
}

@override
String toString() {
    return 'RegisterFormState(imagePath: $imagePath, emailAddress: $emailAddress, username: $username, description: $description, password: $password, isSubmitting: $isSubmitting, showErrorMessages: $showErrorMessages, registrationFailureOrSuccessOption: $registrationFailureOrSuccessOption)';
}


}

/// @nodoc
abstract mixin class _$RegisterFormStateCopyWith<$Res> implements $RegisterFormStateCopyWith<$Res> {
  factory _$RegisterFormStateCopyWith(_RegisterFormState value, $Res Function(_RegisterFormState) _then) = __$RegisterFormStateCopyWithImpl;
@override @useResult
$Res call({
 ImagePath imagePath, EmailAddress emailAddress, Username username, Description description, Password password, bool isSubmitting, bool showErrorMessages, Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>> registrationFailureOrSuccessOption
});




}
/// @nodoc
class __$RegisterFormStateCopyWithImpl<$Res>
    implements _$RegisterFormStateCopyWith<$Res> {
  __$RegisterFormStateCopyWithImpl(this._self, this._then);

  final _RegisterFormState _self;
  final $Res Function(_RegisterFormState) _then;

/// Create a copy of RegisterFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imagePath = null,Object? emailAddress = null,Object? username = null,Object? description = null,Object? password = null,Object? isSubmitting = null,Object? showErrorMessages = null,Object? registrationFailureOrSuccessOption = null,}) {
  return _then(_RegisterFormState(
imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as ImagePath,emailAddress: null == emailAddress ? _self.emailAddress : emailAddress // ignore: cast_nullable_to_non_nullable
as EmailAddress,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as Username,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as Description,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as Password,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,showErrorMessages: null == showErrorMessages ? _self.showErrorMessages : showErrorMessages // ignore: cast_nullable_to_non_nullable
as bool,registrationFailureOrSuccessOption: null == registrationFailureOrSuccessOption ? _self.registrationFailureOrSuccessOption : registrationFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>>,
  ));
}


}

// dart format on
