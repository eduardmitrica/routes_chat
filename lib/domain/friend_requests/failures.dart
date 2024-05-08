sealed class FriendRequestFailure {}

final class InsufficientPermissions extends FriendRequestFailure {}

final class Unexpected extends FriendRequestFailure {}

final class NotFound extends FriendRequestFailure {}