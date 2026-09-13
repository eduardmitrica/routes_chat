import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_actor/chat_actor_bloc.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

/// Records every chat the bloc asks to create.
class _FakeChatRepository implements IChatRepository {
  final created = <Chat>[];

  @override
  Future<Either<ChatFailure, Unit>> create(Chat chat, Message message) async {
    created.add(chat);
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeMessageRepository implements IMessageRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

CurrentUserSession _signedInAs(String uid) =>
    CurrentUserSession()..start(CurrentUseInformationPersistent(uid, uid));

Message _message(String senderUid) => Message(
  id: UniqueId(),
  senderId: UniqueId.fromUniqueString(senderUid),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content('hello'),
  repliedMessageId: UniqueId.empty(),
  lastUpdatedAt: null,
  isEdited: false,
);

Future<Chat> _createWithActor(String currentUid, String otherUid) async {
  final chats = _FakeChatRepository();
  final bloc = ChatActorBloc(chats, _signedInAs(currentUid));
  addTearDown(bloc.close);

  bloc.add(
    ChatActorEvent.created(
      KtList.of(UniqueId.fromUniqueString(otherUid)),
      _message(currentUid),
    ),
  );
  await pumpEventQueue();

  expect(chats.created, hasLength(1));
  return chats.created.single;
}

Future<Chat> _createWithChatBar(String currentUid, String otherUid) async {
  final chats = _FakeChatRepository();
  final bloc = ChatBarBloc(
    chats,
    _FakeMessageRepository(),
    _signedInAs(currentUid),
  );
  addTearDown(bloc.close);

  bloc
    ..add(const ChatBarEvent.messageContentChanged('hello'))
    ..add(ChatBarEvent.newChatCreated(KtList.of(UniqueId.fromUniqueString(otherUid))));
  await pumpEventQueue();

  expect(chats.created, hasLength(1));
  return chats.created.single;
}

void main() {
  // Regression: chats used to get a random id, and ChatRepository.create looked
  // for an existing chat with a query that its transaction could not track, so
  // two first messages sent at once created two chats. The id is now derived
  // from the participants, so both sides always target one document.

  test('ChatActorBloc gives a chat the same id from either side', () async {
    final fromAlice = await _createWithActor('uid-alice', 'uid-bob');
    final fromBob = await _createWithActor('uid-bob', 'uid-alice');

    expect(fromAlice.id.getOrCrash(), fromBob.id.getOrCrash());
    expect(fromAlice.id.getOrCrash(), 'uid-alice_uid-bob');
  });

  test('ChatBarBloc gives a chat the same id from either side', () async {
    final fromAlice = await _createWithChatBar('uid-alice', 'uid-bob');
    final fromBob = await _createWithChatBar('uid-bob', 'uid-alice');

    expect(fromAlice.id.getOrCrash(), fromBob.id.getOrCrash());
    expect(fromAlice.id.getOrCrash(), 'uid-alice_uid-bob');
  });
}
