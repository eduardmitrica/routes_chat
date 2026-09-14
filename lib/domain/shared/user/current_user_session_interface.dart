import 'current_user_information_persistent.dart';

/// Holds the signed-in user's details for the lifetime of the session.
///
/// Consumers receive this through their constructor. It replaces the previous
/// approach of registering [CurrentUserInformationPersistent] into the service
/// locator on sign in and unregistering it on sign out, which made every
/// consumer depend on the container and threw whenever something read the
/// details outside that window.
///
/// [current] is null while nobody is signed in, so callers handle the absence
/// explicitly instead of crashing.
abstract interface class ICurrentUserSession {
  CurrentUserInformationPersistent? get current;

  /// Emits, synchronously, each time a started session ends.
  ///
  /// Repositories stop their Firestore listeners on it with `takeUntil`, and
  /// `AuthenticationBloc` ends the session before signing out of Firebase. The
  /// listeners are therefore cancelled while the auth token is still valid,
  /// instead of outliving it and being rejected by the security rules.
  Stream<void> get ended;

  void start(CurrentUserInformationPersistent user);

  void end();
}
