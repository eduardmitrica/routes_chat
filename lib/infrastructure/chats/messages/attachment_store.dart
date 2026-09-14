import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

/// The photos and GIFs of chats in Storage, each encrypted with a key of its
/// own before it leaves the phone. See docs/e2ee.md.
class AttachmentStore {
  final FirebaseStorage _storage;
  final ChatCipher _cipher;

  const AttachmentStore(this._storage, this._cipher);

  /// Where a file is stored. storage.rules lets only the chat's participants,
  /// whose ids make up [chatId], read or add it.
  static String pathOf(String chatId, String attachmentId) =>
      'chat_media/$chatId/$attachmentId';

  /// Encrypts [draft] and uploads it to [chatId], returning what the message
  /// needs to show it: the key included.
  Future<MessageAttachment> upload(String chatId, MediaDraft draft) async {
    final id = draft.id.getOrCrash();
    final encrypted = await _cipher.encryptFile(
      draft.bytes,
      chatId: chatId,
      fileId: id,
    );
    await _storage
        .ref(pathOf(chatId, id))
        .putData(
          encrypted.stored,
          SettableMetadata(contentType: 'application/octet-stream'),
        );
    return MessageAttachment(
      id: draft.id,
      kind: draft.kind,
      width: draft.width,
      height: draft.height,
      byteSize: draft.bytes.length,
      key: encrypted.key,
      thumbnail: draft.thumbnail,
    );
  }

  /// Downloads and decrypts [attachment] of a message in [chatId].
  ///
  /// Throws [UnreadableCiphertext] if the file does not decrypt, and
  /// Firebase's exceptions if it cannot be downloaded.
  Future<Uint8List> download(
    String chatId,
    MessageAttachment attachment,
  ) async {
    final id = attachment.id.getOrCrash();
    final stored = await _storage
        .ref(pathOf(chatId, id))
        .getData(MediaLimits.maxStoredBytes);
    if (stored == null) {
      throw const FormatException('The file is empty');
    }
    return _cipher.decryptFile(
      stored,
      key: attachment.key,
      chatId: chatId,
      fileId: id,
    );
  }
}
