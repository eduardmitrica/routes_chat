import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'key_bundle.dart';

/// Stretches a passphrase into a key-encryption key with Argon2id.
///
/// Argon2id is slow and memory-hungry on purpose, so that guessing passphrases
/// against a stolen key bundle is expensive. It runs in a background isolate so
/// the UI keeps responding while it works.
abstract final class PassphraseKeyDerivation {
  /// Settings for new bundles: 64 MiB, 3 passes, 1 lane. That is well above
  /// OWASP's minimum of 19 MiB and 2 passes, and takes about half a second on
  /// a desktop and a few seconds on a phone. Existing bundles keep the settings
  /// they were created with.
  static const defaultMemoryKiB = 65536;
  static const defaultIterations = 3;
  static const defaultParallelism = 1;

  static const saltLength = 16;
  static const keyLength = 32;

  /// Settings with a fresh random salt, for a new or changed passphrase.
  static PassphraseKdf newKdf({
    int memoryKiB = defaultMemoryKiB,
    int iterations = defaultIterations,
    int parallelism = defaultParallelism,
  }) {
    final random = Random.secure();
    return PassphraseKdf(
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      salt: Uint8List.fromList(
        List<int>.generate(saltLength, (_) => random.nextInt(256)),
      ),
    );
  }

  /// The key derived from [passphrase] with the settings and salt in [kdf].
  static Future<SecretKeyData> deriveKey(
    String passphrase,
    PassphraseKdf kdf,
  ) async {
    final bytes = await Isolate.run(() async {
      final key = await Argon2id(
        parallelism: kdf.parallelism,
        memory: kdf.memoryKiB,
        iterations: kdf.iterations,
        hashLength: keyLength,
      ).deriveKeyFromPassword(password: passphrase, nonce: kdf.salt);
      return Uint8List.fromList(await key.extractBytes());
    });
    return SecretKeyData(bytes);
  }
}
