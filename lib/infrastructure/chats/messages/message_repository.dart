import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (_session.current == null) {
      yield left(InsufficientPermissions());
      return;
    }

    // Every snapshot carries all the messages again. They do not change once
    // sent, so each is decrypted once per listen.
    final decrypted = <String, (String, bool)>{};
    yield* _firestore
        .collection('chats')
        .doc(id)
        .collection('messages')
        .orderBy('serverTimeStamp', descending: false)
        .snapshots()
        .takeUntil(_session.ended)
        .asyncMap(
          (snapShot) async => (await Future.wait(
            snapShot.docs.map(
              (document) => _decryptedMessage(document, id, decrypted),
            ),
          )).nonNulls,
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

  /// [document] as a message, its text decrypted. One that does not decrypt,
  /// such as one sent before the user reset their keys, is marked unreadable
  /// rather than hiding the rest of the chat.
  ///
  /// Null for a document not in the stored format, which is left out rather
  /// than failing the whole chat. The device's Firestore cache can still hold
  /// such documents after they are gone from the server.
  Future<Message?> _decryptedMessage(
    DocumentSnapshot<Map<String, dynamic>> document,
    String chatId,
    Map<String, (String, bool)> decrypted,
  ) async {
    final MessageDataTransferObject message;
    try {
      message = MessageDataTransferObject.fromFirestore(document);
    } on FormatException catch (error) {
      debugPrint(
        'Message left out, not in the stored format: ${error.message}',
      );
      return null;
    }
    final cacheEntry = '${document.id}:${base64Encode(message.content.mac)}';
    final (text, readable) = decrypted[cacheEntry] ??= await _decrypt(
      message,
      document.id,
      chatId,
    );
    return message.toDomain(content: text, isReadable: readable);
  }

  Future<(String, bool)> _decrypt(
    MessageDataTransferObject message,
    String messageId,
    String chatId,
  ) async {
    try {
      final text = await _cipher.decrypt(
        message.content,
        chatKey: await _keyring.storedChatKey(
          chatId,
          message.content.keyGeneration,
        ),
        chatId: chatId,
        messageId: messageId,
        senderId: message.senderId,
      );
      return (text, true);
    } on UnreadableCiphertext {
      return (ChatCipher.unreadableMessageText, false);
    }
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
      // A user whose keys were reset first adds a generation of the chat key
      // they can use.
      await _keyring.addGenerationIfNeeded(id);

      await _firestore.runTransaction((transaction) async {
        // The current generation is read in the transaction, so a generation
        // added meanwhile makes it retry with that one. The rules accept only
        // the current generation.
        final chat = (await transaction.get(chatRef)).data();
        if (chat == null) {
          throw const FormatException('The chat does not exist');
        }
        final current = chat['currentKeyGeneration'] as int;
        final content = await _cipher.encrypt(
          message.content.getOrCrash(),
          chatKey: await _keyring.chatKey(
            id,
            current,
            KeyGeneration.mapFromJson(chat['keyGenerations']),
          ),
          chatId: id,
          keyGeneration: current,
          messageId: messageId,
          senderId: message.senderId.getOrCrash(),
        );
        final messageDto = MessageDataTransferObject.fromDomain(
          message,
          content: content,
        );

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
    // The type, and a format error's fixed message, which never includes the
    // data: nothing about keys or content belongs in the log.
    debugPrint(
      'Messages failed: ${exception.runtimeType}'
      '${exception is FormatException ? ' (${exception.message})' : ''}',
    );
    return Unexpected();
  }
}
