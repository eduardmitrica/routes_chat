sealed class MessageFailure {}

final class InsufficientPermissions extends MessageFailure {}

final class Unexpected extends MessageFailure {}

/// The message was sent too long ago to edit (see messageEditWindow).
final class EditTimeExpired extends MessageFailure {}
