import 'package:async/async.dart';
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
        .asyncExpand((chatsSnapShot) async* {
      final chatDTOs = chatsSnapShot.docs.map((document) {
        return ChatDataTransferObject(
            participants: (document.data()['participants'] as List<dynamic>)
                .map((e) => Map<String, String>.from(e as Map))
                .toList(),
            messages: [],
            serverTimeStamp: FieldValue.serverTimestamp(),
            id: document.id);
      }).toList();

      final filteredChats = chatDTOs
          .where(
            (chatDTO) => chatDTO.participants
                .map((participant) => participant.keys.first)
                .contains(userDocument.id),
          )
          .toList();

      final chatsWithMessages = filteredChats.map((chatDTO) {
        return _firestore
            .collection('chats')
            .doc(chatDTO.id)
            .collection('messages')
            .orderBy('serverTimeStamp', descending: true)
            .snapshots()
            .map((messagesSnapshot) {
          final messages = messagesSnapshot.docs
              .map((messageDoc) =>
                  MessageDataTransferObject.fromFirestore(messageDoc)
                      .toDomain())
              .toImmutableList();

          return chatDTO.toDomain().copyWith(messages: messages);
        });
      }).toList();

      // yield* StreamGroup.merge(chatsWithMessages).toList().asStream();

      yield* StreamGroup.merge(chatsWithMessages);
    }).map((chatsList) {
      return right<ChatFailure, KtList<Chat>>([chatsList].toImmutableList());
    }).onErrorReturnWith((exception, stackTrace) {
      if (exception is PlatformException &&
          exception.message!.contains('PERMISSION_DENIED')) {
        return left(InsufficientPermissions());
      } else {
        return left(Unexpected());
      }
    });
  }

  @override
  Future<Either<ChatFailure, Unit>> create(Chat chat) async {
    final chatDto = ChatDataTransferObject.fromDomain(chat);
    try {
      await _firestore.collection('chats').doc(chat.id.getOrCrash()).set({
        'id': chatDto.id,
        'participants': chatDto.participants,
        'serverTimeStamp': FieldValue.serverTimestamp(),
      });
      final messages = chat.messages
          .map((message) =>
              MessageDataTransferObject.fromDomain(message).toJson())
          .asList();
      final batch = _firestore.batch();
      final messageCollectionRef = _firestore
          .collection('chats')
          .doc(chat.id.getOrCrash())
          .collection('messages');
      for (Map<String, dynamic> message in messages) {
        final docRef = messageCollectionRef.doc(message['id']);
        batch.set(docRef, message);
      }
      await batch.commit();

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
