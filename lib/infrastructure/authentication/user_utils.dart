import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:routes_chat/domain/authentication/user_utils_interface.dart';

@Singleton(as: IUserUtils)
class UserUtils implements IUserUtils {
  final FirebaseFirestore _firebaseFirestore;

  const UserUtils(this._firebaseFirestore);

  @override
  Future<bool> checkIfUsernameAlreadyExists(String usernameInput) async {
    final userDocsWithGivenUsername = await _firebaseFirestore
        .collection('users')
        .where('username', isEqualTo: usernameInput)
        .get();

    if (userDocsWithGivenUsername.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<bool> checkIfUsernameExistsMoreThanOnce(String username) async {
    final userDocsWithGivenUsername = await _firebaseFirestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (userDocsWithGivenUsername.docs.length == 1) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<bool> checkIfEmailAddressAlreadyExists(String emailAddress) async {
    final userDocsWithGivenEmailAddress = await _firebaseFirestore
        .collection('users')
        .where('emailAddress', isEqualTo: emailAddress)
        .get();

    if (userDocsWithGivenEmailAddress.docs.isEmpty) {
      return false;
    }
    else {
      return true;
    }
  }
}
