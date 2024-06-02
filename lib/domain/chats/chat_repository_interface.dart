import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';

import 'messages/message.dart';

abstract interface class IChatRepository {
  Stream<Either<ChatFailure, KtList<Chat>>> watchAllForCurrentUser();
  Future<Either<ChatFailure, Unit>> create(Chat chat, Message message);
}