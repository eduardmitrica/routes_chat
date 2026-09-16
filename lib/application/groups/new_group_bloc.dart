import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/groups/group.dart';
import '../../domain/groups/group_failure.dart';
import '../../domain/groups/group_repository_interface.dart';

sealed class NewGroupEvent extends Equatable {
  const NewGroupEvent();

  /// Adds [userId] to the people to invite, or takes them off again.
  const factory NewGroupEvent.personToggled(UniqueId userId) =
      NewGroupPersonToggled;

  /// Starts the group with the people chosen.
  const factory NewGroupEvent.created() = NewGroupCreated;

  @override
  List<Object?> get props => const [];
}

final class NewGroupPersonToggled extends NewGroupEvent {
  final UniqueId userId;
  const NewGroupPersonToggled(this.userId);
  @override
  List<Object?> get props => [userId];
}

final class NewGroupCreated extends NewGroupEvent {
  const NewGroupCreated();
}

final class NewGroupState extends Equatable {
  /// Who will be invited, in the order they were chosen.
  final List<UniqueId> chosen;

  final bool creating;

  /// The new group, once it exists.
  final UniqueId? createdId;

  final GroupFailure? failure;

  /// How many attempts failed, so the same failure twice still speaks up.
  final int failures;

  const NewGroupState({
    this.chosen = const [],
    this.creating = false,
    this.createdId,
    this.failure,
    this.failures = 0,
  });

  /// The user and everyone chosen fit in a group, and there is someone.
  bool get canCreate =>
      chosen.isNotEmpty && chosen.length < Group.maxMembers && !creating;

  /// Whether anyone more may be chosen.
  bool get isFull => chosen.length >= Group.maxMembers - 1;

  bool isChosen(UniqueId userId) => chosen.contains(userId);

  @override
  List<Object?> get props => [chosen, creating, createdId, failure, failures];

  @override
  String toString() =>
      'NewGroupState(${chosen.length} chosen, creating: $creating)';
}

/// Choosing people for a new group, and starting it.
class NewGroupBloc extends Bloc<NewGroupEvent, NewGroupState> {
  final IGroupRepository _groups;

  NewGroupBloc(this._groups) : super(const NewGroupState()) {
    on<NewGroupEvent>((event, emit) async {
      switch (event) {
        case NewGroupPersonToggled(:final userId):
          if (state.creating || state.createdId != null) return;
          if (state.isChosen(userId)) {
            emit(
              NewGroupState(
                chosen: [...state.chosen]..remove(userId),
                failures: state.failures,
              ),
            );
          } else if (!state.isFull) {
            emit(
              NewGroupState(
                chosen: [...state.chosen, userId],
                failures: state.failures,
              ),
            );
          }

        case NewGroupCreated():
          if (!state.canCreate) return;
          emit(
            NewGroupState(
              chosen: state.chosen,
              creating: true,
              failures: state.failures,
            ),
          );
          final result = await _groups.create(state.chosen);
          emit(
            result.fold(
              (failure) => NewGroupState(
                chosen: state.chosen,
                failure: failure,
                failures: state.failures + 1,
              ),
              (groupId) => NewGroupState(
                chosen: state.chosen,
                createdId: groupId,
                failures: state.failures,
              ),
            ),
          );
      }
    });
  }
}
