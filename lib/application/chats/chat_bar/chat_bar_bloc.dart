import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/messages/local_chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/composite_id.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/presence/presence_repository_interface.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

part 'chat_bar_event.dart';

part 'chat_bar_state.dart';

part 'chat_bar_bloc.freezed.dart';

/// What the user writes in a chat, and the messages of the chat on their way.
///
/// What is written (its text, the message it replies to and its photos) is
/// kept on the phone as a draft until it is sent. Then the outbox keeps it
/// until it arrives, trying again when sending fails.
class ChatBarBloc extends Bloc<ChatBarEvent, ChatBarState> {
  /// How long typing pauses before the draft is saved.
  static const defaultDraftDelay = Duration(milliseconds: 500);

  /// How often, at most, the other person is told the user is still typing.
  /// Their app shows typing for a little longer than this.
  static const defaultTypingRefresh = Duration(seconds: 3);

  /// How long typing pauses before the other person is told it stopped.
  static const defaultTypingPause = Duration(seconds: 5);

  final ICurrentUserSession _session;
  final IMediaRepository _mediaRepository;
  final IDraftRepository _drafts;
  final MessageOutbox _outbox;
  final Duration _draftDelay;
  final IPresenceRepository? _presence;
  final IPrivacySettingsReader? _privacy;
  final Duration _typingRefresh;
  final Duration _typingPause;

  UniqueId? _otherUserId;
  Timer? _draftTimer;
  StreamSubscription<KtList<OutgoingMessage>>? _outgoing;
  DateTime? _typingSentAt;
  Timer? _typingPauseTimer;

  ChatBarBloc(
    this._session,
    this._mediaRepository,
    this._drafts,
    this._outbox, {
    Duration draftDelay = defaultDraftDelay,
    IPresenceRepository? presence,
    IPrivacySettingsReader? privacy,
    Duration typingRefresh = defaultTypingRefresh,
    Duration typingPause = defaultTypingPause,
  }) : _draftDelay = draftDelay,
       _presence = presence,
       _privacy = privacy,
       _typingRefresh = typingRefresh,
       _typingPause = typingPause,
       super(ChatBarState.initial()) {
    on<ChatBarEvent>((event, emit) async {
      switch (event) {
        case ChatBarStarted(:final otherUserId):
          final userId = _session.current?.id;
          if (userId == null) return;
          _otherUserId = otherUserId;
          // The chat's id follows from its participants, so a chat that does
          // not exist yet already has one to keep a draft under.
          final chatId = compositeId([
            UniqueId.fromUniqueString(userId),
            otherUserId,
          ]);
          emit(state.copyWith(chatId: chatId));
          await _outgoing?.cancel();
          _outgoing = _outbox
              .watch(chatId)
              .listen(
                (messages) => add(ChatBarEvent.outgoingChanged(messages)),
              );
          final draft = await _loadDraft(chatId);
          final untouched =
              state.text.isEmpty &&
              state.replyingTo == null &&
              state.media.isEmpty();
          if (draft != null && untouched) {
            emit(
              state.copyWith(
                text: draft.text,
                textRevision: state.textRevision + 1,
                replyingTo: draft.replyTo,
                media: draft.media,
              ),
            );
          }

        case MessageContentChanged(:final contentString):
          emit(state.copyWith(text: contentString));
          _saveDraftSoon();
          _typed(contentString);

        case ReplyStarted(:final message):
          emit(state.copyWith(replyingTo: MessageQuote.of(message)));
          await _saveDraft();

        case ReplyCancelled():
          emit(state.copyWith(replyingTo: null));
          await _saveDraft();

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
          await _saveDraft();

        case MediaRemoved(:final id):
          emit(
            state.copyWith(
              media: state.media.filter((draft) => draft.id != id),
              mediaFailureOption: none(),
            ),
          );
          await _saveDraft();

        case MessageSent(:final text, :final chatExists):
          final userId = _session.current?.id;
          final chatId = state.chatId;
          final otherUserId = _otherUserId;
          final content = Content(text);
          final hasSomething =
              text.trim().isNotEmpty || state.media.isNotEmpty();
          if (userId == null ||
              chatId == null ||
              otherUserId == null ||
              !content.isValid() ||
              !hasSomething ||
              state.preparingMedia) {
            return;
          }
          final outgoing = OutgoingMessage(
            message: Message(
              id: UniqueId(),
              senderId: UniqueId.fromUniqueString(userId),
              imageUrls: const KtList.empty(),
              reactions: const KtList.empty(),
              content: content,
              replyTo: state.replyingTo,
              lastUpdatedAt: null,
              isEdited: false,
            ),
            chatId: chatId,
            startsChatWith: chatExists
                ? const KtList.empty()
                : KtList.of(otherUserId),
            media: state.media,
            queuedAt: DateTime.now(),
          );
          _draftTimer?.cancel();
          _stopTyping();
          // The field has already cleared itself.
          emit(
            state.copyWith(
              text: '',
              replyingTo: null,
              media: const KtList.empty(),
              mediaFailureOption: none(),
            ),
          );
          // Kept in the outbox before the draft is cleared, so the message is
          // on the phone the whole time.
          await _outbox.enqueue(outgoing);
          await _saveDraft();

        case OutgoingChanged(:final messages):
          emit(state.copyWith(outgoing: messages));

        case OutgoingRetryRequested(:final messageId):
          await _outbox.retry(messageId);

        case OutgoingDiscardRequested(:final messageId):
          if (!await _outbox.discard(messageId)) {
            emit(state.copyWith(discardsRefused: state.discardsRefused + 1));
          }
      }
    });
  }

