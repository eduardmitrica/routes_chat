import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../core/value_objects.dart';

enum AttachmentKind { photo, gif }

/// How many photos and GIFs a message holds, and how big they may be.
///
/// Storage rules allow files up to [maxStoredBytes]; a test keeps the two
/// equal.
abstract final class MediaLimits {
  static const maxPerMessage = 10;

  /// Photos are re-encoded as JPEG with their shorter side at most this many
  /// pixels, which keeps them sharp on a phone and a few hundred kilobytes.
  static const photoSide = 2048;
  static const photoQuality = 82;
  static const maxPhotoBytes = 8 * 1024 * 1024;

  /// GIFs are sent as they are, so they keep their animation.
  static const maxGifBytes = 15 * 1024 * 1024;

  /// The preview shown while a photo loads, which travels inside the message.
  static const thumbnailSide = 40;
  static const thumbnailQuality = 60;
  static const maxThumbnailBytes = 1500;

  /// Encryption adds a 12-byte nonce and a 16-byte tag to each file.
  static const maxStoredBytes = maxGifBytes + 28;
}

/// A photo or GIF a message carries. The file is stored encrypted with [key],
/// which, like [thumbnail], only travels inside the message's own encryption.
final class MessageAttachment extends Equatable {
  final UniqueId id;
  final AttachmentKind kind;
  final int width;
  final int height;

  /// The size of the photo or GIF itself, before encryption.
  final int byteSize;

  final Uint8List key;

  /// A small JPEG of the photo or GIF, shown until it has loaded.
  final Uint8List? thumbnail;

  const MessageAttachment({
    required this.id,
    required this.kind,
    required this.width,
    required this.height,
    required this.byteSize,
    required this.key,
    this.thumbnail,
  });

  /// Width over height; square when the size is not known.
  double get aspectRatio => width > 0 && height > 0 ? width / height : 1;

  @override
  List<Object?> get props => [
    id,
    kind,
    width,
    height,
    byteSize,
    base64Encode(key),
    thumbnail == null ? null : base64Encode(thumbnail!),
  ];

  /// No key and no preview: both are secrets of the chat.
  @override
  String toString() => 'MessageAttachment(${id.getOrCrash()}, ${kind.name})';
}

/// A photo or GIF chosen for the next message: ready to send, not sent yet.
final class MediaDraft extends Equatable {
  final UniqueId id;
  final AttachmentKind kind;

  /// The bytes to send: a re-encoded JPEG for a photo, the file for a GIF.
  final Uint8List bytes;

  final int width;
  final int height;
  final Uint8List? thumbnail;

  const MediaDraft({
    required this.id,
    required this.kind,
    required this.bytes,
    required this.width,
    required this.height,
    this.thumbnail,
  });

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'MediaDraft(${kind.name}, ${bytes.length} bytes)';
}

/// What photos and GIFs of [kinds] are, in a few words: "Photo", "3 photos",
/// "GIF", "2 photos and GIFs". Empty for none.
String describeAttachments(Iterable<AttachmentKind> kinds) {
  final photos = kinds.where((kind) => kind == AttachmentKind.photo).length;
  final gifs = kinds.length - photos;
  if (photos + gifs == 0) return '';
  if (gifs == 0) return photos == 1 ? 'Photo' : '$photos photos';
  if (photos == 0) return gifs == 1 ? 'GIF' : '$gifs GIFs';
  return '${photos + gifs} photos and GIFs';
}

/// A message in one line, for a chat list or a quote: its [text], or what it
/// holds when it has no text.
String summaryOf(String text, Iterable<AttachmentKind> kinds) =>
    text.trim().isNotEmpty ? text : describeAttachments(kinds);
