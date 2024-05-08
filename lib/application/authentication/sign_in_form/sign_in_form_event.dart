part of 'sign_in_form_bloc.dart';

@freezed
class SignInFormEvent with _$SignInFormEvent {
  const factory SignInFormEvent.emailChanged(String emailString) = EmailChanged;
  const factory SignInFormEvent.passwordChanged(String passwordString) = PasswordChanged;
  const factory SignInFormEvent.registerPressed() = SignInPressed;
  const factory SignInFormEvent.signInWithGooglePressed() = SignInWithGooglePressed;
  const factory SignInFormEvent.clearState() = ClearState;
}
