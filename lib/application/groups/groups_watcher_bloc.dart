import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/friend_requests/failures.dart';
import '../../domain/friend_requests/friend_request.dart';
import '../../domain/friend_requests/friend_requests_repository_interface.dart';
import '../../domain/groups/group.dart';
import '../../domain/groups/group_failure.dart';
import '../../domain/groups/group_repository_interface.dart';
import '../../domain/safety/blocks.dart';
import '../../domain/shared/user/current_user_session_interface.dart';

sealed class GroupsWatcherEvent extends Equatable {
  const GroupsWatcherEvent();

  /// Follows the groups the user is in, and the ones they were added to.
  const factory GroupsWatcherEvent.started() = GroupsWatchStarted;

  /// The user joins a group they were added to.
  const factory GroupsWatcherEvent.accepted(UniqueId groupId) =
      GroupInvitationAccepted;

  /// The user turns a group down. Nobody is told.
  const factory GroupsWatcherEvent.declined(UniqueId groupId) =
      GroupInvitationDeclined;

  @override
  List<Object?> get props => const [];
}

final class GroupsWatchStarted extends GroupsWatcherEvent {
  const GroupsWatchStarted();
}

final class GroupInvitationAccepted extends GroupsWatcherEvent {
  final UniqueId groupId;
  const GroupInvitationAccepted(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

final class GroupInvitationDeclined extends GroupsWatcherEvent {
  final UniqueId groupId;
  const GroupInvitationDeclined(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

final class _JoinedReceived extends GroupsWatcherEvent {
  final Either<GroupFailure, KtList<Group>> failureOrGroups;
  const _JoinedReceived(this.failureOrGroups);
  @override
  List<Object?> get props => [failureOrGroups];
}

final class _InvitationsReceived extends GroupsWatcherEvent {
  final Either<GroupFailure, KtList<Group>> failureOrGroups;
  const _InvitationsReceived(this.failureOrGroups);
  @override
  List<Object?> get props => [failureOrGroups];
}

final class _FriendsReceived extends GroupsWatcherEvent {
  final Set<String> friendIds;
  const _FriendsReceived(this.friendIds);
  @override
  List<Object?> get props => [friendIds];
}

final class _BlocksChanged extends GroupsWatcherEvent {
  const _BlocksChanged();
}

final class _SignedOut extends GroupsWatcherEvent {
  const _SignedOut();
}

final class GroupsWatcherState extends Equatable {
  /// The groups the user is in.
  final KtList<Group> joined;

  /// The groups the user was added to by someone who is not a friend, to
  /// accept or turn down. One added by a friend joins by itself and never
  /// shows here; one added by someone the user blocked never shows at all.
  final KtList<Group> invitations;

  /// Whether the groups the user is in have arrived at least once.
  final bool loaded;

  final GroupFailure? failure;

  /// The groups being joined or turned down right now.
  final Set<String> answering;

  const GroupsWatcherState({
    this.joined = const KtList.empty(),
    this.invitations = const KtList.empty(),
    this.loaded = false,
    this.failure,
    this.answering = const {},
  });

  GroupsWatcherState copyWith({
    KtList<Group>? joined,
    KtList<Group>? invitations,
    bool? loaded,
    GroupFailure? failure,
    bool clearFailure = false,
    Set<String>? answering,
  }) => GroupsWatcherState(
    joined: joined ?? this.joined,
    invitations: invitations ?? this.invitations,
    loaded: loaded ?? this.loaded,
    failure: clearFailure ? null : failure ?? this.failure,
    answering: answering ?? this.answering,
  );

  @override
  List<Object?> get props => [joined, invitations, loaded, failure, answering];

  /// Counts only: who is in which group stays out of logs.
  @override
  String toString() =>
      'GroupsWatcherState(${joined.size} joined, '
      '${invitations.size} invitations, loaded: $loaded)';
}

/// The groups the user is in and the ones they were added to.
///
/// An invitation from a friend is accepted on this phone as soon as it
/// arrives: the security rules cannot check friendships for a whole group, so
/// nobody else's phone may put the user in one. Friends therefore join
/// straight away, and everyone else asks.
class GroupsWatcherBloc extends Bloc<GroupsWatcherEvent, GroupsWatcherState> {
  final IGroupRepository _groups;
  final ICurrentUserSession _session;
  final IFriendRequestsRepository? _friendRequests;
  final IBlockList? _blocks;

  StreamSubscription<Either<GroupFailure, KtList<Group>>>? _joinedWatch;
  StreamSubscription<Either<GroupFailure, KtList<Group>>>? _invitationsWatch;
  StreamSubscription<Either<FriendRequestFailure, KtList<FriendRequest>>>?
  _friendsWatch;
  StreamSubscription<Blocks>? _blocksWatch;

  /// Every invitation, before those from friends and blocked people are
  /// taken out.
  var _allInvitations = const KtList<Group>.empty();

  /// Null until the friends have arrived: until then an invitation cannot be
  /// told apart from one to ask about, so none shows.
  Set<String>? _friendIds;

  /// Invitations from friends already being accepted, so each is sent once.
  final _joiningByThemselves = <String>{};

  GroupsWatcherBloc(
    this._groups,
    this._session, {
    IFriendRequestsRepository? friendRequests,
    IBlockList? blocks,
  }) : _friendRequests = friendRequests,
       _blocks = blocks,
       super(const GroupsWatcherState()) {
    if (friendRequests == null) _friendIds = const {};
    // One for the app: the next person to sign in starts from nothing.
    _session.ended.listen((_) {
      unawaited(_joinedWatch?.cancel());
      unawaited(_invitationsWatch?.cancel());
      unawaited(_friendsWatch?.cancel());
      _joinedWatch = null;
      _invitationsWatch = null;
      _friendsWatch = null;
      _allInvitations = const KtList.empty();
      _friendIds = friendRequests == null ? const {} : null;
      _joiningByThemselves.clear();
      if (!isClosed) add(const _SignedOut());
    });
    on<GroupsWatcherEvent>((event, emit) async {
      switch (event) {
        case GroupsWatchStarted():
          await _joinedWatch?.cancel();
          _joinedWatch = _groups.watchJoined().listen((failureOrGroups) {
            if (!isClosed) add(_JoinedReceived(failureOrGroups));
          });
          await _invitationsWatch?.cancel();
          _invitationsWatch = _groups.watchInvitations().listen((
            failureOrGroups,
          ) {
            if (!isClosed) add(_InvitationsReceived(failureOrGroups));
          });
          _friendsWatch ??= _friendRequests
              ?.watchFriendsForCurrentUser()
              .listen((failureOrFriends) {
                if (isClosed) return;
                failureOrFriends.fold(
                  (_) {},
                  (friends) => add(_FriendsReceived(_friendIdsIn(friends))),
                );
              });
          _blocksWatch ??= _blocks?.blocksChanges.listen((_) {
            if (!isClosed) add(const _BlocksChanged());
          });

        case _JoinedReceived(:final failureOrGroups):
          emit(
            failureOrGroups.fold(
              (failure) => state.copyWith(failure: failure, loaded: true),
              (groups) => state.copyWith(
                joined: groups,
                loaded: true,
                clearFailure: true,
              ),
            ),
          );

        case _InvitationsReceived(:final failureOrGroups):
          failureOrGroups.fold(
            (failure) => emit(state.copyWith(failure: failure)),
            (groups) => _allInvitations = groups,
          );
          _sortInvitations(emit);

        case _FriendsReceived(:final friendIds):
          _friendIds = friendIds;
          _sortInvitations(emit);

        case _BlocksChanged():
          _sortInvitations(emit);

        case _SignedOut():
          emit(const GroupsWatcherState());

        case GroupInvitationAccepted(:final groupId):
          await _answer(groupId, emit, _groups.accept);

        case GroupInvitationDeclined(:final groupId):
          await _answer(groupId, emit, _groups.decline);
      }
    });
  }

  /// Splits the invitations: from a friend, joined by itself; from someone
  /// blocked, out of sight; the rest, shown to ask about.
  void _sortInvitations(Emitter<GroupsWatcherState> emit) {
    final userId = _session.current?.id;
    final friendIds = _friendIds;
    if (userId == null || friendIds == null) return;
    final blocks = _blocks?.blocks ?? const Blocks();
    final toAsk = <Group>[];
    for (final group in _allInvitations.iter) {
      final inviter = group.invitedBy[userId];
      if (inviter != null &&
          blocks.isBlocked(UniqueId.fromUniqueString(inviter))) {
        continue;
      }
      if (inviter != null && friendIds.contains(inviter)) {
        if (_joiningByThemselves.add(group.id.getOrCrash())) {
          unawaited(_groups.accept(group.id));
        }
        continue;
      }
      toAsk.add(group);
    }
    emit(state.copyWith(invitations: toAsk.toImmutableList()));
  }

  Future<void> _answer(
    UniqueId groupId,
    Emitter<GroupsWatcherState> emit,
    Future<Either<GroupFailure, Unit>> Function(UniqueId) answer,
  ) async {
    final id = groupId.getOrCrash();
    if (state.answering.contains(id)) return;
    emit(state.copyWith(answering: {...state.answering, id}));
    final result = await answer(groupId);
    emit(
      state.copyWith(
        answering: {...state.answering}..remove(id),
        failure: result.fold((failure) => failure, (_) => null),
        clearFailure: result.isRight(),
      ),
    );
  }

  /// The other person in each accepted friend request.
  Set<String> _friendIdsIn(KtList<FriendRequest> friends) {
    final userId = _session.current?.id;
    return {
      for (final friend in friends.iter)
        friend.senderId.getOrCrash() == userId
            ? friend.receiverId.getOrCrash()
            : friend.senderId.getOrCrash(),
    };
  }

  @override
  Future<void> close() async {
    await _joinedWatch?.cancel();
    await _invitationsWatch?.cancel();
    await _friendsWatch?.cancel();
    await _blocksWatch?.cancel();
    return super.close();
  }
}
