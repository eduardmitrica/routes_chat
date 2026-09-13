import 'current_user_information_persistent.dart';

/// Holds the signed-in user's details for the lifetime of the session.
///
/// Consumers receive this through their constructor. It replaces the previous
/// approach of registering [CurrentUseInformationPersistent] into the service
/// locator on sign in and unregistering it on sign out, which made every
/// consumer depend on the container and threw whenever something read the
/// details outside that window.
///
/// [current] is null while nobody is signed in, so callers handle the absence
/// explicitly instead of crashing.
abstract interface class ICurrentUserSession {
  CurrentUseInformationPersistent? get current;

  void start(CurrentUseInformationPersistent user);

  void end();
}
