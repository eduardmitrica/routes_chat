import 'package:routes_chat/domain/chats/messages/media_failure.dart';

/// What to tell the user when a photo or GIF could not be added, shown or
/// saved.
String mediaFailureMessage(MediaFailure failure) => switch (failure) {
  MediaTooLarge(:final maxBytes) =>
    'That file is too big to send. The limit is '
        '${maxBytes ~/ (1024 * 1024)} MB.',
  TooManyAttachments(:final max) =>
    'A message can hold up to $max photos and GIFs.',
  UnsupportedMedia() => 'That file isn\'t a photo or GIF this app can send.',
  MediaUnavailable() || MediaUnreadable() => 'That photo could not be loaded.',
  PhotoAccessDenied() =>
    'Routes Chat isn\'t allowed to add to your photos. You can allow it in '
        'the phone\'s settings.',
  MediaNotSaved() => 'That photo could not be saved.',
  VoiceTooShort() => 'Hold the microphone to record a voice message.',
  MicrophoneDenied() =>
    'Routes Chat isn\'t allowed to use the microphone. You can allow it in '
        'the phone\'s settings.',
};
