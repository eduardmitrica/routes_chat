import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:routes_chat/domain/shared/user/user.dart' as domain_user;
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../../domain/shared/user/user_utils_interface.dart';
import '../../../domain/shared/user/value_objects.dart';

extension FirebaseUserMapper on User {
  /// The signed-in user's profile, or null when it does not exist or cannot be
  /// read, for example an Auth account whose registration never completed.
  ///
  /// This used to signal "no profile" by returning a user with an invalid
  /// email address. Profiles no longer store an email address, so absence is
  /// now explicit.
  Future<domain_user.User?> toDomain(
    FirebaseFirestore fireStore,
    IUserUtils userUtils,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot;
    try {
      documentSnapshot = await fireStore.collection('users').doc(uid).get();
    } on FirebaseException catch (_) {
      return null;
    }

    final profile = documentSnapshot.data();
    if (!documentSnapshot.exists || profile == null) {
      return null;
    }

    final username = await Username.checkAgainstDatabaseWhenFetching(
      userUtils,
      profile['username'],
    );

    return domain_user.User(
      id: UniqueId.fromUniqueString(uid),
      username: Username(username.getOrCrash()),
      description: Description(profile['description']),
      imageUrl: ImageUrl(profile['imageUrl']),
    );
  }
}
