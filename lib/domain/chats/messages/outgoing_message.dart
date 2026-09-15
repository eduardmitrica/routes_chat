import 'package:equatable/equatable.dart';
import 'package:kt_dart/collection.dart';

import '../../core/value_objects.dart';
import 'message.dart';
import 'message_attachment.dart';
import 'message_quote.dart';

/// Where a message in the outbox stands.
enum OutgoingStatus {
  /// Being sent right now.
  sending,

  /// Not sent, for a reason that may pass, such as a lost connection. It is
  /// tried again by itself.
  waiting,

  /// Not sent, and not tried again until the user asks.
  failed,
}

/// A message on its way, kept on the phone until it has been sent, so a lost
/// connection or a closed app does not lose it.
final class OutgoingMessage extends Equatable {
  /// The message as it is sent, apart from its attachments.
  final Message message;

  final UniqueId chatId;

  /// Who else is in the chat, when this message starts it. Empty for a chat
  /// that already exists.
  final KtList<UniqueId> startsChatWith;

  /// The photos and GIFs to send, in order.
  final KtList<MediaDraft> media;

  /// The stored form of each of [media], by draft id, from the moment its key
  /// was made. A file listed here may already be uploaded.
  final Map<String, MessageAttachment> attachments;

  final OutgoingStatus status;

  /// How many attempts to send it have failed.
  final int failures;

  /// When the user sent it, which orders a chat's messages on their way.
  final DateTime queuedAt;

  const OutgoingMessage({
    required this.message,
    required this.chatId,
    this.startsChatWith = const KtList.empty(),
    this.media = const KtList.empty(),
    this.attachments = const {},
    this.status = OutgoingStatus.sending,
    this.failures = 0,
    required this.queuedAt,
  });

  UniqueId get id => message.id;

  bool get startsChat => startsChatWith.isNotEmpty();

  /// The message with the attachments made so far, in the order of [media].
  Message get withAttachments => message.copyWith(
    attachments: [
      for (final draft in media.iter) ?attachments[draft.id.getOrCrash()],
    ].toImmutableList(),
  );

  OutgoingMessage copyWith({
    Map<String, MessageAttachment>? attachments,
    OutgoingStatus? status,
    int? failures,
  }) => OutgoingMessage(
    message: message,
    chatId: chatId,
    startsChatWith: startsChatWith,
    media: media,
    attachments: attachments ?? this.attachments,
    status: status ?? this.status,
    failures: failures ?? this.failures,
    queuedAt: queuedAt,
  );

  @override
  List<Object?> get props => [
    message,
    chatId,
    startsChatWith,
    media,
    attachments,
    status,
    failures,
    queuedAt,
  ];

  /// Counts only: the message is the user's content.
  @override
  String toString() =>
      'OutgoingMessage(${id.getOrCrash()}, ${status.name}, '
      'media: ${media.size}, failures: $failures)';
}

/// What the user has written in a chat and not sent yet, kept on the phone.
final class ChatDraft extends Equatable {
  final String text;
  final MessageQuote? replyTo;
  final KtList<MediaDraft> media;

  const ChatDraft({
    this.text = '',
    this.replyTo,
    this.media = const KtList.empty(),
  });

  bool get isEmpty => text.isEmpty && replyTo == null && media.isEmpty();

  @override
  List<Object?> get props => [text, replyTo, media];

  /// Counts only, for the same reason as [OutgoingMessage.toString].
  @override
  String toString() =>
      'ChatDraft(${text.length} code units, reply: ${replyTo != null}, '
      'media: ${media.size})';
}
