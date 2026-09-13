part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  const factory AuthenticationEvent.authenticationRequested() =
      AuthenticationRequested;
  const factory AuthenticationEvent.signedOut() = SignedOut;

  @override
  List<Object?> get props => const [];
}

final class AuthenticationRequested extends AuthenticationEvent {
  const AuthenticationRequested();
}

final class SignedOut extends AuthenticationEvent {
  const SignedOut();
}
