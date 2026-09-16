import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

/// The number two people compare to be sure nobody swapped a public key
/// through the server. See docs/e2ee.md.
///
/// It is 60 digits: each person's 30-digit half of the pair, the smaller half
/// first, so both phones show the same number.
final class SafetyNumber extends Equatable {
  /// How the number is built. A later version would show a different number,
  /// so the two sides must agree on it.
  static const version = 1;

  /// Digits per half, one for each person.
  static const halfLength = 30;

  /// How many times each half is hashed, which makes working back from the
  /// number to a key slow. The same count as Signal's.
  static const rounds = 5200;

  final String digits;

  const SafetyNumber(this.digits);

  /// The number in 12 groups of 5, the way it is read out and compared.
  List<String> get groups => [
    for (var start = 0; start < digits.length; start += 5)
      digits.substring(start, start + 5),
  ];

  /// What a QR code carries: the number, named so another app's QR is not
  /// taken for one of ours.
  String get qrPayload => 'routes_chat/safety-number/v$version/$digits';

  /// The number in [payload], or null if it is not one of ours.
  static SafetyNumber? fromQrPayload(String payload) {
    const prefix = 'routes_chat/safety-number/v$version/';
    final trimmed = payload.trim();
    if (!trimmed.startsWith(prefix)) return null;
    final digits = trimmed.substring(prefix.length);
    if (digits.length != halfLength * 2 ||
        !digits.split('').every((digit) => '0123456789'.contains(digit))) {
      return null;
    }
    return SafetyNumber(digits);
  }

  @override
  List<Object?> get props => [digits];

  /// Never the number itself: what is compared stays out of the logs.
  @override
  String toString() => 'SafetyNumber(${digits.length} digits)';
}

/// The safety number of the two people identified by their user ids and
/// published public keys. Both sides work it out the same way.
SafetyNumber safetyNumberOf({
  required String userId,
  required List<int> publicKey,
  required String otherUserId,
  required List<int> otherPublicKey,
}) {
  final mine = _half(userId, publicKey);
  final theirs = _half(otherUserId, otherPublicKey);
  // The smaller half first, so the order of the two people does not matter.
  return SafetyNumber(
    mine.compareTo(theirs) <= 0 ? '$mine$theirs' : '$theirs$mine',
  );
}

/// One person's 30 digits: their public key and id hashed [SafetyNumber.rounds]
/// times, the first 30 bytes read as six numbers of five digits.
String _half(String userId, List<int> publicKey) {
  final key = Uint8List.fromList(publicKey);
  final start = Uint8List.fromList([
    0,
    SafetyNumber.version,
    ...key,
    ...utf8.encode(userId),
  ]);
  var hash = sha512.convert(start).bytes;
  for (var round = 1; round < SafetyNumber.rounds; round++) {
    hash = sha512.convert([...hash, ...key]).bytes;
  }
  final digits = StringBuffer();
  for (var chunk = 0; chunk < SafetyNumber.halfLength ~/ 5; chunk++) {
    var number = 0;
    for (var byte = 0; byte < 5; byte++) {
      number = number * 256 + hash[chunk * 5 + byte];
    }
    digits.write((number % 100000).toString().padLeft(5, '0'));
  }
  return digits.toString();
}
