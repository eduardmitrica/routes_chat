part of 'sign_in_form_bloc.dart';

@freezed
class SignInFormState with _$SignInFormState {
  const factory SignInFormState({
    required EmailAddress emailAddress,
    required Password password,
    required bool isSubmitting,
    required bool showErrorMessages,
    required Option<Either<SignInFailure, Unit>> signInFailureOrSuccessOption
  }) = _SignInFormState;

  factory SignInFormState.initial() => SignInFormState(
    emailAddress:  EmailAddress(''),
    password:  Password(''),
    showErrorMessages: false,
    isSubmitting: false,
    signInFailureOrSuccessOption: none(),
  );
}
