import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';

import '../../../domain/authentication/authentication_facade_interface.dart';
import '../../../domain/chats/chat.dart';
import '../../../domain/chats/chat_failure.dart';
import '../../../domain/chats/chat_repository_interface.dart';
import '../../../domain/chats/messages/message.dart';
import '../../../domain/chats/value_objects.dart';
import '../../../domain/core/value_objects.dart';
import '../../../domain/shared/user/user.dart';

part 'chat_bar_event.dart';

part 'chat_bar_state.dart';

part 'chat_bar_bloc.freezed.dart';

@injectable
class ChatBarBloc extends Bloc<ChatBarEvent, ChatBarState> {
  final IChatRepository _chatRepository;
  final IMessageRepository _messageRepository;
  final IAuthFacade _authFacade;
  var userId = '';

  ChatBarBloc(this._chatRepository, this._authFacade, this._messageRepository)
      : super(ChatBarState.initial()) {
    on<ChatBarEvent>((event, emit) async {
      if (userId.isEmpty) {
        userId = (await _authFacade.getSignedInUser())
            .getOrElse(() => User.empty())
            .id
            .getOrCrash();
      }

      await event.map(messageContentChanged: (event) {
        emit(
          state.copyWith(
            content: Content(event.contentString),
            chatCreationFailureOrSuccessOption: none(),
          ),
        );
      }, newChatCreated: (event) async {
        Either<ChatFailure, Unit>? failureOrSuccess;

        final content = state.content;
        if (content.isValid()) {
          emit(
            state.copyWith(
                isSubmitting: true, chatCreationFailureOrSuccessOption: none()),
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
              repliedMessageId: UniqueId.empty(),
              lastUpdatedAt: null,
              isEdited: false);

          final chat = Chat(
            id: UniqueId(),
            participantsList: ParticipantsList(
              participantsWithCurrentUserIdIncluded.map(
                (participantId) => Tuple2(
                  participantId,
                  UniqueId.empty(),
                ),
              ),
            ),
          );
          failureOrSuccess = await _chatRepository.create(chat, message);
        }

        emit(
          state.copyWith(
            isSubmitting: false,
            showErrorMessages: true,
            chatCreationFailureOrSuccessOption: optionOf(failureOrSuccess),
          ),
        );
      }, newMessageAddedToChatWithId: (event) {
        final content = Content(event.content);
        if (content.isValid()) {
          final message = Message(
              id: UniqueId(),
              senderId: UniqueId.fromUniqueString(userId),
              imageUrls: const KtList.empty(),
              reactions: const KtList.empty(),
              content: content,
              repliedMessageId: UniqueId.empty(),
              lastUpdatedAt: null,
              isEdited: false);
          _messageRepository.addMessageToChatWithId(message, event.chatId);
        }
      });
    });
  }
}
