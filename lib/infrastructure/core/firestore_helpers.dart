import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:routes_chat/domain/core/errors.dart';

import '../../injection.dart';

extension FirestoreX on FirebaseFirestore {
  Future<DocumentReference> get userDocument async {
    final userOption = await getIt<IAuthFacade>().getSignedInUser();
    final user = userOption.getOrElse(() => throw UnauthenticatedUser());
    return collection('users').doc(user.id.getOrCrash());
  }
}

extension DocumentReferenceX on DocumentReference {
  CollectionReference get userCollection => collection('users');

  CollectionReference get friendRequestCollection => collection('friendRequests');
}