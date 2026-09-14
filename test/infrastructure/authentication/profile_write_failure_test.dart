import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart';
import 'package:routes_chat/infrastructure/authentication/profile_write_failure.dart';

void main() {
  // Regression: losing the race for a username (someone claimed it between the
  // form's uniqueness check and the profile write) was reported as a generic
  // "Server Error", leaving the user no hint to pick another name.

  test('a name claimed by someone else means it was taken meanwhile', () {
    expect(
      profileWriteFailure(usernameClaimOwner: 'uid-other', uid: 'uid-me'),
      isA<UsernameTaken>(),
    );
  });

  test('no claim at all is a real server error', () {
    expect(
      profileWriteFailure(usernameClaimOwner: null, uid: 'uid-me'),
      isA<ServerError>(),
    );
  });

  test('a claim held by the same user is a real server error', () {
    // The claim is ours, so the name was not the problem.
    expect(
      profileWriteFailure(usernameClaimOwner: 'uid-me', uid: 'uid-me'),
      isA<ServerError>(),
    );
  });
}
