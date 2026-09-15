import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../core/value_objects.dart';
import 'blocks.dart';

/// Why someone is reported.
enum ReportReason {
  spam,
  harassment,
  inappropriate,
  impersonation,
  other;

  /// As stored, literally, which firestore.rules check; a test keeps them
  /// equal.
  String get storedName => switch (this) {
    ReportReason.spam => 'spam',
    ReportReason.harassment => 'harassment',
    ReportReason.inappropriate => 'inappropriate',
    ReportReason.impersonation => 'impersonation',
    ReportReason.other => 'other',
  };

  String get label => switch (this) {
    ReportReason.spam => 'Spam or scam',
    ReportReason.harassment => 'Harassment or bullying',
    ReportReason.inappropriate => 'Nudity or violence',
    ReportReason.impersonation => 'Pretending to be someone',
    ReportReason.other => 'Something else',
  };
}

/// A message a report shares, in readable form, with the reporter's consent.
final class ReportedMessage extends Equatable {
  /// The most messages a report shares.
  static const maxPerReport = 5;

  final UniqueId messageId;
  final UniqueId senderId;

  /// Its text, or what it holds ("Photo"). Photos themselves are not shared.
  final String text;
  final DateTime sentAt;

  const ReportedMessage({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [messageId, senderId, text, sentAt];

  /// The id only: the text is decrypted content.
  @override
  String toString() => 'ReportedMessage(${messageId.getOrCrash()})';
}

sealed class SafetyFailure {}

final class SafetyInsufficientPermissions extends SafetyFailure {}

final class SafetyUnexpected extends SafetyFailure {}

/// Blocking people, and reporting them.
abstract interface class ISafetyRepository {
  /// Everyone the signed-in user blocked, now or before, as it changes.
  Stream<Blocks> watchBlocks();

  /// Blocks [userId], silently: also ends the friendship with them, and
  /// deletes what they could see of the user in their chat (typing, how far
  /// the user read). Blocking someone blocked already changes nothing.
  Future<Either<SafetyFailure, Unit>> block(UniqueId userId);

  /// Unblocks [userId]. What they sent while blocked stays hidden.
  Future<Either<SafetyFailure, Unit>> unblock(UniqueId userId);

  /// Reports [reportedId] for [reason], sharing [messages] of [chatId].
  Future<Either<SafetyFailure, Unit>> report({
    required UniqueId reportedId,
    UniqueId? chatId,
    required ReportReason reason,
    List<ReportedMessage> messages = const [],
  });
}
