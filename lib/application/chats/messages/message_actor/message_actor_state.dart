part of 'message_actor_bloc.dart';

enum MessageAction { react, delete }

/// Something done to a message that failed. Each has its own number, so the
/// same failure twice is told apart.
final class MessageProblem extends Equatable {
  final MessageAction action;
  final MessageFailure failure;
  final int number;

  const MessageProblem(this.action, this.failure, {required this.number});

  @override
  List<Object?> get props => [action, failure, number];
}

final class MessageActorState extends Equatable {
  /// The emojis the user uses most, most used first.
  final List<String> quickEmojis;

  /// The ids of the messages being deleted.
  final Set<String> deleting;

  final MessageProblem? lastProblem;

  /// The message deleted last, as it is now.
  final Message? lastDeleted;

  const MessageActorState({
    this.quickEmojis = const [],
    this.deleting = const {},
    this.lastProblem,
    this.lastDeleted,
  });

  MessageActorState copyWith({
    List<String>? quickEmojis,
    Set<String>? deleting,
    MessageProblem? lastProblem,
    Message? lastDeleted,
  }) => MessageActorState(
    quickEmojis: quickEmojis ?? this.quickEmojis,
    deleting: deleting ?? this.deleting,
    lastProblem: lastProblem ?? this.lastProblem,
    lastDeleted: lastDeleted ?? this.lastDeleted,
  );

  @override
  List<Object?> get props => [quickEmojis, deleting, lastProblem, lastDeleted];

  /// Counts only: emojis the user uses and messages are content, which does
  /// not belong in logs.
  @override
  String toString() =>
      'MessageActorState(quickEmojis: ${quickEmojis.length}, deleting: '
      '${deleting.length}, lastProblem: ${lastProblem?.action.name}, '
      'deleted: ${lastDeleted != null})';
}
