import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

import 'attachment_store.dart';
import 'image_tools.dart';
import 'photo_library.dart';

/// Photos, GIFs and voice messages: prepared on the phone before sending,
/// decrypted to show or play, and saved to the phone's photos when the user
/// asks. Decrypted files are kept in memory while the app runs. A voice
/// message is the exception: the player needs a file, so one being played is
/// written to the app's own cache, which other apps cannot read, and deleted
/// once it is no longer played or the next time the app starts.
class MediaRepository implements IMediaRepository {
  /// How much decrypted media is kept, the least recently shown dropped first.
  static const cacheBytes = 64 * 1024 * 1024;

  final AttachmentStore _store;
  final ImageTools _images;
  final PhotoLibrary _photos;
  final Future<Uint8List> Function(String path) _readFile;
  final Future<Directory> Function() _cacheDirectory;

  /// Whether files left from an earlier run have been deleted.
  var _sweptPlayables = false;

  /// Decrypted files by chat and id, the most recently shown last.
  final _cache = <String, Uint8List>{};
  var _cachedBytes = 0;

  /// Downloads in progress, which a second request for the same file joins.
  final _loading = <String, Future<Either<MediaFailure, Uint8List>>>{};

  MediaRepository(
    this._store,
    this._images,
    this._photos, {
    Future<Uint8List> Function(String path)? readFile,
    Future<Directory> Function()? cacheDirectory,
  }) : _readFile = readFile ?? ((path) => File(path).readAsBytes()),
       _cacheDirectory = cacheDirectory ?? getTemporaryDirectory;

  @override
  Future<Either<MediaFailure, MediaDraft>> prepare(String path) async {
    try {
      final file = await _readFile(path);
      if (isGif(file)) {
        if (file.length > MediaLimits.maxGifBytes) {
          return left(const MediaTooLarge(MediaLimits.maxGifBytes));
        }
        final (width, height) = await _images.sizeOf(file);
        return right(
          MediaDraft(
            // Random, since a group's files are protected by their names.
            id: UniqueId.random(),
            kind: AttachmentKind.gif,
            bytes: file,
            width: width,
            height: height,
            thumbnail: await _thumbnailOf(file),
          ),
        );
      }
      final photo = await _images.toJpeg(
        file,
        side: MediaLimits.photoSide,
        quality: MediaLimits.photoQuality,
      );
      if (photo.length > MediaLimits.maxPhotoBytes) {
        return left(const MediaTooLarge(MediaLimits.maxPhotoBytes));
      }
      final (width, height) = await _images.sizeOf(photo);
      return right(
        MediaDraft(
          id: UniqueId.random(),
          kind: AttachmentKind.photo,
          bytes: photo,
          width: width,
          height: height,
          thumbnail: await _thumbnailOf(photo),
        ),
      );
    } on Exception catch (exception) {
      // The type only: nothing about the photo belongs in the log.
      debugPrint('Media not prepared: ${exception.runtimeType}');
      return left(const UnsupportedMedia());
    }
  }

  /// A preview small enough to travel inside the message, or none.
  Future<Uint8List?> _thumbnailOf(Uint8List image) async {
    try {
      final thumbnail = await _images.toJpeg(
        image,
        side: MediaLimits.thumbnailSide,
        quality: MediaLimits.thumbnailQuality,
      );
      return thumbnail.length <= MediaLimits.maxThumbnailBytes
          ? thumbnail
          : null;
    } on Exception {
      return null;
    }
  }

  @override
  Future<Either<MediaFailure, MediaDraft>> prepareVoice(
    String path, {
    required Duration duration,
    required Uint8List waveform,
  }) async {
    try {
      if (duration < MediaLimits.minVoiceDuration) {
        return left(const VoiceTooShort());
      }
      final file = await _readFile(path);
      if (file.isEmpty) return left(const VoiceTooShort());
      if (file.length > MediaLimits.maxVoiceBytes) {
        return left(const MediaTooLarge(MediaLimits.maxVoiceBytes));
      }
      return right(
        MediaDraft(
          id: UniqueId.random(),
          kind: AttachmentKind.voice,
          bytes: file,
          width: 0,
          height: 0,
          duration: duration > MediaLimits.maxVoiceDuration
              ? MediaLimits.maxVoiceDuration
              : duration,
          waveform: waveform,
        ),
      );
    } on Exception catch (exception) {
      debugPrint('Voice message not prepared: ${exception.runtimeType}');
      return left(const UnsupportedMedia());
    } finally {
      await _deleteQuietly(path);
    }
  }

