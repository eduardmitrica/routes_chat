import 'package:equatable/equatable.dart';

import '../core/value_objects.dart';
import 'chat.dart';

/// What the user did about a chat from someone who is not their friend.
enum ChatRequestState {
  accepted,
  deleted;

  /// As stored, literally, which firestore.rules check; a test keeps them
  /// equal.
  String get storedName => switch (this) {
    ChatRequestState.accepted => 'accepted',
    ChatRequestState.deleted => 'deleted',
  };

  static ChatRequestState? fromStored(Object? name) => switch (name) {
    'accepted' => ChatRequestState.accepted,
    'deleted' => ChatRequestState.deleted,
    _ => null,
  };
}

/// One chat the user accepted or deleted, and when.
final class ChatRequestDecision extends Equatable {
  final ChatRequestState state;
  final DateTime at;

  const ChatRequestDecision(this.state, this.at);

  @override
  List<Object?> get props => [state, at];
}

/// Where each chat stands for the user: accepted, deleted, or undecided, and
/// whether they take messages from people who are not their friends at all.
final class ChatRequests extends Equatable {
  final Map<String, ChatRequestDecision> byChatId;

  /// Whether someone who is not a friend may reach the user at all. Off, what
  /// they send never shows and never rings.
  final bool allowFromAnyone;

  const ChatRequests({this.byChatId = const {}, this.allowFromAnyone = true});

  ChatRequestDecision? decisionFor(String chatId) => byChatId[chatId];

  @override
  List<Object?> get props => [byChatId, allowFromAnyone];

  /// Counts only: who writes to the user stays out of logs.
  @override
  String toString() =>
      'ChatRequests(${byChatId.length} decided, fromAnyone: $allowFromAnyone)';
}

/// Where a chat belongs for the user.
enum ChatPlace {
  /// Among their chats.
  chats,

  /// Waiting to be accepted or deleted.
  request,

  /// Out of sight: deleted with nothing new since, or from someone who is not
  /// a friend while the user takes no such messages.
  hidden,
}

/// Where [chat] belongs for the user [userId]: a chat with a friend, or one
/// they accepted, is among their chats; one from someone else waits as a
/// request, unless they deleted it and nothing came since, or they take no
/// messages from people who are not friends.
///
/// A chat the user themselves started is always among their chats.
ChatPlace placeOf(
  Chat chat,
  String userId, {
  required bool isFriend,
  required ChatRequests requests,
  required bool startedByUser,
}) {
  final chatId = chat.id.getOrCrash();
  final decision = requests.decisionFor(chatId);
  if (isFriend ||
      startedByUser ||
      decision?.state == ChatRequestState.accepted) {
    return ChatPlace.chats;
  }
  if (!requests.allowFromAnyone) return ChatPlace.hidden;
  final sentAt = chat.lastMessage.lastUpdatedAt;
  if (decision case ChatRequestDecision(
    state: ChatRequestState.deleted,
    :final at,
  ) when sentAt == null || !sentAt.isAfter(at)) {
    return ChatPlace.hidden;
  }
  return ChatPlace.request;
}

/// Whether [chat]'s last message came from [userId], which means they have
/// written in it.
bool lastMessageIsFrom(Chat chat, String userId) =>
    chat.lastMessage.senderId.getOrCrash() == userId;

/// What the user decided about chats from people who are not their friends.
abstract interface class IChatRequests {
  ChatRequests get requests;

  Stream<ChatRequests> get requestsChanges;
}

/// Accepting and deleting chats from people who are not friends, and whether
/// they may reach the user at all.
abstract interface class IChatRequestsRepository {
  /// The user's decisions and their setting, as they change.
  Stream<ChatRequests> watch();

  /// The user takes [chatId] into their chats.
  Future<void> accept(UniqueId chatId);

  /// The user clears [chatId] for now. A later message brings it back as a
  /// request.
  Future<void> delete(UniqueId chatId);

  /// Whether people who are not friends may reach the user.
  Future<void> setAllowFromAnyone({required bool allow});
}
