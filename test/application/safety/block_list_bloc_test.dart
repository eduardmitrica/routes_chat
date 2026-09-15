import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/safety/block_list_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/safety/blocks.dart';
import 'package:routes_chat/domain/safety/safety_repository_interface.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/safety_fakes.dart';

void main() {
  final bob = UniqueId.fromUniqueString('uid-bob');
  final noon = DateTime.utc(2026, 9, 16, 12);
  late FakeSafety safety;

  setUp(() => safety = FakeSafety());

  Future<void> send(BlockListBloc bloc, BlockListEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  test('follows who the user blocked, and tells whoever watches', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    final bloc = BlockListBloc(safety, session);
    addTearDown(bloc.close);
    final seen = <Blocks>[];
    final watching = bloc.blocksChanges.listen(seen.add);
    addTearDown(watching.cancel);

    await send(bloc, const BlockListEvent.started());
    safety.blocks.add(blocking('uid-bob', since: noon));
    await pumpEventQueue();

    expect(bloc.blocks.isBlocked(bob), isTrue);
    expect(seen.last.isBlocked(bob), isTrue);
  });

  test('blocks and unblocks, once while under way', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    final bloc = BlockListBloc(safety, session);
    addTearDown(bloc.close);
    safety.gate = Completer<void>();

    await send(bloc, BlockListEvent.blockRequested(bob));
    expect(bloc.state.changing, {'uid-bob'});
    await send(bloc, BlockListEvent.blockRequested(bob));
    safety.gate!.complete();
    await pumpEventQueue();
    await send(bloc, BlockListEvent.unblockRequested(bob));

    expect(safety.calls, ['block uid-bob', 'unblock uid-bob']);
    expect(bloc.state.changing, isEmpty);
    expect(bloc.state.failures, 0);
  });

  test('says each time blocking failed', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    final bloc = BlockListBloc(safety, session);
    addTearDown(bloc.close);
    safety.failure = SafetyUnexpected();

    await send(bloc, BlockListEvent.blockRequested(bob));
    await send(bloc, BlockListEvent.blockRequested(bob));

    expect(bloc.state.failures, 2);
    expect(bloc.state.changing, isEmpty);
  });

  test('forgets everyone when the session ends', () async {
    final session = signedInAlice();
    final bloc = BlockListBloc(safety, session);
    addTearDown(bloc.close);
    await send(bloc, const BlockListEvent.started());
    safety.blocks.add(blocking('uid-bob', since: noon));
    await pumpEventQueue();

    session.end();
    await pumpEventQueue();

    expect(bloc.blocks, const Blocks());
  });
}
