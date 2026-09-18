import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart' as chat_failure;
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/local_chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

/// What was done, in order, across the fakes that share it.
typedef ActionLog = List<String>;

const aliceAndBob = 'uid-alice_uid-bob';

CurrentUserSession signedInAlice() =>
    CurrentUserSession()
      ..start(const CurrentUserInformationPersistent('uid-alice', 'alice'));

/// Drafts and messages on their way, kept in memory as the phone would.
class MemoryChatStore implements IDraftRepository, IOutboxRepository {
  final ActionLog log;

  MemoryChatStore([ActionLog? log]) : log = log ?? [];

  final drafts = <String, ChatDraft>{};
  final kept = <String, OutgoingMessage>{};
  final toDelete = <(UniqueId, UniqueId)>[];

  /// Thrown by [keep] while set.
  Object? keepFailure;

  @override
  Future<ChatDraft?> loadDraft(UniqueId chatId) async =>
      drafts[chatId.getOrCrash()];

  @override
  Future<void> saveDraft(UniqueId chatId, ChatDraft draft) async {
    if (draft.isEmpty) {
      drafts.remove(chatId.getOrCrash());
    } else {
      drafts[chatId.getOrCrash()] = draft;
    }
  }

  @override
  Future<KtList<OutgoingMessage>> queued() async =>
      (kept.values.toList()..sort((a, b) => a.queuedAt.compareTo(b.queuedAt)))
          .toImmutableList();

  @override
  Future<void> keep(OutgoingMessage message) async {
    if (keepFailure case final failure?) throw failure;
    kept[message.id.getOrCrash()] = message;
    log.add(
      'keep ${message.id.getOrCrash()} with ${message.attachments.length} keys',
    );
  }

  @override
  Future<void> forget(UniqueId messageId) async {
    kept.remove(messageId.getOrCrash());
  }

  @override
  Future<List<(UniqueId, UniqueId)>> filesToDelete() async => [...toDelete];

  @override
  Future<void> addFilesToDelete(Iterable<(UniqueId, UniqueId)> files) async {
    toDelete.addAll(files.where((file) => !toDelete.contains(file)));
  }

  @override
  Future<void> removeFileToDelete(UniqueId chatId, UniqueId fileId) async {
    toDelete.remove((chatId, fileId));
  }
}

/// Uploads and sends in memory, answering with the failures queued up first.
class FakeMessageSender implements IMessageRepository {
  final ActionLog log;

  FakeMessageSender([ActionLog? log]) : log = log ?? [];

  final sent = <Message>[];

  /// Each upload that went through: the file id and the key it used.
  final uploads = <(String, Uint8List)>[];

  final sendFailures = <MessageFailure>[];
  final uploadFailures = <MessageFailure>[];
  final deleteFailures = <MessageFailure>[];

  /// Holds every message back while set.
  Completer<void>? gate;

  var keysMade = 0;

  @override
  MessageAttachment attachmentFor(MediaDraft draft) => MessageAttachment(
    id: draft.id,
    kind: draft.kind,
    width: draft.width,
    height: draft.height,
    byteSize: draft.bytes.length,
    key: Uint8List(32)..fillRange(0, 32, ++keysMade),
    thumbnail: draft.thumbnail,
    duration: draft.duration,
    waveform: draft.waveform,
  );

  @override
  Future<Either<MessageFailure, Unit>> uploadAttachment(
    UniqueId chatId,
    MediaDraft draft,
    MessageAttachment attachment,
  ) async {
    log.add('upload ${draft.id.getOrCrash()}');
    if (uploadFailures.isNotEmpty) return Left(uploadFailures.removeAt(0));
    uploads.add((draft.id.getOrCrash(), attachment.key));
    return const Right(unit);
  }

  @override
  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(
    Message message,
    UniqueId chatId,
  ) async {
    log.add('send ${message.id.getOrCrash()}');
    await gate?.future;
    if (sendFailures.isNotEmpty) return Left(sendFailures.removeAt(0));
    if (!sent.any((other) => other.id == message.id)) sent.add(message);
    return const Right(unit);
  }

  @override
  Future<Either<MessageFailure, Unit>> deleteAttachment(
    UniqueId chatId,
    UniqueId attachmentId,
  ) async {
    log.add('delete ${attachmentId.getOrCrash()}');
    if (deleteFailures.isNotEmpty) return Left(deleteFailures.removeAt(0));
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Starts chats in memory, answering with the failures queued up first.
class FakeChatStarter implements IChatRepository {
  final ActionLog log;

  FakeChatStarter([ActionLog? log]) : log = log ?? [];

  final created = <Chat>[];
  final failures = <chat_failure.ChatFailure>[];

  @override
  Future<Either<chat_failure.ChatFailure, Unit>> create(
    Chat chat,
    Message message,
  ) async {
    log.add('start ${chat.id.getOrCrash()} with ${message.id.getOrCrash()}');
    if (failures.isNotEmpty) return Left(failures.removeAt(0));
    created.add(chat);
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MediaDraft photoDraft(String id) => MediaDraft(
  id: UniqueId.fromUniqueString(id),
  kind: AttachmentKind.photo,
  bytes: Uint8List.fromList([1, 2, 3]),
  width: 4,
  height: 3,
);

var _clock = 0;

/// A message from Alice, each one queued a second after the one before.
OutgoingMessage outgoingMessage(
  String id, {
  String chatId = aliceAndBob,
  String text = 'Salut',
  List<MediaDraft> media = const [],
  List<String> startsChatWith = const [],
}) => OutgoingMessage(
  message: Message(
    id: UniqueId.fromUniqueString(id),
    senderId: UniqueId.fromUniqueString('uid-alice'),
    imageUrls: const KtList.empty(),
    reactions: const KtList.empty(),
    content: Content(text),
    lastUpdatedAt: null,
    isEdited: false,
  ),
  chatId: UniqueId.fromUniqueString(chatId),
  startsChatWith: [
    for (final other in startsChatWith) UniqueId.fromUniqueString(other),
  ].toImmutableList(),
  media: media.toImmutableList(),
  queuedAt: DateTime.utc(2026, 9, 15, 12).add(Duration(seconds: _clock++)),
);
