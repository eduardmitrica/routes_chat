import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/safety/blocks.dart';
import 'package:routes_chat/domain/safety/safety_repository_interface.dart';

/// Who the user blocked, as a test says.
class FakeBlockList implements IBlockList {
  final _changes = StreamController<Blocks>.broadcast();

  @override
  Blocks blocks;

  FakeBlockList([this.blocks = const Blocks()]);

  @override
  Stream<Blocks> get blocksChanges => _changes.stream;

  void change(Blocks next) {
    blocks = next;
    _changes.add(next);
  }

  Future<void> close() => _changes.close();
}

/// Blocks holding one record: [userId] blocked [since], with [earlier]
/// blocks.
Blocks blocking(
  String userId, {
  DateTime? since,
  List<({DateTime from, DateTime to})> earlier = const [],
}) => Blocks({
  userId: BlockRecord(
    userId: UniqueId.fromUniqueString(userId),
    blockedSince: since,
    earlier: earlier,
  ),
});

/// Records blocks, unblocks and reports, answering with [failure] when set.
class FakeSafety implements ISafetyRepository {
  final blocks = StreamController<Blocks>.broadcast();
  final calls = <String>[];
  final reports =
      <
        ({String reportedId, String? chatId, ReportReason reason, int messages})
      >[];
  SafetyFailure? failure;
  Completer<void>? gate;

  Either<SafetyFailure, Unit> get _answer =>
      failure == null ? right(unit) : left(failure!);

  @override
  Stream<Blocks> watchBlocks() => blocks.stream;

  @override
  Future<Either<SafetyFailure, Unit>> block(UniqueId userId) async {
    calls.add('block ${userId.getOrCrash()}');
    await gate?.future;
    return _answer;
  }

  @override
  Future<Either<SafetyFailure, Unit>> unblock(UniqueId userId) async {
    calls.add('unblock ${userId.getOrCrash()}');
    await gate?.future;
    return _answer;
  }

  @override
  Future<Either<SafetyFailure, Unit>> report({
    required UniqueId reportedId,
    UniqueId? chatId,
    required ReportReason reason,
    List<ReportedMessage> messages = const [],
  }) async {
    calls.add('report ${reportedId.getOrCrash()}');
    reports.add((
      reportedId: reportedId.getOrCrash(),
      chatId: chatId?.getOrCrash(),
      reason: reason,
      messages: messages.length,
    ));
    return _answer;
  }
}
