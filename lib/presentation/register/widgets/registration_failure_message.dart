import 'package:routes_chat/domain/authentication/registration_failure.dart';

/// What to tell the user when registering did not work, or null when there is
/// nothing to say: they cancelled it themselves.
String? registrationFailureMessage(
  RegistrationFailure failure,
) => switch (failure) {
  EmailAlreadyInUse() => 'That email already has an account. Sign in instead.',
  UsernameTaken() => 'Someone just took that username. Please choose another.',
  ServerError() =>
    'Couldn\'t reach the server. Check your connection and try again.',
  CancelledByUser() => null,
  UserAlreadyRegistered() =>
    'This Google account is already registered. Sign in instead.',
  SignInWithGoogleFailed() ||
  GoogleError() => 'Google sign-in didn\'t work. Please try again.',
};

/// Whether [failure] means the user already has an account, so the message
/// offers to sign in.
bool alreadyHasAccount(RegistrationFailure failure) =>
    failure is EmailAlreadyInUse || failure is UserAlreadyRegistered;
