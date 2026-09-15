import 'package:equatable/equatable.dart';

/// What a user last said about being in the app: on screen or not, and when.
final class Presence extends Equatable {
  /// Whether the user's app was on screen when [lastSeenAt] was written.
  final bool online;

  /// When the user's app last reported, by the server's clock.
  final DateTime lastSeenAt;

  const Presence({required this.online, required this.lastSeenAt});

  @override
  List<Object?> get props => [online, lastSeenAt];
}
