part of 'chat_bar_bloc.dart';

@freezed
abstract class ChatBarState with _$ChatBarState {
  const factory ChatBarState({
    required Content content,
    required bool isSubmitting,
    required bool showErrorMessages,
    required Option<Either<ChatFailure, Unit>>
    chatCreationFailureOrSuccessOption,

    /// The outcome of the last message sent to an existing chat. At most one
    /// of this and [chatCreationFailureOrSuccessOption] is set: each send
    /// clears the other, so the page only ever reports the latest attempt.
    required Option<Either<message_failure.MessageFailure, Unit>>
    messageSendFailureOrSuccessOption,
  }) = _ChatBarState;

  factory ChatBarState.initial() => ChatBarState(
    content: Content(''),
    isSubmitting: false,
    showErrorMessages: false,
    chatCreationFailureOrSuccessOption: none(),
    messageSendFailureOrSuccessOption: none(),
  );
}
