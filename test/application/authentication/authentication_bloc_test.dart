import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/encryption/encryption_repository_interface.dart';
import 'package:routes_chat/domain/notifications/push_token_registry_interface.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart'
    as value_objects;
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

/// Only the two members [AuthenticationBloc] uses are implemented; the
/// `noSuchMethod` override covers the rest of the interface.
class _FakeAuthFacade implements IAuthFacade {
  _FakeAuthFacade(this._signedInUser);

  final Option<User> _signedInUser;
  var signOutCallCount = 0;

  @override
  Future<Option<User>> getSignedInUser() async => _signedInUser;

  @override
  Future<void> signOut() async => signOutCallCount++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Records which users this device was registered and unregistered for.
class _FakePushTokens implements IPushTokenRegistry {
  final registered = <String>[];
  final unregistered = <String>[];

  @override
  Future<void> register(String uid) async => registered.add(uid);

  @override
  Future<void> unregister(String uid) async => unregistered.add(uid);
}

/// Counts how often the encryption keys on this device are forgotten.
class _FakeEncryption implements IEncryptionRepository {
  var locks = 0;

  @override
  Future<void> lock() async => locks++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

User _user() => User(
  id: UniqueId.fromUniqueString('user-1'),
  imageUrl: value_objects.ImageUrl('https://example.com/avatar.jpg'),
  username: value_objects.Username('eduard'),
  description: value_objects.Description('hello'),
);

void main() {
  late CurrentUserSession session;
  late _FakePushTokens pushTokens;
  late _FakeEncryption encryption;

  setUp(() {
    session = CurrentUserSession();
    pushTokens = _FakePushTokens();
    encryption = _FakeEncryption();
  });

  test('populates the session when a user is signed in', () async {
    final bloc = AuthenticationBloc(
      _FakeAuthFacade(some(_user())),
      session,
      pushTokens,
      encryption,
    );
    addTearDown(bloc.close);

    bloc.add(const AuthenticationEvent.authenticationRequested());

    await expectLater(bloc.stream, emits(const Authenticated()));
    expect(session.current?.id, 'user-1');
    expect(session.current?.username, 'eduard');
  });

  test('leaves the session empty when nobody is signed in', () async {
    final bloc = AuthenticationBloc(
      _FakeAuthFacade(none()),
      session,
      pushTokens,
      encryption,
    );
    addTearDown(bloc.close);

    bloc.add(const AuthenticationEvent.authenticationRequested());

    await expectLater(bloc.stream, emits(const Unauthenticated()));
    expect(session.current, isNull);
  });

  test('registers this device for push notifications once signed in', () async {
    final bloc = AuthenticationBloc(
      _FakeAuthFacade(some(_user())),
      session,
      pushTokens,
      encryption,
    );
    addTearDown(bloc.close);

    bloc.add(const AuthenticationEvent.authenticationRequested());
    await expectLater(bloc.stream, emits(const Authenticated()));
    await pumpEventQueue();

    expect(pushTokens.registered, ['user-1']);
  });

  test(
    'does not register for push notifications when nobody is signed in',
    () async {
      final bloc = AuthenticationBloc(
        _FakeAuthFacade(none()),
        session,
        pushTokens,
        encryption,
      );
      addTearDown(bloc.close);

      bloc.add(const AuthenticationEvent.authenticationRequested());
      await expectLater(bloc.stream, emits(const Unauthenticated()));
      await pumpEventQueue();

      expect(pushTokens.registered, isEmpty);
    },
  );

  test('clears the session and the push token on sign out', () async {
    final facade = _FakeAuthFacade(some(_user()));
    final bloc = AuthenticationBloc(facade, session, pushTokens, encryption);
    addTearDown(bloc.close);

    bloc.add(const AuthenticationEvent.authenticationRequested());
    await expectLater(bloc.stream, emits(const Authenticated()));

    bloc.add(const AuthenticationEvent.signedOut());
    await expectLater(bloc.stream, emits(const Unauthenticated()));

    expect(session.current, isNull);
    expect(facade.signOutCallCount, 1);
    expect(pushTokens.unregistered, ['user-1']);
    expect(encryption.locks, 1);
  });

  test('authenticating twice does not throw', () async {
    // Regression: the session used to be a getIt.registerSingleton call, and
    // authenticationRequested is dispatched from app_widget, sign_in_form and
    // register_form — a second dispatch threw "already registered".
    // Bloc suppresses a repeated identical state, so the second pass is
    // verified by pumping the queue rather than awaiting another emission; an
    // exception in the handler would surface as an unhandled zone error.
    final bloc = AuthenticationBloc(
      _FakeAuthFacade(some(_user())),
      session,
      pushTokens,
      encryption,
    );
    addTearDown(bloc.close);

    bloc.add(const AuthenticationEvent.authenticationRequested());
    await expectLater(bloc.stream, emits(const Authenticated()));

    bloc.add(const AuthenticationEvent.authenticationRequested());
    await pumpEventQueue();

    expect(bloc.state, const Authenticated());
    expect(session.current?.id, 'user-1');
  });

  test('signing out twice does not throw', () async {
    // Regression: the matching getIt.unregister threw when nothing was
    // registered.
    final facade = _FakeAuthFacade(none());
    final bloc = AuthenticationBloc(facade, session, pushTokens, encryption);
    addTearDown(bloc.close);

    bloc.add(const AuthenticationEvent.signedOut());
    await expectLater(bloc.stream, emits(const Unauthenticated()));

    bloc.add(const AuthenticationEvent.signedOut());
    await pumpEventQueue();

    expect(bloc.state, const Unauthenticated());
    expect(session.current, isNull);
    expect(facade.signOutCallCount, 2);
    expect(
      pushTokens.unregistered,
      isEmpty,
      reason: 'with no session there is no user whose token could be removed',
    );
    expect(
      encryption.locks,
      0,
      reason: 'with no session there are no keys of anyone to forget',
    );
  });
}
