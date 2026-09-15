import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/chats/chat_reads.dart';
import '../../../domain/chats/messages/message.dart';
import '../../../domain/core/value_objects.dart';
import '../../../domain/presence/presence.dart';
import '../../../domain/presence/presence_repository_interface.dart';
import '../../../domain/settings/privacy_settings.dart';

sealed class ChatActivityEvent extends Equatable {
  const ChatActivityEvent();

  /// The user opened the chat [chatId] with [otherUserId].
  const factory ChatActivityEvent.started({
    required UniqueId chatId,
    required UniqueId otherUserId,
  }) = ChatActivityStarted;

  /// The chat is on screen, showing messages up to [newest].
  const factory ChatActivityEvent.messagesShown(Message newest) = MessagesShown;

  @override
  List<Object?> get props => const [];
}

final class ChatActivityStarted extends ChatActivityEvent {
  final UniqueId chatId;
  final UniqueId otherUserId;
  const ChatActivityStarted({required this.chatId, required this.otherUserId});
  @override
  List<Object?> get props => [chatId, otherUserId];
}

final class MessagesShown extends ChatActivityEvent {
  final Message newest;
  const MessagesShown(this.newest);
  @override
  List<Object?> get props => [newest];
}

final class _TypingSeen extends ChatActivityEvent {
  final DateTime? typingAt;
  const _TypingSeen(this.typingAt);
  @override
  List<Object?> get props => [typingAt];
}

final class _PresenceSeen extends ChatActivityEvent {
  final Presence? presence;
  const _PresenceSeen(this.presence);
  @override
  List<Object?> get props => [presence];
}

final class _ReadSeen extends ChatActivityEvent {
  final DateTime? readUpTo;
  const _ReadSeen(this.readUpTo);
  @override
  List<Object?> get props => [readUpTo];
}

final class _PrivacyChanged extends ChatActivityEvent {
  final PrivacySettings settings;
  const _PrivacyChanged(this.settings);
  @override
  List<Object?> get props => [settings];
}

/// Time passed, which may end typing or being online.
final class _Tick extends ChatActivityEvent {
  const _Tick();
}

/// What the other person in a chat is doing, as far as both share it.
final class ChatActivityState extends Equatable {
  final bool typing;
  final bool online;

  /// When they were last in the app, unless [online].
  final DateTime? lastSeen;

  /// When the newest message they have read was sent. Every message sent
  /// then or before is seen.
  final DateTime? seenUpTo;

  const ChatActivityState({
    this.typing = false,
    this.online = false,
    this.lastSeen,
    this.seenUpTo,
  });

  @override
  List<Object?> get props => [typing, online, lastSeen, seenUpTo];
}

/// Whether the other person in a chat is typing, online, when they were last
/// seen, and how far they have read; and how far the user has read.
///
/// Typing shows for [defaultTypingShownFor] after each word from their phone,
/// which refreshes it while they type, so it ends even if their app dies. A
/// typing mark older than [defaultTypingIgnoredAfter] is from before, and
/// ignored. They count as online while their app said so within
/// [defaultOnlineWithin]. Nothing is watched that the user does not share,
/// and the user's own reading is told to others only while they share it.
class ChatActivityBloc extends Bloc<ChatActivityEvent, ChatActivityState> {
  static const defaultTypingShownFor = Duration(seconds: 6);
  static const defaultTypingIgnoredAfter = Duration(seconds: 30);
  static const defaultOnlineWithin = Duration(seconds: 90);

  final IPresenceRepository _presence;
  final IPrivacySettingsReader _privacy;
  final IChatReads? _reads;
  final DateTime Function() _now;
  final Duration _typingShownFor;
  final Duration _typingIgnoredAfter;
  final Duration _onlineWithin;

  UniqueId? _chatId;
  UniqueId? _otherUserId;
  StreamSubscription<DateTime?>? _typing;
  StreamSubscription<Presence?>? _presenceWatch;
  StreamSubscription<DateTime?>? _readWatch;
  StreamSubscription<PrivacySettings>? _privacyWatch;
  Timer? _typingEnds;
  Timer? _presenceCheck;
  DateTime? _typingUntil;
  Presence? _lastPresence;
  DateTime? _seenUpTo;

  /// The newest message shown, and the send time of the newest one others
  /// were told the user read.
  Message? _newestShown;
  DateTime? _reportedUpTo;

