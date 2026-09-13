import 'value_objects.dart';

/// Id of a document that must exist at most once for a given set of users,
/// such as the friend request between two users or the chat between them.
///
/// A client-side Firestore transaction only detects conflicts on documents it
/// reads with `transaction.get`; it cannot track a query. So "look for an
/// existing document with a query, then create one" lets two simultaneous
/// writers both create. Keying the document by its members instead makes a
/// duplicate a write to the *same* document, which the transaction does
/// detect, and which the security rules can require.
///
/// Order-insensitive: the ids are sorted before joining, so A→B and B→A map to
/// the same document. The format (sorted, joined with `_`) is mirrored by
/// `firestore.rules`; change both together.
UniqueId compositeId(Iterable<UniqueId> memberIds) {
  final sortedIds = memberIds.map((id) => id.getOrCrash()).toList()..sort();
  return UniqueId.fromUniqueString(sortedIds.join('_'));
}
