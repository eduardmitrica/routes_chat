import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/encryption/key_verifications.dart';
import '../../domain/encryption/safety_number.dart';
import '../../domain/shared/user/current_user_session_interface.dart';
import '../core/local_vault.dart';

/// Whose safety number the user compared, in a file on the phone encrypted
/// like drafts (see [LocalVault]), which signing out deletes.
///
/// It stays on the phone on purpose: the server never learns whom the user
/// checked. A new phone starts with nobody checked.
class KeyVerificationsStore implements IKeyVerificationsRepository {
  static const _file = 'key_verifications';

  final LocalVault _vault;
  final DateTime Function() _now;

  var _verifications = BehaviorSubject<KeyVerifications>();
  Future<KeyVerifications>? _loaded;

  /// Each change waits for the one before, so none is lost.
  Future<void> _tail = Future.value();

  KeyVerificationsStore(
    this._vault,
    ICurrentUserSession session, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    // The next user starts from their own file.
    session.ended.listen((_) {
      final previous = _verifications;
      _verifications = BehaviorSubject<KeyVerifications>();
      _loaded = null;
      unawaited(previous.close());
    });
  }

  Future<T> _inTurn<T>(Future<T> Function() task) {
    final result = _tail.then((_) => task());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<KeyVerifications> _load() => _loaded ??= () async {
    final verifications = await _read() ?? const KeyVerifications();
    _verifications.add(verifications);
    return verifications;
  }();

  Future<KeyVerifications?> _read() async {
    try {
      final bytes = await _vault.read(_file);
      if (bytes == null) return null;
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return KeyVerifications(
        byUserId: {
          for (final MapEntry(:key, :value) in json.entries)
            key: _verificationFrom(value as Map<String, dynamic>),
        },
      );
    } on Object catch (error) {
      if (error is! TypeError && error is! FormatException) rethrow;
      debugPrint('Key verifications not in the stored format; starting again');
      return null;
    }
  }

  static KeyVerification _verificationFrom(Map<String, dynamic> json) {
    final seen = json['seen'];
    return KeyVerification(
      number: SafetyNumber(json['number'] as String),
      at: DateTime.fromMillisecondsSinceEpoch(json['at'] as int, isUtc: true),
      warningSeenFor: seen is String ? SafetyNumber(seen) : null,
    );
  }

  Future<void> _write(KeyVerifications verifications) async {
    try {
      await _vault.write(
        _file,
        utf8.encode(
          jsonEncode({
            for (final MapEntry(:key, :value) in verifications.byUserId.entries)
              key: {
                'number': value.number.digits,
                'at': value.at.millisecondsSinceEpoch,
                if (value.warningSeenFor case final seen?) 'seen': seen.digits,
              },
          }),
        ),
      );
    } on Object catch (error) {
      debugPrint('Key verifications not saved: ${error.runtimeType}');
    }
  }

  Future<void> _change(
    Map<String, KeyVerification> Function(Map<String, KeyVerification>) next,
  ) => _inTurn(() async {
    final verifications = await _load();
    final changed = KeyVerifications(byUserId: next(verifications.byUserId));
    if (changed == verifications) return;
    // What is loaded now, so the change after this one builds on it.
    _loaded = Future.value(changed);
    _verifications.add(changed);
    await _write(changed);
  });

  @override
  Stream<KeyVerifications> watch() {
    unawaited(
      _inTurn(_load).catchError((Object error) {
        debugPrint('Key verifications not loaded: ${error.runtimeType}');
        return const KeyVerifications();
      }),
    );
    return _verifications.stream;
  }

  @override
  Future<void> verify(String userId, SafetyNumber number) => _change(
    (byUserId) => {
      ...byUserId,
      userId: KeyVerification(number: number, at: _now().toUtc()),
    },
  );

  @override
  Future<void> forget(String userId) =>
      _change((byUserId) => {...byUserId}..remove(userId));

  @override
  Future<void> warningSeen(String userId, SafetyNumber number) =>
      _change((byUserId) {
        final verification = byUserId[userId];
        if (verification == null) return byUserId;
        return {...byUserId, userId: verification.withWarningSeenFor(number)};
      });
}
