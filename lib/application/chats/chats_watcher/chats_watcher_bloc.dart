import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/safety/blocks.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

import '../../../domain/chats/chat.dart';
import '../../../domain/core/value_objects.dart';

part 'chats_watcher_event.dart';

part 'chats_watcher_state.dart';

/// The user's chats: which of them have messages the user has not read on
/// this phone, which are with someone the user blocked, and which end with a
/// message that stays out of sight.
class ChatsWatcherBloc extends Bloc<ChatsWatcherEvent, ChatsWatcherState> {
  final IChatRepository _chatRepository;
  final ICurrentUserSession _session;
  final IChatReads? _reads;
  final IBlockList? _blocks;

  StreamSubscription<Either<ChatFailure, KtList<Chat>>>? _chatsSubscription;
  StreamSubscription<ChatReads>? _readsSubscription;
  StreamSubscription<Blocks>? _blocksSubscription;
  ChatReads? _readsNow;

  ChatsWatcherBloc(
    this._chatRepository,
    this._session, {
    IChatReads? reads,
    IBlockList? blocks,
  }) : _reads = reads,
       _blocks = blocks,
       super(const ChatsWatcherState.initial()) {
    on<ChatsWatcherEvent>((event, emit) {
      switch (event) {
        case ChatsWatchAllStarted():
          emit(const ChatsWatcherState.loadInProgress());
          _chatsSubscription = _chatRepository.watchAllForCurrentUser().listen(
            (failureOrFriendRequests) =>
                add(ChatsWatcherEvent.chatsReceived(failureOrFriendRequests)),
          );
          _readsSubscription ??= _reads?.watch().listen((reads) {
            if (!isClosed) add(ChatsWatcherEvent.readsChanged(reads));
          });
          _blocksSubscription ??= _blocks?.blocksChanges.listen((_) {
            if (!isClosed) add(const ChatsWatcherEvent.blocksChanged());
          });
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
                return _loaded(chats, friendsThatCurrentUserHasChatsTo);
              },
            ),
          );
        case ChatsReadsChanged(:final reads):
          _readsNow = reads;
          _refresh(emit);
        case ChatsBlocksChanged():
          _refresh(emit);
      }
    });
  }

  void _refresh(Emitter<ChatsWatcherState> emit) {
    if (state case ChatsWatcherLoadSuccess(
      :final chats,
      :final friendsThatCurrentUserHasChatsTo,
    )) {
      emit(_loaded(chats, friendsThatCurrentUserHasChatsTo));
    }
  }

  /// [chats] with what stands out in each: unread, blocked, or a last message
  /// that stays hidden. A hidden message, or a blocked person, never makes a
  /// chat unread.
  ChatsWatcherLoadSuccess _loaded(
    KtList<Chat> chats,
    KtList<UniqueId> friendsThatCurrentUserHasChatsTo,
  ) {
    final userId = _session.current?.id;
    final reads = _readsNow;
    final blocks = _blocks?.blocks ?? const Blocks();
    final unread = <String>{};
    final blocked = <String>{};
    final hiddenPreview = <String>{};
    for (final chat in chats.iter) {
      final id = chat.id.getOrCrash();
      final withBlocked = chat.participantsList.getOrCrash().iter.any(
        (participant) =>
            participant.value1.getOrCrash() != userId &&
            blocks.isBlocked(participant.value1),
      );
      final last = chat.lastMessage;
      final lastHidden = blocks.hides(last.senderId, last.lastUpdatedAt);
      if (withBlocked) blocked.add(id);
      if (lastHidden) hiddenPreview.add(id);
      if (reads != null &&
          userId != null &&
          !withBlocked &&
          !lastHidden &&
          reads.isUnread(chat, userId)) {
        unread.add(id);
      }
    }
    return ChatsWatcherLoadSuccess(
      chats,
      friendsThatCurrentUserHasChatsTo,
      unreadChatIds: unread,
      blockedChatIds: blocked,
      hiddenPreviewChatIds: hiddenPreview,
    );
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
    await _blocksSubscription?.cancel();
    return super.close();
  }
}
