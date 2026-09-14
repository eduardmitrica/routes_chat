import 'package:uuid/uuid.dart';

/// The username given to a Google registration, until the user picks their
/// own on the profile page.
///
/// It must not collide with another user's, must fit the 12-character limit
/// of Username, and must be usable as a document id in the `usernames` index.
/// Twelve hex digits of a version 4 UUID give 48 random bits and meet all of
/// those rules.
///
/// This used to be the last 12 characters of a version 1 UUID. Those
/// characters are the UUID's node id, which does not change from one UUID to
/// the next, so the same app kept generating the same name and every Google
/// registration after the first was rejected as "username taken".
String generateUsername() =>
    const Uuid().v4().replaceAll('-', '').substring(0, 12);
