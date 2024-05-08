sealed class AuthenticationFailure {}

final class CancelledByUser extends AuthenticationFailure {}

final class ServerError extends AuthenticationFailure {}

final class EmailAlreadyInUse extends AuthenticationFailure {}

final class InvalidEmailAndPasswordCombination extends AuthenticationFailure {}