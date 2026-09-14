import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';

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

  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(
    Message message,
    UniqueId chatId, {
    KtList<MediaDraft> media = const KtList.empty(),
  });
}
