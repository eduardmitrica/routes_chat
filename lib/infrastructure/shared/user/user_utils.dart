import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/shared/user/user_utils_interface.dart';
import '../../core/firestore_helpers.dart';

class UserUtils implements IUserUtils {
  final FirebaseFirestore _firebaseFirestore;

  const UserUtils(this._firebaseFirestore);

  @override
  Future<bool> checkIfUsernameAlreadyExists(String usernameInput) async {
    // Reads the public index instead of querying `users`: this runs before
    // the account exists, and `users` is only readable once signed in.
    final claim = await _firebaseFirestore.usernameDocument(usernameInput).get();
    return claim.exists;
  }
}
