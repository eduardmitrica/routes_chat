import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
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

  /// Replaces the text of [message], which the user sent, with [text],
  /// encrypted again with its quote and photos, and marks it edited. Returns
  /// the message as it is now.
  ///
  /// Fails with [EditTimeExpired] once [message] is too old to edit.
  Future<Either<MessageFailure, Message>> editMessage(
    UniqueId chatId,
    Message message,
    String text,
  );

  /// Deletes [message], which the user sent, for everyone: its encrypted
  /// text and keys, its photos and the reactions to it. What stays says only
  /// that a message was deleted, so replies to it still make sense. Returns
  /// the message as it is now.
  Future<Either<MessageFailure, Message>> deleteMessage(
    UniqueId chatId,
    Message message,
  );

  /// The reactions in [chatId] to messages sent at or after [since],
  /// updated as people react. Reactions that do not decrypt are left out.
  Stream<Either<MessageFailure, KtList<MessageReaction>>> watchReactions(
    UniqueId chatId, {
    required DateTime since,
  });

  /// Sets the user's reaction to [message] to [emoji], replacing any they
  /// had, or removes it when [emoji] is null.
  Future<Either<MessageFailure, Unit>> react(
    UniqueId chatId,
    Message message,
    String? emoji,
  );
}
