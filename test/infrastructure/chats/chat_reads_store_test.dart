import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/chats/chat_reads_store.dart';
import 'package:routes_chat/infrastructure/core/local_vault.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

import '../../helpers/outbox_fakes.dart';

class _MemorySecrets implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  late Directory base;
  late _MemorySecrets secrets;
  late CurrentUserSession session;
  var now = DateTime.utc(2026, 9, 16, 12);
  final chat = UniqueId.fromUniqueString(aliceAndBob);

  ChatReadsStore storeFor(CurrentUserSession session) => ChatReadsStore(
    LocalVault(secrets, session, baseDirectory: () async => base),
    session,
    now: () => now,
  );

  setUp(() {
    base = Directory.systemTemp.createTempSync('chat_reads_store_test');
    secrets = _MemorySecrets();
    session = signedInAlice();
    now = DateTime.utc(2026, 9, 16, 12);
  });

  tearDown(() {
    if (base.existsSync()) base.deleteSync(recursive: true);
  });

  test('starts keeping track from the first time it is asked', () async {
    final reads = await storeFor(session).watch().first;

    expect(reads.since, now);
    expect(reads.readUpTo, isEmpty);
  });

  test('keeps how far each chat was read, moving only forward', () async {
    final store = storeFor(session);
    await store.watch().first;
    final later = now.add(const Duration(minutes: 5));

    await store.markRead(chat, later);
    await store.markRead(chat, now.add(const Duration(minutes: 1)));

    expect((await store.watch().first).readUpToIn(aliceAndBob), later);
  });

  test('keeps it on the phone, encrypted, for the next launch', () async {
    final later = now.add(const Duration(minutes: 5, microseconds: 123));
    final first = storeFor(session);
    await first.markRead(chat, later);
    now = now.add(const Duration(days: 2));

    final reads = await storeFor(session).watch().first;

    expect(reads.readUpToIn(aliceAndBob), later);
    expect(reads.since, DateTime.utc(2026, 9, 16, 12));
    final stored = [
      for (final file in base.listSync(recursive: true).whereType<File>())
        String.fromCharCodes(file.readAsBytesSync()),
    ].join();
    expect(stored, isNot(contains(aliceAndBob)));
  });

  test('tells each change to whoever watches', () async {
    final store = storeFor(session);
    final seen = <ChatReads>[];
    final subscription = store.watch().listen(seen.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    await store.markRead(chat, now.add(const Duration(minutes: 1)));
    await pumpEventQueue();

    expect(seen, hasLength(2));
    expect(seen.last.readUpTo.keys, [aliceAndBob]);
  });

  test('signing out forgets it', () async {
    final store = storeFor(session);
    await store.markRead(chat, now.add(const Duration(minutes: 1)));

    session.end();
    await pumpEventQueue();
    session.start(const CurrentUserInformationPersistent('uid-alice', 'alice'));
    final reads = await store.watch().first;

    expect(reads.readUpTo, isEmpty);
  });
}
