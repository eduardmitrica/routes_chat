import 'package:equatable/equatable.dart';

/// What the user lets others see of their activity. Each works both ways:
/// someone who hides that they are typing does not see others typing either,
/// so nobody watches without being watched.
final class PrivacySettings extends Equatable {
  /// Whether others see when this user is typing, and they see others.
  final bool shareTyping;

  /// Whether others see when this user is online or was last seen, and they
  /// see others.
  final bool shareOnline;

  const PrivacySettings({this.shareTyping = true, this.shareOnline = true});

  PrivacySettings copyWith({bool? shareTyping, bool? shareOnline}) =>
      PrivacySettings(
        shareTyping: shareTyping ?? this.shareTyping,
        shareOnline: shareOnline ?? this.shareOnline,
      );

  @override
  List<Object?> get props => [shareTyping, shareOnline];
}

/// The user's current privacy settings, and their changes.
abstract interface class IPrivacySettingsReader {
  PrivacySettings get privacy;

  Stream<PrivacySettings> get privacyChanges;
}
