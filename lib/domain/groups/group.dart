import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../chats/messages/message.dart';
import '../core/value_objects.dart';

/// A chat of up to [maxMembers] people, kept apart from one-to-one chats. See
/// docs/e2ee.md.
///
/// Everyone added starts out invited, and joins when their own app accepts:
/// by itself when the person who added them is a friend, otherwise when they
/// tap Accept. The group's key is sealed to the invited as well as the
/// members, so accepting needs nobody else to be online, but only members can
/// read the messages.
final class Group extends Equatable {
  static const maxMembers = 32;

  final UniqueId id;

  /// Who has joined, in the order they joined.
  final List<String> memberIds;

  /// Who was added and has not accepted yet.
  final List<String> invitedIds;

  /// Who added each invited person.
  final Map<String, String> invitedBy;

  /// The members who may manage the group. All admins are equal.
  final List<String> adminIds;

  /// The newest message, decrypted, or null before the first one.
  final Message? lastMessage;

  final DateTime? createdAt;

  const Group({
    required this.id,
    required this.memberIds,
    required this.invitedIds,
    required this.invitedBy,
    required this.adminIds,
    this.lastMessage,
    this.createdAt,
  });

  /// Everyone the group's key is sealed to: members and the invited.
  List<String> get everyone => [...memberIds, ...invitedIds];

  bool isMember(String userId) => memberIds.contains(userId);

  bool isInvited(String userId) => invitedIds.contains(userId);

  bool isAdmin(String userId) => adminIds.contains(userId);

  /// When anything last happened: the newest message, or the group's start.
  DateTime? get lastActivityAt => lastMessage?.lastUpdatedAt ?? createdAt;

  @override
  List<Object?> get props => [
    id,
    memberIds,
    invitedIds,
    invitedBy,
    adminIds,
    lastMessage,
    createdAt,
  ];

  /// Counts only: who is in a group, and what they said, stay out of logs.
  @override
  String toString() =>
      'Group(${memberIds.length} members, ${invitedIds.length} invited)';
}

/// What a group's id starts with. A one-to-one chat's id is its two user ids
/// joined with "_", so the two kinds never look alike.
const groupIdPrefix = 'group-';

/// Whether [id] names a group rather than a one-to-one chat.
bool isGroupId(UniqueId id) => isGroupIdString(id.getOrCrash());

bool isGroupIdString(String id) => id.startsWith(groupIdPrefix);

/// A new group's id: the prefix and a random UUID, which says nothing about
/// who made it or when.
UniqueId newGroupId() =>
    UniqueId.fromUniqueString('$groupIdPrefix${const Uuid().v4()}');

/// What a group without a name is called: the other people in it.
String groupTitleOf(List<String> otherNames) => switch (otherNames) {
  [] => 'Just you',
  [final only] => only,
  [final first, final second] => '$first and $second',
  [final first, final second, final third] => '$first, $second and $third',
  [final first, final second, ...final rest] =>
    '$first, $second and ${rest.length} others',
};
