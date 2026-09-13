import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/domain/core/value_validators.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart'
    as value_objects;

void main() {
  // Usernames are document ids in `usernames/{username}`. A name Firestore
  // cannot use as an id would break the uniqueness check — a `/` turns
  // usernames.doc(name) into a nested path — or be rejected by the rules.
  group('validateUsernameIsDocumentIdSafe', () {
    for (final name in [
      'eduard',
      'androidprb',
      'Eduard-1',
      'a.b',
      'x_y',
      '__a',
      'a__',
      '...',
    ]) {
      test('accepts "$name"', () {
        expect(validateUsernameIsDocumentIdSafe(name).isRight(), isTrue);
      });
    }

    for (final name in ['a/b', '/', '.', '..', '__a__', '____']) {
      test('rejects "$name"', () {
        final failure = validateUsernameIsDocumentIdSafe(
          name,
        ).fold((failure) => failure, (_) => null);
        expect(failure, isA<InvalidUsernameCharacters>());
      });
    }
  });

  test('Username is invalid when it cannot be a document id', () {
    expect(value_objects.Username('a/b').isValid(), isFalse);
    expect(value_objects.Username('..').isValid(), isFalse);
    expect(value_objects.Username('eduard').isValid(), isTrue);
  });
}
