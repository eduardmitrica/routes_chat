import 'package:kt_dart/collection.dart';

import '../../core/value_objects.dart';
import 'outgoing_message.dart';

/// Unsent drafts, kept on the phone for the signed-in user.
abstract interface class IDraftRepository {
  Future<ChatDraft?> loadDraft(UniqueId chatId);

  /// Keeps [draft] as the draft of [chatId]. An empty draft removes it.
  Future<void> saveDraft(UniqueId chatId, ChatDraft draft);
}

/// Messages on their way, kept on the phone for the signed-in user until they
/// are sent.
abstract interface class IOutboxRepository {
  /// Every message kept, in the order they were sent.
  Future<KtList<OutgoingMessage>> queued();

  Future<void> keep(OutgoingMessage message);

  Future<void> forget(UniqueId messageId);

  /// Uploaded files of messages the user gave up on, still to delete from the
  /// server, as a chat id and a file id each.
  Future<List<(UniqueId, UniqueId)>> filesToDelete();

  Future<void> addFilesToDelete(Iterable<(UniqueId, UniqueId)> files);

  Future<void> removeFileToDelete(UniqueId chatId, UniqueId fileId);
}
