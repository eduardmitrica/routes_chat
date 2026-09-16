import 'package:equatable/equatable.dart';

/// Something that happened to a group, shown in its chat among the messages.
///
/// Events hold no text of anyone's: who did what to whom, which the server
/// already sees from the group itself. The server checks each against the
/// change it describes, so none can be made up. See firestore.rules.
enum GroupEventType {
  created('created'),
  added('added'),
  joined('joined'),
  left('left'),
  removed('removed'),
  adminAdded('adminAdded'),
  adminRemoved('adminRemoved'),
  renamed('renamed'),
  photoChanged('photoChanged'),
  onlyAdminsAdd('onlyAdminsAdd');

  /// As stored, which firestore.rules checks; a test keeps them equal.
  final String stored;

  const GroupEventType(this.stored);

  static GroupEventType? fromStored(Object? stored) {
    for (final type in values) {
      if (type.stored == stored) return type;
    }
    return null;
  }

  /// Whether the event is about someone other than whoever caused it.
  bool get hasSubject => switch (this) {
    added || removed || adminAdded || adminRemoved => true,
    created ||
    joined ||
    left ||
    renamed ||
    photoChanged ||
    onlyAdminsAdd => false,
  };
}

final class GroupEvent extends Equatable {
  final GroupEventType type;

  /// Who caused it.
  final String byId;

  /// Who it happened to, for the types that have one.
  final String? subjectId;

  /// For [GroupEventType.onlyAdminsAdd], whether only admins add people now.
  final bool? on;

  const GroupEvent({
    required this.type,
    required this.byId,
    this.subjectId,
    this.on,
  });

  @override
  List<Object?> get props => [type, byId, subjectId, on];

  @override
  String toString() => 'GroupEvent(${type.stored})';
}

/// [event] as a line in the chat, [nameOf] giving each person's name, and
/// "You" for [myId].
String describeGroupEvent(
  GroupEvent event, {
  required String Function(String userId) nameOf,
  required String myId,
}) {
  String who(String? id) => id == null
      ? 'Someone'
      : id == myId
      ? 'You'
      : nameOf(id);
  String whom(String? id) => id == null
      ? 'someone'
      : id == myId
      ? 'you'
      : nameOf(id);
  final by = who(event.byId);
  final subject = whom(event.subjectId);
  return switch (event.type) {
    GroupEventType.created => '$by started the group',
    GroupEventType.added => '$by added $subject',
    GroupEventType.joined => '$by joined',
    GroupEventType.left => '$by left',
    GroupEventType.removed => '$by took $subject out of the group',
    GroupEventType.adminAdded =>
      event.subjectId == myId
          ? '$by made you an admin'
          : '$by made $subject an admin',
    GroupEventType.adminRemoved =>
      event.subjectId == event.byId
          ? '$by stopped being an admin'
          : '$by removed $subject as an admin',
    GroupEventType.renamed => '$by changed the group name',
    GroupEventType.photoChanged => '$by changed the group photo',
    GroupEventType.onlyAdminsAdd =>
      event.on ?? false
          ? '$by let only admins add people'
          : '$by let everyone add people',
  };
}
