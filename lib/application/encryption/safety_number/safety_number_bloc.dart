import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/core/value_objects.dart';
import '../../../domain/encryption/key_verifications.dart';
import '../../../domain/encryption/public_keys.dart';
import '../../../domain/encryption/safety_number.dart';
import '../../../domain/shared/user/current_user_session_interface.dart';

sealed class SafetyNumberEvent extends Equatable {
  const SafetyNumberEvent();

  /// Works out the number for the chat with [otherUserId] and follows what
  /// the user has checked.
  const factory SafetyNumberEvent.started(UniqueId otherUserId) =
      SafetyNumberStarted;

  /// The user compared the number and it matched.
  const factory SafetyNumberEvent.verified() = SafetyNumberVerified;

  /// The user takes the check back, which also stops the warnings.
  const factory SafetyNumberEvent.forgotten() = SafetyNumberForgotten;

  /// The user has seen the warning that the number changed.
  const factory SafetyNumberEvent.warningSeen() = SafetyNumberWarningSeen;

  /// A QR code was scanned. It counts as a check only if it carries this
  /// chat's number.
  const factory SafetyNumberEvent.scanned(String payload) = SafetyNumberScanned;

  /// Reads the keys again, for a chat left open while they changed.
  const factory SafetyNumberEvent.refreshed() = SafetyNumberRefreshed;

  @override
  List<Object?> get props => const [];
}

final class SafetyNumberStarted extends SafetyNumberEvent {
  final UniqueId otherUserId;
  const SafetyNumberStarted(this.otherUserId);
  @override
  List<Object?> get props => [otherUserId];
}

final class SafetyNumberVerified extends SafetyNumberEvent {
  const SafetyNumberVerified();
}

final class SafetyNumberForgotten extends SafetyNumberEvent {
  const SafetyNumberForgotten();
}

final class SafetyNumberWarningSeen extends SafetyNumberEvent {
  const SafetyNumberWarningSeen();
}

final class SafetyNumberScanned extends SafetyNumberEvent {
  final String payload;
  const SafetyNumberScanned(this.payload);
  @override
  List<Object?> get props => [payload];
}

final class SafetyNumberRefreshed extends SafetyNumberEvent {
  const SafetyNumberRefreshed();
}

final class _NumberWorkedOut extends SafetyNumberEvent {
  final SafetyNumber? number;
  const _NumberWorkedOut(this.number);
  @override
  List<Object?> get props => [number];
}

final class _VerificationsReceived extends SafetyNumberEvent {
  final KeyVerifications verifications;
  const _VerificationsReceived(this.verifications);
  @override
  List<Object?> get props => [verifications];
}

/// What a scan said about the code it read.
enum ScanOutcome { none, matched, differed, notOurs }

final class SafetyNumberState extends Equatable {
  final String otherUserId;

  /// The number for the two of them, or null while it is being worked out or
  /// when one of them has no keys.
  final SafetyNumber? number;

  final bool loading;

  /// The other person has not set up encryption, so there is nothing to
  /// compare yet.
  final bool withoutKeys;

  final KeyVerifications verifications;

  /// What the last scan said, and how many scans have finished, so the screen
  /// can speak up again for the same outcome twice in a row.
  final ScanOutcome lastScan;
  final int scans;

  const SafetyNumberState({
    this.otherUserId = '',
    this.number,
    this.loading = true,
    this.withoutKeys = false,
    this.verifications = const KeyVerifications(),
    this.lastScan = ScanOutcome.none,
    this.scans = 0,
  });

  SafetyNumberState copyWith({
    String? otherUserId,
    SafetyNumber? number,
    bool clearNumber = false,
    bool? loading,
    bool? withoutKeys,
    KeyVerifications? verifications,
    ScanOutcome? lastScan,
    int? scans,
  }) => SafetyNumberState(
    otherUserId: otherUserId ?? this.otherUserId,
    number: clearNumber ? null : number ?? this.number,
    loading: loading ?? this.loading,
    withoutKeys: withoutKeys ?? this.withoutKeys,
    verifications: verifications ?? this.verifications,
    lastScan: lastScan ?? this.lastScan,
    scans: scans ?? this.scans,
  );

  /// Where the user stands with this person's keys.
  KeyVerificationState get state => verifications.stateOf(otherUserId, number);

  /// Whether the chat should warn that the number changed.
  bool get warns => verifications.warnsAbout(otherUserId, number);

  @override
  List<Object?> get props => [
    otherUserId,
    number,
    loading,
    withoutKeys,
    verifications,
    lastScan,
    scans,
  ];

  /// Never the number: what is compared stays out of the logs.
  @override
  String toString() =>
      'SafetyNumberState($state, loading: $loading, keys: ${!withoutKeys})';
}

/// The safety number of one chat, and whether the user has checked it.
///
/// The number comes from both public keys, so it changes when either person
/// resets their keys - or when someone puts other keys in their place, which
/// is what comparing it catches. See docs/e2ee.md.
class SafetyNumberBloc extends Bloc<SafetyNumberEvent, SafetyNumberState> {
  final IPublicKeys _keys;
  final IKeyVerificationsRepository _verifications;
  final ICurrentUserSession _session;
  StreamSubscription<KeyVerifications>? _watch;

  SafetyNumberBloc(this._keys, this._verifications, this._session)
    : super(const SafetyNumberState()) {
    on<SafetyNumberEvent>((event, emit) async {
      switch (event) {
        case SafetyNumberStarted(:final otherUserId):
          emit(
            state.copyWith(
              otherUserId: otherUserId.getOrCrash(),
              loading: true,
            ),
          );
          await _watch?.cancel();
          _watch = _verifications.watch().listen((verifications) {
            if (!isClosed) add(_VerificationsReceived(verifications));
          });
          unawaited(_workOut());

        case SafetyNumberRefreshed():
          emit(state.copyWith(loading: true));
          unawaited(_workOut());

        case _NumberWorkedOut(:final number):
          emit(
            state.copyWith(
              number: number,
              clearNumber: number == null,
              loading: false,
              withoutKeys: number == null,
            ),
          );

        case _VerificationsReceived(:final verifications):
          emit(state.copyWith(verifications: verifications));

        case SafetyNumberVerified():
          if (state.number case final number?) {
            await _verifications.verify(state.otherUserId, number);
          }

        case SafetyNumberForgotten():
          await _verifications.forget(state.otherUserId);

        case SafetyNumberWarningSeen():
          if (state.number case final number?) {
            await _verifications.warningSeen(state.otherUserId, number);
          }

        case SafetyNumberScanned(:final payload):
          final scanned = SafetyNumber.fromQrPayload(payload);
          final number = state.number;
          final outcome = scanned == null
              ? ScanOutcome.notOurs
              : scanned == number
              ? ScanOutcome.matched
              : ScanOutcome.differed;
          if (outcome == ScanOutcome.matched && number != null) {
            await _verifications.verify(state.otherUserId, number);
          }
          emit(state.copyWith(lastScan: outcome, scans: state.scans + 1));
      }
    });
  }

  /// Reads both public keys and works the number out. Null when either side
  /// has no keys.
  Future<void> _workOut() async {
    final userId = _session.current?.id;
    final mine = await _keys.own();
    final theirs = await _keys.of(state.otherUserId);
    if (isClosed) return;
    add(
      _NumberWorkedOut(
        userId == null || mine == null || theirs == null
            ? null
            : safetyNumberOf(
                userId: userId,
                publicKey: mine.bytes,
                otherUserId: state.otherUserId,
                otherPublicKey: theirs.bytes,
              ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _watch?.cancel();
    return super.close();
  }
}
