abstract interface class IUserUtils {
  /// Whether [username] is already claimed in the `usernames` index.
  ///
  /// Safe to call while signed out: registration runs it before the account
  /// exists, and index entries hold nothing but a uid.
  Future<bool> checkIfUsernameAlreadyExists(String username);

  /// Only called for the signed-in user's own profile.
  Future<bool> checkIfUsernameExistsMoreThanOnce(String username);
}
