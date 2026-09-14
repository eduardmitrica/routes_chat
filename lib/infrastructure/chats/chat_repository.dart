import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/infrastructure/chats/chat_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_data_transfer_object.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';
import 'package:routes_chat/infrastructure/encryption/chat_keyring.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/chats/messages/message.dart';

/// Chats, with the last message encrypted on the way in and decrypted on the
/// way out. See docs/e2ee.md.
class ChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;
  final ChatKeyring _keyring;
  final ChatCipher _cipher;

  const ChatRepository(
    this._firestore,
    this._session,
    this._keyring,
    this._cipher,
  );

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
        .takeUntil(_session.ended)
        .asyncMap((snapShot) => Future.wait(snapShot.docs.map(_decryptedChat)))
        .map(
          (chats) => right<ChatFailure, KtList<Chat>>(chats.toImmutableList()),
        )
        .onErrorReturnWith(
          (exception, stackTrace) => left(_failureFor(exception)),
        );
  }

  /// [document] as a chat, its last message decrypted. One that does not
  /// decrypt reads [ChatCipher.unreadableMessageText], so a single bad chat
  /// does not hide the others.
  Future<Chat> _decryptedChat(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final chat = ChatDataTransferObject.fromFirestore(document);
    final lastMessage = chat.lastMessage;
    String text;
    try {
      text = await _cipher.decrypt(
        lastMessage.content,
        chatKey: await _keyring.chatKey(document.id, chat.chatKeys),
        chatId: document.id,
        messageId: lastMessage.id!,
        senderId: lastMessage.senderId,
      );
    } on UnreadableCiphertext {
      text = ChatCipher.unreadableMessageText;
    }
    return chat.toDomain(lastMessageContent: text);
  }

  @override
  Future<Either<ChatFailure, Unit>> create(
    Chat chat,
    Message firstMessage,
  ) async {
    if (_session.current == null) {
      return Left(InsufficientPermissions());
    }

    final chatId = chat.id.getOrCrash();
    final messageId = firstMessage.id.getOrCrash();
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc(messageId);
    try {
      // Sealing reads the participants' public keys, so the key is made once,
      // outside the transaction, which may run more than once. It goes unused
      // if the other participant creates the chat first.
      final newChatKey = await _keyring.newChatKey(
        chatId,
        chat.participantsList
            .getOrCrash()
            .map((participant) => participant.value1.getOrCrash())
            .asList(),
      );

      final created = await _firestore.runTransaction((transaction) async {
        // The chat id is derived from its participants (compositeId), so a
        // chat between the same people is always this document. Reading it
        // with transaction.get makes a concurrent first message retry against
        // the chat the other one created. The previous check, a query run
        // inside the transaction, was invisible to it, so both could create a
        // chat.
        final existingChat = await transaction.get(chatRef);
        final chatKey = existingChat.exists
            ? await _keyring.chatKey(
                chatId,
                ChatDataTransferObject.fromFirestore(existingChat).chatKeys,
              )
            : newChatKey.key;
        final content = await _cipher.encrypt(
          firstMessage.content.getOrCrash(),
          chatKey: chatKey,
          chatId: chatId,
          messageId: messageId,
          senderId: firstMessage.senderId.getOrCrash(),
        );
        final messageDto = MessageDataTransferObject.fromDomain(
          firstMessage,
          content: content,
        );

        if (existingChat.exists) {
          // The sealed keys stay as the chat's creator stored them; the rules
          // refuse any change to them.
          transaction.update(chatRef, {
            'lastMessage': messageDto.toJsonWithId(),
            'serverTimeStamp': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(
            chatRef,
            ChatDataTransferObject.fromDomain(
              chat,
              lastMessageContent: content,
              chatKeys: newChatKey.sealed,
            ).toJson(),
          );
        }
        transaction.set(messageRef, messageDto.toJson());
        return !existingChat.exists;
      });

      if (created) {
        _keyring.remember(chatId, newChatKey.key);
      }
      return const Right(unit);
    } on Exception catch (exception) {
      return Left(_failureFor(exception));
    }
  }

  static ChatFailure _failureFor(Object exception) {
    if (exception is FirebaseException &&
        exception.code.contains('permission-denied')) {
      return InsufficientPermissions();
    }
    // The type only: nothing about keys or content belongs in the log.
    debugPrint('Chats failed: ${exception.runtimeType}');
    return Unexpected();
  }
}
