import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/emoji_usage.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_changes.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

part 'message_actor_event.dart';

part 'message_actor_state.dart';

/// What the user does to the messages of a chat that arrived: reacting to
/// them, and deleting their own for everyone. Editing happens where they
/// write, in ChatBarBloc.
///
/// The emojis offered first are the ones the user uses most, learned on the
/// phone. There is no fixed set: until they react or send an emoji, only the
/// full picker is offered.
class MessageActorBloc extends Bloc<MessageActorEvent, MessageActorState> {
  /// How many of the user's favourite emojis are offered first.
  static const quickEmojiCount = 6;

  final IMessageRepository _messages;
  final IEmojiPreferences _emojis;
  final ICurrentUserSession _session;

  var _problems = 0;

  MessageActorBloc(this._messages, this._emojis, this._session)
    : super(const MessageActorState()) {
    on<MessageActorEvent>((event, emit) async {
      switch (event) {
        case QuickEmojisRequested():
          emit(state.copyWith(quickEmojis: await _favourites()));

        case ReactionPicked(:final chatId, :final message, :final emoji):
          final userId = _session.current?.id;
          if (userId == null || !message.canBeReactedTo) return;
          final current = message.reactions
              .firstOrNull((reaction) => reaction.userId.getOrCrash() == userId)
              ?.emoji;
          // Picking the reaction the user has takes it back.
          final next = current == emoji ? null : emoji;
          if (next != null) {
            await _emojis.recordUse([next]);
            emit(state.copyWith(quickEmojis: await _favourites()));
          }
          (await _messages.react(chatId, message, next)).fold(
            (failure) => emit(
              state.copyWith(
                lastProblem: MessageProblem(
                  MessageAction.react,
                  failure,
                  number: ++_problems,
                ),
              ),
            ),
            (_) {},
          );

        case ReactionRemoved(:final chatId, :final message):
          (await _messages.react(chatId, message, null)).fold(
            (failure) => emit(
              state.copyWith(
                lastProblem: MessageProblem(
                  MessageAction.react,
                  failure,
                  number: ++_problems,
                ),
              ),
            ),
            (_) {},
          );

        case DeleteRequested(:final chatId, :final message):
          final id = message.id.getOrCrash();
          final userId = _session.current?.id;
          if (userId == null ||
              !message.canBeDeletedBy(userId) ||
              state.deleting.contains(id)) {
            return;
          }
          emit(state.copyWith(deleting: {...state.deleting, id}));
          final result = await _messages.deleteMessage(chatId, message);
          final deleting = {...state.deleting}..remove(id);
          emit(
            result.fold(
              (failure) => state.copyWith(
                deleting: deleting,
                lastProblem: MessageProblem(
                  MessageAction.delete,
                  failure,
                  number: ++_problems,
                ),
              ),
              (deleted) =>
                  state.copyWith(deleting: deleting, lastDeleted: deleted),
            ),
          );
      }
    });
  }

  Future<List<String>> _favourites() =>
      _emojis.favourites(count: quickEmojiCount);
}
