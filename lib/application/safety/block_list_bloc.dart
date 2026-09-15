import 'dart:async';

import 'package:dartz/dartz.dart' show Either, Unit;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/safety/blocks.dart';
import '../../domain/safety/safety_repository_interface.dart';
import '../../domain/shared/user/current_user_session_interface.dart';

sealed class BlockListEvent extends Equatable {
  const BlockListEvent();

  /// Signed in: follow who the user blocked.
  const factory BlockListEvent.started() = BlockListStarted;
  const factory BlockListEvent.blockRequested(UniqueId userId) = BlockRequested;
  const factory BlockListEvent.unblockRequested(UniqueId userId) =
      UnblockRequested;

  @override
  List<Object?> get props => const [];
}

final class BlockListStarted extends BlockListEvent {
  const BlockListStarted();
}

final class BlockRequested extends BlockListEvent {
  final UniqueId userId;
  const BlockRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

final class UnblockRequested extends BlockListEvent {
  final UniqueId userId;
  const UnblockRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

final class _BlocksReceived extends BlockListEvent {
  final Blocks blocks;
  const _BlocksReceived(this.blocks);
  @override
  List<Object?> get props => [blocks];
}

final class BlockListState extends Equatable {
  final Blocks blocks;

  /// The ids of the people being blocked or unblocked.
  final Set<String> changing;

  /// Counts the blocks and unblocks that failed, so the page says so each
  /// time.
  final int failures;

  const BlockListState({
    this.blocks = const Blocks(),
    this.changing = const {},
    this.failures = 0,
  });

  BlockListState copyWith({
    Blocks? blocks,
    Set<String>? changing,
    int? failures,
  }) => BlockListState(
    blocks: blocks ?? this.blocks,
    changing: changing ?? this.changing,
    failures: failures ?? this.failures,
  );

  @override
  List<Object?> get props => [blocks, changing, failures];

  @override
  String toString() =>
      'BlockListState($blocks, changing: ${changing.length}, failures: '
      '$failures)';
}

/// Who the signed-in user blocked, for every screen that keeps them out of
/// sight, and blocking and unblocking them. One for the app, like the
/// privacy settings; it empties when the session ends.
class BlockListBloc extends Bloc<BlockListEvent, BlockListState>
    implements IBlockList {
  final ISafetyRepository _safety;
  StreamSubscription<Blocks>? _watch;

  BlockListBloc(this._safety, ICurrentUserSession session)
    : super(const BlockListState()) {
    session.ended.listen((_) {
      unawaited(_watch?.cancel());
      _watch = null;
      if (!isClosed) add(const _BlocksReceived(Blocks()));
    });
    on<BlockListEvent>((event, emit) async {
      switch (event) {
        case BlockListStarted():
          await _watch?.cancel();
          _watch = _safety.watchBlocks().listen((blocks) {
            if (!isClosed) add(_BlocksReceived(blocks));
          });

        case _BlocksReceived(:final blocks):
          emit(state.copyWith(blocks: blocks));

        case BlockRequested(:final userId):
          await _change(emit, userId, _safety.block);

        case UnblockRequested(:final userId):
          await _change(emit, userId, _safety.unblock);
      }
    });
  }

  Future<void> _change(
    Emitter<BlockListState> emit,
    UniqueId userId,
    Future<Either<SafetyFailure, Unit>> Function(UniqueId userId) change,
  ) async {
    final id = userId.getOrCrash();
    if (state.changing.contains(id)) return;
    emit(state.copyWith(changing: {...state.changing, id}));
    final failed = (await change(userId)).isLeft();
    emit(
      state.copyWith(
        changing: {...state.changing}..remove(id),
        failures: failed ? state.failures + 1 : null,
      ),
    );
  }

  @override
  Blocks get blocks => state.blocks;

  @override
  Stream<Blocks> get blocksChanges =>
      stream.map((state) => state.blocks).distinct();

  @override
  Future<void> close() async {
    await _watch?.cancel();
    return super.close();
  }
}
