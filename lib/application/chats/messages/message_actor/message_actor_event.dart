part of 'message_actor_bloc.dart';

sealed class MessageActorEvent extends Equatable {
  const MessageActorEvent();

  const factory MessageActorEvent.quickEmojisRequested() = QuickEmojisRequested;
  const factory MessageActorEvent.reactionPicked({
    required UniqueId chatId,
    required Message message,
    required String emoji,
  }) = ReactionPicked;
  const factory MessageActorEvent.reactionRemoved({
    required UniqueId chatId,
    required Message message,
  }) = ReactionRemoved;
  const factory MessageActorEvent.deleteRequested({
    required UniqueId chatId,
    required Message message,
  }) = DeleteRequested;

  @override
  List<Object?> get props => const [];
}

/// Load the emojis the user uses most.
final class QuickEmojisRequested extends MessageActorEvent {
  const QuickEmojisRequested();
}

/// The user picked [emoji] for [message]: it becomes their reaction, or,
/// when it already is, their reaction is taken back.
final class ReactionPicked extends MessageActorEvent {
  final UniqueId chatId;
  final Message message;
  final String emoji;

  const ReactionPicked({
    required this.chatId,
    required this.message,
    required this.emoji,
  });

  @override
  List<Object?> get props => [chatId, message, emoji];
}

/// The user takes back their reaction to [message].
final class ReactionRemoved extends MessageActorEvent {
  final UniqueId chatId;
  final Message message;

  const ReactionRemoved({required this.chatId, required this.message});

  @override
  List<Object?> get props => [chatId, message];
}

/// The user deletes [message], which they sent, for everyone.
final class DeleteRequested extends MessageActorEvent {
  final UniqueId chatId;
  final Message message;

  const DeleteRequested({required this.chatId, required this.message});

  @override
  List<Object?> get props => [chatId, message];
}
