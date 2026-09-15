import 'package:equatable/equatable.dart';

import '../core/value_objects.dart';
import 'chat.dart';

/// How far the user has read each chat on this phone.
///
/// Kept on the phone whatever the user shares, since it only decides which
/// chats the list shows as unread. Read receipts others see are separate
/// (IPresenceRepository.markRead).
final class ChatReads extends Equatable {
  /// When the phone started keeping track. Anything sent before counts as
  /// read, so a new phone does not show every chat as unread.
  final DateTime since;

  /// When the newest message read in each chat was sent, by chat id.
  final Map<String, DateTime> readUpTo;

  const ChatReads({required this.since, this.readUpTo = const {}});

  /// When the newest message read in [chatId] was sent.
  DateTime readUpToIn(String chatId) {
    final read = readUpTo[chatId];
    return read != null && read.isAfter(since) ? read : since;
  }

  /// Whether [chat] ends with a message from someone else, sent after what
  /// [userId] has read there.
  bool isUnread(Chat chat, String userId) {
    final last = chat.lastMessage;
    final sentAt = last.lastUpdatedAt;
    return sentAt != null &&
        last.senderId.getOrCrash() != userId &&
        sentAt.isAfter(readUpToIn(chat.id.getOrCrash()));
  }

  @override
  List<Object?> get props => [since, readUpTo];

  /// Counts only: which chats the user reads, and when, stays out of logs.
  @override
  String toString() => 'ChatReads(${readUpTo.length} chats)';
}

/// Keeps how far the user has read each chat, on this phone.
abstract interface class IChatReads {
  /// How far the user has read, now and each time it changes.
  Stream<ChatReads> watch();

  /// The user has read [chatId] up to a message sent at [sentAt]. Reading an
  /// older message changes nothing.
  Future<void> markRead(UniqueId chatId, DateTime sentAt);
}
