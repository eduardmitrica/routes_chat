import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  late CurrentUserSession session;

  setUp(() => session = CurrentUserSession());

  test('starts empty', () {
    expect(session.current, isNull);
  });

  test('holds the user after start', () {
    session.start(const CurrentUserInformationPersistent('id-1', 'eduard'));

    expect(session.current?.id, 'id-1');
    expect(session.current?.username, 'eduard');
  });

  test('is empty again after end', () {
    session.start(const CurrentUserInformationPersistent('id-1', 'eduard'));
    session.end();

    expect(session.current, isNull);
  });

  test('reading an empty session returns null rather than throwing', () {
    // The previous implementation resolved the user from the service locator,
    // which threw once sign-out unregistered it.
    expect(() => session.current, returnsNormally);
  });

  test('starting twice replaces the user instead of throwing', () {
    // getIt.registerSingleton threw when the type was already registered, and
    // authenticationRequested is dispatched from three places.
    session.start(const CurrentUserInformationPersistent('id-1', 'eduard'));

    expect(
      () => session.start(
        const CurrentUserInformationPersistent('id-2', 'someone-else'),
      ),
      returnsNormally,
    );
    expect(session.current?.id, 'id-2');
  });

  test('ending a session that never started does not throw', () {
    // getIt.unregister threw when the type was absent.
    expect(session.end, returnsNormally);
  });

  group('ended', () {
    test('emits synchronously when a started session ends', () {
      var events = 0;
      session.ended.listen((_) => events++);
      session.start(const CurrentUserInformationPersistent('id-1', 'eduard'));

      session.end();

      // Synchronous on purpose: AuthenticationBloc signs out of Firebase on
      // the line after ending the session, so cancellation must already have
      // started by then.
      expect(events, 1);
    });

    test('does not emit when nothing was started', () {
      var events = 0;
      session.ended.listen((_) => events++);

      session.end();

      expect(events, 0);
    });

    test('cancels an upstream listener bounded with takeUntil', () async {
      // This is how repositories bound their Firestore snapshot listeners.
      final source = StreamController<int>();
      addTearDown(source.close);
      session.start(const CurrentUserInformationPersistent('id-1', 'eduard'));
      final received = source.stream.takeUntil(session.ended).toList();

      source.add(1);
      await pumpEventQueue();
      session.end();

      expect(await received, [1]);
      expect(
        source.hasListener,
        isFalse,
        reason: 'the upstream (Firestore) listener must be cancelled',
      );
    });
  });
}
