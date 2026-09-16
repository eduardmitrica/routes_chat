import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../chats/messages/message.dart';
import '../core/value_objects.dart';
import 'group_profile.dart';

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

  /// Whether only admins may add people; otherwise any member may.
  final bool onlyAdminsAdd;

  /// Its name and photo, decrypted; null when it has none, or when this
  /// phone cannot open them yet.
  final GroupProfile? profile;

  /// The newest message, decrypted, or null before the first one.
  final Message? lastMessage;

  final DateTime? createdAt;

  const Group({
    required this.id,
    required this.memberIds,
    required this.invitedIds,
    required this.invitedBy,
    required this.adminIds,
    this.onlyAdminsAdd = false,
    this.profile,
    this.lastMessage,
    this.createdAt,
  });

  /// Everyone the group's key is sealed to: members and the invited.
  List<String> get everyone => [...memberIds, ...invitedIds];

  bool isMember(String userId) => memberIds.contains(userId);

  bool isInvited(String userId) => invitedIds.contains(userId);

  bool isAdmin(String userId) => adminIds.contains(userId);

  /// Whether [userId] may add people: a member, and an admin when only admins
  /// may.
  bool canAdd(String userId) =>
      isMember(userId) && (!onlyAdminsAdd || isAdmin(userId));

  /// Whether [by] may take [userId] out: admins take out anyone else, other
  /// admins and whoever started the group included. Leaving is how someone
  /// takes themselves out.
  bool canRemove(String by, String userId) =>
      isAdmin(by) && by != userId && everyone.contains(userId);

  /// Whether [by] may make [userId] an admin, or stop them being one. There
  /// is always at least one admin.
  bool canSetAdmin(String by, String userId, {required bool admin}) =>
      isAdmin(by) &&
      isMember(userId) &&
      (admin ? !isAdmin(userId) : isAdmin(userId) && adminIds.length > 1);

  /// The admins once [userId] has left: the same without them, or, when they
  /// were the only admin, whoever has been a member longest.
  List<String> adminsAfterLeaving(String userId) {
    final admins = [...adminIds]..remove(userId);
    final members = [...memberIds]..remove(userId);
    if (admins.isEmpty && members.isNotEmpty) return [members.first];
    return admins;
  }

  /// What the group is called: its name, or else the other people in it,
  /// [otherNames].
  String titleWith(List<String> otherNames) {
    final name = profile?.name ?? '';
    return name.isNotEmpty ? name : groupTitleOf(otherNames);
  }

  /// How many more people fit.
  int get room => maxMembers - everyone.length;

  /// When anything last happened: the newest message, or the group's start.
  DateTime? get lastActivityAt => lastMessage?.lastUpdatedAt ?? createdAt;

  @override
  List<Object?> get props => [
    id,
    memberIds,
    invitedIds,
    invitedBy,
    adminIds,
    onlyAdminsAdd,
    profile,
    lastMessage,
    createdAt,
  ];

  /// Counts only: who is in a group, and what they said, stay out of logs.
  @override
  String toString() =>
      'Group(${memberIds.length} members, ${invitedIds.length} invited)';
}

/// How much of a group's past someone added can read.
enum HistoryShare {
  /// Only what is sent from when they are added.
  none,

  /// What was sent in the last 24 hours, copied for them alone.
  day,

  /// What was sent in the last 7 days, copied for them alone.
  week,

  /// Everything the person adding them can read.
  all;

  /// How far back a copied history reaches; null when nothing is copied.
  Duration? get window => switch (this) {
    HistoryShare.day => const Duration(hours: 24),
    HistoryShare.week => const Duration(days: 7),
    HistoryShare.none || HistoryShare.all => null,
  };
}

/// Whether a group's current key has to be replaced before anyone writes:
/// it is sealed to someone no longer in the group, who could otherwise read
/// what comes next, or not to someone who is, who could not.
bool groupKeyOutOfDate(Iterable<String> sealedTo, Iterable<String> everyone) {
  final sealed = sealedTo.toSet();
  final people = everyone.toSet();
  return sealed.length != people.length || !sealed.containsAll(people);
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
