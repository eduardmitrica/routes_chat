import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/chat_requests.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/friend_requests_repository_interface.dart';
import 'package:routes_chat/domain/safety/blocks.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

import '../../../domain/chats/chat.dart';
import '../../../domain/core/value_objects.dart';

part 'chats_watcher_event.dart';

part 'chats_watcher_state.dart';

/// The user's chats, and what stands out about each: unread, with someone
/// blocked, a last message kept out of sight, or waiting to be accepted
/// because it comes from someone who is not a friend.
class ChatsWatcherBloc extends Bloc<ChatsWatcherEvent, ChatsWatcherState> {
  final IChatRepository _chatRepository;
  final ICurrentUserSession _session;
  final IChatReads? _reads;
  final IBlockList? _blocks;
  final IChatRequests? _requests;
  final IFriendRequestsRepository? _friendRequests;

  StreamSubscription<Either<ChatFailure, KtList<Chat>>>? _chatsSubscription;
  StreamSubscription<ChatReads>? _readsSubscription;
  StreamSubscription<Blocks>? _blocksSubscription;
  StreamSubscription<ChatRequests>? _requestsSubscription;
  StreamSubscription<Object>? _friendsSubscription;
  ChatReads? _readsNow;
  var _friendIds = <String>{};

  ChatsWatcherBloc(
    this._chatRepository,
    this._session, {
    IChatReads? reads,
    IBlockList? blocks,
    IChatRequests? requests,
    IFriendRequestsRepository? friendRequests,
  }) : _reads = reads,
       _blocks = blocks,
       _requests = requests,
       _friendRequests = friendRequests,
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
          _requestsSubscription ??= _requests?.requestsChanges.listen((_) {
            if (!isClosed) add(const ChatsWatcherEvent.requestsChanged());
          });
          _friendsSubscription ??= _friendRequests
              ?.watchFriendsForCurrentUser()
              .listen((failureOrFriends) {
                if (isClosed) return;
                failureOrFriends.fold(
                  (_) {},
                  (friends) =>
                      add(ChatsWatcherEvent.friendsReceived(_idsIn(friends))),
                );
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
        case ChatsRequestsChanged():
          _refresh(emit);
        case ChatsFriendsReceived(:final friendIds):
          _friendIds = {for (final id in friendIds.iter) id.getOrCrash()};
          _refresh(emit);
      }
    });
  }

  /// The other person in each accepted friend request.
  KtList<UniqueId> _idsIn(KtList<FriendRequest> friends) {
    final userId = _session.current?.id;
    return friends
        .map(
          (friend) => friend.senderId.getOrCrash() == userId
              ? friend.receiverId
              : friend.senderId,
        )
        .toSet()
        .toList();
  }

  void _refresh(Emitter<ChatsWatcherState> emit) {
    if (state case ChatsWatcherLoadSuccess(
      :final chats,
      :final friendsThatCurrentUserHasChatsTo,
    )) {
      emit(_loaded(chats, friendsThatCurrentUserHasChatsTo));
    }
  }

  /// [chats] with what stands out in each. A hidden message, a blocked
  /// person, or a chat waiting to be accepted never makes a chat unread.
  ChatsWatcherLoadSuccess _loaded(
    KtList<Chat> chats,
    KtList<UniqueId> friendsThatCurrentUserHasChatsTo,
  ) {
    final userId = _session.current?.id;
    final reads = _readsNow;
    final blocks = _blocks?.blocks ?? const Blocks();
    final requests = _requests?.requests;
    final unread = <String>{};
    final blocked = <String>{};
    final hiddenPreview = <String>{};
    final waiting = <String>{};
    final hidden = <String>{};
    for (final chat in chats.iter) {
      final id = chat.id.getOrCrash();
      final others = [
        for (final participant in chat.participantsList.getOrCrash().iter)
          if (participant.value1.getOrCrash() != userId) participant.value1,
      ];
      final withBlocked = others.any(blocks.isBlocked);
      final last = chat.lastMessage;
      final lastHidden = blocks.hides(last.senderId, last.lastUpdatedAt);
      if (withBlocked) blocked.add(id);
      if (lastHidden) hiddenPreview.add(id);

      // Where it belongs: among the chats, waiting, or nowhere.
      if (userId != null && requests != null && !withBlocked) {
        final place = placeOf(
          chat,
          userId,
          isFriend: others.any(
            (other) => _friendIds.contains(other.getOrCrash()),
          ),
          requests: requests,
          startedByUser: lastMessageIsFrom(chat, userId),
        );
        if (place == ChatPlace.request) waiting.add(id);
        if (place == ChatPlace.hidden) hidden.add(id);
      }

      if (reads != null &&
          userId != null &&
          !withBlocked &&
          !lastHidden &&
          !waiting.contains(id) &&
          !hidden.contains(id) &&
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
      requestChatIds: waiting,
      hiddenChatIds: hidden,
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
    await _requestsSubscription?.cancel();
    await _friendsSubscription?.cancel();
    return super.close();
  }
}
