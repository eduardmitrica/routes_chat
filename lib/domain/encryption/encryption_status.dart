/// Where the signed-in user's end-to-end encryption stands on this device.
sealed class EncryptionStatus {
  const EncryptionStatus();
}

/// The user has never set up encryption, on any device. They choose a
/// passphrase and receive a recovery key.
final class EncryptionNotSetUp extends EncryptionStatus {
  const EncryptionNotSetUp();
}

/// Encryption is set up, but this device does not hold the keys yet (a new
/// device, or after signing out). The user unlocks with the passphrase or the
/// recovery key.
final class EncryptionLocked extends EncryptionStatus {
  const EncryptionLocked();
}

/// This device holds the user's keys, so chats can be read and sent.
final class EncryptionUnlocked extends EncryptionStatus {
  const EncryptionUnlocked();
}
