import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/chats/chat_reads.dart';
import '../../domain/chats/messages/message.dart';
import '../../domain/core/value_objects.dart';
import '../../domain/presence/presence_repository_interface.dart';
import '../../domain/safety/blocks.dart';
import '../../domain/settings/privacy_settings.dart';

sealed class GroupActivityEvent extends Equatable {
  const GroupActivityEvent();

  /// The user opened the group [groupId].
  const factory GroupActivityEvent.started(UniqueId groupId) =
      GroupActivityStarted;

  /// The group is on screen, showing messages up to [newest].
  const factory GroupActivityEvent.messagesShown(Message newest) =
      GroupMessagesShown;

  @override
  List<Object?> get props => const [];
}

final class GroupActivityStarted extends GroupActivityEvent {
  final UniqueId groupId;
  const GroupActivityStarted(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

final class GroupMessagesShown extends GroupActivityEvent {
  final Message newest;
  const GroupMessagesShown(this.newest);
  @override
  List<Object?> get props => [newest];
}

final class _TypingSeen extends GroupActivityEvent {
  final Map<String, DateTime> typingAt;
  const _TypingSeen(this.typingAt);
  @override
  List<Object?> get props => [typingAt];
}

final class _ReadsSeen extends GroupActivityEvent {
  final Map<String, DateTime> readUpTo;
  const _ReadsSeen(this.readUpTo);
  @override
  List<Object?> get props => [readUpTo];
}

final class _PrivacyChanged extends GroupActivityEvent {
  final PrivacySettings settings;
  const _PrivacyChanged(this.settings);
  @override
  List<Object?> get props => [settings];
}

/// Time passed, which may end someone's typing.
final class _Tick extends GroupActivityEvent {
  const _Tick();
}

/// Who else in a group is typing and how far each has read, as far as the
/// user shares the same.
final class GroupActivityState extends Equatable {
  /// The people typing now, who started first first.
  final List<String> typingIds;

  /// When the newest message each person has read was sent, by user id.
  final Map<String, DateTime> readUpTo;

  const GroupActivityState({
    this.typingIds = const [],
    this.readUpTo = const {},
  });

  /// The people who have read a message sent at [sentAt], who read furthest
  /// last.
  List<String> seenBy(DateTime sentAt) =>
      (readUpTo.entries.where((entry) => !entry.value.isBefore(sentAt)).toList()
            ..sort((a, b) => a.value.compareTo(b.value)))
          .map((entry) => entry.key)
          .toList();

  @override
  List<Object?> get props => [typingIds, readUpTo];

  /// Counts only: who reads and types stays out of logs.
  @override
  String toString() =>
      'GroupActivityState(${typingIds.length} typing, '
      '${readUpTo.length} read markers)';
}

/// Who is typing in a group and how far everyone has read it, and how far
/// the user has.
///
/// Works like ChatActivityBloc for many people: typing shows for
/// [defaultTypingShownFor] after each word from someone's phone and marks
/// older than [defaultTypingIgnoredAfter] are ignored. Nothing is watched
/// that the user does not share, the user's own reading is told only while
/// they share it, and people the user blocked are left out either way.
class GroupActivityBloc extends Bloc<GroupActivityEvent, GroupActivityState> {
  static const defaultTypingShownFor = Duration(seconds: 6);
  static const defaultTypingIgnoredAfter = Duration(seconds: 30);

  final IPresenceRepository _presence;
  final IPrivacySettingsReader _privacy;
  final IChatReads? _reads;
  final IBlockList? _blocks;
  final DateTime Function() _now;
  final Duration _typingShownFor;
  final Duration _typingIgnoredAfter;

  UniqueId? _groupId;
  StreamSubscription<Map<String, DateTime>>? _typingWatch;
  StreamSubscription<Map<String, DateTime>>? _readsWatch;
  StreamSubscription<PrivacySettings>? _privacyWatch;
  StreamSubscription<Blocks>? _blocksWatch;
  Timer? _typingEnds;

  /// Until when each person's typing shows, by user id.
  var _typingUntil = <String, DateTime>{};
  var _readUpTo = <String, DateTime>{};

  Message? _newestShown;
  DateTime? _reportedUpTo;

  GroupActivityBloc(
    this._presence,
    this._privacy, {
    IChatReads? reads,
    IBlockList? blocks,
    DateTime Function()? now,
    Duration typingShownFor = defaultTypingShownFor,
    Duration typingIgnoredAfter = defaultTypingIgnoredAfter,
  }) : _reads = reads,
       _blocks = blocks,
       _now = now ?? DateTime.now,
       _typingShownFor = typingShownFor,
       _typingIgnoredAfter = typingIgnoredAfter,
       super(const GroupActivityState()) {
    on<GroupActivityEvent>((event, emit) async {
      switch (event) {
        case GroupActivityStarted(:final groupId):
          _groupId = groupId;
          await _privacyWatch?.cancel();
          _privacyWatch = _privacy.privacyChanges.listen(
            (settings) => add(_PrivacyChanged(settings)),
          );
          _blocksWatch ??= _blocks?.blocksChanges.listen((_) {
            if (!isClosed) add(const _Tick());
          });
          _follow(_privacy.privacy);
          emit(_current());

        case GroupMessagesShown(:final newest):
          final groupId = _groupId;
          final sentAt = newest.lastUpdatedAt;
          if (groupId == null || sentAt == null) return;
          final shown = _newestShown?.lastUpdatedAt;
          if (shown == null || sentAt.isAfter(shown)) _newestShown = newest;
          _reportRead(_privacy.privacy);
          await _reads?.markRead(groupId, sentAt);

        case _PrivacyChanged(:final settings):
          _follow(settings);
          _reportRead(settings);
          emit(_current());

        case _TypingSeen(:final typingAt):
          final now = _now();
          _typingUntil = {
            for (final MapEntry(key: id, value: at) in typingAt.entries)
              if (now.difference(at) <= _typingIgnoredAfter)
                // Kept going while their phone keeps saying so.
                id: _typingUntil[id] != null && _typingSince[id] == at
                    ? _typingUntil[id]!
                    : now.add(_typingShownFor),
          };
          _typingSince = Map.of(typingAt);
          _scheduleTypingEnd();
          emit(_current());

        case _ReadsSeen(:final readUpTo):
          _readUpTo = Map.of(readUpTo);
          emit(_current());

        case _Tick():
          _scheduleTypingEnd();
          emit(_current());
      }
    });
  }

  /// The typing marks as they last arrived, so an unchanged mark does not
  /// show typing for longer.
  var _typingSince = <String, DateTime>{};

  /// Wakes up when the first person still shown typing stops being.
  void _scheduleTypingEnd() {
    _typingEnds?.cancel();
    final now = _now();
    final ends = _typingUntil.values.where((until) => until.isAfter(now));
    if (ends.isEmpty) return;
    final first = ends.reduce((a, b) => a.isBefore(b) ? a : b);
    _typingEnds = Timer(first.difference(now), () {
      if (!isClosed) add(const _Tick());
    });
  }

  /// Tells the group the user has read up to the newest message shown, while
  /// the user shares it, and only when that is further than before.
  void _reportRead(PrivacySettings settings) {
    final groupId = _groupId;
    final newest = _newestShown;
    final sentAt = newest?.lastUpdatedAt;
    if (!settings.shareReadReceipts ||
        groupId == null ||
        newest == null ||
        sentAt == null) {
      return;
    }
    final reported = _reportedUpTo;
    if (reported != null && !sentAt.isAfter(reported)) return;
    _reportedUpTo = sentAt;
    unawaited(_presence.markRead(groupId, newest.id));
  }

  /// Watches what the user shares, and stops watching what they don't.
  void _follow(PrivacySettings settings) {
    final groupId = _groupId;
    if (groupId == null) return;

    if (settings.shareTyping) {
      _typingWatch ??= _presence
          .watchTypingInGroup(groupId)
          .listen((typingAt) => add(_TypingSeen(typingAt)));
    } else {
      unawaited(_typingWatch?.cancel());
      _typingWatch = null;
      _typingEnds?.cancel();
      _typingUntil = {};
      _typingSince = {};
    }

    if (settings.shareReadReceipts) {
      _readsWatch ??= _presence
          .watchReadsInGroup(groupId)
          .listen((readUpTo) => add(_ReadsSeen(readUpTo)));
    } else {
      unawaited(_readsWatch?.cancel());
      _readsWatch = null;
      _readUpTo = {};
      // Turned on again, the newest message shown is reported again.
      _reportedUpTo = null;
    }
  }

  GroupActivityState _current() {
    final now = _now();
    final settings = _privacy.privacy;
    final blocks = _blocks?.blocks ?? const Blocks();
    bool blocked(String id) => blocks.isBlocked(UniqueId.fromUniqueString(id));
    final typing =
        _typingUntil.entries
            .where((entry) => now.isBefore(entry.value) && !blocked(entry.key))
            .toList()
          ..sort(
            (a, b) => (_typingSince[a.key] ?? now).compareTo(
              _typingSince[b.key] ?? now,
            ),
          );
    return GroupActivityState(
      typingIds: settings.shareTyping
          ? [for (final entry in typing) entry.key]
          : const [],
      readUpTo: settings.shareReadReceipts
          ? {
              for (final entry in _readUpTo.entries)
                if (!blocked(entry.key)) entry.key: entry.value,
            }
          : const {},
    );
  }

  @override
  Future<void> close() async {
    _typingEnds?.cancel();
    await _typingWatch?.cancel();
    await _readsWatch?.cancel();
    await _blocksWatch?.cancel();
    await _privacyWatch?.cancel();
    return super.close();
  }
}
