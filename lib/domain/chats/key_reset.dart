import 'package:equatable/equatable.dart';

import '../core/value_objects.dart';

/// A participant of a chat reset their encryption keys, after losing both the
/// passphrase and the recovery key.
///
/// From [keyGeneration] on, the chat uses a new key. Messages before it stay
/// unreadable for the participant who reset.
final class KeyReset extends Equatable {
  final UniqueId userId;
  final int keyGeneration;

  const KeyReset({required this.userId, required this.keyGeneration});

  @override
  List<Object?> get props => [userId, keyGeneration];
}
