import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

import '../../domain/authentication/authentication_facade_interface.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final IAuthFacade _authFacade;
  final ICurrentUserSession _session;

  AuthenticationBloc(this._authFacade, this._session)
    : super(const AuthenticationState.initial()) {
    on<AuthenticationEvent>((event, emit) async {
      switch (event) {
        case AuthenticationRequested():
          final userOption = await _authFacade.getSignedInUser();
          userOption.fold(
            () {
              emit(const AuthenticationState.unauthenticated());
            },
            (user) {
              _session.start(
                CurrentUseInformationPersistent(
                  user.id.getOrCrash(),
                  user.username.getOrCrash(),
                ),
              );
              emit(const AuthenticationState.authenticated());
            },
          );
        case SignedOut():
          // End the session before signing out of Firebase. Repositories stop
          // their Firestore listeners when it ends; signing out first left
          // them running without an auth token, and the rules rejected them.
          _session.end();
          await _authFacade.signOut();
          emit(const AuthenticationState.unauthenticated());
      }
    });
  }
}