  /// Where decrypted voice messages are played from.
  Future<Directory> _playables() async {
    final directory = Directory('${(await _cacheDirectory()).path}/voice');
    if (!_sweptPlayables) {
      _sweptPlayables = true;
      if (await directory.exists()) await directory.delete(recursive: true);
    }
    return directory.create(recursive: true);
  }

  @override
  Future<Either<MediaFailure, String>> playableFile(
    UniqueId chatId,
    MessageAttachment attachment,
  ) async {
    final loaded = await load(chatId, attachment);
    return loaded.fold((failure) async => left(failure), (audio) async {
      try {
        final directory = await _playables();
        // A new name each time, so two players never share a file.
        final file = File(
          '${directory.path}/${UniqueId.random().getOrCrash()}.m4a',
        );
        await file.writeAsBytes(audio, flush: true);
        return right(file.path);
      } on Exception catch (exception) {
        debugPrint('Voice message not played: ${exception.runtimeType}');
        return left(const MediaUnavailable());
      }
    });
  }

  @override
  Future<void> forgetPlayable(String path) => _deleteQuietly(path);

  static Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Already gone.
    }
  }

  /// Whether [file] starts the way every GIF does.
  static bool isGif(List<int> file) =>
      file.length >= 6 &&
      file[0] == 0x47 && // G
      file[1] == 0x49 && // I
      file[2] == 0x46 && // F
      file[3] == 0x38; // 8

  @override
  Future<Either<MediaFailure, Uint8List>> load(
    UniqueId chatId,
    MessageAttachment attachment,
  ) {
    final chat = chatId.getOrCrash();
    final key = '$chat/${attachment.id.getOrCrash()}';
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return Future.value(right(cached));
    }
    return _loading[key] ??= () async {
      try {
        final file = await _store.download(chat, attachment);
        _remember(key, file);
        return right<MediaFailure, Uint8List>(file);
      } on UnreadableCiphertext {
        return left<MediaFailure, Uint8List>(const MediaUnreadable());
      } on Exception catch (exception) {
        debugPrint('Media not loaded: ${exception.runtimeType}');
        return left<MediaFailure, Uint8List>(const MediaUnavailable());
      } finally {
        _loading.remove(key);
      }
    }();
  }

  @override
  void remember(UniqueId chatId, UniqueId attachmentId, Uint8List file) {
    final key = '${chatId.getOrCrash()}/${attachmentId.getOrCrash()}';
    if (!_cache.containsKey(key)) _remember(key, file);
  }

  void _remember(String key, Uint8List file) {
    _cache[key] = file;
    _cachedBytes += file.length;
    while (_cachedBytes > cacheBytes && _cache.length > 1) {
      final oldest = _cache.keys.first;
      _cachedBytes -= _cache.remove(oldest)!.length;
    }
  }

  @override
  Future<Either<MediaFailure, Unit>> saveToPhotos(
    UniqueId chatId,
    MessageAttachment attachment,
  ) async {
    final loaded = await load(chatId, attachment);
    return loaded.fold((failure) async => left(failure), (image) async {
      try {
        if (!await _photos.hasAccess() && !await _photos.requestAccess()) {
          return left(const PhotoAccessDenied());
        }
        await _photos.save(
          image,
          name: 'routes_chat_${attachment.id.getOrCrash()}',
          gif: attachment.kind == AttachmentKind.gif,
        );
        return right(unit);
      } on PhotoAccessException {
        return left(const PhotoAccessDenied());
      } on Exception catch (exception) {
        debugPrint('Media not saved: ${exception.runtimeType}');
        return left(const MediaNotSaved());
      }
    });
  }
}
