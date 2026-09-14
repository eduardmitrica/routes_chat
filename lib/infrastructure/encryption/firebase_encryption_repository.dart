import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/encryption/encryption_failure.dart';
import '../../domain/encryption/encryption_repository_interface.dart';
import '../../domain/encryption/encryption_status.dart';
import '../../domain/encryption/value_objects.dart';
import '../../domain/shared/user/current_user_session_interface.dart';
import '../core/firestore_helpers.dart';
import 'chat_keyring.dart';
import 'key_bundle.dart';
import 'recovery_key.dart';
import 'user_key_manager.dart';

/// Keeps the user's key bundle in Firestore and the unlocked master key in the
/// device's secure storage (Android Keystore, iOS Keychain).
///
/// It also hands the unlocked keys to [ChatKeyring], which opens chat keys
/// with them.
class FirebaseEncryptionRepository
    implements IEncryptionRepository, UnlockedKeysSource {
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;
  final UserKeyManager _keys;
  final ICurrentUserSession _session;

  final _keysChanged = StreamController<void>.broadcast(sync: true);

  FirebaseEncryptionRepository(
    this._firestore,
    this._secureStorage,
    this._keys,
    this._session,
  );

  /// The secure storage entry holding [userId]'s master key on this device.
  @visibleForTesting
  static String masterKeyEntry(String userId) => 'e2ee.masterKey.$userId';

  @override
  Stream<void> get keysChanged => _keysChanged.stream;

  @override
  Future<Either<EncryptionFailure, EncryptionStatus>> status() =>
      _forUser((userId) async {
        final bundle = await _loadBundle(userId);
        if (bundle == null) {
          // A key left over from keys that no longer exist is of no use.
          await _secureStorage.delete(key: masterKeyEntry(userId));
          return const Right(EncryptionNotSetUp());
        }

        final masterKey = await _storedMasterKey(userId);
        if (masterKey == null) {
          return const Right(EncryptionLocked());
        }
        try {
          await _keys.privateKeyPair(bundle, masterKey);
          return const Right(EncryptionUnlocked());
        } on WrongSecret {
          // The keys were replaced elsewhere; this device must unlock again.
          await _secureStorage.delete(key: masterKeyEntry(userId));
          return const Right(EncryptionLocked());
        } on KeyBundleMismatch {
          await _secureStorage.delete(key: masterKeyEntry(userId));
          return const Right(EncryptionLocked());
        }
      });

  @override
  Future<Either<EncryptionFailure, String>> setUp(
    Passphrase passphrase,
  ) => _forUser((userId) async {
    // Argon2id takes seconds, so it runs once, before the transaction,
    // which may retry.
    final keys = await _keys.create(passphrase.getOrCrash());

    final alreadySetUp = await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(
        _firestore.encryptionBundleDocument(userId),
      );
      if (existing.exists) {
        return true;
      }
      // The rules require the bundle and the published public key to be
      // written together, and to carry the same public key and version.
      transaction
        ..set(_firestore.encryptionBundleDocument(userId), keys.bundle.toJson())
        ..set(
          _firestore.publicKeyDocument(userId),
          _publishedKeys(keys.bundle),
        );
      return false;
    });
    if (alreadySetUp) {
      return const Left(EncryptionAlreadySetUp());
    }

    await _storeMasterKey(userId, keys.masterKey);
    return Right(keys.recoveryKey.formatted);
  });

  @override
  Future<Either<EncryptionFailure, Unit>> unlockWithPassphrase(
    Passphrase passphrase,
  ) => _forUser((userId) async {
    final bundle = await _loadBundle(userId);
    if (bundle == null) {
      return const Left(EncryptionKeysUnavailable());
    }
    try {
      final masterKey = await _keys.unlockWithPassphrase(
        bundle,
        passphrase.getOrCrash(),
      );
      await _keys.privateKeyPair(bundle, masterKey);
      await _storeMasterKey(userId, masterKey);
      return const Right(unit);
    } on WrongSecret {
      return const Left(WrongPassphrase());
    }
  });

  @override
  Future<Either<EncryptionFailure, Unit>> unlockWithRecoveryKey(
    RecoveryKeyInput recoveryKey,
  ) => _forUser((userId) async {
    final parsed = RecoveryKey.tryParse(recoveryKey.getOrCrash());
    if (parsed == null) {
      return const Left(WrongRecoveryKey());
    }
    final bundle = await _loadBundle(userId);
    if (bundle == null) {
      return const Left(EncryptionKeysUnavailable());
    }
    try {
      final masterKey = await _keys.unlockWithRecoveryKey(bundle, parsed);
      await _keys.privateKeyPair(bundle, masterKey);
      await _storeMasterKey(userId, masterKey);
      return const Right(unit);
    } on WrongSecret {
      return const Left(WrongRecoveryKey());
    }
  });

  @override
  Future<Either<EncryptionFailure, String>> changePassphrase(
    Passphrase newPassphrase,
  ) => _forUser((userId) async {
    final masterKey = await _storedMasterKey(userId);
    final bundle = await _loadBundle(userId);
    if (masterKey == null || bundle == null) {
      return const Left(EncryptionKeysUnavailable());
    }
    try {
      final rekeyed = await _keys.changePassphrase(
        bundle,
        masterKey,
        newPassphrase.getOrCrash(),
      );
      // Rules allow this update only when the key pair stays the same.
      await _firestore
          .encryptionBundleDocument(userId)
          .set(rekeyed.bundle.toJson());
      return Right(rekeyed.recoveryKey.formatted);
    } on WrongSecret {
      await _secureStorage.delete(key: masterKeyEntry(userId));
      return const Left(EncryptionKeysUnavailable());
    }
  });

  @override
  Future<Either<EncryptionFailure, String>> resetKeys(
    Passphrase newPassphrase,
  ) => _forUser((userId) async {
    final current = await _loadBundle(userId);
    if (current == null) {
      return const Left(EncryptionKeysUnavailable());
    }
    // Argon2id takes seconds, so the new keys are made once, before the
    // transaction, which may retry.
    final keys = await _keys.create(
      newPassphrase.getOrCrash(),
      keyVersion: current.keyVersion + 1,
    );

    final bool replaced;
    try {
      replaced = await _firestore.runTransaction((transaction) async {
        final stored = (await transaction.get(
          _firestore.encryptionBundleDocument(userId),
        )).data();
        // Reset from another device meanwhile: do not replace those keys.
        if (stored == null ||
            KeyBundle.fromJson(stored).keyVersion != current.keyVersion) {
          return false;
        }
        transaction
          ..set(
            _firestore.encryptionBundleDocument(userId),
            keys.bundle.toJson(),
          )
          ..set(
            _firestore.publicKeyDocument(userId),
            _publishedKeys(keys.bundle),
          );
        return true;
      });
    } on FirebaseException catch (error) {
      // The rules allow a reset only shortly after signing in. Everything
      // else about the write is the app's own doing.
      if (error.code == 'permission-denied') {
        return const Left(RecentSignInRequired());
      }
      rethrow;
    }
    if (!replaced) {
      return const Left(EncryptionServerError());
    }

    await _storeMasterKey(userId, keys.masterKey);
    return Right(keys.recoveryKey.formatted);
  });

  @override
  Future<void> lock() async {
    final userId = _session.current?.id;
    if (userId == null) return;
    try {
      await _secureStorage.delete(key: masterKeyEntry(userId));
    } on Exception catch (error) {
      debugPrint(
        'Could not remove the encryption key from this device: $error',
      );
    }
  }

  @override
  Future<UnlockedKeys> unlockedKeys(String userId) async {
    final masterKey = await _storedMasterKey(userId);
    final bundle = masterKey == null ? null : await _loadBundle(userId);
    if (masterKey == null || bundle == null) {
      throw const EncryptionKeysLocked();
    }
    try {
      return UnlockedKeys(
        await _keys.privateKeyPair(bundle, masterKey),
        bundle.keyVersion,
      );
    } on WrongSecret {
      throw const EncryptionKeysLocked();
    }
  }

  /// What `userKeys/{uid}` publishes for [bundle].
  static Map<String, Object> _publishedKeys(KeyBundle bundle) => {
    'publicKey': base64Encode(bundle.publicKey),
    'keyVersion': bundle.keyVersion,
  };

  /// Runs [operation] for the signed-in user, turning storage and parsing
  /// errors into [EncryptionServerError].
  Future<Either<EncryptionFailure, T>> _forUser<T>(
    Future<Either<EncryptionFailure, T>> Function(String userId) operation,
  ) async {
    final userId = _session.current?.id;
    if (userId == null) {
      return const Left(EncryptionKeysUnavailable());
    }
    try {
      return await operation(userId);
    } on FirebaseException catch (error) {
      debugPrint('Encryption keys unavailable: ${error.code}');
      return const Left(EncryptionServerError());
    } on FormatException catch (error) {
      debugPrint('Encryption key bundle unreadable: ${error.message}');
      return const Left(EncryptionServerError());
    } on KeyBundleMismatch {
      return const Left(EncryptionServerError());
    } on PlatformException catch (error) {
      // The native crypto and secure storage plugins report failures this
      // way. Left uncaught, the page waits forever on a derivation that died.
      debugPrint('Encryption failed on this device: ${error.code}');
      return const Left(EncryptionServerError());
    }
  }

  Future<KeyBundle?> _loadBundle(String userId) async {
    final snapshot = await _firestore.encryptionBundleDocument(userId).get();
    final data = snapshot.data();
    return snapshot.exists && data != null ? KeyBundle.fromJson(data) : null;
  }

  Future<SecretKeyData?> _storedMasterKey(String userId) async {
    final stored = await _secureStorage.read(key: masterKeyEntry(userId));
    return stored == null ? null : SecretKeyData(base64Decode(stored));
  }

  /// Stores the master key this device now uses, and tells whoever holds keys
  /// opened with earlier ones to drop them.
  Future<void> _storeMasterKey(String userId, SecretKeyData masterKey) async {
    await _secureStorage.write(
      key: masterKeyEntry(userId),
      value: base64Encode(masterKey.bytes),
    );
    _keysChanged.add(null);
  }
}
