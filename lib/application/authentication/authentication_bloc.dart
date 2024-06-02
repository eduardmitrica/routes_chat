import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';

import '../../domain/authentication/authentication_facade_interface.dart';
import '../../injection.dart';

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
        userOption.fold(() {
          emit(const AuthenticationState.unauthenticated());
        }, (user) {
          getIt.registerSingleton<CurrentUseInformationPersistent>(
            CurrentUseInformationPersistent(
              user.id.getOrCrash(),
              user.username.getOrCrash(),
            ),
          );
          emit(const AuthenticationState.authenticated());
        });
      }, signedOut: (_) async {
        await _authFacade.signOut();
        getIt.unregister<CurrentUseInformationPersistent>();
        emit(
          const AuthenticationState.unauthenticated(),
        );
      });
    });
  }
}
