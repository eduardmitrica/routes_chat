import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';

import 'messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';

abstract interface class IChatRepository {
  Stream<Either<ChatFailure, KtList<Chat>>> watchAllForCurrentUser();

  /// Starts [chat] with its first [message], which carries [media] once
  /// they are encrypted and uploaded.
  Future<Either<ChatFailure, Unit>> create(
    Chat chat,
    Message message, {
    KtList<MediaDraft> media = const KtList.empty(),
  });
}
