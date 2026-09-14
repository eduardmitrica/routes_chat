import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

/// What [message] encrypts: its text and, for a reply, the quote it carries.
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
          ),
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
        );
}
