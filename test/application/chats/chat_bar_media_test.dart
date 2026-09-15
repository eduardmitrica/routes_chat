import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../helpers/outbox_fakes.dart';

/// Prepares every path as a photo, except those set to fail.
class _FakeMedia implements IMediaRepository {
  final prepared = <String>[];
  final failing = <String, MediaFailure>{};

  @override
  Future<Either<MediaFailure, MediaDraft>> prepare(String path) async {
    prepared.add(path);
    if (failing[path] case final failure?) return Left(failure);
    return Right(
      MediaDraft(
        id: UniqueId.fromUniqueString('draft-$path'),
        kind: AttachmentKind.photo,
        bytes: Uint8List(10),
        width: 10,
        height: 10,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeMedia media;
  late FakeMessageSender messages;
  late FakeChatStarter chats;
  late ChatBarBloc bloc;

  setUp(() async {
    media = _FakeMedia();
    messages = FakeMessageSender();
    chats = FakeChatStarter();
    final store = MemoryChatStore();
    final session = signedInAlice();
    addTearDown(session.end);
    bloc = ChatBarBloc(
      session,
      media,
      store,
      MessageOutbox(
        messages,
        chats,
        store,
        session,
        retryDelays: const [Duration(hours: 1)],
      ),
    );
    addTearDown(bloc.close);
    bloc.add(ChatBarEvent.started(UniqueId.fromUniqueString('uid-bob')));
    await pumpEventQueue();
  });

  Future<void> send(ChatBarEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  List<String> draftIds() =>
      bloc.state.media.asList().map((draft) => draft.id.getOrCrash()).toList();

  test('chosen photos are made ready and wait for the message', () async {
    await send(const ChatBarEvent.mediaPicked(['a.jpg', 'b.jpg']));

    expect(draftIds(), ['draft-a.jpg', 'draft-b.jpg']);
    expect(bloc.state.preparingMedia, isFalse);
    expect(bloc.state.mediaFailureOption, none());
  });

  test('a message holds at most ten photos', () async {
    await send(
      ChatBarEvent.mediaPicked([for (var i = 0; i < 12; i++) '$i.jpg']),
    );

    expect(media.prepared, hasLength(MediaLimits.maxPerMessage));
    expect(bloc.state.media.size, MediaLimits.maxPerMessage);
    expect(
      bloc.state.mediaFailureOption,
      some(const TooManyAttachments(MediaLimits.maxPerMessage)),
    );
  });

  test('photos chosen later count towards the same ten', () async {
    await send(
      ChatBarEvent.mediaPicked([for (var i = 0; i < 9; i++) '$i.jpg']),
    );
    await send(const ChatBarEvent.mediaPicked(['x.jpg', 'y.jpg']));

    expect(bloc.state.media.size, 10);
    expect(draftIds().last, 'draft-x.jpg');
    expect(bloc.state.mediaFailureOption.isSome(), isTrue);
  });

  test('a file that cannot be used is reported, the others kept', () async {
    media.failing['big.gif'] = const MediaTooLarge(MediaLimits.maxGifBytes);

    await send(const ChatBarEvent.mediaPicked(['a.jpg', 'big.gif', 'b.jpg']));

    expect(draftIds(), ['draft-a.jpg', 'draft-b.jpg']);
    expect(
      bloc.state.mediaFailureOption,
      some(const MediaTooLarge(MediaLimits.maxGifBytes)),
    );
  });

  test('a chosen photo can be taken out', () async {
    await send(const ChatBarEvent.mediaPicked(['a.jpg', 'b.jpg']));

    await send(
      ChatBarEvent.mediaRemoved(UniqueId.fromUniqueString('draft-a.jpg')),
    );

    expect(draftIds(), ['draft-b.jpg']);
  });

  test('photos can be sent without a caption', () async {
    await send(const ChatBarEvent.mediaPicked(['a.jpg', 'b.jpg']));

    await send(const ChatBarEvent.sent('', chatExists: true));

    final message = messages.sent.single;
    expect(message.content.getOrCrash(), '');
    expect(message.attachments.size, 2);
    expect(messages.uploads, hasLength(2));
    expect(bloc.state.media.isEmpty(), isTrue);
  });

  test('photos go out with their caption and the reply', () async {
    final original = Message(
      id: UniqueId.fromUniqueString('message-1'),
      senderId: UniqueId.fromUniqueString('uid-bob'),
      imageUrls: const KtList.empty(),
      reactions: const KtList.empty(),
      content: Content('Unde ești?'),
      lastUpdatedAt: null,
      isEdited: false,
    );
    await send(ChatBarEvent.replyStarted(original));
    await send(const ChatBarEvent.mediaPicked(['a.jpg']));

    await send(const ChatBarEvent.sent('Aici', chatExists: true));

    final message = messages.sent.single;
    expect(message.content.getOrCrash(), 'Aici');
    expect(message.replyTo?.messageId, original.id);
    expect(message.attachments.size, 1);
  });

  test('an empty message without photos is not sent', () async {
    await send(const ChatBarEvent.sent('  ', chatExists: true));

    expect(messages.sent, isEmpty);
    expect(bloc.state.outgoing.isEmpty(), isTrue);
  });

  test('photos stay with a message that could not be sent yet', () async {
    messages.sendFailures.add(Unexpected());
    await send(const ChatBarEvent.mediaPicked(['a.jpg']));

    await send(const ChatBarEvent.sent('', chatExists: true));

    expect(bloc.state.media.isEmpty(), isTrue);
    final entry = bloc.state.outgoing.single();
    expect(entry.status, OutgoingStatus.waiting);
    expect(entry.media.single().id.getOrCrash(), 'draft-a.jpg');
  });

  test('the first message of a chat can carry photos', () async {
    await send(const ChatBarEvent.mediaPicked(['a.jpg']));

    await send(const ChatBarEvent.sent('', chatExists: false));

    expect(chats.created.single.lastMessage.attachments.size, 1);
    expect(bloc.state.media.isEmpty(), isTrue);
  });
}
