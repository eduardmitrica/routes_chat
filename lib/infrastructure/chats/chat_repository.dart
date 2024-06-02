import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
    final userDocument = _firestore.userDocument;
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
      if (exception is FirebaseException &&
          exception.code.contains('permission-denied')) {
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
    final messageDto = MessageDataTransferObject.fromDomain(firstMessage);

    final chatRef = _firestore.collection('chats').doc(chat.id.getOrCrash());
    final messageRef = _firestore
        .collection('chats')
        .doc(chat.id.getOrCrash())
        .collection('messages')
        .doc(firstMessage.id.getOrCrash());

    final chatsOfCurrentUserRef = _firestore
        .collection('chats')
        .where('participants', whereIn: chatDto.participants);
    try {
      await _firestore.runTransaction((transaction) async {
        final chatsOfCurrentUser = await chatsOfCurrentUserRef.get();
        final chatsThatMatchTheChatDtoParticipants =
            chatsOfCurrentUser.docs.where((chat) {
          final chatParticipants = (chat.data()['participants']
              as List<Map<String, String>>)
            ..sort((first, second) =>
                first.keys.first.compareTo(second.keys.first));

          final pendingChatParticipants = chatDto.participants;
          pendingChatParticipants.sort(
              (first, second) => first.keys.first.compareTo(second.keys.first));
          return const DeepCollectionEquality()
              .equals(chatParticipants, pendingChatParticipants);
        });

        DocumentReference? existingChatRef;
        if (chatsThatMatchTheChatDtoParticipants.isNotEmpty) {
          existingChatRef =
              chatsThatMatchTheChatDtoParticipants.first.reference;
        }

        if (existingChatRef != null) {
          final chatWithTheSpecifiedParticipants =
              await transaction.get(existingChatRef);
          if (chatWithTheSpecifiedParticipants.exists == false) {
            transaction.set(chatRef, chatDto.toJson());
            transaction.set(messageRef, messageDto.toJson());
          } else {
            transaction.update(chatRef, chatDto.toJson());
            transaction.set(messageRef, messageDto.toJson());
          }
        } else {
          transaction.set(chatRef, chatDto.toJson());
          transaction.set(messageRef, messageDto.toJson());
        }
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
