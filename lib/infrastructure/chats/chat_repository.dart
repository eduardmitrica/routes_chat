import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';

@LazySingleton(as: IChatRepository)
class ChatRepository implements IChatRepository {
  @override
  Stream<Either<ChatFailure, KtList<Chat>>> watchAllForCurrentUser() {
    // TODO: implement watchAllForCurrentUser
    throw UnimplementedError();
  }

}
