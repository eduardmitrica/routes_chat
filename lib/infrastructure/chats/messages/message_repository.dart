import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:kt_dart/collection.dart';

import 'package:routes_chat/domain/chats/messages/message.dart';

import 'package:routes_chat/domain/chats/messages/message_failure.dart';

import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';
import 'package:routes_chat/infrastructure/encryption/chat_keyring.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/chats/messages/message_repository_interface.dart';
import '../../../domain/shared/user/current_user_session_interface.dart';

/// A chat's messages, encrypted on the way in and decrypted on the way out.
/// See docs/e2ee.md.
class MessageRepository implements IMessageRepository {
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;
  final ChatKeyring _keyring;
  final ChatCipher _cipher;

  const MessageRepository(
    this._firestore,
    this._session,
    this._keyring,
    this._cipher,
  );

  @override
  Stream<Either<MessageFailure, KtList<Message>>> watchAllForChatWithId(
    UniqueId chatId,
  ) async* {
    final id = chatId.getOrCrash();
    final SecretKey chatKey;
    try {
      chatKey = await _keyring.storedChatKey(id);
    } on Exception catch (exception) {
      yield left(_failureFor(exception));
      return;
    }
    // The session may have ended while the key was being opened, and a
    // listener started now would miss that and outlive it.
    if (_session.current == null) {
      yield left(InsufficientPermissions());
      return;
    }

    // Every snapshot carries all the messages again. They do not change once
    // sent, so each is decrypted once per listen.
    final texts = <String, String>{};
    yield* _firestore
        .collection('chats')
        .doc(id)
        .collection('messages')
        .orderBy('serverTimeStamp', descending: false)
        .snapshots()
        .takeUntil(_session.ended)
        .asyncMap(
          (snapShot) => Future.wait(
            snapShot.docs.map(
              (document) => _decryptedMessage(document, id, chatKey, texts),
            ),
          ),
        )
        .map(
          (messages) => right<MessageFailure, KtList<Message>>(
            messages.toImmutableList(),
          ),
        )
        .onErrorReturnWith(
          (exception, stackTrace) => left(_failureFor(exception)),
        );
  }

  /// [document] as a message, its text decrypted. One that does not decrypt
  /// reads [ChatCipher.unreadableMessageText], so the rest of the chat still
  /// shows.
  Future<Message> _decryptedMessage(
    DocumentSnapshot<Map<String, dynamic>> document,
    String chatId,
    SecretKey chatKey,
    Map<String, String> texts,
  ) async {
    final message = MessageDataTransferObject.fromFirestore(document);
    final cacheEntry = '${document.id}:${base64Encode(message.content.mac)}';
    var text = texts[cacheEntry];
    if (text == null) {
      try {
        text = await _cipher.decrypt(
          message.content,
          chatKey: chatKey,
          chatId: chatId,
          messageId: document.id,
          senderId: message.senderId,
        );
      } on UnreadableCiphertext {
        text = ChatCipher.unreadableMessageText;
      }
      texts[cacheEntry] = text;
    }
    return message.toDomain(content: text);
  }

  @override
  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(
    Message message,
    UniqueId chatId,
  ) async {
    final id = chatId.getOrCrash();
    final messageId = message.id.getOrCrash();
    final chatRef = _firestore.collection('chats').doc(id);
    final messageRef = chatRef.collection('messages').doc(messageId);
    try {
      final content = await _cipher.encrypt(
        message.content.getOrCrash(),
        chatKey: await _keyring.storedChatKey(id),
        chatId: id,
        messageId: messageId,
        senderId: message.senderId.getOrCrash(),
      );
      final messageDto = MessageDataTransferObject.fromDomain(
        message,
        content: content,
      );

      await _firestore.runTransaction((transaction) async {
        transaction.set(messageRef, messageDto.toJson());
        transaction.update(chatRef, {'lastMessage': messageDto.toJsonWithId()});
      });

      return const Right(unit);
    } on Exception catch (exception) {
      return Left(_failureFor(exception));
    }
  }

  static MessageFailure _failureFor(Object exception) {
    if (exception is FirebaseException &&
        exception.code.contains('permission-denied')) {
      return InsufficientPermissions();
    }
    // The type only: nothing about keys or content belongs in the log.
    debugPrint('Messages failed: ${exception.runtimeType}');
    return Unexpected();
  }
}
