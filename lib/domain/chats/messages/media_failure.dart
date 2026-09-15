import 'package:equatable/equatable.dart';

/// Choosing, sending, showing or saving a photo or GIF failed. See the
/// subclasses.
sealed class MediaFailure extends Equatable {
  const MediaFailure();

  @override
  List<Object?> get props => const [];
}

/// The file is bigger than a message may carry.
final class MediaTooLarge extends MediaFailure {
  final int maxBytes;

  const MediaTooLarge(this.maxBytes);

  @override
  List<Object?> get props => [maxBytes];
}

/// More photos and GIFs were chosen than one message holds.
final class TooManyAttachments extends MediaFailure {
  final int max;

  const TooManyAttachments(this.max);

  @override
  List<Object?> get props => [max];
}

/// The file could not be read as a photo or GIF.
final class UnsupportedMedia extends MediaFailure {
  const UnsupportedMedia();
}

/// The file could not be downloaded.
final class MediaUnavailable extends MediaFailure {
  const MediaUnavailable();
}

/// The file downloaded but did not decrypt.
final class MediaUnreadable extends MediaFailure {
  const MediaUnreadable();
}

/// The app may not add photos to the phone's photos.
final class PhotoAccessDenied extends MediaFailure {
  const PhotoAccessDenied();
}

/// The photo could not be added to the phone's photos.
final class MediaNotSaved extends MediaFailure {
  const MediaNotSaved();
}
