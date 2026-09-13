part of 'sign_in_form_bloc.dart';

sealed class SignInFormEvent extends Equatable {
  const SignInFormEvent();

  const factory SignInFormEvent.emailChanged(String emailString) = EmailChanged;
  const factory SignInFormEvent.passwordChanged(String passwordString) =
      PasswordChanged;
  const factory SignInFormEvent.signInPressed() = SignInPressed;
  const factory SignInFormEvent.signInWithGooglePressed() =
      SignInWithGooglePressed;
  const factory SignInFormEvent.clearState() = ClearState;

  @override
  List<Object?> get props => const [];
}

final class EmailChanged extends SignInFormEvent {
  final String emailString;
  const EmailChanged(this.emailString);
  @override
  List<Object?> get props => [emailString];
}

final class PasswordChanged extends SignInFormEvent {
  final String passwordString;
  const PasswordChanged(this.passwordString);
  @override
  List<Object?> get props => [passwordString];
}

final class SignInPressed extends SignInFormEvent {
  const SignInPressed();
}

final class SignInWithGooglePressed extends SignInFormEvent {
  const SignInWithGooglePressed();
}

final class ClearState extends SignInFormEvent {
  const ClearState();
}
