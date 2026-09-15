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

  /// Whether others see when this user has read their messages, and they see
  /// when others read theirs.
  final bool shareReadReceipts;

  const PrivacySettings({
    this.shareTyping = true,
    this.shareOnline = true,
    this.shareReadReceipts = true,
  });

  PrivacySettings copyWith({
    bool? shareTyping,
    bool? shareOnline,
    bool? shareReadReceipts,
  }) => PrivacySettings(
    shareTyping: shareTyping ?? this.shareTyping,
    shareOnline: shareOnline ?? this.shareOnline,
    shareReadReceipts: shareReadReceipts ?? this.shareReadReceipts,
  );

  @override
  List<Object?> get props => [shareTyping, shareOnline, shareReadReceipts];
}

/// The user's current privacy settings, and their changes.
abstract interface class IPrivacySettingsReader {
  PrivacySettings get privacy;

  Stream<PrivacySettings> get privacyChanges;
}
