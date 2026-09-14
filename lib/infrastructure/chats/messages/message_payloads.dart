import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

/// What [message] encrypts: its text, for a reply the quote it carries, and
/// its photos and GIFs with their keys.
MessagePayload payloadOf(Message message) {
  final quote = message.replyTo;
  return MessagePayload(
    message.content.getOrCrash(),
    replyTo: quote == null
        ? null
        : QuotedMessage(
            messageId: quote.messageId.getOrCrash(),
            senderId: quote.senderId.getOrCrash(),
            text: quote.text,
            thumbnail: quote.thumbnail,
          ),
    attachments: [
      for (final attachment in message.attachments.iter)
        AttachedFile(
          id: attachment.id.getOrCrash(),
          kind: attachment.kind.name,
          width: attachment.width,
          height: attachment.height,
          size: attachment.byteSize,
          key: attachment.key,
          thumbnail: attachment.thumbnail,
        ),
    ],
  );
}

/// The quote a decrypted [payload] carries, when it is a reply.
MessageQuote? quoteIn(MessagePayload payload) {
  final quoted = payload.replyTo;
  return quoted == null
      ? null
      : MessageQuote(
          messageId: UniqueId.fromUniqueString(quoted.messageId),
          senderId: UniqueId.fromUniqueString(quoted.senderId),
          text: quoted.text,
          thumbnail: quoted.thumbnail,
        );
}

/// The photos and GIFs a decrypted [payload] carries.
KtList<MessageAttachment> attachmentsIn(MessagePayload payload) => [
  for (final file in payload.attachments)
    MessageAttachment(
      id: UniqueId.fromUniqueString(file.id),
      kind: AttachmentKind.values.byName(file.kind),
      width: file.width,
      height: file.height,
      byteSize: file.size,
      key: file.key,
      thumbnail: file.thumbnail,
    ),
].toImmutableList();

extension PayloadSummary on MessagePayload {
  /// The payload in one line: its text, or what it holds ("Photo").
  String get summary => summaryOf(
    text,
    attachments.map((file) => AttachmentKind.values.byName(file.kind)),
  );
}
