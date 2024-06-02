import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/injection.dart';

import '../../../domain/chats/chat.dart';
import '../../../domain/core/value_objects.dart';

part 'chats_watcher_event.dart';

part 'chats_watcher_state.dart';

part 'chats_watcher_bloc.freezed.dart';

@injectable
class ChatsWatcherBloc extends Bloc<ChatsWatcherEvent, ChatsWatcherState> {
  final IChatRepository _chatRepository;

  var userId = '';

  StreamSubscription<Either<ChatFailure, KtList<Chat>>>? _chatsSubscription;

  ChatsWatcherBloc(this._chatRepository)
      : super(const ChatsWatcherState.initial()) {
    on<ChatsWatcherEvent>(
      (event, emit) {
        event.map(
          watchAllStarted: (event) {
            emit(const ChatsWatcherState.loadInProgress());
            _chatsSubscription = _chatRepository
                .watchAllForCurrentUser()
                .listen(
                  (failureOrFriendRequests) => add(
                    ChatsWatcherEvent.chatsReceived(failureOrFriendRequests),
                  ),
                );
          },
          chatsReceived: (event) {
            if (userId.isEmpty) {
              final fetchedUserId = getIt<CurrentUseInformationPersistent>().id;
              userId = fetchedUserId;
            }
            emit(
              event.failureOrFriendRequests.fold(
                  (failure) => ChatsWatcherState.loadFailure(failure), (chats) {
                var friendsThatCurrentUserHasChatsTo = chats
                    .map((chat) => chat.participantsList
                        .getOrCrash()
                        .map((tuple) => tuple.value1))
                    .flatten();

                friendsThatCurrentUserHasChatsTo =
                    friendsThatCurrentUserHasChatsTo.filter(
                        (chatParticipantId) =>
                            chatParticipantId.getOrCrash() != userId);

                friendsThatCurrentUserHasChatsTo =
                    friendsThatCurrentUserHasChatsTo.toSet().toList();
                return ChatsWatcherState.loadSuccess(
                    chats, friendsThatCurrentUserHasChatsTo);
              }),
            );
          },
        );
      },
    );
  }

  Future<void> refreshSubscription() async {
    _chatsSubscription?.cancel();
    add(const ChatsWatcherEvent.watchAllStarted());
  }

  @override
  Future<void> close() async {
    await _chatsSubscription?.cancel();
    return super.close();
  }
}
