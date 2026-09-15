import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

abstract interface class IMessageRepository {
  /// The newest [limit] messages of [chatId], oldest first, updated as
  /// messages arrive.
  Stream<Either<MessageFailure, MessagePage>> watchLatestForChatWithId(
    UniqueId chatId, {
    required int limit,
  });

  /// Up to [limit] messages of [chatId] sent before the message [messageId],
  /// oldest first.
  Future<Either<MessageFailure, MessagePage>> getPageBefore(
    UniqueId chatId,
    UniqueId messageId, {
    required int limit,
  });

  /// Sends [message], whose files are uploaded already, to [chatId].
  ///
  /// Sending a message that already arrived, after an attempt whose answer
  /// was lost, succeeds without sending it twice.
  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(
    Message message,
    UniqueId chatId,
  );

  /// What a message needs to show [draft] once it is uploaded, with a new key
  /// of its own. Nothing leaves the phone.
  MessageAttachment attachmentFor(MediaDraft draft);

  /// Encrypts [draft] with the key of [attachment] and uploads it to
  /// [chatId], unless an earlier attempt already did.
  Future<Either<MessageFailure, Unit>> uploadAttachment(
    UniqueId chatId,
    MediaDraft draft,
    MessageAttachment attachment,
  );

  /// Deletes the uploaded file [attachmentId] of a message that was never
  /// sent. A file that is not there counts as deleted.
  Future<Either<MessageFailure, Unit>> deleteAttachment(
    UniqueId chatId,
    UniqueId attachmentId,
  );
}
