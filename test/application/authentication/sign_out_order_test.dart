import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

/// Only `signOut` is implemented; it reports back when Firebase sign-out is
/// requested so the test can inspect the session at that exact moment.
class _FakeAuthFacade implements IAuthFacade {
  _FakeAuthFacade(this._onSignOut);

  final void Function() _onSignOut;

  @override
  Future<void> signOut() async => _onSignOut();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  test('ends the session before signing out of Firebase', () async {
    // Repositories stop their Firestore listeners when the session ends. When
    // Firebase signed out first, those listeners outlived the auth token and
    // the security rules rejected them: PERMISSION_DENIED on every sign-out.
    final session = CurrentUserSession()
      ..start(const CurrentUseInformationPersistent('user-1', 'eduard'));
    var endedEvents = 0;
    session.ended.listen((_) => endedEvents++);

    bool? sessionActiveAtSignOut;
    int? endedEventsAtSignOut;
    final bloc = AuthenticationBloc(
      _FakeAuthFacade(() {
        sessionActiveAtSignOut = session.current != null;
        endedEventsAtSignOut = endedEvents;
      }),
      session,
    );
    addTearDown(bloc.close);

    bloc.add(const AuthenticationEvent.signedOut());
    await expectLater(bloc.stream, emits(const Unauthenticated()));

    expect(
      sessionActiveAtSignOut,
      isFalse,
      reason: 'the session must already be over when Firebase signs out',
    );
    expect(
      endedEventsAtSignOut,
      1,
      reason: 'listeners must be told to stop before Firebase signs out',
    );
  });
}
