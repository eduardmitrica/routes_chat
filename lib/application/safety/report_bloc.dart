import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/safety/safety_repository_interface.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();

  /// The user reports [reportedId] for [reason], sharing [messages] of
  /// [chatId], and blocks them too when [alsoBlock].
  const factory ReportEvent.submitted({
    required UniqueId reportedId,
    UniqueId? chatId,
    required ReportReason reason,
    List<ReportedMessage> messages,
    bool alsoBlock,
  }) = ReportSubmitted;

  @override
  List<Object?> get props => const [];
}

final class ReportSubmitted extends ReportEvent {
  final UniqueId reportedId;
  final UniqueId? chatId;
  final ReportReason reason;
  final List<ReportedMessage> messages;
  final bool alsoBlock;

  const ReportSubmitted({
    required this.reportedId,
    this.chatId,
    required this.reason,
    this.messages = const [],
    this.alsoBlock = false,
  });

  @override
  List<Object?> get props => [reportedId, chatId, reason, messages, alsoBlock];
}

/// How reporting went. Each report counts, so the same outcome twice is told
/// apart.
final class ReportState extends Equatable {
  final bool submitting;
  final int sent;
  final int failures;

  /// Whether the last report sent also blocked the person.
  final bool lastAlsoBlocked;

  const ReportState({
    this.submitting = false,
    this.sent = 0,
    this.failures = 0,
    this.lastAlsoBlocked = false,
  });

  @override
  List<Object?> get props => [submitting, sent, failures, lastAlsoBlocked];
}

/// Sends a report, and blocks the person reported when asked to.
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ISafetyRepository _safety;

  ReportBloc(this._safety) : super(const ReportState()) {
    on<ReportEvent>((event, emit) async {
      switch (event) {
        case ReportSubmitted(
          :final reportedId,
          :final chatId,
          :final reason,
          :final messages,
          :final alsoBlock,
        ):
          if (state.submitting) return;
          emit(
            ReportState(
              submitting: true,
              sent: state.sent,
              failures: state.failures,
            ),
          );
          final reported = await _safety.report(
            reportedId: reportedId,
            chatId: chatId,
            reason: reason,
            messages: messages,
          );
          // Blocking does not wait for the report to succeed: someone who
          // asks to block wants them gone either way.
          final blocked = alsoBlock
              ? (await _safety.block(reportedId)).isRight()
              : false;
          emit(
            ReportState(
              sent: reported.isRight() ? state.sent + 1 : state.sent,
              failures: reported.isLeft() || (alsoBlock && !blocked)
                  ? state.failures + 1
                  : state.failures,
              lastAlsoBlocked: blocked,
            ),
          );
      }
    });
  }
}
