import 'package:dartz/dartz.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/attachment_store.dart';
import 'package:routes_chat/infrastructure/chats/messages/image_tools.dart';
import 'package:routes_chat/infrastructure/chats/messages/media_repository.dart';
import 'package:routes_chat/infrastructure/chats/messages/photo_library.dart';
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

/// The phone's photos, with permission as set, recording what was added.
class _FakePhotos implements PhotoLibrary {
  var access = true;
  var grantedWhenAsked = true;
  var requests = 0;
  Object? failure;
  final saved = <({Uint8List image, String name, bool gif})>[];

  @override
  Future<bool> hasAccess() async => access;

  @override
  Future<bool> requestAccess() async {
    requests++;
    return access = grantedWhenAsked;
  }

  @override
  Future<void> save(
    Uint8List image, {
    required String name,
    required bool gif,
  }) async {
    if (failure case final failure?) throw failure;
    saved.add((image: image, name: name, gif: gif));
  }
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
  late _FakePhotos photos;
  late Map<String, Uint8List> files;
  late MediaRepository media;

  setUp(() {
    images = _FakeImages();
    store = _FakeStore();
    photos = _FakePhotos();
    files = {'photo.jpg': _jpeg, 'animation.gif': _gif};
    media = MediaRepository(
      store,
      images,
      photos,
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

    test('a photo just sent shows without being downloaded', () async {
      media.remember(
        chatId,
        UniqueId.fromUniqueString('file-9'),
        Uint8List.fromList([7]),
      );

      final shown = await media.load(chatId, _attachment('file-9'));

      expect(store.downloads, 0);
      expect(shown.getOrElse(() => Uint8List(0)), [7]);
    });

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

  group('saving to the phone', () {
    final chatId = UniqueId.fromUniqueString('alice_bob');

    MediaFailure? failureOf(Either<MediaFailure, Unit> result) =>
        result.fold((failure) => failure, (_) => null);

    test('a photo is added as it was sent', () async {
      final result = await media.saveToPhotos(chatId, _attachment('file-1'));

      expect(result.isRight(), isTrue);
      final saved = photos.saved.single;
      expect(saved.image, [1, 2, 3]);
      expect(saved.name, 'routes_chat_file-1');
      expect(saved.gif, isFalse);
      expect(photos.requests, 0);
    });

    test('a GIF is added as a GIF, so it keeps its animation', () async {
      await media.saveToPhotos(
        chatId,
        MessageAttachment(
          id: UniqueId.fromUniqueString('file-2'),
          kind: AttachmentKind.gif,
          width: 10,
          height: 10,
          byteSize: 3,
          key: Uint8List(32),
        ),
      );

      expect(photos.saved.single.gif, isTrue);
    });

    test('permission is asked for first when the app has none', () async {
      photos.access = false;

      final result = await media.saveToPhotos(chatId, _attachment('file-1'));

      expect(result.isRight(), isTrue);
      expect(photos.requests, 1);
      expect(photos.saved, hasLength(1));
    });

    test('nothing is added without permission', () async {
      photos
        ..access = false
        ..grantedWhenAsked = false;

      final result = await media.saveToPhotos(chatId, _attachment('file-1'));

      expect(failureOf(result), const PhotoAccessDenied());
      expect(photos.saved, isEmpty);
    });

    test('a photo that cannot be downloaded is not added', () async {
      store.failure = Exception('offline');

      final result = await media.saveToPhotos(chatId, _attachment('file-1'));

      expect(failureOf(result), const MediaUnavailable());
      expect(photos.saved, isEmpty);
    });

    test('a photo the phone does not take is reported', () async {
      photos.failure = Exception('disk full');
      final notSaved = await media.saveToPhotos(chatId, _attachment('file-1'));
      photos.failure = const PhotoAccessException();
      final denied = await media.saveToPhotos(chatId, _attachment('file-1'));

      expect(failureOf(notSaved), const MediaNotSaved());
      expect(failureOf(denied), const PhotoAccessDenied());
    });
  });
}
