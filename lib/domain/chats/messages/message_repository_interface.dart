import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

abstract interface class IMessageRepository {
  Stream<Either<MessageFailure, KtList<Message>>> watchAllForChatWithId(UniqueId chatId);
  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(Message message, UniqueId chatId);
}