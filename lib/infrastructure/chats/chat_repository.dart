import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
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
import 'package:routes_chat/infrastructure/chats/messages/message_payloads.dart';

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
        .asyncMap(
          (snapShot) async =>
              (await Future.wait(snapShot.docs.map(_decryptedChat))).nonNulls,
        )
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
  ///
  /// Null for a document not in the stored format, which is left out rather
  /// than failing the whole list. The device's Firestore cache can still hold
  /// such documents after they are gone from the server.
  Future<Chat?> _decryptedChat(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final ChatDataTransferObject chat;
    try {
      chat = ChatDataTransferObject.fromFirestore(document);
    } on FormatException catch (error) {
      debugPrint('Chat left out, not in the stored format: ${error.message}');
      return null;
    }
    final lastMessage = chat.lastMessage;

    // After a reset, the user adds a generation of each chat's key sealed to
    // their new keys, which also shows their chat partner the reset. Not
    // awaited: the chat list does not wait on a write.
    if (await _keyring.needsNewGeneration(
      chat.keyGenerations,
      chat.currentKeyGeneration,
    )) {
      unawaited(
        _keyring
            .addGenerationIfNeeded(document.id)
            .catchError(
              (Object error) =>
                  debugPrint('Key generation not added: ${error.runtimeType}'),
            ),
      );
    }

    String text;
    var readable = true;
    try {
      text = (await _cipher.decrypt(
        lastMessage.content,
        chatKey: await _keyring.chatKey(
          document.id,
          lastMessage.content.keyGeneration,
          chat.keyGenerations,
        ),
        chatId: document.id,
        messageId: lastMessage.id!,
        senderId: lastMessage.senderId,
      )).text;
    } on UnreadableCiphertext {
      text = ChatCipher.unreadableMessageText;
      readable = false;
    }
    return chat.toDomain(
      lastMessageContent: text,
      lastMessageReadable: readable,
    );
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
      final firstGeneration = await _keyring.firstGeneration(
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
        final int keyGeneration;
        final SecretKey chatKey;
        if (existingChat.exists) {
          final existing = ChatDataTransferObject.fromFirestore(existingChat);
          keyGeneration = existing.currentKeyGeneration;
          chatKey = await _keyring.chatKey(
            chatId,
            keyGeneration,
            existing.keyGenerations,
          );
        } else {
          keyGeneration = 1;
          chatKey = firstGeneration.key;
        }
        final content = await _cipher.encrypt(
          payloadOf(firstMessage),
          chatKey: chatKey,
          chatId: chatId,
          keyGeneration: keyGeneration,
          messageId: messageId,
          senderId: firstMessage.senderId.getOrCrash(),
        );
        final messageDto = MessageDataTransferObject.fromDomain(
          firstMessage,
          content: content,
        );

        if (existingChat.exists) {
          // The key generations stay as they are; the rules refuse any change
          // to them other than adding the next.
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
              firstKeyGeneration: firstGeneration.stored,
            ).toJson(),
          );
        }
        transaction.set(messageRef, messageDto.toJson());
        return !existingChat.exists;
      });

      if (created) {
        _keyring.remember(chatId, firstGeneration);
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
    // The type, and a format error's fixed message, which never includes the
    // data: nothing about keys or content belongs in the log.
    debugPrint(
      'Chats failed: ${exception.runtimeType}'
      '${exception is FormatException ? ' (${exception.message})' : ''}',
    );
    return Unexpected();
  }
}
