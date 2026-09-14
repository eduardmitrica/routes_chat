import '../../domain/authentication/registration_failure.dart';

/// Why writing a new user's profile failed, judged by who holds the username
/// claim (`usernames/{username}`) right after the failed write.
///
/// The profile and the claim are committed together, and the security rules
/// reject the pair when the name is already claimed by someone else. The
/// uniqueness check in the form runs earlier, so another user can take the
/// name in between. That case deserves its own failure, so the user is asked
/// for another name instead of seeing a generic server error. Anything else,
/// including a claim that belongs to [uid] itself, is a real server-side
/// failure.
RegistrationFailure profileWriteFailure({
  required String? usernameClaimOwner,
  required String uid,
}) {
  if (usernameClaimOwner != null && usernameClaimOwner != uid) {
    return UsernameTaken();
  }
  return ServerError();
}
