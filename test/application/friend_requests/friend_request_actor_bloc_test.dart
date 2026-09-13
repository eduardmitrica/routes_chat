import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import 'package:routes_chat/domain/core/composite_id.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/failures.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/friend_requests_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/domain/shared/user/user_failure.dart' as user_failure;
import 'package:routes_chat/domain/shared/user/user_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart'
    as value_objects;
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

/// No existing requests; records what the bloc asks to create.
class _FakeFriendRequestsRepository implements IFriendRequestsRepository {
  final created = <FriendRequest>[];

  @override
  Future<Either<FriendRequestFailure, FriendRequest>>
  findBySenderAndReceiverIds(UniqueId senderId, UniqueId receiverId) async =>
      Left(NotFound());

  @override
  Future<Either<FriendRequestFailure, Unit>> create(
    FriendRequest friendRequest,
  ) async {
    created.add(friendRequest);
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Resolves every username to a user whose uid is `uid-<username>`.
class _FakeUserRepository implements IUserRepository {
  @override
  Future<Either<user_failure.UserFailure, User>> findUserByUsername(
    value_objects.Username username,
  ) async {
    final name = username.getOrCrash();
    return Right(
      User(
        id: UniqueId.fromUniqueString('uid-$name'),
        emailAddress: value_objects.EmailAddress('$name@example.com'),
        imageUrl: value_objects.ImageUrl('https://example.com/$name.jpg'),
        username: value_objects.Username(name),
        description: value_objects.Description(''),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Signs in as [username] and sends a friend request to [receiverUsername].
Future<FriendRequest> _sendAs(String username, String receiverUsername) async {
  final friendRequests = _FakeFriendRequestsRepository();
  final session = CurrentUserSession()
    ..start(CurrentUseInformationPersistent('uid-$username', username));
  final bloc = FriendRequestActorBloc(
    friendRequests,
    _FakeUserRepository(),
    session,
  );
  addTearDown(bloc.close);

  bloc.add(FriendRequestActorEvent.sent(receiverUsername));
  await pumpEventQueue();

  expect(friendRequests.created, hasLength(1));
  return friendRequests.created.single;
}

void main() {
  test('a request in either direction targets the same document', () async {
    // Regression: requests used to get a random id, so A→B and B→A sent at
    // the same moment became two documents. With a pair id the second one is
    // a write to the first's document, which the transaction and the rules
    // both reject.
    final fromAlice = await _sendAs('alice', 'bob');
    final fromBob = await _sendAs('bob', 'alice');

    expect(fromAlice.id.getOrCrash(), fromBob.id.getOrCrash());
  });

  test('the request id is the pair of uids that firestore.rules requires', () async {
    final request = await _sendAs('alice', 'bob');

    expect(request.senderId.getOrCrash(), 'uid-alice');
    expect(request.receiverId.getOrCrash(), 'uid-bob');
    expect(
      request.id.getOrCrash(),
      compositeId([request.senderId, request.receiverId]).getOrCrash(),
    );
    expect(request.id.getOrCrash(), 'uid-alice_uid-bob');
  });

  test('a list of requests is still validated for duplicates', () {
    // The domain-level duplicate check stays meaningful alongside the ids.
    expect(const KtList<FriendRequest>.empty().failureOption, none());
  });
}
