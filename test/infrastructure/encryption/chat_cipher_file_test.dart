import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

const _chatId = 'alice_bob';

void main() {
  final cipher = ChatCipher();
  final photo = Uint8List.fromList(utf8.encode('GIF89a pretend this is a GIF'));

  Future<Uint8List> decrypt(
    EncryptedFile file, {
    List<int>? stored,
    List<int>? key,
    String chatId = _chatId,
    String fileId = 'file-1',
  }) => cipher.decryptFile(
    stored ?? file.stored,
    key: key ?? file.key,
    chatId: chatId,
    fileId: fileId,
  );

  group('encrypting a photo', () {
    test('the photo comes back', () async {
      final file = await cipher.encryptFile(
        photo,
        chatId: _chatId,
        fileId: 'file-1',
      );

      expect(await decrypt(file), photo);
    });

    test('what is stored is the nonce, the ciphertext and the tag', () async {
      final file = await cipher.encryptFile(
        photo,
        chatId: _chatId,
        fileId: 'file-1',
      );

      expect(
        file.stored,
        hasLength(photo.length + ChatCipher.fileOverheadBytes),
      );
      expect(file.key, hasLength(ChatCipher.chatKeyLength));
      expect(
        utf8.decode(file.stored, allowMalformed: true),
        isNot(contains('GIF89a')),
      );
    });

    test('every photo gets a key of its own', () async {
      final first = await cipher.encryptFile(
        photo,
        chatId: _chatId,
        fileId: 'a',
      );
      final second = await cipher.encryptFile(
        photo,
        chatId: _chatId,
        fileId: 'a',
      );

      expect(first.key, isNot(second.key));
      expect(first.stored, isNot(second.stored));
    });

    test('it decrypts only with its key, for its chat and file', () async {
      final file = await cipher.encryptFile(
        photo,
        chatId: _chatId,
        fileId: 'file-1',
      );

      for (final wrong in [
        () => decrypt(file, chatId: 'alice_carol'),
        () => decrypt(file, fileId: 'file-2'),
        () => decrypt(file, key: Uint8List(32)),
        () => decrypt(file, key: Uint8List(16)),
      ]) {
        await expectLater(wrong(), throwsA(isA<UnreadableCiphertext>()));
      }
    });

    test('an altered or cut short file is rejected', () async {
      final file = await cipher.encryptFile(
        photo,
        chatId: _chatId,
        fileId: 'file-1',
      );

      await expectLater(
        decrypt(file, stored: Uint8List.fromList(file.stored)..[14] ^= 1),
        throwsA(isA<UnreadableCiphertext>()),
      );
      await expectLater(
        decrypt(file, stored: file.stored.sublist(0, file.stored.length - 1)),
        throwsA(isA<UnreadableCiphertext>()),
      );
      await expectLater(
        decrypt(file, stored: file.stored.sublist(0, 20)),
        throwsA(isA<UnreadableCiphertext>()),
      );
    });

    test('its key never shows in logs', () async {
      final file = await cipher.encryptFile(
        photo,
        chatId: _chatId,
        fileId: 'file-1',
      );

      expect(file.toString(), isNot(contains(base64Encode(file.key))));
    });
  });

  group('photos in a message', () {
    final attached = AttachedFile(
      id: 'file-1',
      kind: 'photo',
      width: 1536,
      height: 2048,
      size: 412345,
      key: Uint8List.fromList(List.generate(32, (index) => index)),
      thumbnail: Uint8List.fromList([0xff, 0xd8, 1, 2, 3]),
    );

    test('a message with photos and a caption comes back', () async {
      final chatKey = cipher.newChatKey();
      final payload = MessagePayload(
        'La mare 🌊',
        attachments: [
          attached,
          AttachedFile(
            id: 'file-2',
            kind: 'gif',
            width: 320,
            height: 240,
            size: 900000,
            key: Uint8List(32),
          ),
        ],
      );

      final content = await cipher.encrypt(
        payload,
        chatKey: chatKey,
        chatId: _chatId,
        keyGeneration: 1,
        messageId: 'message-1',
        senderId: 'alice',
      );

      expect(
        await cipher.decrypt(
          content,
          chatKey: chatKey,
          chatId: _chatId,
          messageId: 'message-1',
          senderId: 'alice',
        ),
        payload,
      );
    });

    test('a reply to a photo keeps its preview', () {
      final payload = MessagePayload(
        'Frumos!',
        replyTo: QuotedMessage(
          messageId: 'message-0',
          senderId: 'bob',
          text: 'Photo',
          thumbnail: Uint8List.fromList([1, 2, 3]),
        ),
      );

      expect(
        MessagePayload.fromJson(jsonDecode(jsonEncode(payload.toJson()))),
        payload,
      );
    });

    test('attachments that could not have been written are refused', () {
      Map<String, Object?> file([Map<String, Object?> changes = const {}]) => {
        ...attached.toJson(),
        ...changes,
      };
      for (final attachments in [
        'file-1',
        [
          file({'kind': 'video'}),
        ],
        [
          file({'key': base64Encode(Uint8List(16))}),
        ],
        [
          file({'width': '1536'}),
        ],
        [
          file({'thumb': 5}),
        ],
        ['file-1'],
      ]) {
        expect(
          () =>
              MessagePayload.fromJson({'text': '', 'attachments': attachments}),
          throwsFormatException,
          reason: '$attachments',
        );
      }
    });

    test(
      'ten photos, a quote and the longest caption fit the rules limit',
      () async {
        // The worst case: control characters, which JSON escapes as ,
        // ids as long as the app's, and every preview at its largest.
        final preview = Uint8List(MediaLimits.maxThumbnailBytes);
        final content = await cipher.encrypt(
          MessagePayload(
            '' * 1000,
            replyTo: QuotedMessage(
              messageId: 'm' * 36,
              senderId: 'u' * 28,
              text: '' * 101,
              thumbnail: preview,
            ),
            attachments: [
              for (var index = 0; index < MediaLimits.maxPerMessage; index++)
                AttachedFile(
                  id: 'f' * 36,
                  kind: 'photo',
                  width: 20480,
                  height: 20480,
                  size: MediaLimits.maxGifBytes,
                  key: Uint8List(32),
                  thumbnail: preview,
                ),
            ],
          ),
          chatKey: cipher.newChatKey(),
          chatId: _chatId,
          keyGeneration: 1,
          messageId: 'message-1',
          senderId: 'alice',
        );

        expect(
          content.toJson()['cipherText'],
          hasLength(lessThanOrEqualTo(48000)),
        );
      },
    );

    test('keys and previews never show in logs', () {
      final payload = MessagePayload('secret', attachments: [attached]);

      expect(payload.toString(), isNot(contains(base64Encode(attached.key))));
      expect(attached.toString(), isNot(contains(base64Encode(attached.key))));
    });
  });
}
