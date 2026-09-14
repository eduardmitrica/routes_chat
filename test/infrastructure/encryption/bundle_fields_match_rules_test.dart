import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/key_bundle.dart';

WrappedKey _wrapped() => WrappedKey(
  nonce: Uint8List(12),
  cipherText: Uint8List(32),
  mac: Uint8List(16),
);

Set<String> _storedFields() {
  final bundle = KeyBundle(
    version: KeyBundle.currentVersion,
    keyVersion: 1,
    kdf: PassphraseKdf(
      memoryKiB: 65536,
      iterations: 3,
      parallelism: 1,
      salt: Uint8List(16),
    ),
    masterKeyByPassphrase: _wrapped(),
    masterKeyByRecoveryKey: _wrapped(),
    privateKey: _wrapped(),
    publicKey: Uint8List(32),
  );
  return (jsonDecode(jsonEncode(bundle.toJson())) as Map<String, dynamic>).keys
      .toSet();
}

Set<String> _fieldsAllowedByRules() {
  final rules = File('firestore.rules').readAsStringSync();
  final function = RegExp(
    r'function encryptionBundleFields\(\)\s*\{\s*return\s*\[([^\]]*)\]',
  ).firstMatch(rules);
  expect(function, isNotNull, reason: 'encryptionBundleFields() not found');
  return RegExp(
    r"'([^']+)'",
  ).allMatches(function!.group(1)!).map((match) => match.group(1)!).toSet();
}

void main() {
  test(
    'the stored key bundle fields are exactly what firestore.rules allows',
    () {
      // The rules use keys().hasOnly(encryptionBundleFields()). A field added to
      // KeyBundle but not to the rules would make every encryption setup fail in
      // production while the app still compiles.
      expect(_storedFields(), _fieldsAllowedByRules());
    },
  );

  test('the published public key has the length the rules require', () {
    // userKeys/{uid}.publicKey must be exactly 44 characters: base64 of the
    // 32-byte X25519 public key, with padding.
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('request.resource.data.publicKey.size() == 44'));
    expect(base64Encode(Uint8List(32)), hasLength(44));
  });

  test('replacing keys needs a recent sign-in, for both key documents', () {
    // Otherwise a device someone left signed in could reset the keys, and
    // receive every message sent after.
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('request.auth.token.auth_time * 1000'));
    expect(
      'signedInRecently()'.allMatches(rules),
      hasLength(3),
      reason: 'defined once, then required by the bundle and userKeys updates',
    );
  });
}
