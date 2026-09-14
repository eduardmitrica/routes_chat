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
}
