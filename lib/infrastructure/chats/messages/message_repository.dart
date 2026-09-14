import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:kt_dart/collection.dart';

import 'package:routes_chat/domain/chats/messages/message.dart';

import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';

import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';
import 'package:routes_chat/infrastructure/encryption/chat_keyring.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/chats/messages/message_repository_interface.dart';
import '../../../domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_payloads.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/infrastructure/chats/messages/attachment_store.dart';

/// A chat's messages, encrypted on the way in and decrypted on the way out.
/// See docs/e2ee.md.
class MessageRepository implements IMessageRepository {
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;
  final ChatKeyring _keyring;
  final ChatCipher _cipher;
  final AttachmentStore _attachments;

  const MessageRepository(
    this._firestore,
    this._session,
    this._keyring,
    this._cipher,
    this._attachments,
  );

  @override
  Stream<Either<MessageFailure, MessagePage>> watchLatestForChatWithId(
    UniqueId chatId, {
    required int limit,
  }) async* {
    final id = chatId.getOrCrash();
    if (_session.current == null) {
      yield left(InsufficientPermissions());
      return;
    }

    // Every snapshot carries the whole page again. Messages do not change
    // once sent, so each is decrypted once per listen.
    final decrypted = <String, (MessagePayload, bool)>{};
    yield* _messages(id)
        .orderBy('serverTimeStamp', descending: true)
        .limit(limit)
        .snapshots()
        .takeUntil(_session.ended)
        .asyncMap(
          (snapShot) async => right<MessageFailure, MessagePage>(
            await _page(snapShot.docs, id, limit, decrypted),
          ),
        )
        .onErrorReturnWith(
          (exception, stackTrace) => left(_failureFor(exception)),
        );
  }

  @override
  Future<Either<MessageFailure, MessagePage>> getPageBefore(
    UniqueId chatId,
    UniqueId messageId, {
    required int limit,
  }) async {
    final id = chatId.getOrCrash();
    try {
      final messages = _messages(id);
      // The page starts right after this message, in the same order as the
      // live page, so no message falls between the two.
      final cursor = await messages.doc(messageId.getOrCrash()).get();
      if (!cursor.exists) {
        return Left(Unexpected());
      }
      final older = await messages
          .orderBy('serverTimeStamp', descending: true)
          .startAfterDocument(cursor)
          .limit(limit)
          .get();
      return Right(await _page(older.docs, id, limit, {}));
    } on Exception catch (exception) {
      return Left(_failureFor(exception));
    }
  }

  /// [documents], newest first as queried, as a page of messages oldest first.
  Future<MessagePage> _page(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
    String chatId,
    int limit,
    Map<String, (MessagePayload, bool)> decrypted,
  ) async {
    final messages = (await Future.wait(
      documents.map(
        (document) => _decryptedMessage(document, chatId, decrypted),
      ),
    )).nonNulls.toList().reversed;
    // Fewer documents than asked for means there are none older. Counted
    // before any document not in the stored format is left out.
    return MessagePage(
      messages.toImmutableList(),
      reachesStart: documents.length < limit,
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
    Map<String, (MessagePayload, bool)> decrypted,
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
    final (payload, readable) = decrypted[cacheEntry] ??= await _decrypt(
      message,
      document.id,
      chatId,
    );
    return message.toDomain(
      content: payload.text,
      replyTo: quoteIn(payload),
      attachments: attachmentsIn(payload),
      isReadable: readable,
    );
  }

  Future<(MessagePayload, bool)> _decrypt(
    MessageDataTransferObject message,
    String messageId,
    String chatId,
  ) async {
    try {
      final payload = await _cipher.decrypt(
        message.content,
        chatKey: await _keyring.storedChatKey(
          chatId,
          message.content.keyGeneration,
        ),
        chatId: chatId,
        messageId: messageId,
        senderId: message.senderId,
      );
      return (payload, true);
    } on UnreadableCiphertext {
      return (const MessagePayload(ChatCipher.unreadableMessageText), false);
    }
  }

  @override
  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(
    Message message,
    UniqueId chatId, {
    KtList<MediaDraft> media = const KtList.empty(),
  }) async {
    final id = chatId.getOrCrash();
    final messageId = message.id.getOrCrash();
    final chatRef = _firestore.collection('chats').doc(id);
    final messageRef = chatRef.collection('messages').doc(messageId);
    try {
      // A user whose keys were reset first adds a generation of the chat key
      // they can use.
      // The files go first, because the message refers to them. If the
      // message then fails, they stay in Storage, unused and unreadable.
      final attachments = await Future.wait([
        for (final draft in media.iter) _attachments.upload(id, draft),
      ]);
      final sent = message.copyWith(attachments: attachments.toImmutableList());

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
          payloadOf(sent),
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

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _firestore.collection('chats').doc(chatId).collection('messages');

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
