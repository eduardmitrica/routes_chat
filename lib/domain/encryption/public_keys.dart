import 'package:equatable/equatable.dart';

/// Someone's public key and the version of their keys.
final class PublishedKey extends Equatable {
  final List<int> bytes;
  final int keyVersion;

  const PublishedKey(this.bytes, this.keyVersion);

  @override
  List<Object?> get props => [bytes, keyVersion];

  /// Never the key itself, so nothing about it reaches the logs.
  @override
  String toString() => 'PublishedKey(version $keyVersion)';
}

/// The public keys a safety number is worked out from. See docs/e2ee.md.
abstract interface class IPublicKeys {
  /// The signed-in user's own key, from the bundle this device holds rather
  /// than from what the server publishes: if someone replaced the published
  /// copy, the two sides then see different numbers, which is the point.
  ///
  /// Null when they have not set up encryption.
  Future<PublishedKey?> own();

  /// What [userId] published, or null when they have not set up encryption.
  Future<PublishedKey?> of(String userId);
}
