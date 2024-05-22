import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/infrastructure/chats/chat_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/core/firestore_helpers.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/chats/messages/message.dart';

@LazySingleton(as: IChatRepository)
class ChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;

  const ChatRepository(this._firestore);

  @override
  Stream<Either<ChatFailure, KtList<Chat>>> watchAllForCurrentUser() async* {
    final userDocument = await _firestore.userDocument;
    yield* _firestore
        .collection('chats')
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapShot) => snapShot.docs.map(
            (document) =>
                ChatDataTransferObject.fromFirestore(document).toDomain(),
          ),
        )
        .map(
          (chats) => right<ChatFailure, KtList<Chat>>(
            chats
                .where((chat) => chat.participantsList
                    .getOrCrash()
                    .map((tuple) => tuple.value1.getOrCrash())
                    .contains(userDocument.id))
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((exception, stackTrace) {
      if (exception is PlatformException &&
          exception.message!.contains('PERMISSION_DENIED')) {
        return left(InsufficientPermissions());
      } else {
        return left(Unexpected());
      }
    });
  }

  @override
  Future<Either<ChatFailure, Unit>> create(
      Chat chat, Message firstMessage) async {
    final chatDto = ChatDataTransferObject.fromDomain(chat);
    try {
      await _firestore
          .collection('chats')
          .doc(chat.id.getOrCrash())
          .set(chatDto.toJson());

      await _firestore
          .collection('chats')
          .doc(chat.id.getOrCrash())
          .collection('messages')
          .doc(firstMessage.id.getOrCrash())
          .set(MessageDataTransferObject.fromDomain(firstMessage).toJson());

      return const Right(unit);
    } on PlatformException catch (exception) {
      if (exception.message!.contains('PERMISSION_DENIED')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> update(Chat chat) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chat.id.getOrCrash())
          .update(ChatDataTransferObject.fromDomain(chat).toJson());
      return const Right(unit);
    } on PlatformException catch (exception) {
      if (exception.message!.contains('PERMISSION_DENIED')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }
}
