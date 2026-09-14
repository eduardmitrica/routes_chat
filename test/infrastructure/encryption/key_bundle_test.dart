import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/key_bundle.dart';

Uint8List _bytes(int length, int seed) => Uint8List.fromList(
  List<int>.generate(length, (i) => (i * 31 + seed) & 0xff),
);

WrappedKey _wrapped(int seed) => WrappedKey(
  nonce: _bytes(12, seed),
  cipherText: _bytes(32, seed + 1),
  mac: _bytes(16, seed + 2),
);

KeyBundle _bundle() => KeyBundle(
  version: KeyBundle.currentVersion,
  kdf: PassphraseKdf(
    memoryKiB: 65536,
    iterations: 3,
    parallelism: 1,
    salt: _bytes(16, 7),
  ),
  masterKeyByPassphrase: _wrapped(10),
  masterKeyByRecoveryKey: _wrapped(20),
  privateKey: _wrapped(30),
  publicKey: _bytes(32, 40),
);

/// What Firestore hands back: plain maps and strings, not the original objects.
Map<String, dynamic> _throughFirestore(KeyBundle bundle) =>
    jsonDecode(jsonEncode(bundle.toJson())) as Map<String, dynamic>;

void main() {
  test('survives a round trip through its stored form', () {
    final bundle = _bundle();

    expect(KeyBundle.fromJson(_throughFirestore(bundle)), bundle);
  });

  test('stores only base64 strings and numbers, never raw bytes', () {
    final stored = jsonEncode(_bundle().toJson());

    expect(() => jsonDecode(stored), returnsNormally);
    expect(_throughFirestore(_bundle())['publicKey'], isA<String>());
    expect((_throughFirestore(_bundle())['kdf'] as Map)['memoryKiB'], 65536);
  });

  test('stores exactly the fields the security rules will allow', () {
    expect(_throughFirestore(_bundle()).keys.toSet(), {
      'version',
      'kdf',
      'masterKeyByPassphrase',
      'masterKeyByRecoveryKey',
      'privateKey',
      'publicKey',
    });
  });

  test('refuses a bundle version it does not understand', () {
    final stored = _throughFirestore(_bundle())..['version'] = 2;

    expect(() => KeyBundle.fromJson(stored), throwsFormatException);
  });

  test('refuses a KDF it does not implement', () {
    final stored = _throughFirestore(_bundle());
    (stored['kdf'] as Map<String, dynamic>)['algorithm'] = 'pbkdf2';

    expect(() => KeyBundle.fromJson(stored), throwsFormatException);
  });

  test('copyWith replaces only the passphrase-related parts', () {
    final bundle = _bundle();
    final changed = bundle.copyWith(
      masterKeyByPassphrase: _wrapped(50),
      masterKeyByRecoveryKey: _wrapped(60),
    );

    expect(changed.masterKeyByPassphrase, _wrapped(50));
    expect(changed.masterKeyByRecoveryKey, _wrapped(60));
    expect(changed.privateKey, bundle.privateKey);
    expect(changed.publicKey, bundle.publicKey);
    expect(changed.kdf, bundle.kdf);
    expect(changed, isNot(bundle));
  });
}
