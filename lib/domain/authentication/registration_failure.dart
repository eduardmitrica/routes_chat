sealed class RegistrationFailure {}

final class ServerError extends RegistrationFailure {}

final class EmailAlreadyInUse extends RegistrationFailure {}

final class CancelledByUser extends RegistrationFailure {}

final class UserAlreadyRegistered extends RegistrationFailure {}

final class SignInWithGoogleFailed extends RegistrationFailure {}

final class GoogleError extends RegistrationFailure {}