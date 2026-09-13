import 'package:cloud_firestore/cloud_firestore.dart';

extension FirestoreX on FirebaseFirestore {
  DocumentReference userDocument(String userId) =>
      collection('users').doc(userId);

  /// Entry in the username uniqueness index: `usernames/{username}` holding
  /// only `{uid}`.
  ///
  /// It lets registration check uniqueness while signed out without making
  /// `users` (which carries email addresses) publicly readable, and lets the
  /// security rules enforce uniqueness: a profile may only carry a username
  /// whose entry here belongs to it.
  DocumentReference<Map<String, dynamic>> usernameDocument(String username) =>
      collection('usernames').doc(username);
}

extension DocumentReferenceX on DocumentReference {
  CollectionReference get userCollection => collection('users');

  CollectionReference get friendRequestCollection =>
      collection('friendRequests');
}
