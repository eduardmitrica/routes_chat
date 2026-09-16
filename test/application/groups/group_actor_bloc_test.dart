import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/groups/group_actor_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/groups/group_failure.dart';
import 'package:routes_chat/domain/groups/group_repository_interface.dart';

class _Groups implements IGroupRepository {
  final calls = <String>[];
  GroupFailure? failure;

  /// Holds every answer back while set.
  Completer<void>? gate;

  Future<Either<GroupFailure, Unit>> _answer(String call) async {
    calls.add(call);
    await gate?.future;
    final failure = this.failure;
    return failure == null ? right(unit) : left(failure);
  }

  @override
  Future<Either<GroupFailure, Unit>> remove(
    UniqueId groupId,
    UniqueId userId,
  ) => _answer('remove ${userId.getOrCrash()}');

  @override
  Future<Either<GroupFailure, Unit>> leave(UniqueId groupId) =>
      _answer('leave');

  @override
  Future<Either<GroupFailure, Unit>> setAdmin(
    UniqueId groupId,
    UniqueId userId, {
    required bool admin,
  }) => _answer('admin ${userId.getOrCrash()} $admin');

  @override
  Future<Either<GroupFailure, Unit>> setOnlyAdminsAdd(
    UniqueId groupId, {
    required bool onlyAdmins,
  }) => _answer('only admins add $onlyAdmins');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Groups groups;
  late GroupActorBloc bloc;
  final bob = UniqueId.fromUniqueString('uid-bob');

  setUp(() {
    groups = _Groups();
    bloc = GroupActorBloc(groups, UniqueId.fromUniqueString('group-1'));
    addTearDown(bloc.close);
  });

  Future<void> send(GroupActorEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  test('each change goes to the repository', () async {
    await send(GroupActorEvent.adminSet(bob, admin: true));
    await send(const GroupActorEvent.onlyAdminsAddSet(true));
    await send(GroupActorEvent.removed(bob));

    expect(groups.calls, [
      'admin uid-bob true',
      'only admins add true',
      'remove uid-bob',
    ]);
    expect(bloc.state.busy, isEmpty);
    expect(bloc.state.failures, 0);
  });

  test('leaving says so once it went through', () async {
    await send(const GroupActorEvent.left());
    expect(groups.calls, ['leave']);
    expect(bloc.state.left, isTrue);
  });

  test('a refused change speaks up, and a refused leave is no leave', () async {
    groups.failure = const GroupInsufficientPermissions();
    await send(const GroupActorEvent.left());
    await send(GroupActorEvent.removed(bob));

    expect(bloc.state.left, isFalse);
    expect(bloc.state.failures, 2);
    expect(bloc.state.lastFailure, isA<GroupInsufficientPermissions>());
  });

  test('the same change is not sent twice while on its way', () async {
    final gate = groups.gate = Completer<void>();
    await send(GroupActorEvent.removed(bob));
    await send(GroupActorEvent.removed(bob));
    expect(groups.calls, ['remove uid-bob']);
    expect(bloc.state.busy, {'uid-bob'});

    gate.complete();
    await pumpEventQueue();
    expect(bloc.state.busy, isEmpty);
  });
}
