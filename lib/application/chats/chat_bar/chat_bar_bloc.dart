import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';

import '../../../domain/chats/chat.dart';
import '../../../domain/chats/chat_failure.dart';
import '../../../domain/chats/chat_repository_interface.dart';
import '../../../domain/chats/messages/message.dart';
import '../../../domain/chats/value_objects.dart';
import '../../../domain/core/value_objects.dart';
import '../../../injection.dart';

part 'chat_bar_event.dart';

part 'chat_bar_state.dart';

part 'chat_bar_bloc.freezed.dart';

@injectable
class ChatBarBloc extends Bloc<ChatBarEvent, ChatBarState> {
  final IChatRepository _chatRepository;
  final IMessageRepository _messageRepository;
  var userId = '';

  ChatBarBloc(this._chatRepository, this._messageRepository)
      : super(ChatBarState.initial()) {
    on<ChatBarEvent>((event, emit) async {
      if (userId.isEmpty) {
        userId = getIt<CurrentUseInformationPersistent>().id;
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
            lastMessage: message,
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
