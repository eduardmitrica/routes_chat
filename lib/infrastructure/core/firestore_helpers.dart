import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/groups/group.dart';

extension FirestoreX on FirebaseFirestore {
  /// Where the conversation [id] is kept: a group under `groups`, a
  /// one-to-one chat under `chats`. Messages, keys and the last message work
  /// the same way in both.
  DocumentReference<Map<String, dynamic>> conversationDocument(String id) =>
      collection(isGroupIdString(id) ? 'groups' : 'chats').doc(id);

  DocumentReference userDocument(String userId) =>
      collection('users').doc(userId);

  /// Entry in the username uniqueness index: `usernames/{username}` holding
  /// only `{uid}`.
  ///
  /// It lets registration check uniqueness while signed out without making
  /// `users` publicly readable, and lets the
  /// security rules enforce uniqueness: a profile may only carry a username
  /// whose entry here belongs to it.
  DocumentReference<Map<String, dynamic>> usernameDocument(String username) =>
      collection('usernames').doc(username);

  /// One of [userId]'s devices, registered for push notifications. The
  /// document id is the device's FCM token.
  DocumentReference<Map<String, dynamic>> pushTokenDocument(
    String userId,
    String token,
  ) => collection('users').doc(userId).collection('fcmTokens').doc(token);

  /// [userId]'s end-to-end encryption key bundle, readable only by its owner.
  /// See docs/e2ee.md.
  DocumentReference<Map<String, dynamic>> encryptionBundleDocument(
    String userId,
  ) => collection('users').doc(userId).collection('private').doc('encryption');

  /// [userId]'s published X25519 public key, readable by any signed-in user.
  DocumentReference<Map<String, dynamic>> publicKeyDocument(String userId) =>
      collection('userKeys').doc(userId);
}
