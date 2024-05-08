sealed class UserFailure {}

final class InsufficientPermission extends UserFailure {}

final class UnableToUpdate extends UserFailure {}

final class Unexpected extends UserFailure {}

final class UserNotFound extends UserFailure {}