import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/attachment_store.dart';
import 'package:routes_chat/infrastructure/chats/messages/image_tools.dart';
import 'package:routes_chat/infrastructure/chats/messages/media_repository.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

/// Re-encodes by making bytes of a chosen length, and records what it did.
class _FakeImages implements ImageTools {
  final calls = <(int side, int quality)>[];
  var photoBytes = 5000;
  var thumbnailBytes = 800;
  var size = (1536, 2048);
  var notAnImage = false;
  var noPreview = false;

  @override
  Future<Uint8List> toJpeg(
    Uint8List image, {
    required int side,
    required int quality,
  }) async {
    calls.add((side, quality));
    if (side == MediaLimits.thumbnailSide) {
      if (noPreview) throw Exception('no preview');
      return Uint8List(thumbnailBytes);
    }
    if (notAnImage) throw Exception('not an image');
    return Uint8List(photoBytes);
  }

  @override
  Future<(int, int)> sizeOf(Uint8List image) async => size;
}

/// Serves one decrypted file, and counts downloads.
class _FakeStore implements AttachmentStore {
  var downloads = 0;
  Object? failure;
  Completer<void>? gate;

  @override
  Future<Uint8List> download(
    String chatId,
    MessageAttachment attachment,
  ) async {
    downloads++;
    await gate?.future;
    if (failure case final failure?) throw failure;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _gif = Uint8List.fromList([
  ...'GIF89a'.codeUnits,
  ...List.filled(100, 0),
]);
final _jpeg = Uint8List.fromList([0xff, 0xd8, 0xff, ...List.filled(100, 0)]);

MessageAttachment _attachment(String id) => MessageAttachment(
  id: UniqueId.fromUniqueString(id),
  kind: AttachmentKind.photo,
  width: 10,
  height: 10,
  byteSize: 3,
  key: Uint8List(32),
);

void main() {
  late _FakeImages images;
  late _FakeStore store;
  late Map<String, Uint8List> files;
  late MediaRepository media;

  setUp(() {
    images = _FakeImages();
    store = _FakeStore();
    files = {'photo.jpg': _jpeg, 'animation.gif': _gif};
    media = MediaRepository(
      store,
      images,
      readFile: (path) async => files[path] ?? (throw Exception('no file')),
    );
  });

  group('preparing', () {
    test('a photo is re-encoded, measured and given a preview', () async {
      final draft = (await media.prepare(
        'photo.jpg',
      )).getOrElse(() => throw StateError('not prepared'));

      expect(draft.kind, AttachmentKind.photo);
      expect(draft.bytes, hasLength(5000));
      expect((draft.width, draft.height), (1536, 2048));
      expect(draft.thumbnail, hasLength(800));
      expect(images.calls, [
        (MediaLimits.photoSide, MediaLimits.photoQuality),
        (MediaLimits.thumbnailSide, MediaLimits.thumbnailQuality),
      ]);
    });

    test('a GIF is sent as it is, so it keeps its animation', () async {
      final draft = (await media.prepare(
        'animation.gif',
      )).getOrElse(() => throw StateError('not prepared'));

      expect(draft.kind, AttachmentKind.gif);
      expect(draft.bytes, _gif);
      expect(images.calls, [
        (MediaLimits.thumbnailSide, MediaLimits.thumbnailQuality),
      ]);
    });

    test('a GIF over the limit is refused', () async {
      files['big.gif'] = Uint8List.fromList([
        ..._gif,
        ...Uint8List(MediaLimits.maxGifBytes),
      ]);

      expect(
        await media.prepare('big.gif'),
        isA<dynamic>().having(
          (result) => result.fold((failure) => failure, (_) => null),
          'failure',
          const MediaTooLarge(MediaLimits.maxGifBytes),
        ),
      );
    });

    test('a photo still too big once re-encoded is refused', () async {
      images.photoBytes = MediaLimits.maxPhotoBytes + 1;

      final failure = (await media.prepare(
        'photo.jpg',
      )).fold((failure) => failure, (_) => null);

      expect(failure, const MediaTooLarge(MediaLimits.maxPhotoBytes));
    });

    test('a file that is not an image is refused', () async {
      images.notAnImage = true;

      final failure = (await media.prepare(
        'photo.jpg',
      )).fold((failure) => failure, (_) => null);

      expect(failure, const UnsupportedMedia());
    });

    test('a file that cannot be read is refused', () async {
      final failure = (await media.prepare(
        'gone.jpg',
      )).fold((failure) => failure, (_) => null);

      expect(failure, const UnsupportedMedia());
    });

    test('a photo without a usable preview is still sent', () async {
      images.noPreview = true;
      final withoutPreview = (await media.prepare(
        'photo.jpg',
      )).getOrElse(() => throw StateError('not prepared'));
      images
        ..noPreview = false
        ..thumbnailBytes = MediaLimits.maxThumbnailBytes + 1;
      final previewTooBig = (await media.prepare(
        'photo.jpg',
      )).getOrElse(() => throw StateError('not prepared'));

      expect(withoutPreview.thumbnail, isNull);
      expect(previewTooBig.thumbnail, isNull);
    });

    test('every photo gets its own id', () async {
      final first = await media.prepare('photo.jpg');
      final second = await media.prepare('photo.jpg');

      expect(first, isNot(second));
    });
  });

  group('loading', () {
    final chatId = UniqueId.fromUniqueString('alice_bob');

    test('a photo is downloaded once, then kept', () async {
      await media.load(chatId, _attachment('file-1'));
      final again = await media.load(chatId, _attachment('file-1'));

      expect(store.downloads, 1);
      expect(again.isRight(), isTrue);
    });

    test('photos shown at the same time download once', () async {
      store.gate = Completer<void>();

      final first = media.load(chatId, _attachment('file-1'));
      final second = media.load(chatId, _attachment('file-1'));
      store.gate!.complete();
      await Future.wait([first, second]);

      expect(store.downloads, 1);
    });

    test('a photo that does not decrypt is unreadable', () async {
      store.failure = const UnreadableCiphertext();

      final failure = (await media.load(
        chatId,
        _attachment('file-1'),
      )).fold((failure) => failure, (_) => null);

      expect(failure, const MediaUnreadable());
    });

    test('a photo that could not be downloaded is tried again', () async {
      store.failure = Exception('offline');
      final failed = await media.load(chatId, _attachment('file-1'));
      store.failure = null;
      final retried = await media.load(chatId, _attachment('file-1'));

      expect(
        failed.fold((failure) => failure, (_) => null),
        const MediaUnavailable(),
      );
      expect(retried.isRight(), isTrue);
      expect(store.downloads, 2);
    });
  });
}
