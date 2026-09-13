// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_in_form_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignInFormState {

 EmailAddress get emailAddress; Password get password; bool get isSubmitting; bool get showErrorMessages; Option<Either<SignInFailure, Unit>> get signInFailureOrSuccessOption;
/// Create a copy of SignInFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInFormStateCopyWith<SignInFormState> get copyWith => _$SignInFormStateCopyWithImpl<SignInFormState>(this as SignInFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SignInFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInFormState&&(identical(other.emailAddress, _this.emailAddress) || other.emailAddress == _this.emailAddress)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.isSubmitting, _this.isSubmitting) || other.isSubmitting == _this.isSubmitting)&&(identical(other.showErrorMessages, _this.showErrorMessages) || other.showErrorMessages == _this.showErrorMessages)&&(identical(other.signInFailureOrSuccessOption, _this.signInFailureOrSuccessOption) || other.signInFailureOrSuccessOption == _this.signInFailureOrSuccessOption));
}


@override
int get hashCode {
  final _this = this as SignInFormState;
  return Object.hash(runtimeType,_this.emailAddress,_this.password,_this.isSubmitting,_this.showErrorMessages,_this.signInFailureOrSuccessOption);
}

@override
String toString() {
  final _this = this as SignInFormState;
  return 'SignInFormState(emailAddress: ${_this.emailAddress}, password: ${_this.password}, isSubmitting: ${_this.isSubmitting}, showErrorMessages: ${_this.showErrorMessages}, signInFailureOrSuccessOption: ${_this.signInFailureOrSuccessOption})';
}


}

/// @nodoc
abstract mixin class $SignInFormStateCopyWith<$Res>  {
  factory $SignInFormStateCopyWith(SignInFormState value, $Res Function(SignInFormState) _then) = _$SignInFormStateCopyWithImpl;
@useResult
$Res call({
 EmailAddress emailAddress, Password password, bool isSubmitting, bool showErrorMessages, Option<Either<SignInFailure, Unit>> signInFailureOrSuccessOption
});




}
/// @nodoc
class _$SignInFormStateCopyWithImpl<$Res>
    implements $SignInFormStateCopyWith<$Res> {
  _$SignInFormStateCopyWithImpl(this._self, this._then);

  final SignInFormState _self;
  final $Res Function(SignInFormState) _then;

/// Create a copy of SignInFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emailAddress = null,Object? password = null,Object? isSubmitting = null,Object? showErrorMessages = null,Object? signInFailureOrSuccessOption = null,}) {
  return _then(SignInFormState(
emailAddress: null == emailAddress ? _self.emailAddress : emailAddress // ignore: cast_nullable_to_non_nullable
as EmailAddress,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as Password,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,showErrorMessages: null == showErrorMessages ? _self.showErrorMessages : showErrorMessages // ignore: cast_nullable_to_non_nullable
as bool,signInFailureOrSuccessOption: null == signInFailureOrSuccessOption ? _self.signInFailureOrSuccessOption : signInFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<SignInFailure, Unit>>,
  ));
}

}


/// Adds pattern-matching-related methods to [SignInFormState].
extension SignInFormStatePatterns on SignInFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignInFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignInFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignInFormState value)  $default,){
final _that = this;
switch (_that) {
case _SignInFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignInFormState value)?  $default,){
final _that = this;
switch (_that) {
case _SignInFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EmailAddress emailAddress,  Password password,  bool isSubmitting,  bool showErrorMessages,  Option<Either<SignInFailure, Unit>> signInFailureOrSuccessOption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignInFormState() when $default != null:
return $default(_that.emailAddress,_that.password,_that.isSubmitting,_that.showErrorMessages,_that.signInFailureOrSuccessOption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EmailAddress emailAddress,  Password password,  bool isSubmitting,  bool showErrorMessages,  Option<Either<SignInFailure, Unit>> signInFailureOrSuccessOption)  $default,) {final _that = this;
switch (_that) {
case _SignInFormState():
return $default(_that.emailAddress,_that.password,_that.isSubmitting,_that.showErrorMessages,_that.signInFailureOrSuccessOption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EmailAddress emailAddress,  Password password,  bool isSubmitting,  bool showErrorMessages,  Option<Either<SignInFailure, Unit>> signInFailureOrSuccessOption)?  $default,) {final _that = this;
switch (_that) {
case _SignInFormState() when $default != null:
return $default(_that.emailAddress,_that.password,_that.isSubmitting,_that.showErrorMessages,_that.signInFailureOrSuccessOption);case _:
  return null;

}
}

}

/// @nodoc


class _SignInFormState implements SignInFormState {
  const _SignInFormState({required this.emailAddress, required this.password, required this.isSubmitting, required this.showErrorMessages, required this.signInFailureOrSuccessOption});
  

@override final  EmailAddress emailAddress;
@override final  Password password;
@override final  bool isSubmitting;
@override final  bool showErrorMessages;
@override final  Option<Either<SignInFailure, Unit>> signInFailureOrSuccessOption;

/// Create a copy of SignInFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignInFormStateCopyWith<_SignInFormState> get copyWith => __$SignInFormStateCopyWithImpl<_SignInFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInFormState&&(identical(other.emailAddress, emailAddress) || other.emailAddress == emailAddress)&&(identical(other.password, password) || other.password == password)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.showErrorMessages, showErrorMessages) || other.showErrorMessages == showErrorMessages)&&(identical(other.signInFailureOrSuccessOption, signInFailureOrSuccessOption) || other.signInFailureOrSuccessOption == signInFailureOrSuccessOption));
}


@override
int get hashCode {
    return Object.hash(runtimeType,emailAddress,password,isSubmitting,showErrorMessages,signInFailureOrSuccessOption);
}

@override
String toString() {
    return 'SignInFormState(emailAddress: $emailAddress, password: $password, isSubmitting: $isSubmitting, showErrorMessages: $showErrorMessages, signInFailureOrSuccessOption: $signInFailureOrSuccessOption)';
}


}

/// @nodoc
abstract mixin class _$SignInFormStateCopyWith<$Res> implements $SignInFormStateCopyWith<$Res> {
  factory _$SignInFormStateCopyWith(_SignInFormState value, $Res Function(_SignInFormState) _then) = __$SignInFormStateCopyWithImpl;
@override @useResult
$Res call({
 EmailAddress emailAddress, Password password, bool isSubmitting, bool showErrorMessages, Option<Either<SignInFailure, Unit>> signInFailureOrSuccessOption
});




}
/// @nodoc
class __$SignInFormStateCopyWithImpl<$Res>
    implements _$SignInFormStateCopyWith<$Res> {
  __$SignInFormStateCopyWithImpl(this._self, this._then);

  final _SignInFormState _self;
  final $Res Function(_SignInFormState) _then;

/// Create a copy of SignInFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emailAddress = null,Object? password = null,Object? isSubmitting = null,Object? showErrorMessages = null,Object? signInFailureOrSuccessOption = null,}) {
  return _then(_SignInFormState(
emailAddress: null == emailAddress ? _self.emailAddress : emailAddress // ignore: cast_nullable_to_non_nullable
as EmailAddress,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as Password,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,showErrorMessages: null == showErrorMessages ? _self.showErrorMessages : showErrorMessages // ignore: cast_nullable_to_non_nullable
as bool,signInFailureOrSuccessOption: null == signInFailureOrSuccessOption ? _self.signInFailureOrSuccessOption : signInFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<SignInFailure, Unit>>,
  ));
}


}

// dart format on
