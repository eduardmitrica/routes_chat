import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../core/value_objects.dart';
import 'media_failure.dart';
import 'message_attachment.dart';

abstract interface class IMediaRepository {
  /// The photo or GIF at [path], made ready to send: a photo re-encoded
  /// without its metadata (such as where it was taken), a GIF as it is, both
  /// with a small preview.
  Future<Either<MediaFailure, MediaDraft>> prepare(String path);

  /// The photo or GIF [attachment] of a message in [chatId], downloaded and
  /// decrypted.
  Future<Either<MediaFailure, Uint8List>> load(
    UniqueId chatId,
    MessageAttachment attachment,
  );

  /// Keeps [file] as the decrypted photo or GIF [attachmentId] of [chatId],
  /// as if it had been loaded, so a photo just sent is not downloaded again.
  void remember(UniqueId chatId, UniqueId attachmentId, Uint8List file);

  /// Adds [attachment] of a message in [chatId] to the phone's photos, as the
  /// photo or GIF it is, asking for permission first if needed.
  Future<Either<MediaFailure, Unit>> saveToPhotos(
    UniqueId chatId,
    MessageAttachment attachment,
  );
}
