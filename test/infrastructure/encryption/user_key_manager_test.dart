import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/key_bundle.dart';
import 'package:routes_chat/infrastructure/encryption/passphrase_key_derivation.dart';
import 'package:routes_chat/infrastructure/encryption/recovery_key.dart';
import 'package:routes_chat/infrastructure/encryption/user_key_manager.dart';

const _passphrase = 'correct horse battery staple';

/// Cheap Argon2id settings, so the tests don't spend seconds per derivation.
UserKeyManager _manager() => UserKeyManager(
  newKdf: () => PassphraseKeyDerivation.newKdf(memoryKiB: 1024, iterations: 1),
);

KeyBundle _throughFirestore(KeyBundle bundle) => KeyBundle.fromJson(
  jsonDecode(jsonEncode(bundle.toJson())) as Map<String, dynamic>,
);

void main() {
  late UserKeyManager manager;
  late NewUserKeys keys;

  setUpAll(() async {
    manager = _manager();
    keys = await manager.create(_passphrase);
  });

  group('unlocking', () {
    test('the passphrase unlocks the master key', () async {
      final masterKey = await manager.unlockWithPassphrase(
        keys.bundle,
        _passphrase,
      );

      expect(masterKey.bytes, keys.masterKey.bytes);
    });

    test(
      'the recovery key, as the user would type it, unlocks it too',
      () async {
        final typed = RecoveryKey.tryParse(
          keys.recoveryKey.formatted.toLowerCase(),
        )!;

        final masterKey = await manager.unlockWithRecoveryKey(
          keys.bundle,
          typed,
        );

        expect(masterKey.bytes, keys.masterKey.bytes);
      },
    );

    test('a wrong passphrase is rejected, not turned into a wrong key', () {
      expect(
        manager.unlockWithPassphrase(
          keys.bundle,
          'correct horse battery stapl',
        ),
        throwsA(isA<WrongSecret>()),
      );
    });

    test('a wrong recovery key is rejected', () {
      expect(
        manager.unlockWithRecoveryKey(keys.bundle, RecoveryKey.generate()),
        throwsA(isA<WrongSecret>()),
      );
    });

    test(
      'the bundle still unlocks after a round trip through Firestore',
      () async {
        final masterKey = await manager.unlockWithPassphrase(
          _throughFirestore(keys.bundle),
          _passphrase,
        );

        expect(masterKey.bytes, keys.masterKey.bytes);
      },
    );
  });

  group('the key pair', () {
    test(
      'is recovered from the master key and matches the public key',
      () async {
        final keyPair = await manager.privateKeyPair(
          keys.bundle,
          keys.masterKey,
        );
        final publicKey = await keyPair.extractPublicKey();

        expect(publicKey.bytes, keys.bundle.publicKey);
      },
    );

    test('cannot be recovered with another master key', () {
      expect(
        manager.privateKeyPair(
          keys.bundle,
          SecretKeyData.random(length: UserKeyManager.masterKeyLength),
        ),
        throwsA(isA<WrongSecret>()),
      );
    });

    test(
      'is refused when the bundle carries someone else\'s public key',
      () async {
        final other = await _manager().create('another passphrase');
        final tampered = KeyBundle(
          version: keys.bundle.version,
          kdf: keys.bundle.kdf,
          masterKeyByPassphrase: keys.bundle.masterKeyByPassphrase,
          masterKeyByRecoveryKey: keys.bundle.masterKeyByRecoveryKey,
          privateKey: keys.bundle.privateKey,
          publicKey: other.bundle.publicKey,
        );

        expect(
          manager.privateKeyPair(tampered, keys.masterKey),
          throwsA(isA<KeyBundleMismatch>()),
        );
      },
    );

    test('lets two users derive the same shared secret', () async {
      // The basis for sealing chat keys to a participant's public key.
      final other = await _manager().create('another passphrase');
      final x25519 = X25519();

      final mine = await x25519.sharedSecretKey(
        keyPair: await manager.privateKeyPair(keys.bundle, keys.masterKey),
        remotePublicKey: SimplePublicKey(
          other.bundle.publicKey,
          type: KeyPairType.x25519,
        ),
      );
      final theirs = await x25519.sharedSecretKey(
        keyPair: await manager.privateKeyPair(other.bundle, other.masterKey),
        remotePublicKey: SimplePublicKey(
          keys.bundle.publicKey,
          type: KeyPairType.x25519,
        ),
      );

      expect(await mine.extractBytes(), await theirs.extractBytes());
    });
  });

  group('changing the passphrase', () {
    late RekeyedBundle rekeyed;

    setUpAll(() async {
      rekeyed = await manager.changePassphrase(
        keys.bundle,
        keys.masterKey,
        'a brand new passphrase',
      );
    });

    test('unlocks the same master key with the new passphrase', () async {
      final masterKey = await manager.unlockWithPassphrase(
        rekeyed.bundle,
        'a brand new passphrase',
      );

      expect(masterKey.bytes, keys.masterKey.bytes);
    });

    test('unlocks it with the new recovery key', () async {
      final masterKey = await manager.unlockWithRecoveryKey(
        rekeyed.bundle,
        rekeyed.recoveryKey,
      );

      expect(masterKey.bytes, keys.masterKey.bytes);
    });

    test('stops the old passphrase and the old recovery key working', () {
      expect(
        manager.unlockWithPassphrase(rekeyed.bundle, _passphrase),
        throwsA(isA<WrongSecret>()),
      );
      expect(
        manager.unlockWithRecoveryKey(rekeyed.bundle, keys.recoveryKey),
        throwsA(isA<WrongSecret>()),
      );
      expect(rekeyed.recoveryKey, isNot(keys.recoveryKey));
    });

    test('keeps the key pair, so chats stay readable', () {
      expect(rekeyed.bundle.privateKey, keys.bundle.privateKey);
      expect(rekeyed.bundle.publicKey, keys.bundle.publicKey);
    });

    test('refuses a master key that does not belong to the bundle', () {
      expect(
        manager.changePassphrase(
          keys.bundle,
          SecretKeyData.random(length: UserKeyManager.masterKeyLength),
          'anything',
        ),
        throwsA(isA<WrongSecret>()),
      );
    });
  });

  test('two bundles made with the same passphrase share nothing', () async {
    final other = await manager.create(_passphrase);

    expect(other.bundle.kdf.salt, isNot(keys.bundle.kdf.salt));
    expect(other.masterKey.bytes, isNot(keys.masterKey.bytes));
    expect(
      other.bundle.masterKeyByPassphrase,
      isNot(keys.bundle.masterKeyByPassphrase),
    );
    expect(other.bundle.publicKey, isNot(keys.bundle.publicKey));
  });

  group('passphrase key derivation', () {
    test('is deterministic for the same passphrase and settings', () async {
      final kdf = PassphraseKeyDerivation.newKdf(
        memoryKiB: 1024,
        iterations: 1,
      );

      final first = await PassphraseKeyDerivation.deriveKey(_passphrase, kdf);
      final second = await PassphraseKeyDerivation.deriveKey(_passphrase, kdf);

      expect(first.bytes, second.bytes);
      expect(first.bytes, hasLength(32));
    });

    test('depends on the salt', () async {
      final a = PassphraseKeyDerivation.newKdf(memoryKiB: 1024, iterations: 1);
      final b = PassphraseKeyDerivation.newKdf(memoryKiB: 1024, iterations: 1);

      expect(
        (await PassphraseKeyDerivation.deriveKey(_passphrase, a)).bytes,
        isNot((await PassphraseKeyDerivation.deriveKey(_passphrase, b)).bytes),
      );
    });

    test('defaults stay above the OWASP minimum for Argon2id', () {
      // 19 MiB and 2 passes. Lowering the defaults makes stolen bundles
      // cheaper to attack.
      expect(
        PassphraseKeyDerivation.defaultMemoryKiB,
        greaterThanOrEqualTo(19456),
      );
      expect(
        PassphraseKeyDerivation.defaultIterations,
        greaterThanOrEqualTo(2),
      );
      expect(PassphraseKeyDerivation.newKdf().salt, hasLength(16));
    });
  });
}
