import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

void main() {
  late CurrentUserSession session;

  setUp(() => session = CurrentUserSession());

  test('starts empty', () {
    expect(session.current, isNull);
  });

  test('holds the user after start', () {
    session.start(const CurrentUseInformationPersistent('id-1', 'eduard'));

    expect(session.current?.id, 'id-1');
    expect(session.current?.username, 'eduard');
  });

  test('is empty again after end', () {
    session.start(const CurrentUseInformationPersistent('id-1', 'eduard'));
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
    session.start(const CurrentUseInformationPersistent('id-1', 'eduard'));

    expect(
      () => session.start(
        const CurrentUseInformationPersistent('id-2', 'someone-else'),
      ),
      returnsNormally,
    );
    expect(session.current?.id, 'id-2');
  });

  test('ending a session that never started does not throw', () {
    // getIt.unregister threw when the type was absent.
    expect(session.end, returnsNormally);
  });
}
