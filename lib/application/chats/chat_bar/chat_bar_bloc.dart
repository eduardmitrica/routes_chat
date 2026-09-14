import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart'
    as message_failure;
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

import '../../../domain/chats/chat.dart';
import '../../../domain/chats/chat_failure.dart';
import '../../../domain/chats/chat_repository_interface.dart';
import '../../../domain/chats/messages/message.dart';
import '../../../domain/chats/value_objects.dart';
import '../../../domain/core/composite_id.dart';
import '../../../domain/core/value_objects.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';

part 'chat_bar_event.dart';

part 'chat_bar_state.dart';

part 'chat_bar_bloc.freezed.dart';

class ChatBarBloc extends Bloc<ChatBarEvent, ChatBarState> {
  final IChatRepository _chatRepository;
  final IMessageRepository _messageRepository;
  final ICurrentUserSession _session;

  ChatBarBloc(this._chatRepository, this._messageRepository, this._session)
    : super(ChatBarState.initial()) {
    on<ChatBarEvent>((event, emit) async {
      final userId = _session.current?.id ?? '';

      switch (event) {
        case MessageContentChanged():
          emit(
            state.copyWith(
              content: Content(event.contentString),
              chatCreationFailureOrSuccessOption: none(),
              messageSendFailureOrSuccessOption: none(),
            ),
          );
        case ReplyStarted(:final message):
          emit(state.copyWith(replyingTo: MessageQuote.of(message)));
        case ReplyCancelled():
          emit(state.copyWith(replyingTo: null));
        case NewChatCreated():
          {
            Either<ChatFailure, Unit>? failureOrSuccess;

            final content = state.content;
            if (content.isValid()) {
              emit(
                state.copyWith(
                  isSubmitting: true,
                  chatCreationFailureOrSuccessOption: none(),
                  messageSendFailureOrSuccessOption: none(),
                ),
              );

              var participantsWithCurrentUserIdIncluded =
                  event.otherThanCurrentParticipantIds.toMutableList()
                    ..add(UniqueId.fromUniqueString(userId));

              final message = Message(
                id: UniqueId(),
                senderId: UniqueId.fromUniqueString(userId),
                imageUrls: const KtList.empty(),
                reactions: const KtList.empty(),
                content: content,

                lastUpdatedAt: null,
                isEdited: false,
              );

              final chat = Chat(
                // One chat per pair of participants; see compositeId.
                id: compositeId(participantsWithCurrentUserIdIncluded.asList()),
                participantsList: ParticipantsList(
                  participantsWithCurrentUserIdIncluded.map(
                    (participantId) => Tuple2(participantId, UniqueId.empty()),
                  ),
                ),
                lastMessage: message,
              );
              failureOrSuccess = await _chatRepository.create(chat, message);
            }

            emit(
              state.copyWith(
                isSubmitting: false,
                showErrorMessages: true,
                chatCreationFailureOrSuccessOption: optionOf(failureOrSuccess),
                messageSendFailureOrSuccessOption: none(),
              ),
            );
          }
        case NewMessageAddedToChatWithId():
          {
            final content = Content(event.content);
            if (content.isValid()) {
              // The reply goes out with this message, not with the next.
              final replyTo = state.replyingTo;
              emit(state.copyWith(replyingTo: null));
              final message = Message(
                id: UniqueId(),
                senderId: UniqueId.fromUniqueString(userId),
                imageUrls: const KtList.empty(),
                reactions: const KtList.empty(),
                content: content,
                replyTo: replyTo,
                lastUpdatedAt: null,
                isEdited: false,
              );
              // The message bar has already cleared the text, so the outcome
              // is kept in state for the page to report; ignoring it made a
              // failed send vanish.
              final failureOrSuccess = await _messageRepository
                  .addMessageToChatWithId(message, event.chatId);
              emit(
                state.copyWith(
                  chatCreationFailureOrSuccessOption: none(),
                  messageSendFailureOrSuccessOption: some(failureOrSuccess),
                ),
              );
            }
          }
      }
    });
  }
}
