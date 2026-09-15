import 'dart:convert';
import 'dart:typed_data';

import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';
import 'package:kt_dart/collection.dart';

import '../../core/value_objects.dart';
import 'message.dart';
import 'message_attachment.dart';

/// The message a reply answers, as the reply carries it: which message, who
/// sent it, the start of its text, and a preview of its first photo or GIF.
///
/// It travels inside the reply's encryption, so the server cannot tell a reply
/// from any other message, and the quote shows even when the original is not
/// loaded or can no longer be read. See docs/e2ee.md.
final class MessageQuote extends Equatable {
  /// The most of the original's text a quote keeps, in UTF-16 code units,
  /// before an ellipsis.
  static const maxLength = 100;

  final UniqueId messageId;
  final UniqueId senderId;

  /// The start of the original's text, or what it holds ("Photo") when it has
  /// no text.
  final String text;

  /// A small preview of the original's first photo or GIF, if it has any.
  final Uint8List? thumbnail;

  /// Whether the original was deleted since. The quote then keeps nothing
  /// of it.
  final bool originalDeleted;

  const MessageQuote({
    required this.messageId,
    required this.senderId,
    required this.text,
    this.thumbnail,
    this.originalDeleted = false,
  });

  /// A quote of [message]: its text cut to [maxLength], never through the
  /// middle of a character such as an emoji.
  factory MessageQuote.of(Message message) {
    final text = summaryOf(
      message.content.getOrCrash(),
      message.attachments.iter.map((attachment) => attachment.kind),
    );
    final kept = StringBuffer();
    var cut = false;
    for (final character in text.characters) {
      if (kept.length + character.length > maxLength) {
        cut = true;
        break;
      }
      kept.write(character);
    }
    return MessageQuote(
      messageId: message.id,
      senderId: message.senderId,
      text: cut ? '${kept.toString().trimRight()}…' : text,
      thumbnail: message.attachments.firstOrNull()?.thumbnail,
    );
  }

  /// The quote as [original], the message it quotes, is now. The reply
  /// carries the quote as it was when sent, so once the original is edited
  /// the quote shows its new text, and once it is deleted, nothing of it.
  MessageQuote following(Message original) {
    if (original.id != messageId) return this;
    if (original.isDeleted) {
      return MessageQuote(
        messageId: messageId,
        senderId: senderId,
        text: '',
        originalDeleted: true,
      );
    }
    return original.isEdited && original.isReadable
        ? MessageQuote.of(original)
        : this;
  }

  @override
  List<Object?> get props => [
    messageId,
    senderId,
    text,
    thumbnail == null ? null : base64Encode(thumbnail!),
    originalDeleted,
  ];

  /// The id only: the text is decrypted content, which does not belong in
  /// logs.
  @override
  String toString() => 'MessageQuote(${messageId.getOrCrash()})';
}
