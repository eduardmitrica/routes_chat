import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';

import 'messages/message.dart';

abstract interface class IChatRepository {
  Stream<Either<ChatFailure, KtList<Chat>>> watchAllForCurrentUser();

  /// Starts [chat] with its first [message], whose files are uploaded
  /// already.
  ///
  /// When the other person started the chat meanwhile, the message joins it.
  /// Sending a message that already arrived, after an attempt whose answer was
  /// lost, succeeds without sending it twice.
  Future<Either<ChatFailure, Unit>> create(Chat chat, Message message);
}
