import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/authentication/authentication_facade_interface.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

part 'authentication_bloc.freezed.dart';

@injectable
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final IAuthFacade _authFacade;

  AuthenticationBloc(this._authFacade)
      : super(const AuthenticationState.initial()) {
    on<AuthenticationEvent>((event, emit) async {
      await event.map(authenticationRequested: (_) async {
        final userOption = await _authFacade.getSignedInUser();
        emit(
          userOption.fold(
            () => const AuthenticationState.unauthenticated(),
            (_) => const AuthenticationState.authenticated(),
          ),
        );
      }, signedOut: (_) async {
        await _authFacade.signOut();
        emit(
          const AuthenticationState.unauthenticated(),
        );
      });
    });
  }
}
