import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';
import 'package:routes_chat/infrastructure/encryption/passphrase_key_derivation.dart';
import 'package:routes_chat/infrastructure/encryption/user_key_manager.dart';

/// Behaves like cryptography_flutter's HMAC on Android, which hands the key to
/// javax.crypto's SecretKeySpec and so throws on an empty key. The pure Dart
/// HMAC used by the other tests accepts one, which is how an empty HKDF salt
/// got past them and broke key creation on the phone.
class _NoEmptyKeyHmac extends DartHmac {
  const _NoEmptyKeyHmac(super.hashAlgorithm);

  @override
  Future<Mac> calculateMac(
    List<int> bytes, {
    required SecretKey secretKey,
    List<int> nonce = const <int>[],
    List<int> aad = const <int>[],
  }) async {
    if ((await secretKey.extractBytes()).isEmpty) {
      throw ArgumentError('Empty key');
    }
    return super.calculateMac(
      bytes,
      secretKey: secretKey,
      nonce: nonce,
      aad: aad,
    );
  }
}

class _AndroidLikeCryptography extends DartCryptography {
  @override
  Hmac hmac(HashAlgorithm hashAlgorithm) => _NoEmptyKeyHmac(hashAlgorithm);
}

void main() {
  late Cryptography original;

  setUp(() {
    original = Cryptography.instance;
    Cryptography.instance = _AndroidLikeCryptography();
  });

  tearDown(() => Cryptography.instance = original);

  test('the stand-in rejects an HKDF with no salt, as Android does', () {
    expect(
      Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
        secretKey: SecretKeyData(List.filled(20, 7)),
        info: [1, 2, 3],
      ),
      throwsArgumentError,
    );
  });

  test(
    'keys can be created and recovered when HMAC rejects empty keys',
    () async {
      final manager = UserKeyManager(
        newKdf: () =>
            PassphraseKeyDerivation.newKdf(memoryKiB: 1024, iterations: 1),
      );

      final keys = await manager.create('correct horse battery staple');
      final recovered = await manager.unlockWithRecoveryKey(
        keys.bundle,
        keys.recoveryKey,
      );

      expect(recovered.bytes, keys.masterKey.bytes);
    },
  );

  test(
    'chat keys can be sealed and opened when HMAC rejects empty keys',
    () async {
      final cipher = ChatCipher();
      final recipient = await X25519().newKeyPair();
      final chatKey = cipher.newChatKey();

      final sealed = await cipher.seal(
        chatKey,
        recipientPublicKey: (await recipient.extractPublicKey()).bytes,
        recipientKeyVersion: 1,
        chatId: 'a_b',
        keyGeneration: 1,
        recipientId: 'b',
      );
      final opened = await cipher.open(
        sealed,
        recipientKeyPair: recipient,
        chatId: 'a_b',
        keyGeneration: 1,
        recipientId: 'b',
      );

      expect(opened.bytes, chatKey.bytes);
    },
  );

  test('a salt of 32 zero bytes derives the same key as no salt', () async {
    // RFC 5869 section 2.2: no salt means HashLen zeros. Spelling it out keeps
    // the derived keys exactly what they would have been.
    Cryptography.instance = original;
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final secretKey = SecretKeyData(List.generate(20, (i) => i));
    final info = [9, 8, 7];

    final unsalted = await hkdf.deriveKey(secretKey: secretKey, info: info);
    final zeroSalted = await hkdf.deriveKey(
      secretKey: secretKey,
      nonce: List.filled(32, 0),
      info: info,
    );

    expect(await zeroSalted.extractBytes(), await unsalted.extractBytes());
  });
}
