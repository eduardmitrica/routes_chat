import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
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

  group('in a group', () {
    const groupId = 'group-00000000-0000-4000-8000-000000000000';
    // The block up to its closing brace, which the name patterns' braces
    // would end early for a regular expression.
    final flat = rules.replaceAll('\r\n', '\n');
    final start = flat.indexOf('match /group_media/{groupId}/{fileName} {');
    final groupMedia = start < 0
        ? null
        : (group: flat.substring(start, flat.indexOf('\n    }\n', start)));
    const uuidV4 =
        "'[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}'";

    test('files are stored apart from chats, where the rules protect them', () {
      expect(groupMedia, isNotNull);
      expect(
        AttachmentStore.pathOf(groupId, 'file-1'),
        'group_media/$groupId/file-1',
      );
    });

    test('a file is fetched only by its exact random name, never listed', () {
      final block = groupMedia!.group;
      expect(block, contains('allow get:'));
      expect(block, isNot(contains('allow read')));
      expect(block, isNot(contains('list')));
      // Once to fetch, once to add.
      expect(
        RegExp(RegExp.escape('fileName.matches($uuidV4)')).allMatches(block),
        hasLength(2),
      );
    });

    test('photos are named with random ids, which the rules require', () {
      final id = UniqueId.random().getOrCrash();
      expect(
        RegExp(
          '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\$',
        ).hasMatch(id),
        isTrue,
      );
      final media = File(
        'lib/infrastructure/chats/messages/media_repository.dart',
      ).readAsStringSync();
      expect(media, isNot(contains('id: UniqueId(),')));
      expect(
        RegExp(r'id: UniqueId\.random\(\),').allMatches(media),
        hasLength(2),
      );
    });

    test('files hold the same limits, and only the uploader deletes', () {
      final block = groupMedia!.group;
      expect(
        block,
        contains('request.resource.size <= ${MediaLimits.maxStoredBytes}'),
      );
      expect(
        block,
        contains("request.resource.contentType == 'application/octet-stream'"),
      );
      expect(
        block,
        contains('request.resource.metadata.uploader == request.auth.uid'),
      );
      expect(
        block,
        contains(
          'allow delete: if request.auth != null &&\n'
          '        resource.metadata.uploader == request.auth.uid;',
        ),
      );
      expect(block, isNot(contains('update')));
      expect(block, isNot(contains('write')));
    });
  });
}
