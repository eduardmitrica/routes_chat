import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_search.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../../../domain/chats/messages/message_failure.dart';

part 'messages_watcher_event.dart';

part 'messages_watcher_state.dart';

/// A chat's messages, a page at a time: the newest page live, older pages as
/// the user scrolls up, and every page back to the start while searching.
class MessagesWatcherBloc
    extends Bloc<MessagesWatcherEvent, MessagesWatcherState> {
  static const pageSize = 30;

  final IMessageRepository _messageRepository;

  StreamSubscription<Either<MessageFailure, MessagePage>>? _latestSubscription;
  UniqueId? _chatId;

  /// Every message seen, by id. Messages are never deleted, so one that moves
  /// out of the live page as new ones arrive stays shown.
  final _messagesById = <String, Message>{};

  /// The older page being loaded, which a second request joins instead of
  /// loading it again.
  Future<bool>? _olderPage;

  /// How many reveals were asked for, which numbers each one.
  var _reveals = 0;

  MessagesWatcherBloc(this._messageRepository)
    : super(MessagesWatcherState.initial()) {
    on<MessagesWatcherEvent>((event, emit) async {
      switch (event) {
        case MessagesWatchStarted(:final chatId):
          _chatId = chatId;
          emit(state.copyWith(status: MessagesStatus.loading));
          await _latestSubscription?.cancel();
          _latestSubscription = _messageRepository
              .watchLatestForChatWithId(chatId, limit: pageSize)
              .listen(
                (failureOrPage) =>
                    add(MessagesWatcherEvent.latestReceived(failureOrPage)),
              );

        case MessagesLatestReceived(:final failureOrPage):
          emit(
            failureOrPage.fold(
              (failure) => state.copyWith(
                status: MessagesStatus.failure,
                failureOption: some(failure),
              ),
              (page) {
                _remember(page.messages);
                return _withMessages(
                  state.copyWith(
                    status: MessagesStatus.loaded,
                    // Once the start is loaded it stays loaded, even when new
                    // messages make the live page full.
                    reachedStart: state.reachedStart || page.reachesStart,
                  ),
                );
              },
            ),
          );

        case MessagesOlderRequested():
          await _loadOlderPage(emit);

        case MessagesSearchChanged(:final query):
          emit(_withSearchResults(state.copyWith(searchQuery: query)));
          // Search the whole chat: load older pages back to the start, unless
          // the query changes or a page fails first.
          var searching = query.trim().isNotEmpty;
          while (searching &&
              !state.reachedStart &&
              state.searchQuery == query) {
            emit(state.copyWith(searchingOlder: true));
            searching = await _loadOlderPage(emit);
          }
          if (state.searchQuery == query && state.searchingOlder) {
            emit(state.copyWith(searchingOlder: false));
          }

        case MessageRevealRequested(:final messageId):
          final id = messageId.getOrCrash();
          // Older pages until the message is among those loaded, unless the
          // start is reached or a page fails first.
          var loading = true;
          while (loading &&
              !_messagesById.containsKey(id) &&
              !state.reachedStart) {
            emit(state.copyWith(revealingMessage: true));
            loading = await _loadOlderPage(emit);
          }
          emit(
            state.copyWith(
              revealingMessage: false,
              lastReveal: MessageReveal(
                messageId,
                message: _messagesById[id],
                request: ++_reveals,
              ),
            ),
          );

        case MessagesSearchClosed():
          emit(
            state.copyWith(
              searchQuery: '',
              searchResults: const KtList.empty(),
              searchingOlder: false,
            ),
          );
      }
    });
  }

  /// Loads the page before the oldest message loaded. Returns whether it did;
  /// false when there is nothing to load it from, the start is already
  /// loaded, or the page failed.
  Future<bool> _loadOlderPage(Emitter<MessagesWatcherState> emit) {
    return _olderPage ??= () async {
      try {
        final chatId = _chatId;
        final oldest = state.messages.firstOrNull();
        if (chatId == null || oldest == null || state.reachedStart) {
          return false;
        }
        emit(state.copyWith(loadingOlder: true));
        final result = await _messageRepository.getPageBefore(
          chatId,
          oldest.id,
          limit: pageSize,
        );
        emit(
          result.fold(
            (failure) => state.copyWith(
              loadingOlder: false,
              failureOption: some(failure),
            ),
            (page) {
              _remember(page.messages);
              return _withMessages(
                state.copyWith(
                  loadingOlder: false,
                  reachedStart: page.reachesStart,
                  failureOption: none(),
                ),
              );
            },
          ),
        );
        return result.isRight();
      } finally {
        _olderPage = null;
      }
    }();
  }

  void _remember(KtList<Message> messages) {
    for (final message in messages.iter) {
      _messagesById[message.id.getOrCrash()] = message;
    }
  }

  MessagesWatcherState _withMessages(MessagesWatcherState next) =>
      _withSearchResults(
        next.copyWith(
          messages: (_messagesById.values.toList()..sort(_bySendingTime))
              .toImmutableList(),
        ),
      );

  static MessagesWatcherState _withSearchResults(MessagesWatcherState next) {
    final query = next.searchQuery;
    return next.copyWith(
      searchResults: query.trim().isEmpty
          ? const KtList.empty()
          : next.messages
                .filter(
                  (message) =>
                      message.isReadable &&
                      matchesSearch(
                        message.content.value.fold((_) => '', (text) => text),
                        query,
                      ),
                )
                .reversed(),
    );
  }

  static int _bySendingTime(Message a, Message b) {
    final aTime = a.lastUpdatedAt;
    final bTime = b.lastUpdatedAt;
    if (aTime != null && bTime != null) {
      final byTime = aTime.compareTo(bTime);
      if (byTime != 0) return byTime;
    }
    return a.id.getOrCrash().compareTo(b.id.getOrCrash());
  }

  @override
  Future<void> close() async {
    await _latestSubscription?.cancel();
    return super.close();
  }
}
