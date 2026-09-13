part of 'chat_bar_bloc.dart';

@freezed
abstract class ChatBarState with _$ChatBarState {
  const factory ChatBarState({
    required Content content,
    required bool isSubmitting,
    required bool showErrorMessages,
    required Option<Either<ChatFailure, Unit>>
    chatCreationFailureOrSuccessOption,
  }) = _ChatBarState;

  factory ChatBarState.initial() => ChatBarState(
    content: Content(''),
    isSubmitting: false,
    showErrorMessages: false,
    chatCreationFailureOrSuccessOption: none(),
  );
}
