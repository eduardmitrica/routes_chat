import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../core/value_objects.dart';

enum AttachmentKind {
  photo,
  gif,

  /// A recorded voice message, sent on its own.
  voice,
}

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

  /// A voice message is AAC at [voiceBitRate], at most [maxVoiceDuration]
  /// long: about 2.4 megabytes. [maxVoiceBytes] leaves room for the container
  /// and a recorder that runs a little over.
  static const maxVoiceDuration = Duration(minutes: 5);
  static const voiceBitRate = 64000;
  static const voiceSampleRate = 44100;
  static const maxVoiceBytes = 4 * 1024 * 1024;

  /// Shorter than this, a recording is taken for a slip and not sent.
  static const minVoiceDuration = Duration(seconds: 1);

  /// How many bars a voice message's waveform has, each a loudness 0 to 255.
  static const waveformBars = 64;
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

  /// How long a voice message plays.
  final Duration? duration;

  /// A voice message's loudness over its length, [MediaLimits.waveformBars]
  /// values from 0 to 255.
  final Uint8List? waveform;

  const MessageAttachment({
    required this.id,
    required this.kind,
    required this.width,
    required this.height,
    required this.byteSize,
    required this.key,
    this.thumbnail,
    this.duration,
    this.waveform,
  });

  bool get isVoice => kind == AttachmentKind.voice;

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
    duration,
    waveform == null ? null : base64Encode(waveform!),
  ];

  /// No key and no preview: both are secrets of the chat.
  @override
  String toString() => 'MessageAttachment(${id.getOrCrash()}, ${kind.name})';
}

/// A photo, GIF or voice recording chosen for the next message: ready to
/// send, not sent yet.
final class MediaDraft extends Equatable {
  final UniqueId id;
  final AttachmentKind kind;

  /// The bytes to send: a re-encoded JPEG for a photo, the file for a GIF,
  /// AAC for a voice message.
  final Uint8List bytes;

  final int width;
  final int height;
  final Uint8List? thumbnail;

  /// How long a voice message plays, and its loudness over time.
  final Duration? duration;
  final Uint8List? waveform;

  const MediaDraft({
    required this.id,
    required this.kind,
    required this.bytes,
    required this.width,
    required this.height,
    this.thumbnail,
    this.duration,
    this.waveform,
  });

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'MediaDraft(${kind.name}, ${bytes.length} bytes)';
}

/// What photos and GIFs of [kinds] are, in a few words: "Photo", "3 photos",
/// "GIF", "2 photos and GIFs", "Voice message". Empty for none.
String describeAttachments(Iterable<AttachmentKind> kinds) {
  if (kinds.contains(AttachmentKind.voice)) return 'Voice message';
  final photos = kinds.where((kind) => kind == AttachmentKind.photo).length;
  final gifs = kinds.where((kind) => kind == AttachmentKind.gif).length;
  if (photos + gifs == 0) return '';
  if (gifs == 0) return photos == 1 ? 'Photo' : '$photos photos';
  if (photos == 0) return gifs == 1 ? 'GIF' : '$gifs GIFs';
  return '${photos + gifs} photos and GIFs';
}

/// A message in one line, for a chat list or a quote: its [text], or what it
/// holds when it has no text.
String summaryOf(String text, Iterable<AttachmentKind> kinds) =>
    text.trim().isNotEmpty ? text : describeAttachments(kinds);

/// The loudness of a recording, sampled as it was made in decibels below full
/// scale (0 is the loudest, quieter is more negative), as
/// [MediaLimits.waveformBars] bars from 0 to 255: the loudest sample of each
/// stretch, from silence at [floor] decibels. Fewer samples than bars are
/// stretched. Empty for no samples.
Uint8List waveformOf(List<double> decibels, {double floor = -50}) {
  if (decibels.isEmpty) return Uint8List(0);
  const bars = MediaLimits.waveformBars;
  final waveform = Uint8List(bars);
  for (var bar = 0; bar < bars; bar++) {
    final start = bar * decibels.length ~/ bars;
    final end = ((bar + 1) * decibels.length / bars).ceil().clamp(
      start + 1,
      decibels.length,
    );
    var loudest = floor;
    for (var index = start; index < end; index++) {
      final value = decibels[index];
      if (value.isFinite && value > loudest) loudest = value;
    }
    waveform[bar] = ((loudest - floor) / -floor * 255).round().clamp(0, 255);
  }
  return waveform;
}

/// A voice message's length as it shows: "0:07", "1:42", "5:00".
String formatVoiceDuration(Duration duration) {
  final seconds = duration.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
