/// Keeps the signed-in user's device registered for push notifications.
///
/// Neither method throws. Notifications are optional, so a failure (permission
/// denied, no Google Play services, offline) must never get in the way of
/// signing in or out.
abstract interface class IPushTokenRegistry {
  /// Asks for notification permission if needed, stores this device's token
  /// for [uid], and keeps it up to date until the session ends.
  Future<void> register(String uid);

  /// Removes this device's token for [uid] and invalidates it on the device.
  ///
  /// Call it while still signed in: the security rules only let the owner
  /// delete a token.
  Future<void> unregister(String uid);
}
