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
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';

part 'chat_bar_event.dart';

part 'chat_bar_state.dart';

part 'chat_bar_bloc.freezed.dart';

class ChatBarBloc extends Bloc<ChatBarEvent, ChatBarState> {
  final IChatRepository _chatRepository;
  final IMessageRepository _messageRepository;
  final ICurrentUserSession _session;
  final IMediaRepository _mediaRepository;

  ChatBarBloc(
    this._chatRepository,
    this._messageRepository,
    this._session,
    this._mediaRepository,
  ) : super(ChatBarState.initial()) {
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
        case MediaPicked(:final paths):
          final room = MediaLimits.maxPerMessage - state.media.size;
          emit(
            state.copyWith(preparingMedia: true, mediaFailureOption: none()),
          );
          final drafts = <MediaDraft>[];
          MediaFailure? failure;
          for (final path in paths.take(room)) {
            (await _mediaRepository.prepare(path)).fold((problem) {
              failure ??= problem;
            }, drafts.add);
          }
          if (paths.length > room) {
            failure ??= const TooManyAttachments(MediaLimits.maxPerMessage);
          }
          emit(
            state.copyWith(
              media: state.media.plus(drafts.toImmutableList()),
              preparingMedia: false,
              mediaFailureOption: optionOf(failure),
            ),
          );
        case MediaRemoved(:final id):
          emit(
            state.copyWith(
              media: state.media.filter((draft) => draft.id != id),
              mediaFailureOption: none(),
            ),
          );
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
              failureOrSuccess = await _chatRepository.create(
                chat,
                message,
                media: state.media,
              );
            }

            emit(
              state.copyWith(
                isSubmitting: false,
                showErrorMessages: true,
                // Photos stay chosen after a failure, to try again.
                media: failureOrSuccess?.isRight() ?? false
                    ? const KtList.empty()
                    : state.media,
                chatCreationFailureOrSuccessOption: optionOf(failureOrSuccess),
                messageSendFailureOrSuccessOption: none(),
              ),
            );
          }
        case NewMessageAddedToChatWithId():
          {
            final content = Content(event.content);
            final hasSomething =
                event.content.trim().isNotEmpty || state.media.isNotEmpty();
            if (content.isValid() && hasSomething) {
              // The reply goes out with this message, not with the next.
              final replyTo = state.replyingTo;
              emit(state.copyWith(replyingTo: null, isSubmitting: true));
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
                  .addMessageToChatWithId(
                    message,
                    event.chatId,
                    media: state.media,
                  );
              emit(
                state.copyWith(
                  isSubmitting: false,
                  // Photos stay chosen after a failure, to try again.
                  media: failureOrSuccess.isRight()
                      ? const KtList.empty()
                      : state.media,
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
