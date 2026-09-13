import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

import '../../../domain/chats/chat.dart';
import '../../../domain/core/value_objects.dart';

part 'chats_watcher_event.dart';

part 'chats_watcher_state.dart';

class ChatsWatcherBloc extends Bloc<ChatsWatcherEvent, ChatsWatcherState> {
  final IChatRepository _chatRepository;
  final ICurrentUserSession _session;

  StreamSubscription<Either<ChatFailure, KtList<Chat>>>? _chatsSubscription;

  ChatsWatcherBloc(this._chatRepository, this._session)
    : super(const ChatsWatcherState.initial()) {
    on<ChatsWatcherEvent>((event, emit) {
      switch (event) {
        case ChatsWatchAllStarted():
          emit(const ChatsWatcherState.loadInProgress());
          _chatsSubscription = _chatRepository.watchAllForCurrentUser().listen(
            (failureOrFriendRequests) =>
                add(ChatsWatcherEvent.chatsReceived(failureOrFriendRequests)),
          );
        case ChatsReceived():
          final userId = _session.current?.id ?? '';
          emit(
            event.failureOrFriendRequests.fold(
              (failure) => ChatsWatcherState.loadFailure(failure),
              (chats) {
                var friendsThatCurrentUserHasChatsTo = chats
                    .map(
                      (chat) => chat.participantsList.getOrCrash().map(
                        (tuple) => tuple.value1,
                      ),
                    )
                    .flatten();

                friendsThatCurrentUserHasChatsTo =
                    friendsThatCurrentUserHasChatsTo.filter(
                      (chatParticipantId) =>
                          chatParticipantId.getOrCrash() != userId,
                    );

                friendsThatCurrentUserHasChatsTo =
                    friendsThatCurrentUserHasChatsTo.toSet().toList();
                return ChatsWatcherState.loadSuccess(
                  chats,
                  friendsThatCurrentUserHasChatsTo,
                );
              },
            ),
          );
      }
    });
  }

  Future<void> refreshSubscription() async {
    await _chatsSubscription?.cancel();
    Future loadSuccessOrFailureState = stream
        .where(
          (state) =>
              state is ChatsWatcherLoadSuccess ||
              state is ChatsWatcherLoadFailure,
        )
        .first;
    add(const ChatsWatcherEvent.watchAllStarted());
    await loadSuccessOrFailureState;
  }

  @override
  Future<void> close() async {
    await _chatsSubscription?.cancel();
    return super.close();
  }
}
