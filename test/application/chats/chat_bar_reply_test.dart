import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import '../../helpers/unused_media_repository.dart';

class _UnusedChatRepository implements IChatRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Keeps every message the bloc sends.
class _SentMessages implements IMessageRepository {
  final sent = <Message>[];

  @override
  Future<Either<MessageFailure, Unit>> addMessageToChatWithId(
    Message message,
    UniqueId chatId, {
    KtList<MediaDraft> media = const KtList.empty(),
  }) async {
    sent.add(message);
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Message _fromBob(String id, String text) => Message(
  id: UniqueId.fromUniqueString(id),
  senderId: UniqueId.fromUniqueString('uid-bob'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(text),
  lastUpdatedAt: DateTime.utc(2026, 9, 14),
  isEdited: false,
);

final _chatId = UniqueId.fromUniqueString('uid-alice_uid-bob');

void main() {
  late _SentMessages messages;
  late ChatBarBloc bloc;

  setUp(() {
    messages = _SentMessages();
    bloc = ChatBarBloc(
      _UnusedChatRepository(),
      messages,
      CurrentUserSession()
        ..start(const CurrentUserInformationPersistent('uid-alice', 'alice')),
      UnusedMediaRepository(),
    );
    addTearDown(bloc.close);
  });

  Future<void> send(ChatBarEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  test('a message sent while replying carries the quote', () async {
    final original = _fromBob('message-1', 'Ne vedem mâine?');

    await send(ChatBarEvent.replyStarted(original));
    expect(bloc.state.replyingTo, MessageQuote.of(original));
    await send(ChatBarEvent.newMessageAddedToChatWithId('Da!', _chatId));

    expect(messages.sent.single.replyTo, MessageQuote.of(original));
    expect(bloc.state.replyingTo, isNull);
  });

  test('only the next message is a reply', () async {
    await send(ChatBarEvent.replyStarted(_fromBob('message-1', 'Salut')));
    await send(ChatBarEvent.newMessageAddedToChatWithId('Da!', _chatId));
    await send(ChatBarEvent.newMessageAddedToChatWithId('Și tu?', _chatId));

    expect(messages.sent.last.replyTo, isNull);
  });

  test('a cancelled reply sends the message on its own', () async {
    await send(ChatBarEvent.replyStarted(_fromBob('message-1', 'Salut')));
    await send(const ChatBarEvent.replyCancelled());
    await send(ChatBarEvent.newMessageAddedToChatWithId('Da!', _chatId));

    expect(messages.sent.single.replyTo, isNull);
  });

  test('replying to another message replaces the first', () async {
    final second = _fromBob('message-2', 'Sau poimâine?');

    await send(ChatBarEvent.replyStarted(_fromBob('message-1', 'Mâine?')));
    await send(ChatBarEvent.replyStarted(second));
    await send(ChatBarEvent.newMessageAddedToChatWithId('Poimâine', _chatId));

    expect(messages.sent.single.replyTo, MessageQuote.of(second));
  });
}
