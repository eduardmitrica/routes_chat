import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/infrastructure/chats/chat_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_data_transfer_object.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/chats/messages/message.dart';

class ChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;

  const ChatRepository(this._firestore, this._session);

  @override
  Stream<Either<ChatFailure, KtList<Chat>>> watchAllForCurrentUser() async* {
    final currentUser = _session.current;
    if (currentUser == null) {
      yield left(InsufficientPermissions());
      return;
    }
    // Scoped server-side rather than filtered in Dart, so the security rule
    // `request.auth.uid in resource.data.participantIds` can be satisfied:
    // Firestore validates a list query against what it *could* return, so an
    // unscoped listen would be denied outright.
    yield* _firestore
        .collection('chats')
        .where('participantIds', arrayContains: currentUser.id)
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapShot) => snapShot.docs.map(
            (document) =>
                ChatDataTransferObject.fromFirestore(document).toDomain(),
          ),
        )
        .map(
          (chats) =>
              right<ChatFailure, KtList<Chat>>(chats.toImmutableList()),
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
    Chat chat,
    Message firstMessage,
  ) async {
    final currentUser = _session.current;
    if (currentUser == null) {
      return Left(InsufficientPermissions());
    }

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
        .where('participantIds', arrayContains: currentUser.id);
    try {
      await _firestore.runTransaction((transaction) async {
        final chatsOfCurrentUser = await chatsOfCurrentUserRef.get();
        // Matched on participant ids alone. The `participants` maps carry each
        // participant's last-seen message id as their value, which differs
        // between a stored chat and the one being created, so comparing those
        // maps never matches and every message would start a duplicate chat.
        final pendingParticipantIds = chatDto.participantIds.toSet();
        final chatsThatMatchTheChatDtoParticipants = chatsOfCurrentUser.docs
            .where((chat) {
              final storedParticipantIds =
                  (chat.data()['participantIds'] as List<dynamic>? ??
                          const <dynamic>[])
                      .cast<String>()
                      .toSet();

              return storedParticipantIds.length ==
                      pendingParticipantIds.length &&
                  storedParticipantIds.containsAll(pendingParticipantIds);
            });

        DocumentReference? existingChatRef;
        if (chatsThatMatchTheChatDtoParticipants.isNotEmpty) {
          existingChatRef =
              chatsThatMatchTheChatDtoParticipants.first.reference;
        }

        if (existingChatRef != null) {
          final chatWithTheSpecifiedParticipants =
              await transaction.get(existingChatRef)
                  as DocumentSnapshot<Map<String, dynamic>>;
          if (chatWithTheSpecifiedParticipants.exists == false) {
            transaction.set(chatRef, chatDto.toJson());
            transaction.set(messageRef, messageDto.toJson());
          } else {
            transaction.update(
              existingChatRef,
              ChatDataTransferObject.fromFirestore(
                chatWithTheSpecifiedParticipants,
              ).copyWith(lastMessage: chatDto.lastMessage).toJson(),
            );
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
