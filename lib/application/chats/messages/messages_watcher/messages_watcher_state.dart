part of 'messages_watcher_bloc.dart';

enum MessagesStatus { initial, loading, loaded, failure }

final class MessagesWatcherState extends Equatable {
  final MessagesStatus status;

  /// Every message loaded so far, oldest first.
  final KtList<Message> messages;

  /// Whether [messages] go back to the chat's first message.
  final bool reachedStart;

  /// Whether an older page is being loaded.
  final bool loadingOlder;

  /// The last failure, of the newest page or of an older one. Messages that
  /// were already loaded stay in [messages].
  final Option<MessageFailure> failureOption;

  /// What the user is searching for; empty when not searching.
  final String searchQuery;

  /// Loaded messages that match [searchQuery], newest first.
  final KtList<Message> searchResults;

  /// Whether older pages are still being loaded to search the whole chat.
  final bool searchingOlder;

  const MessagesWatcherState({
    required this.status,
    required this.messages,
    required this.reachedStart,
    required this.loadingOlder,
    required this.failureOption,
    required this.searchQuery,
    required this.searchResults,
    required this.searchingOlder,
  });

  factory MessagesWatcherState.initial() => MessagesWatcherState(
    status: MessagesStatus.initial,
    messages: const KtList.empty(),
    reachedStart: false,
    loadingOlder: false,
    failureOption: none(),
    searchQuery: '',
    searchResults: const KtList.empty(),
    searchingOlder: false,
  );

  bool get isSearching => searchQuery.isNotEmpty;

  MessagesWatcherState copyWith({
    MessagesStatus? status,
    KtList<Message>? messages,
    bool? reachedStart,
    bool? loadingOlder,
    Option<MessageFailure>? failureOption,
    String? searchQuery,
    KtList<Message>? searchResults,
    bool? searchingOlder,
  }) => MessagesWatcherState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    reachedStart: reachedStart ?? this.reachedStart,
    loadingOlder: loadingOlder ?? this.loadingOlder,
    failureOption: failureOption ?? this.failureOption,
    searchQuery: searchQuery ?? this.searchQuery,
    searchResults: searchResults ?? this.searchResults,
    searchingOlder: searchingOlder ?? this.searchingOlder,
  );

  @override
  List<Object?> get props => [
    status,
    messages,
    reachedStart,
    loadingOlder,
    failureOption,
    searchQuery,
    searchResults,
    searchingOlder,
  ];

  /// Counts only: message text and the search query are decrypted content,
  /// which does not belong in logs.
  @override
  String toString() =>
      'MessagesWatcherState(status: ${status.name}, messages: '
      '${messages.size}, reachedStart: $reachedStart, loadingOlder: '
      '$loadingOlder, failure: $failureOption, searching: $isSearching, '
      'searchResults: ${searchResults.size}, searchingOlder: $searchingOlder)';
}
