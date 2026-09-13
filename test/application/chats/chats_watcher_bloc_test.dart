import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

class _FakeChatRepository implements IChatRepository {
  @override
  Stream<Either<ChatFailure, KtList<Chat>>> watchAllForCurrentUser() =>
      Stream.value(right(const KtList<Chat>.empty()));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  late CurrentUserSession session;

  setUp(() => session = CurrentUserSession());

  test('reads the signed-in user from the injected session', () async {
    session.start(const CurrentUseInformationPersistent('user-1', 'eduard'));
    final bloc = ChatsWatcherBloc(_FakeChatRepository(), session);
    addTearDown(bloc.close);

    bloc.add(ChatsWatcherEvent.chatsReceived(right(const KtList.empty())));

    await expectLater(bloc.stream, emits(isA<ChatsWatcherLoadSuccess>()));
  });

  test('handles chats arriving while nobody is signed in', () async {
    // Regression: this handler used to call getIt<CurrentUseInformationPersistent>()
    // inside a Firestore stream callback. Sign-out unregistered that type, so a
    // snapshot arriving mid-sign-out threw out of the stream.
    final bloc = ChatsWatcherBloc(_FakeChatRepository(), session);
    addTearDown(bloc.close);

    expect(session.current, isNull);
    bloc.add(ChatsWatcherEvent.chatsReceived(right(const KtList.empty())));

    await expectLater(bloc.stream, emits(isA<ChatsWatcherLoadSuccess>()));
  });

  test('still surfaces repository failures without a session', () async {
    final bloc = ChatsWatcherBloc(_FakeChatRepository(), session);
    addTearDown(bloc.close);

    bloc.add(
      ChatsWatcherEvent.chatsReceived(left(InsufficientPermissions())),
    );

    await expectLater(bloc.stream, emits(isA<ChatsWatcherLoadFailure>()));
  });
}
