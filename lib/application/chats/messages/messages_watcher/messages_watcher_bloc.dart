import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../../../domain/chats/messages/message_failure.dart';

part 'messages_watcher_event.dart';

part 'messages_watcher_state.dart';

part 'messages_watcher_bloc.freezed.dart';

@injectable
class MessagesWatcherBloc
    extends Bloc<MessagesWatcherEvent, MessagesWatcherState> {
  final IMessageRepository _messageRepository;

  StreamSubscription<Either<MessageFailure, KtList<Message>>>?
      _messagesSubscription;

  MessagesWatcherBloc(this._messageRepository)
      : super(const MessagesWatcherState.initial()) {
    on<MessagesWatcherEvent>(
      (event, emit) {
        event.map(
          watchAllStartedForChatWithId: (event) {
            emit(const MessagesWatcherState.loadInProgress());
            _messagesSubscription = _messageRepository
                .watchAllForChatWithId(event.chatId)
                .listen(
                  (failureOrMessage) => add(
                    MessagesWatcherEvent.messagesReceived(
                        failureOrMessage),
                  ),
                );
          },
          messagesReceived: (event) {
            emit(
              event.failureOrMessages.fold(
                (failure) =>
                    MessagesWatcherState.loadFailure(failure),
                (messages) =>
                    MessagesWatcherState.loadSuccess(
                        messages),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
