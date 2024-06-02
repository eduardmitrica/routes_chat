import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:routes_chat/domain/shared/user/user.dart' as domain_user;
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../../domain/shared/user/value_objects.dart';

extension FirebaseUserMapper on User {
  Future<domain_user.User> toDomain(FirebaseFirestore fireStore) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot;
    try {
      documentSnapshot = await fireStore.collection('users').doc(uid).get();
    } on FirebaseException catch (_) {
      return domain_user.User(
          id: UniqueId(),
          description: Description(''),
          emailAddress: EmailAddress(''),
          imageUrl: ImageUrl(''),
          username: Username(''));
    }

    final username = await Username.checkAgainstDatabaseWhenFetching(
        documentSnapshot['username']);
    final usernameString = username.getOrCrash();

    return domain_user.User(
      id: UniqueId.fromUniqueString(uid),
      emailAddress: EmailAddress(documentSnapshot['emailAddress']),
      username: Username(usernameString),
      description: Description(
        documentSnapshot['description'],
      ),
      imageUrl: ImageUrl(
        documentSnapshot['imageUrl'],
      ),
    );
  }
}
