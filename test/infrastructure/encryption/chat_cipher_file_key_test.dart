import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

const _chatId = 'alice_bob';

void main() {
  // The outbox makes a file's key and keeps it on the phone before the file is
  // uploaded, so a repeated upload uses the key its message records.
  final cipher = ChatCipher();
  final photo = Uint8List.fromList(utf8.encode('GIF89a pretend this is a GIF'));

  test('a file encrypted under a key made earlier decrypts with it', () async {
    final key = cipher.newFileKey();

    final file = await cipher.encryptFile(
      photo,
      chatId: _chatId,
      fileId: 'file-1',
      key: key,
    );

    expect(file.key, key);
    expect(
      await cipher.decryptFile(
        file.stored,
        key: key,
        chatId: _chatId,
        fileId: 'file-1',
      ),
      photo,
    );
  });

  test('encrypting again under the same key stores a new nonce', () async {
    final key = cipher.newFileKey();

    final first = await cipher.encryptFile(
      photo,
      chatId: _chatId,
      fileId: 'file-1',
      key: key,
    );
    final second = await cipher.encryptFile(
      photo,
      chatId: _chatId,
      fileId: 'file-1',
      key: key,
    );

    expect(first.stored.sublist(0, 12), isNot(second.stored.sublist(0, 12)));
  });

  test('each new key is new, and as long as a chat key', () {
    final first = cipher.newFileKey();
    final second = cipher.newFileKey();

    expect(first, hasLength(ChatCipher.chatKeyLength));
    expect(first, isNot(second));
  });

  test('a key of the wrong length is refused', () async {
    await expectLater(
      cipher.encryptFile(
        photo,
        chatId: _chatId,
        fileId: 'file-1',
        key: Uint8List(16),
      ),
      throwsArgumentError,
    );
  });
}
