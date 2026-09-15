import 'package:routes_chat/domain/authentication/sign_in_failure.dart';

/// What to tell the user when signing in did not work, or null when there is
/// nothing to say: they cancelled it themselves.
String? signInFailureMessage(SignInFailure failure) => switch (failure) {
  InvalidEmailAndPasswordCombination() =>
    'That email and password don\'t match an account.',
  ServerError() =>
    'Couldn\'t reach the server. Check your connection and try again.',
  CancelledByUser() => null,
  InvalidUser() =>
    'This Google account isn\'t registered yet. Register it, then sign in.',
  SignInFailed() => 'Signing in didn\'t work. Please try again.',
  GoogleError() => 'Google sign-in didn\'t work. Please try again.',
};
