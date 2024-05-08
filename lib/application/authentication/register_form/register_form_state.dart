part of 'register_form_bloc.dart';

@freezed
class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState({
    required ImagePath imagePath,
    required EmailAddress emailAddress,
    required Username username,
    required Description description,
    required Password password,
    required bool isSubmitting,
    required bool showErrorMessages,
    required Option<Either<RegistrationFailure, Either<EmailAddress, Unit>>> registrationFailureOrSuccessOption
}) = _RegisterFormState;

  factory RegisterFormState.initial() => RegisterFormState(
    imagePath: ImagePath(''),
    emailAddress:  EmailAddress(''),
    username: Username(''),
    description: Description(''),
    password:  Password(''),
    showErrorMessages: false,
    isSubmitting: false,
    registrationFailureOrSuccessOption: none(),
  );
}
