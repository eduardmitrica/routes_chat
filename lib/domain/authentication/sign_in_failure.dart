sealed class SignInFailure {}

final class CancelledByUser extends SignInFailure {}

final class ServerError extends SignInFailure {}

final class InvalidEmailAndPasswordCombination extends SignInFailure {}

final class InvalidUser extends SignInFailure {}

final class SignInFailed extends SignInFailure {}

final class GoogleError extends SignInFailure {}