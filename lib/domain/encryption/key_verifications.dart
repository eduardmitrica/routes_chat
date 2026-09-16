import 'package:equatable/equatable.dart';

import 'safety_number.dart';

/// Where the user stands with one person's keys.
enum KeyVerificationState {
  /// Never compared.
  unverified,

  /// Compared, and the number still matches.
  verified,

  /// Compared before, but the number is not the one that was checked: their
  /// keys changed, or someone put other keys in their place.
  changed,
}

/// One person's keys as the user checked them.
final class KeyVerification extends Equatable {
  /// The number that was compared.
  final SafetyNumber number;

  final DateTime at;

  /// The number the user was warned about and waved away, if any. A further
  /// change warns again.
  final SafetyNumber? warningSeenFor;

  const KeyVerification({
    required this.number,
    required this.at,
    this.warningSeenFor,
  });

  KeyVerification withWarningSeenFor(SafetyNumber number) =>
      KeyVerification(number: this.number, at: at, warningSeenFor: number);

  @override
  List<Object?> get props => [number, at, warningSeenFor];
}

/// Whose keys the user has checked, kept on this phone only.
final class KeyVerifications extends Equatable {
  final Map<String, KeyVerification> byUserId;

  const KeyVerifications({this.byUserId = const {}});

  KeyVerification? forUser(String userId) => byUserId[userId];

  /// Where [userId] stands, given the number their keys make now.
  KeyVerificationState stateOf(String userId, SafetyNumber? now) {
    final verification = byUserId[userId];
    if (verification == null || now == null) {
      return KeyVerificationState.unverified;
    }
    return verification.number == now
        ? KeyVerificationState.verified
        : KeyVerificationState.changed;
  }

  /// Whether the chat with [userId] should warn that their number changed:
  /// it did, and the user has not waved this one away yet.
  bool warnsAbout(String userId, SafetyNumber? now) =>
      stateOf(userId, now) == KeyVerificationState.changed &&
      byUserId[userId]?.warningSeenFor != now;

  @override
  List<Object?> get props => [byUserId];

  /// Counts only: whom the user checked stays out of the logs.
  @override
  String toString() => 'KeyVerifications(${byUserId.length} checked)';
}

/// The people whose keys the user has checked, on this phone.
abstract interface class IKeyVerificationsRepository {
  /// What the phone holds, as it changes.
  Stream<KeyVerifications> watch();

  /// The user compared [number] with [userId] and it matched.
  Future<void> verify(String userId, SafetyNumber number);

  /// Drops what was checked for [userId], which stops the warnings too.
  Future<void> forget(String userId);

  /// The user has seen the warning that [userId]'s number is now [number].
  Future<void> warningSeen(String userId, SafetyNumber number);
}

/// What the screens read: the verifications, without the storage.
abstract interface class IKeyVerifications {
  KeyVerifications get verifications;

  Stream<KeyVerifications> get verificationsChanges;
}
