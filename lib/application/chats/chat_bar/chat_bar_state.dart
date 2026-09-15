part of 'chat_bar_bloc.dart';

@freezed
abstract class ChatBarState with _$ChatBarState {
  const factory ChatBarState({
    /// The chat being written in, known once the bloc has started.
    UniqueId? chatId,

    /// What the user has typed.
    @Default('') String text,

    /// Counts the times [text] was set from outside the field, such as from a
    /// restored draft, so the field shows the new text rather than keeping its
    /// own.
    @Default(0) int textRevision,

    /// The message the next one sent answers, while the user is replying.
    MessageQuote? replyingTo,

    /// Photos and GIFs chosen for the next message, ready to send.
    @Default(KtList<MediaDraft>.empty()) KtList<MediaDraft> media,

    /// Whether chosen photos are still being made ready.
    @Default(false) bool preparingMedia,

    /// Why the last photos chosen could not all be added.
    required Option<MediaFailure> mediaFailureOption,

    /// The messages of this chat on their way, in the order they were sent.
    @Default(KtList<OutgoingMessage>.empty()) KtList<OutgoingMessage> outgoing,

    /// Counts the messages the user asked to delete while they were being
    /// sent, which were not deleted, so the page can say so each time.
    @Default(0) int discardsRefused,

    /// The message the user is editing. Meanwhile [text] is its new text,
    /// and the draft waits, to come back once the edit ends.
    Message? editing,

    /// Whether the edit is being saved.
    @Default(false) bool savingEdit,

    /// Why the last edit could not be saved.
    MessageFailure? lastEditFailure,

    /// Counts the edits that could not be saved, so the page can say so each
    /// time.
    @Default(0) int editFailures,

    /// The message edited last, as it is now.
    Message? lastEdited,
  }) = _ChatBarState;

  factory ChatBarState.initial() => ChatBarState(mediaFailureOption: none());
}
