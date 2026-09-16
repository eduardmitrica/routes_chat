import 'dart:async';

import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/presence/presence.dart';
import 'package:routes_chat/domain/presence/presence_repository_interface.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

/// Records what is written, and lets a test say what the other person does.
class FakePresence implements IPresenceRepository {
  final calls = <String>[];
  final typing = StreamController<DateTime?>.broadcast();
  final presence = StreamController<Presence?>.broadcast();
  var typingWatches = 0;
  var presenceWatches = 0;

  @override
  Future<void> startTyping(UniqueId chatId) async =>
      calls.add('typing ${chatId.getOrCrash()}');

  @override
  Future<void> stopTyping(UniqueId chatId) async =>
      calls.add('stopped ${chatId.getOrCrash()}');

  @override
  Stream<DateTime?> watchTyping(UniqueId chatId, UniqueId userId) {
    typingWatches++;
    return typing.stream;
  }

  @override
  Future<void> reportOnline() async => calls.add('online');

  @override
  Future<void> reportOffline() async => calls.add('offline');

  @override
  Future<void> clearPresence(String userId) async =>
      calls.add('cleared $userId');

  @override
  Stream<Presence?> watchPresence(UniqueId userId) {
    presenceWatches++;
    return presence.stream;
  }

  final reads = StreamController<DateTime?>.broadcast();
  var readWatches = 0;

  @override
  Future<void> markRead(UniqueId chatId, UniqueId messageId) async =>
      calls.add('read ${chatId.getOrCrash()} ${messageId.getOrCrash()}');

  @override
  Stream<DateTime?> watchReadUpTo(UniqueId chatId, UniqueId userId) {
    readWatches++;
    return reads.stream;
  }

  @override
  Future<void> clearReads() async => calls.add('cleared reads');

  final groupTyping = StreamController<Map<String, DateTime>>.broadcast();
  final groupReads = StreamController<Map<String, DateTime>>.broadcast();
  var groupTypingWatches = 0;
  var groupReadWatches = 0;

  @override
  Stream<Map<String, DateTime>> watchTypingInGroup(UniqueId groupId) {
    groupTypingWatches++;
    return groupTyping.stream;
  }

  @override
  Stream<Map<String, DateTime>> watchReadsInGroup(UniqueId groupId) {
    groupReadWatches++;
    return groupReads.stream;
  }

  Future<void> close() async {
    await typing.close();
    await presence.close();
    await reads.close();
    await groupTyping.close();
    await groupReads.close();
  }
}

/// Privacy settings a test changes at will.
class FakePrivacy implements IPrivacySettingsReader {
  final _changes = StreamController<PrivacySettings>.broadcast();

  @override
  PrivacySettings privacy;

  FakePrivacy([this.privacy = const PrivacySettings()]);

  @override
  Stream<PrivacySettings> get privacyChanges => _changes.stream;

  void change(PrivacySettings settings) {
    privacy = settings;
    _changes.add(settings);
  }

  Future<void> close() => _changes.close();
}
