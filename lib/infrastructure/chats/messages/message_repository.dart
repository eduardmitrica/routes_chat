import 'dart:async';
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
import 'package:routes_chat/domain/chats/messages/message_changes.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/attachment_store.dart';
import 'package:routes_chat/infrastructure/core/firestore_helpers.dart';

/// A chat's messages, encrypted on the way in and decrypted on the way out.
/// See docs/e2ee.md.
class MessageRepository implements IMessageRepository {
  /// How long deleting one of a message's photos may take.
  static const fileDeleteTimeout = Duration(seconds: 30);

  /// The fields a message loses when it is deleted; see
  /// [MessageDataTransferObject.deletedFields] for those it keeps. Older
  /// versions of the app also stored repliedMessageId.
  static const erasedFields = {
    'content',
    'imageUrls',
    'reactions',
    'isEdited',
    'repliedMessageId',
  };

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

    // Every snapshot carries the whole page again. A message is decrypted
    // once per listen, and again only once it is edited.
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
  /// rather than hiding the rest of the chat. A deleted message has nothing
  /// to decrypt.
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
    final EncryptedContent? content;
    try {
      message = MessageDataTransferObject.fromFirestore(document);
      content = message.isDeleted ? null : message.encryptedContent;
    } on FormatException catch (error) {
      debugPrint(
        'Message left out, not in the stored format: ${error.message}',
      );
      return null;
    }
    if (content == null) return message.toDomain(content: '');
    // An edit changes the ciphertext, and with it the tag.
    final cacheEntry = '${document.id}:${base64Encode(content.mac)}';
    final (payload, readable) = decrypted[cacheEntry] ??= await _decrypt(
      message,
      content,
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
    EncryptedContent content,
    String messageId,
    String chatId,
  ) async {
    try {
      final payload = await _cipher.decrypt(
        content,
        chatKey: await _keyring.storedChatKey(chatId, content.keyGeneration),
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
    UniqueId chatId,
  ) async {
    final id = chatId.getOrCrash();
    final messageId = message.id.getOrCrash();
    final chatRef = _conversation(id);
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
        // Sent already, by an attempt whose answer was lost. The rules refuse
        // to overwrite a message, and there is nothing to add.
        if ((await transaction.get(messageRef)).exists) return;
        final current = chat['currentKeyGeneration'] as int;
        final content = await _cipher.encrypt(
          payloadOf(message),
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

  @override
  MessageAttachment attachmentFor(MediaDraft draft) =>
      _attachments.attachmentFor(draft);

  @override
  Future<Either<MessageFailure, Unit>> uploadAttachment(
    UniqueId chatId,
    MediaDraft draft,
    MessageAttachment attachment,
  ) async {
    try {
      await _attachments.upload(chatId.getOrCrash(), draft, attachment);
      return const Right(unit);
    } on Exception catch (exception) {
      return Left(_failureFor(exception));
    }
  }

  @override
  Future<Either<MessageFailure, Unit>> deleteAttachment(
    UniqueId chatId,
    UniqueId attachmentId,
  ) async {
    try {
      await _attachments.delete(chatId.getOrCrash(), attachmentId.getOrCrash());
      return const Right(unit);
    } on Exception catch (exception) {
      return Left(_failureFor(exception));
    }
  }

  @override
  Future<Either<MessageFailure, Message>> editMessage(
    UniqueId chatId,
    Message message,
    String text,
  ) async {
    final userId = _session.current?.id;
    final sentAt = message.lastUpdatedAt;
    if (userId == null || sentAt == null || !message.isFrom(userId)) {
      return left(InsufficientPermissions());
    }
    if (DateTime.now().difference(sentAt) >= messageEditSaveWindow) {
      return left(EditTimeExpired());
    }
    final id = chatId.getOrCrash();
    final messageId = message.id.getOrCrash();
    final chatRef = _conversation(id);
    final messageRef = chatRef.collection('messages').doc(messageId);
    final edited = message.copyWith(content: Content(text), isEdited: true);
    try {
      await _firestore.runTransaction((transaction) async {
        final chat = (await transaction.get(chatRef)).data();
        final stored = (await transaction.get(messageRef)).data();
        if (chat == null || stored == null || stored['deleted'] == true) {
          throw const FormatException('The message is not there to edit');
        }
        // Encrypted again under the key generation it was sent with, so it
        // keeps its place among the chat's key resets.
        final generation = EncryptedContent.fromJson(
          stored['content'],
        ).keyGeneration;
        final content = await _cipher.encrypt(
          payloadOf(edited),
          chatKey: await _keyring.chatKey(
            id,
            generation,
            KeyGeneration.mapFromJson(chat['keyGenerations']),
          ),
          chatId: id,
          keyGeneration: generation,
          messageId: messageId,
          senderId: userId,
        );
        _changeMessage(transaction, chatRef, messageRef, chat, {
          'content': content.toJson(),
          'isEdited': true,
        });
      });
      return right(edited);
    } on Exception catch (exception) {
      final failure = _failureFor(exception);
      // The rules refuse an edit once it is too late, which the phone's clock
      // may not have known.
      return left(
        failure is InsufficientPermissions &&
                DateTime.now().difference(sentAt) >= messageEditWindow
            ? EditTimeExpired()
            : failure,
      );
    }
  }

  @override
  Future<Either<MessageFailure, Message>> deleteMessage(
    UniqueId chatId,
    Message message,
  ) async {
    final userId = _session.current?.id;
    if (userId == null || !message.isFrom(userId)) {
      return left(InsufficientPermissions());
    }
    final id = chatId.getOrCrash();
    final messageId = message.id.getOrCrash();
    final chatRef = _conversation(id);
    final messageRef = chatRef.collection('messages').doc(messageId);
    try {
      // The photos go first. Once the message is deleted, nothing refers to
      // them any more, so nobody would ever delete them. A failure here
      // leaves the message as it was, to try again.
      for (final attachment in message.attachments.iter) {
        await _attachments
            .delete(id, attachment.id.getOrCrash())
            .timeout(fileDeleteTimeout);
      }
      final reactions = await _reactionsTo(id, messageId);
      await _firestore.runTransaction((transaction) async {
        final chat = (await transaction.get(chatRef)).data();
        final stored = (await transaction.get(messageRef)).data();
        if (chat == null || stored == null) {
          throw const FormatException('The message is not there to delete');
        }
        if (stored['deleted'] == true) return;
        _changeMessage(transaction, chatRef, messageRef, chat, {
          for (final field in erasedFields) field: FieldValue.delete(),
          'deleted': true,
        });
        for (final reaction in reactions) {
          transaction.delete(reaction);
        }
      });
      // A reaction that landed just before the message was deleted. The
      // rules refuse any after it.
      for (final reaction in await _reactionsTo(id, messageId)) {
        await reaction.delete();
      }
      return right(
        message.copyWith(
          content: Content(''),
          replyTo: null,
          attachments: const KtList.empty(),
          reactions: const KtList.empty(),
          isEdited: false,
          isDeleted: true,
        ),
      );
    } on Exception catch (exception) {
      return left(_failureFor(exception));
    }
  }

  /// Applies [changes] to the message at [messageRef], and to the chat's
  /// copy of it when it is the chat's last message. The rules require the
  /// two to stay the same.
  static void _changeMessage(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> chatRef,
    DocumentReference<Map<String, dynamic>> messageRef,
    Map<String, dynamic> chat,
    Map<String, Object> changes,
  ) {
    transaction.update(messageRef, changes);
    final lastMessage = chat['lastMessage'];
    if (lastMessage is Map && lastMessage['id'] == messageRef.id) {
      transaction.update(chatRef, {
        for (final MapEntry(:key, :value) in changes.entries)
          'lastMessage.$key': value,
      });
    }
  }

  Future<List<DocumentReference<Map<String, dynamic>>>> _reactionsTo(
    String chatId,
    String messageId,
  ) async => [
    for (final document in (await _reactions(
      chatId,
    ).where('messageId', isEqualTo: messageId).get()).docs)
      document.reference,
  ];

  @override
  Stream<Either<MessageFailure, KtList<MessageReaction>>> watchReactions(
    UniqueId chatId, {
    required DateTime since,
  }) async* {
    final id = chatId.getOrCrash();
    if (_session.current == null) {
      yield left(InsufficientPermissions());
      return;
    }
    // Emojis by document and tag, null for one that does not decrypt, so
    // each is decrypted once per listen.
    final decrypted = <String, String?>{};
    yield* _reactions(id)
        .where(
          'messageSentAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(since),
        )
        .snapshots()
        .takeUntil(_session.ended)
        .asyncMap(
          (snapshot) async => right<MessageFailure, KtList<MessageReaction>>(
            (await Future.wait(
              snapshot.docs.map(
                (document) => _decryptedReaction(document, id, decrypted),
              ),
            )).nonNulls.toImmutableList(),
          ),
        )
        .onErrorReturnWith(
          (exception, stackTrace) => left(_failureFor(exception)),
        );
  }

  /// [document] as a reaction. Null when it is not in the stored format or
  /// does not decrypt, such as one made before the user reset their keys.
  Future<MessageReaction?> _decryptedReaction(
    DocumentSnapshot<Map<String, dynamic>> document,
    String chatId,
    Map<String, String?> decrypted,
  ) async {
    final String messageId;
    final String userId;
    final EncryptedContent content;
    try {
      final data = document.data()!;
      messageId = data['messageId'] as String;
      userId = data['userId'] as String;
      content = EncryptedContent.fromJson(data['content']);
    } on Object catch (error) {
      if (error is! TypeError && error is! FormatException) rethrow;
      debugPrint('Reaction left out, not in the stored format');
      return null;
    }
    final cacheEntry = '${document.id}:${base64Encode(content.mac)}';
    if (!decrypted.containsKey(cacheEntry)) {
      try {
        decrypted[cacheEntry] = await _cipher.decryptReaction(
          content,
          chatKey: await _keyring.storedChatKey(chatId, content.keyGeneration),
          chatId: chatId,
          messageId: messageId,
          reactorId: userId,
        );
      } on UnreadableCiphertext {
        decrypted[cacheEntry] = null;
      }
    }
    final emoji = decrypted[cacheEntry];
    return emoji == null
        ? null
        : MessageReaction(
            messageId: UniqueId.fromUniqueString(messageId),
            userId: UniqueId.fromUniqueString(userId),
            emoji: emoji,
          );
  }

  @override
  Future<Either<MessageFailure, Unit>> react(
    UniqueId chatId,
    Message message,
    String? emoji,
  ) async {
    final userId = _session.current?.id;
    if (userId == null) return left(InsufficientPermissions());
    final id = chatId.getOrCrash();
    final messageId = message.id.getOrCrash();
    // One per person per message, so another replaces it.
    final reactionRef = _reactions(id).doc(reactionIdOf(messageId, userId));
    try {
      if (emoji == null) {
        await reactionRef.delete();
        return right(unit);
      }
      await _keyring.addGenerationIfNeeded(id);
      final chatRef = _conversation(id);
      final (chatDocument, messageDocument) = await (
        chatRef.get(),
        chatRef.collection('messages').doc(messageId).get(),
      ).wait;
      final chat = chatDocument.data();
      final stored = messageDocument.data();
      if (chat == null || stored == null || stored['deleted'] == true) {
        throw const FormatException('The message is not there to react to');
      }
      final generation = chat['currentKeyGeneration'] as int;
      final content = await _cipher.encryptReaction(
        emoji,
        chatKey: await _keyring.chatKey(
          id,
          generation,
          KeyGeneration.mapFromJson(chat['keyGenerations']),
        ),
        chatId: id,
        keyGeneration: generation,
        messageId: messageId,
        reactorId: userId,
      );
      await reactionRef.set({
        'messageId': messageId,
        'userId': userId,
        // When the message was sent, so a chat can watch the reactions to
        // the messages it has loaded.
        'messageSentAt': stored['serverTimeStamp'],
        'content': content.toJson(),
      });
      return right(unit);
    } on ArgumentError {
      debugPrint('Reaction not saved: not one emoji');
      return left(Unexpected());
    } on Exception catch (exception) {
      return left(_failureFor(exception));
    }
  }

  /// The id of the reaction of [userId] to [messageId]. Neither contains
  /// "_": message ids are UUIDs and user ids Firebase uids.
  static String reactionIdOf(String messageId, String userId) =>
      '${messageId}_$userId';

  /// A one-to-one chat or a group, by its id.
  DocumentReference<Map<String, dynamic>> _conversation(String chatId) =>
      _firestore.conversationDocument(chatId);

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _conversation(chatId).collection('messages');

  CollectionReference<Map<String, dynamic>> _reactions(String chatId) =>
      _conversation(chatId).collection('reactions');

  static MessageFailure _failureFor(Object exception) {
    // Firestore says permission-denied, Storage unauthorized.
    if (exception is FirebaseException &&
        (exception.code.contains('permission-denied') ||
            exception.code == 'unauthorized')) {
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
