import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/chats/chat_requests.dart';
import '../../../domain/core/value_objects.dart';
import '../../../domain/shared/user/current_user_session_interface.dart';

sealed class MessageRequestsEvent extends Equatable {
  const MessageRequestsEvent();

  /// Signed in: follow what the user decided about chats from people who are
  /// not their friends.
  const factory MessageRequestsEvent.started() = MessageRequestsStarted;
  const factory MessageRequestsEvent.accepted(UniqueId chatId) =
      MessageRequestAccepted;
  const factory MessageRequestsEvent.deleted(UniqueId chatId) =
      MessageRequestDeleted;
  const factory MessageRequestsEvent.allowFromAnyoneChanged(bool allow) =
      AllowMessagesFromAnyoneChanged;

  @override
  List<Object?> get props => const [];
}

final class MessageRequestsStarted extends MessageRequestsEvent {
  const MessageRequestsStarted();
}

final class MessageRequestAccepted extends MessageRequestsEvent {
  final UniqueId chatId;
  const MessageRequestAccepted(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

final class MessageRequestDeleted extends MessageRequestsEvent {
  final UniqueId chatId;
  const MessageRequestDeleted(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

final class AllowMessagesFromAnyoneChanged extends MessageRequestsEvent {
  final bool allow;
  const AllowMessagesFromAnyoneChanged(this.allow);
  @override
  List<Object?> get props => [allow];
}

final class _RequestsReceived extends MessageRequestsEvent {
  final ChatRequests requests;
  const _RequestsReceived(this.requests);
  @override
  List<Object?> get props => [requests];
}

final class MessageRequestsState extends Equatable {
  final ChatRequests requests;

  const MessageRequestsState({this.requests = const ChatRequests()});

  @override
  List<Object?> get props => [requests];

  @override
  String toString() => 'MessageRequestsState($requests)';
}

/// What the user decided about chats from people who are not their friends,
/// for every screen that needs it, and the decisions themselves. One for the
/// app, like the block list; it empties when the session ends.
class MessageRequestsBloc
    extends Bloc<MessageRequestsEvent, MessageRequestsState>
    implements IChatRequests {
  final IChatRequestsRepository _repository;
  StreamSubscription<ChatRequests>? _watch;

  MessageRequestsBloc(this._repository, ICurrentUserSession session)
    : super(const MessageRequestsState()) {
    session.ended.listen((_) {
      unawaited(_watch?.cancel());
      _watch = null;
      if (!isClosed) add(const _RequestsReceived(ChatRequests()));
    });
    on<MessageRequestsEvent>((event, emit) async {
      switch (event) {
        case MessageRequestsStarted():
          await _watch?.cancel();
          _watch = _repository.watch().listen((requests) {
            if (!isClosed) add(_RequestsReceived(requests));
          });

        case _RequestsReceived(:final requests):
          emit(MessageRequestsState(requests: requests));

        case MessageRequestAccepted(:final chatId):
          await _repository.accept(chatId);

        case MessageRequestDeleted(:final chatId):
          await _repository.delete(chatId);

        case AllowMessagesFromAnyoneChanged(:final allow):
          await _repository.setAllowFromAnyone(allow: allow);
      }
    });
  }

  @override
  ChatRequests get requests => state.requests;

  @override
  Stream<ChatRequests> get requestsChanges =>
      stream.map((state) => state.requests).distinct();

  @override
  Future<void> close() async {
    await _watch?.cancel();
    return super.close();
  }
}