  /// Tells the other person the user is typing, while the user shares it:
  /// at most every [_typingRefresh], and that it stopped once typing pauses
  /// for [_typingPause] or the field empties.
  void _typed(String text) {
    final presence = _presence;
    final chatId = state.chatId;
    if (presence == null ||
        chatId == null ||
        !(_privacy?.privacy.shareTyping ?? false)) {
      return;
    }
    if (text.trim().isEmpty) {
      _stopTyping();
      return;
    }
    final now = DateTime.now();
    final sentAt = _typingSentAt;
    if (sentAt == null || now.difference(sentAt) >= _typingRefresh) {
      _typingSentAt = now;
      unawaited(presence.startTyping(chatId));
    }
    _typingPauseTimer?.cancel();
    _typingPauseTimer = Timer(_typingPause, _stopTyping);
  }

  void _stopTyping() {
    _typingPauseTimer?.cancel();
    _typingPauseTimer = null;
    if (_typingSentAt == null) return;
    _typingSentAt = null;
    final chatId = state.chatId;
    if (chatId != null) unawaited(_presence?.stopTyping(chatId));
  }

  void _saveDraftSoon() {
    _draftTimer?.cancel();
    _draftTimer = Timer(_draftDelay, () => unawaited(_saveDraft()));
  }

  Future<void> _saveDraft() async {
    _draftTimer?.cancel();
    final chatId = state.chatId;
    if (chatId == null) return;
    try {
      await _drafts.saveDraft(
        chatId,
        ChatDraft(
          text: state.text,
          replyTo: state.replyingTo,
          media: state.media,
        ),
      );
    } on Object catch (error) {
      debugPrint('Draft not saved: ${error.runtimeType}');
    }
  }

  Future<ChatDraft?> _loadDraft(UniqueId chatId) async {
    try {
      return await _drafts.loadDraft(chatId);
    } on Object catch (error) {
      debugPrint('Draft not loaded: ${error.runtimeType}');
      return null;
    }
  }

  /// Saves what was typed just before the chat closed.
  @override
  Future<void> close() async {
    _stopTyping();
    await _outgoing?.cancel();
    if (_draftTimer?.isActive ?? false) await _saveDraft();
    return super.close();
  }
}
