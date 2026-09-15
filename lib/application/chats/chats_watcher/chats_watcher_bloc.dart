import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

import '../../../domain/chats/chat.dart';
import '../../../domain/core/value_objects.dart';

part 'chats_watcher_event.dart';

part 'chats_watcher_state.dart';

/// The user's chats, and which of them have messages the user has not read
/// on this phone.
class ChatsWatcherBloc extends Bloc<ChatsWatcherEvent, ChatsWatcherState> {
  final IChatRepository _chatRepository;
  final ICurrentUserSession _session;
  final IChatReads? _reads;

  StreamSubscription<Either<ChatFailure, KtList<Chat>>>? _chatsSubscription;
  StreamSubscription<ChatReads>? _readsSubscription;
  ChatReads? _readsNow;

  ChatsWatcherBloc(this._chatRepository, this._session, {IChatReads? reads})
    : _reads = reads,
      super(const ChatsWatcherState.initial()) {
    on<ChatsWatcherEvent>((event, emit) {
      switch (event) {
        case ChatsWatchAllStarted():
          emit(const ChatsWatcherState.loadInProgress());
          _chatsSubscription = _chatRepository.watchAllForCurrentUser().listen(
            (failureOrFriendRequests) =>
                add(ChatsWatcherEvent.chatsReceived(failureOrFriendRequests)),
          );
          _readsSubscription ??= _reads?.watch().listen(
            (reads) => add(ChatsWatcherEvent.readsChanged(reads)),
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
                  unreadChatIds: _unreadIn(chats),
                );
              },
            ),
          );
        case ChatsReadsChanged(:final reads):
          _readsNow = reads;
          if (state case ChatsWatcherLoadSuccess(
            :final chats,
            :final friendsThatCurrentUserHasChatsTo,
          )) {
            emit(
              ChatsWatcherState.loadSuccess(
                chats,
                friendsThatCurrentUserHasChatsTo,
                unreadChatIds: _unreadIn(chats),
              ),
            );
          }
      }
    });
  }

  /// The ids of [chats] with messages the user has not read. None until it
  /// is known how far the user has read.
  Set<String> _unreadIn(KtList<Chat> chats) {
    final reads = _readsNow;
    final userId = _session.current?.id;
    if (reads == null || userId == null) return const {};
    return {
      for (final chat in chats.iter)
        if (reads.isUnread(chat, userId)) chat.id.getOrCrash(),
    };
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
    await _readsSubscription?.cancel();
    return super.close();
  }
}
