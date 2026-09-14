import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import 'key_bundle.dart';
import 'passphrase_key_derivation.dart';
import 'recovery_key.dart';

/// The passphrase or recovery key did not unlock the key bundle.
final class WrongSecret implements Exception {
  const WrongSecret();

  @override
  String toString() => 'WrongSecret';
}

/// The private key in a bundle does not match the bundle's public key.
final class KeyBundleMismatch implements Exception {
  const KeyBundleMismatch();

  @override
  String toString() => 'KeyBundleMismatch';
}

/// A user's freshly created keys.
///
/// Only [bundle] may be stored. Show [recoveryKey] to the user once, and keep
/// [masterKey] in the device's secure storage.
final class NewUserKeys {
  final KeyBundle bundle;
  final RecoveryKey recoveryKey;
  final SecretKeyData masterKey;

  const NewUserKeys({
    required this.bundle,
    required this.recoveryKey,
    required this.masterKey,
  });
}

/// A bundle re-wrapped for a new passphrase, with the new recovery key to show.
final class RekeyedBundle {
  final KeyBundle bundle;
  final RecoveryKey recoveryKey;

  const RekeyedBundle({required this.bundle, required this.recoveryKey});
}

/// Creates and unlocks a user's encryption keys. See docs/e2ee.md.
///
/// This is pure cryptography: storing and loading the bundle is the caller's
/// job.
class UserKeyManager {
  /// Associated data that ties each wrapped key to its purpose, so one wrapped
  /// key cannot be passed off as another.
  static const _masterKeyByPassphrase = 'routes_chat/v1/master-key/passphrase';
  static const _masterKeyByRecoveryKey = 'routes_chat/v1/master-key/recovery';
  static const _privateKeyPurpose = 'routes_chat/v1/private-key';
  static const _recoveryKeyInfo = 'routes_chat/v1/recovery-kek';

  static const masterKeyLength = 32;

  final PassphraseKdf Function() _newKdf;

  /// [newKdf] exists so tests can use cheap Argon2id settings.
  UserKeyManager({PassphraseKdf Function()? newKdf})
    : _newKdf = newKdf ?? PassphraseKeyDerivation.newKdf;

  // Built on use rather than once, so they always come from the current
  // Cryptography.instance. cryptography_flutter registers itself and swaps in
  // the platform's native AES-GCM and X25519 where available.
  AesGcm get _aead => AesGcm.with256bits();
  X25519 get _x25519 => X25519();
  Hkdf get _hkdf => Hkdf(hmac: Hmac.sha256(), outputLength: masterKeyLength);

  Future<NewUserKeys> create(String passphrase) async {
    final masterKey = SecretKeyData.random(length: masterKeyLength);
    final keyPair = await _x25519.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final recoveryKey = RecoveryKey.generate();
    final kdf = _newKdf();

    final bundle = KeyBundle(
      version: KeyBundle.currentVersion,
      kdf: kdf,
      masterKeyByPassphrase: await _wrap(
        masterKey.bytes,
        await PassphraseKeyDerivation.deriveKey(passphrase, kdf),
        _masterKeyByPassphrase,
      ),
      masterKeyByRecoveryKey: await _wrap(
        masterKey.bytes,
        await _recoveryKek(recoveryKey),
        _masterKeyByRecoveryKey,
      ),
      privateKey: await _wrap(
        await keyPair.extractPrivateKeyBytes(),
        masterKey,
        _privateKeyPurpose,
      ),
      publicKey: Uint8List.fromList(publicKey.bytes),
    );

    return NewUserKeys(
      bundle: bundle,
      recoveryKey: recoveryKey,
      masterKey: masterKey,
    );
  }

  /// The master key, if [passphrase] is right. Throws [WrongSecret] otherwise.
  Future<SecretKeyData> unlockWithPassphrase(
    KeyBundle bundle,
    String passphrase,
  ) async => SecretKeyData(
    await _unwrap(
      bundle.masterKeyByPassphrase,
      await PassphraseKeyDerivation.deriveKey(passphrase, bundle.kdf),
      _masterKeyByPassphrase,
    ),
  );

