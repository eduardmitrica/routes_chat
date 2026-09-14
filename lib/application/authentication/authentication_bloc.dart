import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/domain/notifications/push_token_registry_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

import '../../domain/authentication/authentication_facade_interface.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final IAuthFacade _authFacade;
  final ICurrentUserSession _session;
  final IPushTokenRegistry _pushTokens;

  AuthenticationBloc(this._authFacade, this._session, this._pushTokens)
    : super(const AuthenticationState.initial()) {
    on<AuthenticationEvent>((event, emit) async {
      switch (event) {
        case AuthenticationRequested():
          final user = (await _authFacade.getSignedInUser()).toNullable();
          if (user == null) {
            emit(const AuthenticationState.unauthenticated());
            return;
          }
          final uid = user.id.getOrCrash();
          _session.start(
            CurrentUserInformationPersistent(uid, user.username.getOrCrash()),
          );
          emit(const AuthenticationState.authenticated());
          // Not awaited: the permission prompt and the token upload must not
          // hold up the home page, and registration never throws.
          unawaited(_pushTokens.register(uid));
        case SignedOut():
          // Remove this device's push token while still signed in. The rules
          // only let the owner delete it, and a token left behind would keep
          // sending this user's notifications to a device they signed out of.
          final uid = _session.current?.id;
          if (uid != null) {
            await _pushTokens.unregister(uid);
          }
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
