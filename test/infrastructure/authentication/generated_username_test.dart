import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';
import 'package:routes_chat/infrastructure/authentication/generated_username.dart';

void main() {
  // Regression: Google registrations took the last 12 characters of a
  // version 1 UUID as the username. That part of a v1 UUID is its node id and
  // stays the same between calls, so the app kept producing the same name and
  // every Google registration after the first failed as "username taken".

  test('generated usernames differ from one call to the next', () {
    final usernames = {for (var i = 0; i < 1000; i++) generateUsername()};

    expect(usernames, hasLength(1000));
  });

  test('a generated username is a valid Username', () {
    for (var i = 0; i < 100; i++) {
      final username = generateUsername();

      expect(Username(username).isValid(), isTrue, reason: username);
    }
  });
}
