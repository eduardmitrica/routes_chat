import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:routes_chat/domain/encryption/encryption_repository_interface.dart';
import 'package:routes_chat/domain/notifications/push_token_registry_interface.dart';
import 'package:routes_chat/domain/presence/presence_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

/// Only `signOut` is implemented; it reports back when Firebase sign-out is
/// requested so the test can record the order of events.
class _FakeAuthFacade implements IAuthFacade {
  _FakeAuthFacade(this._onSignOut);

  final void Function() _onSignOut;

  @override
  Future<void> signOut() async => _onSignOut();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Reports back when this device's push token is removed.
class _FakePushTokens implements IPushTokenRegistry {
  _FakePushTokens(this._onUnregister);

  final void Function(String uid) _onUnregister;

  @override
  Future<void> register(String uid) async {}

  @override
  Future<void> unregister(String uid) async => _onUnregister(uid);
}

/// Reports back when the encryption keys on this device are forgotten.
class _FakeEncryption implements IEncryptionRepository {
  _FakeEncryption(this._onLock);

  final void Function() _onLock;

  @override
  Future<void> lock() async => _onLock();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Reports back when what friends see of this user's presence is deleted.
class _FakePresence implements IPresenceRepository {
  _FakePresence(this._onClear);

  final void Function(String uid) _onClear;

  @override
  Future<void> clearPresence(String userId) async => _onClear(userId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'removes the push token and the keys, then ends the session, then signs out',
    () async {
      // Repositories stop their Firestore listeners when the session ends. When
      // Firebase signed out first, those listeners outlived the auth token and
      // the security rules rejected them: PERMISSION_DENIED on every sign-out.
      // The push token and the encryption keys have to go before either:
      // deleting the token needs the owner's auth, removing the keys needs to
      // know whose they are, and anything left behind would serve the next
      // person to use this device.
      final session = CurrentUserSession()
        ..start(const CurrentUserInformationPersistent('user-1', 'eduard'));
      final steps = <String>[];
      String sessionState() => session.current == null ? 'over' : 'active';
      session.ended.listen((_) => steps.add('session ended'));

      final bloc = AuthenticationBloc(
        _FakeAuthFacade(() => steps.add('signed out of Firebase')),
        session,
        _FakePushTokens(
          (uid) => steps.add(
            'push token removed for $uid, session ${sessionState()}',
          ),
        ),
        _FakeEncryption(
          () => steps.add('encryption keys locked, session ${sessionState()}'),
        ),
        _FakePresence(
          (uid) =>
              steps.add('presence cleared for $uid, session ${sessionState()}'),
        ),
      );
      addTearDown(bloc.close);

      bloc.add(const AuthenticationEvent.signedOut());
      await expectLater(bloc.stream, emits(const Unauthenticated()));

      expect(steps, [
        'push token removed for user-1, session active',
        'presence cleared for user-1, session active',
        'encryption keys locked, session active',
        'session ended',
        'signed out of Firebase',
      ]);
    },
  );
}
