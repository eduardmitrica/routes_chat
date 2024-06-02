import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';

import 'package:routes_chat/domain/chats/messages/message.dart';

import 'package:routes_chat/domain/chats/messages/message_failure.dart';

import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_data_transfer_object.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/chats/messages/message_repository_interface.dart';

@LazySingleton(as: IMessageRepository)
class MessageRepository implements IMessageRepository {
  final FirebaseFirestore _firestore;

  const MessageRepository(this._firestore);

  @override
  Stream<Either<MessageFailure, KtList<Message>>> watchAllForChatWithId(
      UniqueId chatId) async* {
    yield* _firestore
        .collection('chats')
        .doc(chatId.getOrCrash())
        .collection('messages')
        .orderBy('serverTimeStamp', descending: false)
        .snapshots()
        .map(
          (snapShot) => snapShot.docs.map(
            (document) =>
                MessageDataTransferObject.fromFirestore(document).toDomain(),
          ),
        )
        .map(
          (messages) => right<MessageFailure, KtList<Message>>(
              messages.toImmutableList()),
        )
        .onErrorReturnWith((exception, stackTrace) {
      if (exception is FirebaseException &&
          exception.code.contains('permission-denied')) {
        return left(InsufficientPermissions());
      } else {
        return left(Unexpected());
      }
    });
  }

  @override
  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(
      Message message, UniqueId chatId) async {
    final messageDto = MessageDataTransferObject.fromDomain(message);

    final chatRef = _firestore.collection('chats').doc(chatId.getOrCrash());
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId.getOrCrash())
        .collection('messages')
        .doc(message.id.getOrCrash());
    try {
      await _firestore.runTransaction((transaction) async {
        transaction.set(messageRef, messageDto.toJson());
        transaction.update(chatRef, {'lastMessage': messageDto.toJsonWithId()});
      });

      return const Right(unit);
    } on FirebaseException catch (exception) {
      if (exception.code.contains('permission-denied')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }
}
