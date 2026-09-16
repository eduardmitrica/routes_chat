import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/groups/group.dart';
import '../../domain/groups/group_failure.dart';
import '../../domain/groups/group_repository_interface.dart';

sealed class GroupActorEvent extends Equatable {
  const GroupActorEvent();

  /// An admin takes [userId] out of the group.
  const factory GroupActorEvent.removed(UniqueId userId) = GroupMemberRemoved;

  /// The user leaves the group.
  const factory GroupActorEvent.left() = GroupLeft;

  /// An admin makes [userId] an admin, or stops them being one.
  const factory GroupActorEvent.adminSet(
    UniqueId userId, {
    required bool admin,
  }) = GroupAdminSet;

  /// An admin decides whether only admins may add people.
  const factory GroupActorEvent.onlyAdminsAddSet(bool onlyAdmins) =
      GroupOnlyAdminsAddSet;

  /// A member names the group [name], and gives it the photo at [photoPath],
  /// or takes its photo away.
  const factory GroupActorEvent.profileSaved({
    required String name,
    String? photoPath,
    bool removePhoto,
  }) = GroupProfileSaved;

  @override
  List<Object?> get props => const [];
}

final class GroupMemberRemoved extends GroupActorEvent {
  final UniqueId userId;
  const GroupMemberRemoved(this.userId);
  @override
  List<Object?> get props => [userId];
}

final class GroupLeft extends GroupActorEvent {
  const GroupLeft();
}

final class GroupAdminSet extends GroupActorEvent {
  final UniqueId userId;
  final bool admin;
  const GroupAdminSet(this.userId, {required this.admin});
  @override
  List<Object?> get props => [userId, admin];
}

final class GroupOnlyAdminsAddSet extends GroupActorEvent {
  final bool onlyAdmins;
  const GroupOnlyAdminsAddSet(this.onlyAdmins);
  @override
  List<Object?> get props => [onlyAdmins];
}

final class GroupProfileSaved extends GroupActorEvent {
  final String name;
  final String? photoPath;
  final bool removePhoto;
  const GroupProfileSaved({
    required this.name,
    this.photoPath,
    this.removePhoto = false,
  });
  @override
  List<Object?> get props => [name, photoPath, removePhoto];
}

final class GroupActorState extends Equatable {
  /// Whose change is on its way, by user id; "leave" and "onlyAdminsAdd"
  /// for those.
  final Set<String> busy;

  final GroupFailure? lastFailure;

  /// How many changes failed, so the same failure twice still speaks up.
  final int failures;

  /// The user has left the group.
  final bool left;

  /// How many times the name and photo were saved, so a screen can close.
  final int profilesSaved;

  const GroupActorState({
    this.busy = const {},
    this.lastFailure,
    this.failures = 0,
    this.left = false,
    this.profilesSaved = 0,
  });

  @override
  List<Object?> get props => [busy, lastFailure, failures, left, profilesSaved];
}

/// Changes to one group: who is in it, who manages it, and leaving it. What
/// each person may do is checked by the security rules; the screens only
/// offer what [Group] says they may.
class GroupActorBloc extends Bloc<GroupActorEvent, GroupActorState> {
  static const leaving = 'leave';
  static const settingOnlyAdminsAdd = 'onlyAdminsAdd';
  static const savingProfile = 'profile';

  final IGroupRepository _groups;
  final UniqueId _groupId;

  GroupActorBloc(this._groups, this._groupId) : super(const GroupActorState()) {
    on<GroupActorEvent>((event, emit) async {
      switch (event) {
        case GroupMemberRemoved(:final userId):
          await _run(
            userId.getOrCrash(),
            emit,
            () => _groups.remove(_groupId, userId),
          );
        case GroupLeft():
          final left = await _run(leaving, emit, () => _groups.leave(_groupId));
          if (left) emit(_copy(left: true));
        case GroupAdminSet(:final userId, :final admin):
          await _run(
            userId.getOrCrash(),
            emit,
            () => _groups.setAdmin(_groupId, userId, admin: admin),
          );
        case GroupProfileSaved(
          :final name,
          :final photoPath,
          :final removePhoto,
        ):
          final saved = await _run(
            savingProfile,
            emit,
            () => _groups.setProfile(
              _groupId,
              name: name,
              photoPath: photoPath,
              removePhoto: removePhoto,
            ),
          );
          if (saved) emit(_copy(profilesSaved: state.profilesSaved + 1));
        case GroupOnlyAdminsAddSet(:final onlyAdmins):
          await _run(
            settingOnlyAdminsAdd,
            emit,
            () => _groups.setOnlyAdminsAdd(_groupId, onlyAdmins: onlyAdmins),
          );
      }
    });
  }

  /// Runs [change] under [key], once at a time, and says whether it worked.
  Future<bool> _run(
    String key,
    Emitter<GroupActorState> emit,
    Future<Either<GroupFailure, Unit>> Function() change,
  ) async {
    if (state.busy.contains(key)) return false;
    emit(_copy(busy: {...state.busy, key}));
    final result = await change();
    return result.fold(
      (failure) {
        emit(
          _copy(
            busy: {...state.busy}..remove(key),
            lastFailure: failure,
            failures: state.failures + 1,
          ),
        );
        return false;
      },
      (_) {
        emit(_copy(busy: {...state.busy}..remove(key)));
        return true;
      },
    );
  }

  GroupActorState _copy({
    Set<String>? busy,
    GroupFailure? lastFailure,
    int? failures,
    bool? left,
    int? profilesSaved,
  }) => GroupActorState(
    busy: busy ?? state.busy,
    lastFailure: lastFailure ?? state.lastFailure,
    failures: failures ?? state.failures,
    left: left ?? state.left,
    profilesSaved: profilesSaved ?? state.profilesSaved,
  );
}
