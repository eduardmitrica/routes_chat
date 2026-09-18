import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

/// The photos and GIFs of chats in Storage, each encrypted with a key of its
/// own before it leaves the phone. See docs/e2ee.md.
class AttachmentStore {
  final FirebaseStorage _storage;
  final ChatCipher _cipher;
  final ICurrentUserSession _session;

  const AttachmentStore(this._storage, this._cipher, this._session);

  /// Where a file is stored. storage.rules lets only a chat's participants,
  /// whose ids make up [chatId], read or add it. A group's files are kept
  /// apart, protected by their random names, since Storage cannot check who
  /// is in a group.
  static String pathOf(String chatId, String attachmentId) =>
      isGroupIdString(chatId)
      ? 'group_media/$chatId/$attachmentId'
      : 'chat_media/$chatId/$attachmentId';

  /// What a message needs to show [draft] once it is uploaded: a new key of
  /// its own, its size and its preview. Nothing is uploaded yet.
  MessageAttachment attachmentFor(MediaDraft draft) => MessageAttachment(
    id: draft.id,
    kind: draft.kind,
    width: draft.width,
    height: draft.height,
    byteSize: draft.bytes.length,
    key: _cipher.newFileKey(),
    thumbnail: draft.thumbnail,
    duration: draft.duration,
    waveform: draft.waveform,
  );

  /// Encrypts [draft] with the key of [attachment] and uploads it to [chatId],
  /// unless an earlier attempt already did.
  ///
  /// A stored file never changes, so an upload whose answer was lost cannot
  /// simply be repeated. The key is kept before uploading, so the file found
  /// there is the one encrypted with it.
  Future<void> upload(
    String chatId,
    MediaDraft draft,
    MessageAttachment attachment,
  ) async {
    final uploader = _session.current?.id;
    if (uploader == null) {
      throw StateError('Nobody is signed in');
    }
    final id = draft.id.getOrCrash();
    final file = _storage.ref(pathOf(chatId, id));
    if (await _exists(file).timeout(stallTimeout)) return;
    final encrypted = await _cipher.encryptFile(
      draft.bytes,
      chatId: chatId,
      fileId: id,
      key: attachment.key,
    );
    final task = file.putData(
      encrypted.stored,
      // storage.rules let only the uploader delete a file, such as one of a
      // message that was never sent.
      SettableMetadata(
        contentType: 'application/octet-stream',
        customMetadata: {'uploader': uploader},
      ),
    );
    try {
      await _untilDone(task);
    } on FirebaseException catch (exception) {
      // An earlier attempt may have finished after it was given up, and the
      // rules refuse to replace its file, which is this same file.
      if (exception.code == 'unauthorized' &&
          await _exists(file).timeout(stallTimeout)) {
        return;
      }
      rethrow;
    }
  }

  /// How long a request to Storage may go without progress before it is
  /// given up. Without a connection Storage waits for one to return, however
  /// long that takes, so a message would show as sending the whole time.
  static const stallTimeout = Duration(seconds: 30);

  /// How long downloading a photo may take before it is shown as not loaded,
  /// with a way to try again. Long enough for the largest GIF on a slow
  /// connection.
  static const downloadTimeout = Duration(seconds: 90);

  /// Waits for [task], cancelling it once it makes no progress for
  /// [stallTimeout]; then throws [TimeoutException].
  static Future<void> _untilDone(UploadTask task) async {
    Timer? watchdog;
    var stalled = false;
    void restartWatchdog() {
      watchdog?.cancel();
      watchdog = Timer(stallTimeout, () {
        stalled = true;
        unawaited(task.cancel());
      });
    }

    restartWatchdog();
    final progress = task.snapshotEvents.listen(
      (_) => restartWatchdog(),
      onError: (Object _) {},
    );
    try {
      await task;
    } on FirebaseException catch (exception) {
      if (stalled && exception.code == 'canceled') {
        throw TimeoutException('The upload made no progress', stallTimeout);
      }
      rethrow;
    } finally {
      watchdog?.cancel();
      await progress.cancel();
    }
  }

  /// Deletes a file of a message that was never sent. A file already gone is
  /// deleted too.
  Future<void> delete(String chatId, String attachmentId) async {
    try {
      await _storage.ref(pathOf(chatId, attachmentId)).delete();
    } on FirebaseException catch (exception) {
      if (exception.code != 'object-not-found') rethrow;
    }
  }

  static Future<bool> _exists(Reference file) async {
    try {
      await file.getMetadata();
      return true;
    } on FirebaseException catch (exception) {
      if (exception.code == 'object-not-found') return false;
      rethrow;
    }
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
    // Without a connection Storage waits for one, so the photo would show as
    // loading until then instead of offering to try again.
    final stored = await _storage
        .ref(pathOf(chatId, id))
        .getData(MediaLimits.maxStoredBytes)
        .timeout(downloadTimeout);
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
