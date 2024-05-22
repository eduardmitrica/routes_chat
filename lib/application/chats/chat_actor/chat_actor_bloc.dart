import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../../domain/authentication/authentication_facade_interface.dart';
import '../../../domain/chats/chat.dart';
import '../../../domain/chats/chat_repository_interface.dart';
import '../../../domain/chats/messages/message.dart';
import '../../../domain/shared/user/user.dart';

part 'chat_actor_event.dart';

part 'chat_actor_state.dart';

part 'chat_actor_bloc.freezed.dart';

@injectable
class ChatActorBloc extends Bloc<ChatActorEvent, ChatActorState> {
  final IChatRepository _chatRepository;
  final IAuthFacade _authFacade;
  var userId = '';

  ChatActorBloc(this._chatRepository, this._authFacade)
      : super(const ChatActorState.initial()) {
    on<ChatActorEvent>(
      (event, emit) async {
        if (userId.isEmpty) {
          userId = (await _authFacade.getSignedInUser())
              .getOrElse(() => User.empty())
              .id
              .getOrCrash();
        }

        await event.map(
          created: (event) async {
            emit(const ChatActorState.actionInProgress());
            var participantsWithCurrentUserIdIncluded =
                event.otherThanCurrentParticipantIds.toMutableList()
                  ..add(UniqueId.fromUniqueString(userId));

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
                messages: [event.firstMessage].toImmutableList());
            final operationResult = await _chatRepository.create(chat);
            emit(operationResult.fold(
                (failure) => ChatActorState.creationFailure(failure),
                (_) => const ChatActorState.creationSuccess()));
          },
        );
      },
    );
  }
}
