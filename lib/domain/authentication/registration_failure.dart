sealed class RegistrationFailure {}

final class ServerError extends RegistrationFailure {}

final class EmailAlreadyInUse extends RegistrationFailure {}

/// The username passed the form's uniqueness check, but someone else claimed
/// it before this registration's profile was written.
final class UsernameTaken extends RegistrationFailure {}

final class CancelledByUser extends RegistrationFailure {}

final class UserAlreadyRegistered extends RegistrationFailure {}

final class SignInWithGoogleFailed extends RegistrationFailure {}

final class GoogleError extends RegistrationFailure {}
