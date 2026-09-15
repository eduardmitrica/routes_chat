import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart' as chat_failure;
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/local_chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart'
    as message_failure;
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

/// How an attempt to send a message ended.
enum _Outcome {
  sent,

  /// Failed for a reason that may pass, such as a lost connection.
  mayPass,

  /// Refused, so trying again will not help.
  refused,
}

/// Messages on their way, kept on the phone until they are sent.
///
/// A message is kept before anything leaves the phone. Its photos upload one
/// by one, each skipped when an earlier attempt already uploaded it, and then
/// the message itself is sent. Sending one that already arrived, after an
/// attempt whose answer was lost, does not send it twice.
///
/// The messages of a chat go one at a time, in the order they were sent, so a
/// caption never arrives before the photos sent ahead of it. When an attempt
/// fails for a reason that may pass, such as a lost connection, the message
/// is tried again after a growing pause, without end, and at once when the
/// connection returns or the user asks. One the server refuses waits for the
/// user, without holding up the rest. A message the user gives up on takes
/// its uploaded files with it.
class MessageOutbox {
  /// The pause before each retry. The last repeats.
  static const defaultRetryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 45),
    Duration(minutes: 2),
  ];

  /// How long sending a message may take before the attempt counts as
  /// failed. Without a connection Firebase waits for one to return, however
  /// long that takes. A send that lands after all is not sent twice.
  static const defaultSendTimeout = Duration(seconds: 60);

  final IMessageRepository _messages;
  final IChatRepository _chats;
  final IOutboxRepository _store;
  final List<Duration> _retryDelays;
  final Duration _sendTimeout;

  /// Every message on its way, by id.
  final _entries = <String, OutgoingMessage>{};
  final _changes = StreamController<void>.broadcast();

  /// The pauses before the next attempt, by message id.
  final _pauses = <String, Timer>{};

  /// The messages being sent right now.
  final _inFlight = <String>{};

  /// Messages changed since they were last kept on the phone.
  final _unkept = <String>{};

  Future<void>? _loading;
  Future<void>? _deleting;

  MessageOutbox(
    this._messages,
    this._chats,
    this._store,
    ICurrentUserSession session, {
    Stream<void>? reconnected,
    List<Duration> retryDelays = defaultRetryDelays,
    Duration sendTimeout = defaultSendTimeout,
  }) : assert(retryDelays.isNotEmpty),
       _retryDelays = retryDelays,
       _sendTimeout = sendTimeout {
    session.ended.listen((_) => _forget());
    reconnected?.listen((_) => retryNow());
  }

  /// The messages of [chatId] on their way, in the order they were sent.
  Stream<KtList<OutgoingMessage>> watch(UniqueId chatId) {
    late final StreamController<KtList<OutgoingMessage>> controller;
    StreamSubscription<void>? changes;
    controller = StreamController(
      onListen: () async {
        changes = _changes.stream.listen((_) => controller.add(_of(chatId)));
        await _load();
        if (!controller.isClosed) controller.add(_of(chatId));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream.distinct();
  }

  KtList<OutgoingMessage> _of(UniqueId chatId) =>
      (_entries.values.where((entry) => entry.chatId == chatId).toList()
            ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt)))
          .toImmutableList();

  /// Loads what the phone kept and sends it: messages that were on their way
  /// when the app closed, and the files of given-up messages still to delete.
  /// Messages the server refused wait for the user.
  Future<void> resume() async {
    await _load();
    _sendNextEverywhere();
    unawaited(_deleteGivenUpFiles());
  }

  /// Keeps [message] on the phone and sends it, after any sent before it in
  /// its chat.
  Future<void> enqueue(OutgoingMessage message) async {
    await _load();
    final entry = message.copyWith(status: OutgoingStatus.sending, failures: 0);
    _put(entry);
    await _keep(entry);
    _sendNext(entry.chatId);
  }

  /// Tries every message waiting for its next attempt now, such as when the
  /// connection returns or the app comes back to the screen.
  void retryNow() {
    for (final pause in _pauses.values) {
      pause.cancel();
    }
    _pauses.clear();
    _sendNextEverywhere();
  }

  /// Tries [messageId] again now, as the user asked, with the pauses between
  /// attempts starting over. The messages before it in its chat go first, so
  /// they are tried now too.
  Future<void> retry(UniqueId messageId) async {
    final entry = _entries[messageId.getOrCrash()];
    if (entry == null) return;
    for (final other in _of(entry.chatId).iter) {
      _pauses.remove(other.id.getOrCrash())?.cancel();
    }
    if (!_inFlight.contains(messageId.getOrCrash())) {
      final restarted = entry.copyWith(
        status: OutgoingStatus.sending,
        failures: 0,
      );
      _put(restarted);
      await _keep(restarted);
    }
    _sendNext(entry.chatId);
  }

  /// Gives up on [messageId]: it is not sent, and the files it uploaded are
  /// deleted. False, and nothing done, while it is being sent.
  Future<bool> discard(UniqueId messageId) async {
    final id = messageId.getOrCrash();
    if (_inFlight.contains(id)) return false;
    _pauses.remove(id)?.cancel();
    final entry = _entries.remove(id);
    if (entry == null) return true;
    _unkept.remove(id);
    _changed();
    try {
      // Forgotten first: a message closed between the two steps must not be
      // sent later with its files deleted. At worst its files stay unused.
      await _store.forget(messageId);
      if (entry.attachments.isNotEmpty) {
        await _store.addFilesToDelete([
          for (final attachment in entry.attachments.values)
            (entry.chatId, attachment.id),
        ]);
      }
    } on Object catch (error) {
      debugPrint('Given-up message not forgotten: ${error.runtimeType}');
    }
    _sendNext(entry.chatId);
    unawaited(_deleteGivenUpFiles());
    return true;
  }

  Future<void> _load() => _loading ??= () async {
    try {
      for (final entry in (await _store.queued()).iter) {
        _entries.putIfAbsent(entry.id.getOrCrash(), () => entry);
      }
    } on Object catch (error) {
      debugPrint('Outbox not loaded: ${error.runtimeType}');
      _loading = null;
    }
    _changed();
  }();

  void _sendNextEverywhere() {
    for (final chatId in {for (final entry in _entries.values) entry.chatId}) {
      _sendNext(chatId);
    }
  }

  /// Sends the first message of [chatId] not refused, unless it is being sent
  /// or waits for its next attempt.
  void _sendNext(UniqueId chatId) {
    final next = _of(
      chatId,
    ).firstOrNull((entry) => entry.status != OutgoingStatus.failed);
    if (next == null) return;
    final id = next.id.getOrCrash();
    if (_inFlight.contains(id) || _pauses.containsKey(id)) return;
    unawaited(_send(id));
  }

  Future<void> _send(String id) async {
    final entry = _entries[id];
    if (entry == null || !_inFlight.add(id)) return;
    if (entry.status != OutgoingStatus.sending) {
      _put(entry.copyWith(status: OutgoingStatus.sending));
    }
    _Outcome outcome;
    try {
      outcome = await _attempt(id);
    } on Object catch (error) {
      debugPrint('Message not sent: ${error.runtimeType}');
      outcome = _Outcome.mayPass;
    } finally {
      _inFlight.remove(id);
    }

    final settled = _entries[id];
    // Given up or signed out meanwhile.
    if (settled == null) return;
    switch (outcome) {
      case _Outcome.sent:
        _entries.remove(id);
        _unkept.remove(id);
        _changed();
        try {
          await _store.forget(settled.id);
        } on Object catch (error) {
          debugPrint('Sent message not forgotten: ${error.runtimeType}');
        }
        _sendNext(settled.chatId);
      case _Outcome.mayPass:
        final failures = settled.failures + 1;
        final waiting = settled.copyWith(
          status: OutgoingStatus.waiting,
          failures: failures,
        );
        _put(waiting);
        _pauses[id]?.cancel();
        _pauses[id] = Timer(
          _retryDelays[min(failures, _retryDelays.length) - 1],
          () {
            _pauses.remove(id);
            _sendNext(settled.chatId);
          },
        );
        await _keep(waiting);
      case _Outcome.refused:
        final failed = settled.copyWith(
          status: OutgoingStatus.failed,
          failures: settled.failures + 1,
        );
        _put(failed);
        await _keep(failed);
        _sendNext(settled.chatId);
    }
  }

  Future<_Outcome> _attempt(String id) async {
    for (final draft in _entries[id]!.media.iter) {
      final draftId = draft.id.getOrCrash();
      var entry = _entries[id];
      if (entry == null) return _Outcome.mayPass;
      var attachment = entry.attachments[draftId];
      if (attachment == null) {
        attachment = _messages.attachmentFor(draft);
        entry = entry.copyWith(
          attachments: {...entry.attachments, draftId: attachment},
        );
        _put(entry);
        _unkept.add(id);
      }
      // A file is uploaded only once its key is kept on the phone. If the
      // answer to the upload is lost and the app closes, the next attempt then
      // finds the file there encrypted with the key the message records.
      if (_unkept.contains(id)) await _keepOrThrow(entry);
      final failure = (await _messages.uploadAttachment(
        entry.chatId,
        draft,
        attachment,
      )).fold((failure) => failure, (_) => null);
      if (failure != null) {
        return failure is message_failure.InsufficientPermissions
            ? _Outcome.refused
            : _Outcome.mayPass;
      }
    }

    final entry = _entries[id];
    if (entry == null) return _Outcome.mayPass;
    final message = entry.withAttachments;
    if (entry.startsChat) {
      return (await _chats
              .create(_chatFor(entry, message), message)
              .timeout(_sendTimeout))
          .fold(
            (failure) => failure is chat_failure.InsufficientPermissions
                ? _Outcome.refused
                : _Outcome.mayPass,
            (_) => _Outcome.sent,
          );
    }
    return (await _messages
            .addMessageToChatWithId(message, entry.chatId)
            .timeout(_sendTimeout))
        .fold(
          (failure) => failure is message_failure.InsufficientPermissions
              ? _Outcome.refused
              : _Outcome.mayPass,
          (_) => _Outcome.sent,
        );
  }

  Future<void> _deleteGivenUpFiles() => _deleting ??= () async {
    try {
      for (final (chatId, fileId) in await _store.filesToDelete()) {
        final deleted = await _messages.deleteAttachment(chatId, fileId);
        if (deleted.isRight()) {
          await _store.removeFileToDelete(chatId, fileId);
        }
      }
    } on Object catch (error) {
      debugPrint('Given-up files not deleted: ${error.runtimeType}');
    } finally {
      _deleting = null;
    }
  }();

  Chat _chatFor(OutgoingMessage entry, Message message) => Chat(
    id: entry.chatId,
    participantsList: ParticipantsList(
      [message.senderId, ...entry.startsChatWith.iter].toImmutableList().map(
        (participant) => Tuple2(participant, UniqueId.empty()),
      ),
    ),
    lastMessage: message,
  );

  void _put(OutgoingMessage entry) {
    _entries[entry.id.getOrCrash()] = entry;
    _changed();
  }

  Future<void> _keepOrThrow(OutgoingMessage entry) async {
    final id = entry.id.getOrCrash();
    _unkept.add(id);
    await _store.keep(entry);
    // Only if it is still the latest version.
    if (identical(_entries[id], entry)) _unkept.remove(id);
  }

  Future<void> _keep(OutgoingMessage entry) async {
    try {
      await _keepOrThrow(entry);
    } on Object catch (error) {
      debugPrint('Message on its way not kept: ${error.runtimeType}');
    }
  }

  /// Signed out: the messages on their way stop, and are forgotten here. The
  /// phone's copy goes with the user's other local files.
  void _forget() {
    for (final pause in _pauses.values) {
      pause.cancel();
    }
    _pauses.clear();
    _entries.clear();
    _unkept.clear();
    _loading = null;
    _changed();
  }

  void _changed() {
    if (!_changes.isClosed) _changes.add(null);
  }
}
