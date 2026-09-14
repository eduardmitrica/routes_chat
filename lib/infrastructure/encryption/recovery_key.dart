import 'dart:math';

import 'package:flutter/foundation.dart';

/// The one-time recovery key shown to a user when encryption is set up.
///
/// It holds 160 random bits, which unlock a second wrapped copy of the user's
/// master key if the passphrase is forgotten. It is never stored: the user
/// writes it down. It is shown as eight groups of four base32 characters, for
/// example `ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4567`.
@immutable
final class RecoveryKey {
  /// 20 bytes encode to exactly 32 base32 characters, with no padding.
  static const byteLength = 20;

  static const _groupLength = 4;

  final Uint8List bytes;

  const RecoveryKey._(this.bytes);

  /// A new random recovery key.
  factory RecoveryKey.generate([Random? random]) {
    final source = random ?? Random.secure();
    return RecoveryKey._(
      Uint8List.fromList(
        List<int>.generate(byteLength, (_) => source.nextInt(256)),
      ),
    );
  }

  /// Reads a recovery key as the user typed it. Case, spaces and dashes don't
  /// matter. Returns null when it isn't 32 base32 characters.
  static RecoveryKey? tryParse(String input) {
    final normalized = input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (normalized.length != byteLength * 8 ~/ 5) return null;
    final decoded = base32Decode(normalized);
    if (decoded == null || decoded.length != byteLength) return null;
    return RecoveryKey._(decoded);
  }

  /// The key as shown to the user, in groups of four separated by dashes.
  String get formatted {
    final encoded = base32Encode(bytes);
    return [
      for (var start = 0; start < encoded.length; start += _groupLength)
        encoded.substring(start, start + _groupLength),
    ].join('-');
  }

  @override
  bool operator ==(Object other) =>
      other is RecoveryKey && listEquals(other.bytes, bytes);

  @override
  int get hashCode => Object.hashAll(bytes);

  /// Deliberately does not reveal the key.
  @override
  String toString() => 'RecoveryKey(…)';
}

const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

/// RFC 4648 base32 without padding.
@visibleForTesting
String base32Encode(List<int> bytes) {
  final output = StringBuffer();
  var buffer = 0;
  var bits = 0;
  for (final byte in bytes) {
    buffer = (buffer << 8) | (byte & 0xff);
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      output.write(_alphabet[(buffer >> bits) & 0x1f]);
    }
    buffer &= (1 << bits) - 1;
  }
  if (bits > 0) {
    output.write(_alphabet[(buffer << (5 - bits)) & 0x1f]);
  }
  return output.toString();
}

/// Decodes unpadded RFC 4648 base32. Returns null on any character outside
/// the alphabet.
@visibleForTesting
Uint8List? base32Decode(String input) {
  final output = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final character in input.split('')) {
    final value = _alphabet.indexOf(character);
    if (value < 0) return null;
    buffer = (buffer << 5) | value;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      output.add((buffer >> bits) & 0xff);
    }
    buffer &= (1 << bits) - 1;
  }
  return Uint8List.fromList(output);
}
