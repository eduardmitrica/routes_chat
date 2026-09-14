import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart' as chat_failure;
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

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

/// Keeps what the bloc sends, and answers with [result].
class _Messages implements IMessageRepository {
  final sent = <(Message, KtList<MediaDraft>)>[];
  Either<MessageFailure, Unit> result = const Right(unit);

  @override
  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(
    Message message,
    UniqueId chatId, {
    KtList<MediaDraft> media = const KtList.empty(),
  }) async {
    sent.add((message, media));
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Chats implements IChatRepository {
  final created = <KtList<MediaDraft>>[];

  @override
  Future<Either<chat_failure.ChatFailure, Unit>> create(
    Chat chat,
    Message message, {
    KtList<MediaDraft> media = const KtList.empty(),
  }) async {
    created.add(media);
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _chatId = UniqueId.fromUniqueString('uid-alice_uid-bob');

void main() {
  late _FakeMedia media;
  late _Messages messages;
  late _Chats chats;
  late ChatBarBloc bloc;

  setUp(() {
    media = _FakeMedia();
    messages = _Messages();
    chats = _Chats();
    bloc = ChatBarBloc(
      chats,
      messages,
      CurrentUserSession()
        ..start(const CurrentUserInformationPersistent('uid-alice', 'alice')),
      media,
    );
    addTearDown(bloc.close);
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

    await send(ChatBarEvent.newMessageAddedToChatWithId('', _chatId));

    final (message, sentMedia) = messages.sent.single;
    expect(message.content.getOrCrash(), '');
    expect(sentMedia.size, 2);
    expect(bloc.state.media.isEmpty(), isTrue);
    expect(bloc.state.isSubmitting, isFalse);
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

    await send(ChatBarEvent.newMessageAddedToChatWithId('Aici', _chatId));

    final (message, sentMedia) = messages.sent.single;
    expect(message.content.getOrCrash(), 'Aici');
    expect(message.replyTo?.messageId, original.id);
    expect(sentMedia.size, 1);
  });

  test('an empty message without photos is not sent', () async {
    await send(ChatBarEvent.newMessageAddedToChatWithId('  ', _chatId));

    expect(messages.sent, isEmpty);
  });

  test('photos stay chosen when sending fails, to try again', () async {
    messages.result = Left(Unexpected());
    await send(const ChatBarEvent.mediaPicked(['a.jpg']));

    await send(ChatBarEvent.newMessageAddedToChatWithId('', _chatId));

    expect(draftIds(), ['draft-a.jpg']);
    expect(bloc.state.isSubmitting, isFalse);
  });

  test('the first message of a chat can carry photos', () async {
    await send(const ChatBarEvent.mediaPicked(['a.jpg']));

    await send(
      ChatBarEvent.newChatCreated(
        KtList.of(UniqueId.fromUniqueString('uid-bob')),
      ),
    );

    expect(chats.created.single.size, 1);
    expect(bloc.state.media.isEmpty(), isTrue);
  });
}
