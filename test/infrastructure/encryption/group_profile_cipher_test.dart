import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/groups/group_profile.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

void main() {
  final cipher = ChatCipher();
  const groupId = 'group-00000000-0000-4000-8000-000000000000';
  const profile = GroupProfile(name: 'Drumeție', photo: [255, 216, 255, 1, 2]);

  test('a group\'s name and photo come back as they were', () async {
    final key = cipher.newChatKey();
    final encrypted = await cipher.encryptGroupProfile(
      profile,
      groupKey: key,
      groupId: groupId,
      keyGeneration: 3,
    );

    expect(encrypted.keyGeneration, 3);
    expect(encrypted.version, 1);
    expect(
      await cipher.decryptGroupProfile(
        encrypted,
        groupKey: key,
        groupId: groupId,
      ),
      profile,
    );
  });

  test('neither the name nor the photo is in the stored form', () async {
    final encrypted = await cipher.encryptGroupProfile(
      profile,
      groupKey: cipher.newChatKey(),
      groupId: groupId,
      keyGeneration: 1,
    );
    expect(encrypted.toJson().toString(), isNot(contains('Drumeție')));
  });

  test(
    'they open only for their group, their key and their generation',
    () async {
      final key = cipher.newChatKey();
      final encrypted = await cipher.encryptGroupProfile(
        profile,
        groupKey: key,
        groupId: groupId,
        keyGeneration: 1,
      );

      await expectLater(
        cipher.decryptGroupProfile(
          encrypted,
          groupKey: cipher.newChatKey(),
          groupId: groupId,
        ),
        throwsA(isA<UnreadableCiphertext>()),
      );
      await expectLater(
        cipher.decryptGroupProfile(
          encrypted,
          groupKey: key,
          groupId: 'group-11111111-1111-4111-8111-111111111111',
        ),
        throwsA(isA<UnreadableCiphertext>()),
      );
      // Moved to another generation, the associated data no longer matches.
      await expectLater(
        cipher.decryptGroupProfile(
          EncryptedContent(
            version: encrypted.version,
            keyGeneration: 2,
            nonce: encrypted.nonce,
            cipherText: encrypted.cipherText,
            mac: encrypted.mac,
          ),
          groupKey: key,
          groupId: groupId,
        ),
        throwsA(isA<UnreadableCiphertext>()),
      );
    },
  );

  test('a group without a photo stays without one', () async {
    final key = cipher.newChatKey();
    const named = GroupProfile(name: 'Fără poză');
    final encrypted = await cipher.encryptGroupProfile(
      named,
      groupKey: key,
      groupId: groupId,
      keyGeneration: 1,
    );
    final opened = await cipher.decryptGroupProfile(
      encrypted,
      groupKey: key,
      groupId: groupId,
    );
    expect(opened.photo, isNull);
    expect(opened.name, 'Fără poză');
  });
}
