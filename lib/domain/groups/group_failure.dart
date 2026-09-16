/// Why something about a group did not work.
sealed class GroupFailure {
  const GroupFailure();
}

/// The server refused: the user is not in the group, or the rules changed.
final class GroupInsufficientPermissions extends GroupFailure {
  const GroupInsufficientPermissions();
}

/// More than a group holds.
final class GroupTooBig extends GroupFailure {
  const GroupTooBig();
}

/// Someone added has not set up encryption, so the group's key cannot be
/// sealed to them.
final class GroupMemberWithoutKeys extends GroupFailure {
  final String userId;

  const GroupMemberWithoutKeys(this.userId);
}

final class GroupUnexpected extends GroupFailure {
  const GroupUnexpected();
}
