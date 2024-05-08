abstract interface class IUserUtils {
  Future<bool> checkIfUsernameAlreadyExists(String username);
  Future<bool> checkIfUsernameExistsMoreThanOnce(String username);
  Future<bool> checkIfEmailAddressAlreadyExists(String emailAddress);
}