  /// The master key, if [recoveryKey] is right. Throws [WrongSecret] otherwise.
  Future<SecretKeyData> unlockWithRecoveryKey(
    KeyBundle bundle,
    RecoveryKey recoveryKey,
  ) async => SecretKeyData(
    await _unwrap(
      bundle.masterKeyByRecoveryKey,
      await _recoveryKek(recoveryKey),
      _masterKeyByRecoveryKey,
    ),
  );

  /// Re-wraps the master key for [newPassphrase] and a new recovery key.
  ///
  /// The old passphrase and the old recovery key stop working. The key pair
  /// stays the same, so every chat and message remains readable. Throws
  /// [WrongSecret] if [masterKey] does not belong to [bundle].
  Future<RekeyedBundle> changePassphrase(
    KeyBundle bundle,
    SecretKeyData masterKey,
    String newPassphrase,
  ) async {
    await privateKeyPair(bundle, masterKey);

    final kdf = _newKdf();
    final recoveryKey = RecoveryKey.generate();
    return RekeyedBundle(
      bundle: bundle.copyWith(
        kdf: kdf,
        masterKeyByPassphrase: await _wrap(
          masterKey.bytes,
          await PassphraseKeyDerivation.deriveKey(newPassphrase, kdf),
          _masterKeyByPassphrase,
        ),
        masterKeyByRecoveryKey: await _wrap(
          masterKey.bytes,
          await _recoveryKek(recoveryKey),
          _masterKeyByRecoveryKey,
        ),
      ),
      recoveryKey: recoveryKey,
    );
  }

  /// The user's X25519 key pair.
  ///
  /// Throws [WrongSecret] if [masterKey] does not unlock it, and
  /// [KeyBundleMismatch] if it does not match the bundle's public key.
  Future<SimpleKeyPair> privateKeyPair(
    KeyBundle bundle,
    SecretKey masterKey,
  ) async {
    final privateKey = await _unwrap(
      bundle.privateKey,
      masterKey,
      _privateKeyPurpose,
    );
    final keyPair = await _x25519.newKeyPairFromSeed(privateKey);
    final publicKey = await keyPair.extractPublicKey();
    if (!listEquals(publicKey.bytes, bundle.publicKey)) {
      throw const KeyBundleMismatch();
    }
    return keyPair;
  }

  Future<SecretKey> _recoveryKek(RecoveryKey recoveryKey) => _hkdf.deriveKey(
    secretKey: SecretKeyData(recoveryKey.bytes),
    // RFC 5869's default salt, spelled out. Leaving it empty gives the same
    // key in pure Dart, but Android's native HMAC rejects an empty key.
    nonce: _hkdfDefaultSalt,
    info: utf8.encode(_recoveryKeyInfo),
  );

  /// HashLen zero bytes: what HKDF uses when no salt is given (RFC 5869, 2.2).
  static final _hkdfDefaultSalt = List<int>.filled(32, 0, growable: false);

  Future<WrappedKey> _wrap(
    List<int> key,
    SecretKey keyEncryptionKey,
    String purpose,
  ) async {
    final box = await _aead.encrypt(
      key,
      secretKey: keyEncryptionKey,
      aad: utf8.encode(purpose),
    );
    return WrappedKey(
      nonce: Uint8List.fromList(box.nonce),
      cipherText: Uint8List.fromList(box.cipherText),
      mac: Uint8List.fromList(box.mac.bytes),
    );
  }

  Future<List<int>> _unwrap(
    WrappedKey wrapped,
    SecretKey keyEncryptionKey,
    String purpose,
  ) async {
    try {
      return await _aead.decrypt(
        SecretBox(
          wrapped.cipherText,
          nonce: wrapped.nonce,
          mac: Mac(wrapped.mac),
        ),
        secretKey: keyEncryptionKey,
        aad: utf8.encode(purpose),
      );
    } on SecretBoxAuthenticationError {
      throw const WrongSecret();
    }
  }
}
