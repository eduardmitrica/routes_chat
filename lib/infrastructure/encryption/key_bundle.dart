import 'dart:convert';

import 'package:flutter/foundation.dart';

/// The Argon2id settings a passphrase was stretched with.
///
/// They are stored with the bundle, so they can be raised for new users later
/// without breaking the ones already set up.
@immutable
final class PassphraseKdf {
  static const algorithm = 'argon2id';

  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final Uint8List salt;

  const PassphraseKdf({
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
    required this.salt,
  });

  Map<String, Object> toJson() => {
    'algorithm': algorithm,
    'memoryKiB': memoryKiB,
    'iterations': iterations,
    'parallelism': parallelism,
    'salt': base64Encode(salt),
  };

  factory PassphraseKdf.fromJson(Map<String, dynamic> json) {
    if (json['algorithm'] != algorithm) {
      throw FormatException('Unsupported KDF: ${json['algorithm']}');
    }
    return PassphraseKdf(
      memoryKiB: json['memoryKiB'] as int,
      iterations: json['iterations'] as int,
      parallelism: json['parallelism'] as int,
      salt: base64Decode(json['salt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PassphraseKdf &&
      other.memoryKiB == memoryKiB &&
      other.iterations == iterations &&
      other.parallelism == parallelism &&
      listEquals(other.salt, salt);

  @override
  int get hashCode =>
      Object.hash(memoryKiB, iterations, parallelism, Object.hashAll(salt));
}

/// A key encrypted with AES-256-GCM under another key.
@immutable
final class WrappedKey {
  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;

  const WrappedKey({
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  Map<String, String> toJson() => {
    'nonce': base64Encode(nonce),
    'cipherText': base64Encode(cipherText),
    'mac': base64Encode(mac),
  };

  factory WrappedKey.fromJson(Map<String, dynamic> json) => WrappedKey(
    nonce: base64Decode(json['nonce'] as String),
    cipherText: base64Decode(json['cipherText'] as String),
    mac: base64Decode(json['mac'] as String),
  );

  @override
  bool operator ==(Object other) =>
      other is WrappedKey &&
      listEquals(other.nonce, nonce) &&
      listEquals(other.cipherText, cipherText) &&
      listEquals(other.mac, mac);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(nonce),
    Object.hashAll(cipherText),
    Object.hashAll(mac),
  );
}

/// Everything stored about a user's encryption keys, at
/// `users/{uid}/private/encryption`.
///
/// None of it is usable without the passphrase or the recovery key:
/// - the master key, wrapped twice (once by each of those);
/// - the X25519 private key, wrapped by the master key;
/// - the public key, in the clear, for chat partners.
///
/// See docs/e2ee.md.
@immutable
final class KeyBundle {
  static const currentVersion = 1;

  final int version;

  /// Which keys these are: 1 for a user's first, one more after each reset
  /// that replaced lost keys. Sealed chat keys record the version they were
  /// sealed to, so a reset shows as a version they no longer match.
  final int keyVersion;
  final PassphraseKdf kdf;
  final WrappedKey masterKeyByPassphrase;
  final WrappedKey masterKeyByRecoveryKey;
  final WrappedKey privateKey;
  final Uint8List publicKey;

  const KeyBundle({
    required this.version,
    required this.keyVersion,
    required this.kdf,
    required this.masterKeyByPassphrase,
    required this.masterKeyByRecoveryKey,
    required this.privateKey,
    required this.publicKey,
  });

  KeyBundle copyWith({
    PassphraseKdf? kdf,
    WrappedKey? masterKeyByPassphrase,
    WrappedKey? masterKeyByRecoveryKey,
  }) => KeyBundle(
    version: version,
    keyVersion: keyVersion,
    kdf: kdf ?? this.kdf,
    masterKeyByPassphrase: masterKeyByPassphrase ?? this.masterKeyByPassphrase,
    masterKeyByRecoveryKey:
        masterKeyByRecoveryKey ?? this.masterKeyByRecoveryKey,
    privateKey: privateKey,
    publicKey: publicKey,
  );

  Map<String, Object> toJson() => {
    'version': version,
    'keyVersion': keyVersion,
    'kdf': kdf.toJson(),
    'masterKeyByPassphrase': masterKeyByPassphrase.toJson(),
    'masterKeyByRecoveryKey': masterKeyByRecoveryKey.toJson(),
    'privateKey': privateKey.toJson(),
    'publicKey': base64Encode(publicKey),
  };

  factory KeyBundle.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    if (version != currentVersion) {
      throw FormatException('Unsupported key bundle version: $version');
    }
    return KeyBundle(
      version: currentVersion,
      // Bundles created before key resets existed carry no version: they
      // hold a user's first keys.
      keyVersion: json['keyVersion'] as int? ?? 1,
      kdf: PassphraseKdf.fromJson(json['kdf'] as Map<String, dynamic>),
      masterKeyByPassphrase: WrappedKey.fromJson(
        json['masterKeyByPassphrase'] as Map<String, dynamic>,
      ),
      masterKeyByRecoveryKey: WrappedKey.fromJson(
        json['masterKeyByRecoveryKey'] as Map<String, dynamic>,
      ),
      privateKey: WrappedKey.fromJson(
        json['privateKey'] as Map<String, dynamic>,
      ),
      publicKey: base64Decode(json['publicKey'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is KeyBundle &&
      other.version == version &&
      other.keyVersion == keyVersion &&
      other.kdf == kdf &&
      other.masterKeyByPassphrase == masterKeyByPassphrase &&
      other.masterKeyByRecoveryKey == masterKeyByRecoveryKey &&
      other.privateKey == privateKey &&
      listEquals(other.publicKey, publicKey);

  @override
  int get hashCode => Object.hash(
    version,
    keyVersion,
    kdf,
    masterKeyByPassphrase,
    masterKeyByRecoveryKey,
    privateKey,
    Object.hashAll(publicKey),
  );
}
