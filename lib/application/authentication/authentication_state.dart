part of 'authentication_bloc.dart';

sealed class AuthenticationState extends Equatable {
  const AuthenticationState();

  const factory AuthenticationState.initial() = AuthenticationInitial;
  const factory AuthenticationState.authenticated() = Authenticated;
  const factory AuthenticationState.unauthenticated() = Unauthenticated;

  @override
  List<Object?> get props => const [];
}

final class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

final class Authenticated extends AuthenticationState {
  const Authenticated();
}

final class Unauthenticated extends AuthenticationState {
  const Unauthenticated();
}
