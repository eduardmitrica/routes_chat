import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/unused_media_repository.dart';

Future<Chat> _startedFrom(String currentUid, String otherUid) async {
  final store = MemoryChatStore();
  final chats = FakeChatStarter();
  final session = CurrentUserSession()
    ..start(CurrentUserInformationPersistent(currentUid, currentUid));
  addTearDown(session.end);
  final bloc = ChatBarBloc(
    session,
    UnusedMediaRepository(),
    store,
    MessageOutbox(FakeMessageSender(), chats, store, session),
  );
  addTearDown(bloc.close);

  bloc.add(ChatBarEvent.started(UniqueId.fromUniqueString(otherUid)));
  await pumpEventQueue();
  bloc.add(const ChatBarEvent.sent('hello', chatExists: false));
  await pumpEventQueue();

  expect(chats.created, hasLength(1));
  expect(bloc.state.chatId, chats.created.single.id);
  return chats.created.single;
}

void main() {
  // Regression: chats used to get a random id, and ChatRepository.create looked
  // for an existing chat with a query that its transaction could not track, so
  // two first messages sent at once created two chats. The id is now derived
  // from the participants, so both sides always target one document.

  test('ChatBarBloc gives a chat the same id from either side', () async {
    final fromAlice = await _startedFrom('uid-alice', 'uid-bob');
    final fromBob = await _startedFrom('uid-bob', 'uid-alice');

    expect(fromAlice.id.getOrCrash(), fromBob.id.getOrCrash());
    expect(fromAlice.id.getOrCrash(), 'uid-alice_uid-bob');
  });
}
