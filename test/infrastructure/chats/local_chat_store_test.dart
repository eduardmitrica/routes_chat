import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/local_chat_store.dart';
import 'package:routes_chat/infrastructure/core/local_vault.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

import '../../helpers/outbox_fakes.dart';

class _MemorySecrets implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

final _photoBytes = Uint8List.fromList(
  utf8.encode('pretend these are the bytes of a photo'),
);

MediaDraft _photo(String id) => MediaDraft(
  id: UniqueId.fromUniqueString(id),
  kind: AttachmentKind.photo,
  bytes: _photoBytes,
  width: 4,
  height: 3,
  thumbnail: Uint8List.fromList([9, 8, 7]),
);

bool _contains(List<int> haystack, List<int> needle) {
  outer:
  for (var start = 0; start + needle.length <= haystack.length; start++) {
    for (var offset = 0; offset < needle.length; offset++) {
      if (haystack[start + offset] != needle[offset]) continue outer;
    }
    return true;
  }
  return false;
}

void main() {
  late Directory base;
  late _MemorySecrets secrets;
  late CurrentUserSession session;
  late LocalChatStore store;
  final chatId = UniqueId.fromUniqueString(aliceAndBob);
  final quote = MessageQuote(
    messageId: UniqueId.fromUniqueString('message-1'),
    senderId: UniqueId.fromUniqueString('uid-bob'),
    text: 'Unde ești?',
    thumbnail: Uint8List.fromList([1, 2]),
  );

  setUp(() {
    base = Directory.systemTemp.createTempSync('local_chat_store_test');
    secrets = _MemorySecrets();
    session = signedInAlice();
    store = LocalChatStore(
      LocalVault(secrets, session, baseDirectory: () async => base),
    );
  });

  tearDown(() {
    if (base.existsSync()) base.deleteSync(recursive: true);
  });

  List<File> files() => [...base.listSync(recursive: true).whereType<File>()];

  List<String> names(String prefix) => [
    for (final file in files())
      if (file.uri.pathSegments.last.startsWith(prefix))
        file.uri.pathSegments.last,
  ];

  File fileNamed(String name) =>
      files().singleWhere((file) => file.uri.pathSegments.last == name);

  group('drafts', () {
    test('a draft comes back with its text, reply and photos', () async {
      await store.saveDraft(
        chatId,
        ChatDraft(text: 'Aici', replyTo: quote, media: KtList.of(_photo('a'))),
      );

      final draft = await store.loadDraft(chatId);

      expect(draft?.text, 'Aici');
      expect(draft?.replyTo, quote);
      final photo = draft!.media.single();
      expect(photo.id.getOrCrash(), 'a');
      expect(photo.bytes, _photoBytes);
      expect((photo.width, photo.height), (4, 3));
      expect(photo.thumbnail, [9, 8, 7]);
    });

    test('an empty draft is removed, with its photos', () async {
      await store.saveDraft(
        chatId,
        ChatDraft(text: 'Aici', media: KtList.of(_photo('a'))),
      );

      await store.saveDraft(chatId, const ChatDraft());

      expect(await store.loadDraft(chatId), isNull);
      expect(names('draft_'), isEmpty);
      expect(names('media_'), isEmpty);
    });

    test('a photo taken out of a draft is deleted', () async {
      await store.saveDraft(
        chatId,
        ChatDraft(media: KtList.of(_photo('a'), _photo('b'))),
      );

      await store.saveDraft(chatId, ChatDraft(media: KtList.of(_photo('b'))));

      expect(names('media_'), ['media_b']);
    });

    test('each chat keeps its own draft', () async {
      final other = UniqueId.fromUniqueString('uid-alice_uid-carol');

      await store.saveDraft(chatId, const ChatDraft(text: 'Bob'));
      await store.saveDraft(other, const ChatDraft(text: 'Carol'));

      expect((await store.loadDraft(chatId))?.text, 'Bob');
      expect((await store.loadDraft(other))?.text, 'Carol');
    });
  });

  group('messages on their way', () {
    test('a message comes back as it was kept, keys included', () async {
      final key = Uint8List.fromList(List.generate(32, (index) => index));
      final photo = _photo('a');
      final queued = outgoingMessage(
        'm1',
        media: [photo],
        startsChatWith: ['uid-bob'],
      );
      final entry = OutgoingMessage(
        message: queued.message.copyWith(replyTo: quote),
        chatId: queued.chatId,
        startsChatWith: queued.startsChatWith,
        media: queued.media,
        attachments: {
          'a': MessageAttachment(
            id: photo.id,
            kind: photo.kind,
            width: 4,
            height: 3,
            byteSize: _photoBytes.length,
            key: key,
            thumbnail: photo.thumbnail,
          ),
        },
        status: OutgoingStatus.waiting,
        failures: 2,
        queuedAt: queued.queuedAt,
      );

      await store.keep(entry);
      final back = (await store.queued()).single();

      expect(back, entry);
      expect(back.media.single().bytes, _photoBytes);
      expect(back.attachments['a']!.key, key);
    });

    test('messages come back in the order they were sent', () async {
      final first = outgoingMessage('m1');
      final second = outgoingMessage('m2');

      await store.keep(second);
      await store.keep(first);

      expect(
        (await store.queued())
            .map((message) => message.id.getOrCrash())
            .asList(),
        ['m1', 'm2'],
      );
    });

    test(
      'a photo a draft and its message share stays while either needs it',
      () async {
        await store.saveDraft(
          chatId,
          ChatDraft(text: 'Aici', media: KtList.of(_photo('a'))),
        );
        await store.keep(outgoingMessage('m1', media: [_photo('a')]));

        await store.saveDraft(chatId, const ChatDraft());
        expect(names('media_'), ['media_a']);

        await store.forget(UniqueId.fromUniqueString('m1'));
        expect(names('media_'), isEmpty);
        expect((await store.queued()).isEmpty(), isTrue);
      },
    );

    test('files still to delete are remembered once each', () async {
      final a = (chatId, UniqueId.fromUniqueString('a'));
      final b = (chatId, UniqueId.fromUniqueString('b'));

      await store.addFilesToDelete([a, b]);
      await store.addFilesToDelete([a]);
      expect(await store.filesToDelete(), [a, b]);

      await store.removeFileToDelete(a.$1, a.$2);
      expect(await store.filesToDelete(), [b]);
    });
  });

  group('on the phone', () {
    test('nothing readable is written', () async {
      await store.saveDraft(
        chatId,
        ChatDraft(
          text: 'Parola e sub preș',
          replyTo: quote,
          media: KtList.of(_photo('a')),
        ),
      );
      await store.keep(
        outgoingMessage('m1', text: 'Parola e sub preș', media: [_photo('b')]),
      );

      expect(files(), isNotEmpty);
      for (final file in files()) {
        final stored = file.readAsBytesSync();
        for (final secret in [
          utf8.encode('Parola e sub preș'),
          utf8.encode('Unde ești?'),
          _photoBytes,
        ]) {
          expect(_contains(stored, secret), isFalse, reason: file.path);
        }
      }
    });

    test('a file changed on the phone is left out', () async {
      await store.keep(outgoingMessage('m1'));
      final file = fileNamed('outbox_m1');
      final stored = file.readAsBytesSync();
      stored[stored.length - 1] ^= 1;
      file.writeAsBytesSync(stored);

      expect((await store.queued()).isEmpty(), isTrue);
    });

    test('one file cannot pass for another', () async {
      await store.saveDraft(chatId, const ChatDraft(text: 'Aici'));
      final other = UniqueId.fromUniqueString('uid-alice_uid-carol');
      final file = fileNamed('draft_$aliceAndBob');

      file.copySync('${file.parent.path}/draft_${other.getOrCrash()}');

      expect(await store.loadDraft(other), isNull);
    });

    test('signing out deletes every file kept, and their key', () async {
      await store.saveDraft(
        chatId,
        ChatDraft(text: 'Aici', media: KtList.of(_photo('a'))),
      );
      expect(secrets.values, isNotEmpty);

      session.end();
      for (
        var tries = 0;
        tries < 100 && (files().isNotEmpty || secrets.values.isNotEmpty);
        tries++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      expect(files(), isEmpty);
      expect(secrets.values, isEmpty);
    });

    test('nothing is kept while nobody is signed in', () async {
      session.end();

      await expectLater(
        store.saveDraft(chatId, const ChatDraft(text: 'Aici')),
        throwsStateError,
      );
    });
  });
}
