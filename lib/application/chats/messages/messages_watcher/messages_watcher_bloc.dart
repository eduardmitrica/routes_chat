import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_search.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../../../domain/chats/messages/message_failure.dart';

part 'messages_watcher_event.dart';

part 'messages_watcher_state.dart';

/// A chat's messages, a page at a time: the newest page live, older pages as
/// the user scrolls up, and every page back to the start while searching.
/// Each message shows with the reactions to it, and a reply's quote follows
/// the original when it is edited or deleted.
class MessagesWatcherBloc
    extends Bloc<MessagesWatcherEvent, MessagesWatcherState> {
  static const pageSize = 30;

  final IMessageRepository _messageRepository;

  StreamSubscription<Either<MessageFailure, MessagePage>>? _latestSubscription;
  StreamSubscription<Either<MessageFailure, KtList<MessageReaction>>>?
  _reactionsSubscription;
  UniqueId? _chatId;

  /// Every message seen, by id. Messages are never removed, a deleted one
  /// only emptied, so one that moves out of the live page as new ones arrive
  /// stays shown.
  final _messagesById = <String, Message>{};

  /// The reactions to the messages loaded, by message id.
  var _reactionsByMessage = <String, KtList<MessageReaction>>{};

  /// When the oldest message the reactions are watched for was sent.
  DateTime? _reactionsSince;

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
          final message = _messagesById[id];
          emit(
            state.copyWith(
              revealingMessage: false,
              lastReveal: MessageReveal(
                messageId,
                message: message == null ? null : _shown(message),
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

        case MessagesReactionsReceived(:final failureOrReactions):
          // Without reactions, the messages still show.
          if (failureOrReactions case Right(value: final reactions)) {
            final byMessage = <String, List<MessageReaction>>{};
            for (final reaction in reactions.iter) {
              (byMessage[reaction.messageId.getOrCrash()] ??= []).add(reaction);
            }
            _reactionsByMessage = {
              for (final MapEntry(:key, :value) in byMessage.entries)
                key: value.toImmutableList(),
            };
            emit(_withMessages(state));
          }

        case MessageChanged(:final message):
          final id = message.id.getOrCrash();
          if (!_messagesById.containsKey(id)) return;
          _messagesById[id] = message;
          emit(_withMessages(state));
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
    _watchReactionsToLoaded();
  }

  /// Watches the reactions to every message loaded, from the oldest: again
  /// each time an older page goes further back.
  void _watchReactionsToLoaded() {
    final chatId = _chatId;
    DateTime? oldest;
    for (final message in _messagesById.values) {
      final sentAt = message.lastUpdatedAt;
      if (sentAt != null && (oldest == null || sentAt.isBefore(oldest))) {
        oldest = sentAt;
      }
    }
    final since = _reactionsSince;
    if (chatId == null ||
        oldest == null ||
        (since != null && !oldest.isBefore(since))) {
      return;
    }
    _reactionsSince = oldest;
    unawaited(_reactionsSubscription?.cancel());
    _reactionsSubscription = _messageRepository
        .watchReactions(chatId, since: oldest)
        .listen(
          (failureOrReactions) =>
              add(MessagesWatcherEvent.reactionsReceived(failureOrReactions)),
        );
  }

  /// [message] as it shows: with the reactions to it, and when it is a reply
  /// to a message loaded, with the quote as that message is now.
  Message _shown(Message message) {
    final quote = message.replyTo;
    final original = quote == null
        ? null
        : _messagesById[quote.messageId.getOrCrash()];
    return message.copyWith(
      reactions: message.isDeleted
          ? const KtList.empty()
          : _reactionsByMessage[message.id.getOrCrash()] ??
                const KtList.empty(),
      replyTo: original == null ? quote : quote!.following(original),
    );
  }

  MessagesWatcherState _withMessages(MessagesWatcherState next) =>
      _withSearchResults(
        next.copyWith(
          messages: [
            for (final message
                in _messagesById.values.toList()..sort(_bySendingTime))
              _shown(message),
          ].toImmutableList(),
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
                      !message.isDeleted &&
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
    await _reactionsSubscription?.cancel();
    return super.close();
  }
}