  ChatActivityBloc(
    this._presence,
    this._privacy, {
    IChatReads? reads,
    DateTime Function()? now,
    Duration typingShownFor = defaultTypingShownFor,
    Duration typingIgnoredAfter = defaultTypingIgnoredAfter,
    Duration onlineWithin = defaultOnlineWithin,
  }) : _reads = reads,
       _now = now ?? DateTime.now,
       _typingShownFor = typingShownFor,
       _typingIgnoredAfter = typingIgnoredAfter,
       _onlineWithin = onlineWithin,
       super(const ChatActivityState()) {
    on<ChatActivityEvent>((event, emit) async {
      switch (event) {
        case ChatActivityStarted(:final chatId, :final otherUserId):
          _chatId = chatId;
          _otherUserId = otherUserId;
          await _privacyWatch?.cancel();
          _privacyWatch = _privacy.privacyChanges.listen(
            (settings) => add(_PrivacyChanged(settings)),
          );
          _follow(_privacy.privacy);
          emit(_current());

        case MessagesShown(:final newest):
          final chatId = _chatId;
          final sentAt = newest.lastUpdatedAt;
          if (chatId == null || sentAt == null) return;
          final shown = _newestShown?.lastUpdatedAt;
          if (shown == null || sentAt.isAfter(shown)) _newestShown = newest;
          _reportRead(_privacy.privacy);
          await _reads?.markRead(chatId, sentAt);

        case _PrivacyChanged(:final settings):
          _follow(settings);
          _reportRead(settings);
          emit(_current());

        case _TypingSeen(:final typingAt):
          _typingEnds?.cancel();
          final now = _now();
          if (typingAt == null ||
              now.difference(typingAt) > _typingIgnoredAfter) {
            _typingUntil = null;
          } else {
            _typingUntil = now.add(_typingShownFor);
            _typingEnds = Timer(_typingShownFor, () {
              if (!isClosed) add(const _Tick());
            });
          }
          emit(_current());

        case _PresenceSeen(:final presence):
          _lastPresence = presence;
          emit(_current());

        case _ReadSeen(:final readUpTo):
          _seenUpTo = readUpTo;
          emit(_current());

        case _Tick():
          emit(_current());
      }
    });
  }

  /// Tells others the user has read up to the newest message shown, while
  /// the user shares it, and only when that is further than before.
  void _reportRead(PrivacySettings settings) {
    final chatId = _chatId;
    final newest = _newestShown;
    final sentAt = newest?.lastUpdatedAt;
    if (!settings.shareReadReceipts ||
        chatId == null ||
        newest == null ||
        sentAt == null) {
      return;
    }
    final reported = _reportedUpTo;
    if (reported != null && !sentAt.isAfter(reported)) return;
    _reportedUpTo = sentAt;
    unawaited(_presence.markRead(chatId, newest.id));
  }

  /// Watches what the user shares, and stops watching what they don't.
  void _follow(PrivacySettings settings) {
    final chatId = _chatId;
    final otherUserId = _otherUserId;
    if (chatId == null || otherUserId == null) return;

    if (settings.shareTyping) {
      _typing ??= _presence
          .watchTyping(chatId, otherUserId)
          .listen((typingAt) => add(_TypingSeen(typingAt)));
    } else {
      unawaited(_typing?.cancel());
      _typing = null;
      _typingEnds?.cancel();
      _typingUntil = null;
    }

    if (settings.shareOnline) {
      _presenceWatch ??= _presence
          .watchPresence(otherUserId)
          .listen((presence) => add(_PresenceSeen(presence)));
      // Being online ends when their app stops saying so.
      _presenceCheck ??= Timer.periodic(const Duration(seconds: 30), (_) {
        if (!isClosed) add(const _Tick());
      });
    } else {
      unawaited(_presenceWatch?.cancel());
      _presenceWatch = null;
      _presenceCheck?.cancel();
      _presenceCheck = null;
      _lastPresence = null;
    }

    if (settings.shareReadReceipts) {
      _readWatch ??= _presence
          .watchReadUpTo(chatId, otherUserId)
          .listen((readUpTo) => add(_ReadSeen(readUpTo)));
    } else {
      unawaited(_readWatch?.cancel());
      _readWatch = null;
      _seenUpTo = null;
      // Turned on again, the newest message shown is reported again.
      _reportedUpTo = null;
    }
  }

  ChatActivityState _current() {
    final now = _now();
    final settings = _privacy.privacy;
    final typingUntil = _typingUntil;
    final presence = settings.shareOnline ? _lastPresence : null;
    final online =
        presence != null &&
        presence.online &&
        now.difference(presence.lastSeenAt) < _onlineWithin;
    return ChatActivityState(
      typing:
          settings.shareTyping &&
          typingUntil != null &&
          now.isBefore(typingUntil),
      online: online,
      lastSeen: online ? null : presence?.lastSeenAt,
      seenUpTo: settings.shareReadReceipts ? _seenUpTo : null,
    );
  }

  @override
  Future<void> close() async {
    _typingEnds?.cancel();
    _presenceCheck?.cancel();
    await _typing?.cancel();
    await _presenceWatch?.cancel();
    await _readWatch?.cancel();
    await _privacyWatch?.cancel();
    return super.close();
  }
}
