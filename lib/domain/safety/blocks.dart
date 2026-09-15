import 'package:equatable/equatable.dart';

import '../core/value_objects.dart';

/// Someone the user blocked, now or before.
///
/// A block is silent: the blocked person is never told. What they send is
/// stored as usual, and the user's app keeps it out of sight: every message
/// sent while they were blocked, even after they are unblocked.
final class BlockRecord extends Equatable {
  final UniqueId userId;

  /// When the current block started; null while they are not blocked.
  final DateTime? blockedSince;

  /// Earlier blocks, each from when to when.
  final List<({DateTime from, DateTime to})> earlier;

  const BlockRecord({
    required this.userId,
    this.blockedSince,
    this.earlier = const [],
  });

  bool get isBlocked => blockedSince != null;

  /// Whether something sent at [sentAt] came while they were blocked.
  bool covers(DateTime sentAt) {
    final since = blockedSince;
    if (since != null && !sentAt.isBefore(since)) return true;
    return earlier.any(
      (block) => !sentAt.isBefore(block.from) && sentAt.isBefore(block.to),
    );
  }

  @override
  List<Object?> get props => [userId, blockedSince, earlier];
}

/// Everyone the user blocked, now or before, by user id.
final class Blocks extends Equatable {
  final Map<String, BlockRecord> byUserId;

  const Blocks([this.byUserId = const {}]);

  bool isBlocked(UniqueId userId) =>
      byUserId[userId.getOrCrash()]?.isBlocked ?? false;

  /// The people blocked now.
  List<UniqueId> get blockedUserIds => [
    for (final record in byUserId.values)
      if (record.isBlocked) record.userId,
  ];

  /// Whether what [senderId] sent at [sentAt] stays out of sight: sent while
  /// they were blocked. Something not yet dated counts while they are blocked.
  bool hides(UniqueId senderId, DateTime? sentAt) {
    final record = byUserId[senderId.getOrCrash()];
    if (record == null) return false;
    return sentAt == null ? record.isBlocked : record.covers(sentAt);
  }

  @override
  List<Object?> get props => [byUserId];

  /// Counts only: who the user blocked stays out of logs.
  @override
  String toString() => 'Blocks(${blockedUserIds.length} blocked)';
}

/// The people the user blocked, now and as it changes.
abstract interface class IBlockList {
  Blocks get blocks;

  Stream<Blocks> get blocksChanges;
}
