import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/groups/new_group_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/groups/group_failure.dart';
import 'package:routes_chat/domain/groups/group_repository_interface.dart';

class _Groups implements IGroupRepository {
  final created = <List<String>>[];
  GroupFailure? failure;

  @override
  Future<Either<GroupFailure, UniqueId>> create(List<UniqueId> invitees) async {
    created.add([for (final id in invitees) id.getOrCrash()]);
    final failure = this.failure;
    return failure == null
        ? right(UniqueId.fromUniqueString('group-new'))
        : left(failure);
  }

  @override
  Stream<Either<GroupFailure, KtList<Group>>> watchJoined() =>
      const Stream.empty();

  @override
  Stream<Either<GroupFailure, KtList<Group>>> watchInvitations() =>
      const Stream.empty();

  @override
  Future<Either<GroupFailure, Unit>> accept(UniqueId groupId) =>
      throw UnimplementedError();

  @override
  Future<Either<GroupFailure, Unit>> decline(UniqueId groupId) =>
      throw UnimplementedError();
}

UniqueId _id(String id) => UniqueId.fromUniqueString(id);

void main() {
  late _Groups groups;
  late NewGroupBloc bloc;

  setUp(() {
    groups = _Groups();
    bloc = NewGroupBloc(groups);
    addTearDown(bloc.close);
  });

  Future<void> send(NewGroupEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  test('someone must be chosen before a group can start', () async {
    expect(bloc.state.canCreate, isFalse);
    await send(const NewGroupEvent.created());
    expect(groups.created, isEmpty);

    await send(NewGroupEvent.personToggled(_id('uid-bob')));
    expect(bloc.state.canCreate, isTrue);

    // Chosen twice is not chosen.
    await send(NewGroupEvent.personToggled(_id('uid-bob')));
    expect(bloc.state.chosen, isEmpty);
  });

  test('starts the group with the people chosen, in order', () async {
    await send(NewGroupEvent.personToggled(_id('uid-bob')));
    await send(NewGroupEvent.personToggled(_id('uid-carol')));
    await send(const NewGroupEvent.created());

    expect(groups.created, [
      ['uid-bob', 'uid-carol'],
    ]);
    expect(bloc.state.createdId, _id('group-new'));
  });

  test('a group holds at most 32 people, the user included', () async {
    for (var i = 0; i < Group.maxMembers + 3; i++) {
      await send(NewGroupEvent.personToggled(_id('uid-$i')));
    }
    expect(bloc.state.chosen.length, Group.maxMembers - 1);
    expect(bloc.state.isFull, isTrue);
  });

  test('a failure is said, and the choice stays to try again', () async {
    groups.failure = const GroupMemberWithoutKeys('uid-bob');
    await send(NewGroupEvent.personToggled(_id('uid-bob')));
    await send(const NewGroupEvent.created());

    expect(bloc.state.failure, isA<GroupMemberWithoutKeys>());
    expect(bloc.state.failures, 1);
    expect(bloc.state.createdId, isNull);
    expect(bloc.state.chosen, [_id('uid-bob')]);
    expect(bloc.state.canCreate, isTrue);
  });
}
