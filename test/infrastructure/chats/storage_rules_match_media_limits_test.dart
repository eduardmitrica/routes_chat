import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/infrastructure/chats/messages/attachment_store.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

void main() {
  // The app and storage.rules must agree on where chat files live and how big
  // they may be. If they drift, sending a photo fails in production with a
  // permission error while every other test passes.
  final rules = File('storage.rules').readAsStringSync();
  final chatMedia = RegExp(
    r'match /chat_media/\{chatId\}/\{fileName\} \{([^}]*)\}',
  ).firstMatch(rules);

  test('chat files are stored where the rules protect them', () {
    expect(chatMedia, isNotNull);
    expect(AttachmentStore.pathOf('a_b', 'file-1'), 'chat_media/a_b/file-1');
  });

  test('only the two people of a chat can read or add its files', () {
    final block = chatMedia!.group(1)!;

    expect(block, contains("request.auth.uid in chatId.split('_')"));
    expect(
      RegExp(r"request\.auth\.uid in chatId\.split\('_'\)").allMatches(block),
      hasLength(3),
    );
  });

  test('a stored file is never replaced, and only its uploader deletes it', () {
    final block = chatMedia!.group(1)!;

    expect(block, isNot(contains('write')));
    expect(block, isNot(contains('update')));
    expect(
      block,
      contains('request.resource.metadata.uploader == request.auth.uid'),
    );
    expect(
      RegExp(
        r'allow delete: if [^;]*resource\.metadata\.uploader == request\.auth\.uid',
      ).hasMatch(block),
      isTrue,
    );
  });

  test('the app names the uploader the rules check', () {
    final store = File(
      'lib/infrastructure/chats/messages/attachment_store.dart',
    ).readAsStringSync();

    expect(store, contains("customMetadata: {'uploader': uploader}"));
  });

  test('the size limit is the largest file the app sends, encrypted', () {
    expect(
      MediaLimits.maxStoredBytes,
      MediaLimits.maxGifBytes + ChatCipher.fileOverheadBytes,
    );
    expect(
      MediaLimits.maxPhotoBytes,
      lessThanOrEqualTo(MediaLimits.maxGifBytes),
    );
    expect(
      chatMedia!.group(1),
      contains('request.resource.size <= ${MediaLimits.maxStoredBytes}'),
    );
  });

  test('stored files are opaque bytes', () {
    expect(
      chatMedia!.group(1),
      contains("request.resource.contentType == 'application/octet-stream'"),
    );
  });
}
