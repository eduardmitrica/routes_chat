import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';

import '../../injection.dart';

extension FirestoreX on FirebaseFirestore {
  DocumentReference get userDocument {
    final userId = getIt<CurrentUseInformationPersistent>().id;
    return collection('users').doc(userId);
  }
}

extension DocumentReferenceX on DocumentReference {
  CollectionReference get userCollection => collection('users');

  CollectionReference get friendRequestCollection => collection('friendRequests');
}