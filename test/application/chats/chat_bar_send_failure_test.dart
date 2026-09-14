import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart' as chat_failure;
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart'
    as message_failure;
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

class _FailingChatRepository implements IChatRepository {
  @override
  Future<Either<chat_failure.ChatFailure, Unit>> create(
    Chat chat,
    Message message,
  ) async => Left(chat_failure.InsufficientPermissions());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingMessageRepository implements IMessageRepository {
  @override
  Future<Either<message_failure.MessageFailure, Unit>> addMessageToChatWithId(
    Message message,
    UniqueId chatId,
  ) async => Left(message_failure.Unexpected());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ChatBarBloc _bloc() {
  final bloc = ChatBarBloc(
    _FailingChatRepository(),
    _FailingMessageRepository(),
    CurrentUserSession()
      ..start(const CurrentUserInformationPersistent('uid-alice', 'alice')),
  );
  addTearDown(bloc.close);
  return bloc;
}

T? _failure<T>(Option<Either<T, Unit>> option) => option.fold(
  () => null,
  (either) => either.fold((failure) => failure, (_) => null),
);

final _existingChatId = UniqueId.fromUniqueString('uid-alice_uid-bob');

void main() {
  // Regression: a message sent to an existing chat ignored the repository's
  // result, and a failed chat creation was kept in state but never shown. The
  // message bar clears its text on send, so either failure vanished without a
  // trace. The page now shows a snackbar for whichever outcome is set.

  test(
    'a failed first message is reported as a chat creation failure',
    () async {
      final bloc = _bloc()
        ..add(const ChatBarEvent.messageContentChanged('hello'))
        ..add(
          ChatBarEvent.newChatCreated(
            KtList.of(UniqueId.fromUniqueString('uid-bob')),
          ),
        );
      await pumpEventQueue();

      expect(
        _failure(bloc.state.chatCreationFailureOrSuccessOption),
        isA<chat_failure.InsufficientPermissions>(),
      );
      expect(bloc.state.messageSendFailureOrSuccessOption, none());
    },
  );

  test('a failed message to an existing chat is reported', () async {
    final bloc = _bloc()
      ..add(ChatBarEvent.newMessageAddedToChatWithId('hello', _existingChatId));
    await pumpEventQueue();

    expect(
      _failure(bloc.state.messageSendFailureOrSuccessOption),
      isA<message_failure.Unexpected>(),
    );
    expect(bloc.state.chatCreationFailureOrSuccessOption, none());
  });

  test('typing again clears a reported failure', () async {
    final bloc = _bloc()
      ..add(ChatBarEvent.newMessageAddedToChatWithId('hello', _existingChatId));
    await pumpEventQueue();
    bloc.add(const ChatBarEvent.messageContentChanged('retry'));
    await pumpEventQueue();

    expect(bloc.state.messageSendFailureOrSuccessOption, none());
  });
}
