// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';

part 'message_data_transfer_object.freezed.dart';

part 'message_data_transfer_object.g.dart';

@freezed
abstract class MessageDataTransferObject with _$MessageDataTransferObject {
  const MessageDataTransferObject._();

  const factory MessageDataTransferObject({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String senderId,
    @Default(<String>[]) List<String> imageUrls,

    /// Always empty: reactions are stored encrypted, one document each. Kept
    /// for older versions of the app, which require it.
    @Default(<String>[]) List<String> reactions,

    /// The message text, encrypted with the chat's key. The repositories,
    /// which hold the key, turn it into text; see docs/e2ee.md. Null only
    /// once the message is [deleted].
    @OptionalEncryptedContentConverter()
    @JsonKey(includeIfNull: false)
    EncryptedContent? content,

    @Default(false) bool isEdited,

    /// Whether its sender deleted it. Nothing else is left of it but who sent
    /// it and when. Only stored once true.
    @JsonKey(includeIfNull: false) bool? deleted,
    @JsonKey(includeToJson: false, includeFromJson: false) DateTime? timeStamp,
    @ServerTimestampConverter() required FieldValue serverTimeStamp,
  }) = _MessageDataTransferObject;

  factory MessageDataTransferObject.fromJson(Map<String, dynamic> json) =>
      _$MessageDataTransferObjectFromJson(json);

  Map<String, dynamic> toJsonWithId() => toJson()..putIfAbsent('id', () => id);

  /// The fields a deleted message keeps. The rest are removed from the
  /// document; a test checks that firestore.rules agree.
  static const deletedFields = {'senderId', 'serverTimeStamp', 'deleted'};

  bool get isDeleted => deleted ?? false;

  /// The encrypted text of a message that is not deleted.
  ///
  /// Throws [FormatException] for a message stored without it, which is not
  /// in the stored format.
  EncryptedContent get encryptedContent =>
      content ??
      (throw const FormatException('The message content is missing'));

  /// The message, with [content] as its decrypted text, or as a placeholder
  /// when it could not be decrypted ([isReadable] false), and [replyTo] as
  /// the quote its ciphertext carries. A deleted message has no text.
  Message toDomain({
    required String content,
    MessageQuote? replyTo,
    KtList<MessageAttachment> attachments = const KtList.empty(),
    bool isReadable = true,
  }) => Message(
    id: UniqueId.fromUniqueString(id!),
    senderId: UniqueId.fromUniqueString(senderId),
    imageUrls: imageUrls
        .map((imageUrl) => ImageUrl(imageUrl))
        .toImmutableList(),
    content: Content(isDeleted ? '' : content),
    replyTo: isDeleted ? null : replyTo,
    attachments: isDeleted ? const KtList.empty() : attachments,
    lastUpdatedAt: timeStamp!,
    isEdited: isEdited,
    isReadable: isReadable,
    isDeleted: isDeleted,
    keyGeneration: this.content?.keyGeneration ?? 1,
  );

  /// [message] as stored, with [content] as its encrypted text.
  factory MessageDataTransferObject.fromDomain(
    Message message, {
    required EncryptedContent content,
  }) {
    return MessageDataTransferObject(
      id: message.id.getOrCrash(),
      senderId: message.senderId.getOrCrash(),
      imageUrls: message.imageUrls
          .map((imageUrl) => imageUrl.getOrCrash())
          .asList(),
      reactions: const [],
      content: content,

      isEdited: message.isEdited,
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory MessageDataTransferObject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
  ) => MessageDataTransferObject.fromJson(documentSnapshot.data()!).copyWith(
    id: documentSnapshot.id,
    timeStamp: (documentSnapshot.data()!['serverTimeStamp'] as Timestamp)
        .toDate(),
  );
}

// from Json, to Json
class ServerTimestampConverter implements JsonConverter<FieldValue, Object?> {
  // For annotation it has to be constant
  const ServerTimestampConverter();

  @override
  FieldValue fromJson(Object? json) {
    return FieldValue.serverTimestamp();
  }

  @override
  Object toJson(FieldValue fieldValue) => fieldValue;
}

/// Reads plaintext content as an error rather than a message, and no content,
/// which is all a deleted message has, as none.
class OptionalEncryptedContentConverter
    implements JsonConverter<EncryptedContent?, Object?> {
  const OptionalEncryptedContentConverter();

  @override
  EncryptedContent? fromJson(Object? json) =>
      json == null ? null : EncryptedContent.fromJson(json);

  @override
  Object? toJson(EncryptedContent? content) => content?.toJson();
}
