import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

import '../../../domain/chats/chat.dart';
import '../../../domain/chats/chat_repository_interface.dart';
import '../../../domain/chats/messages/message.dart';
import '../../../domain/chats/messages/value_objects.dart';

part 'chat_actor_event.dart';

part 'chat_actor_state.dart';

class ChatActorBloc extends Bloc<ChatActorEvent, ChatActorState> {
  final IChatRepository _chatRepository;
  final ICurrentUserSession _session;

  ChatActorBloc(this._chatRepository, this._session)
    : super(const ChatActorState.initial()) {
    on<ChatActorEvent>((event, emit) async {
      final userId = _session.current?.id ?? '';

      switch (event) {
        case ChatActorCreated():
          {
            emit(const ChatActorState.actionInProgress());
            var participantsWithCurrentUserIdIncluded =
                event.otherThanCurrentParticipantIds.toMutableList()
                  ..add(UniqueId.fromUniqueString(userId));

            final message = Message(
              id: UniqueId(),
              senderId: UniqueId.fromUniqueString(userId),
              imageUrls: const KtList.empty(),
              reactions: const KtList.empty(),
              content: Content('idk'),
              repliedMessageId: UniqueId.empty(),
              lastUpdatedAt: null,
              isEdited: false,
            );

            final chat = Chat(
              id: UniqueId(),
              participantsList: ParticipantsList(
                participantsWithCurrentUserIdIncluded.map(
                  (participantId) => Tuple2(
                    participantId,
                    UniqueId.fromUniqueString('No message seen'),
                  ),
                ),
              ),
              lastMessage: message,
            );
            final operationResult = await _chatRepository.create(
              chat,
              event.firstMessage,
            );
            emit(
              operationResult.fold(
                (failure) => ChatActorState.creationFailure(failure),
                (_) => const ChatActorState.creationSuccess(),
              ),
            );
          }
      }
    });
  }
}
