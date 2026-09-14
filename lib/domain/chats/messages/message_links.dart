import 'package:equatable/equatable.dart';

/// A stretch of a message's text: a link, or the text around links.
final class TextPart extends Equatable {
  final String text;

  /// Where the part leads; null for plain text.
  final Uri? link;

  const TextPart(this.text, {this.link});

  @override
  List<Object?> get props => [text, link];
}

/// Addresses starting with http://, https:// or www., and email addresses.
/// Not preceded by a letter, digit or address character, so a word that only
/// ends in "www." is not taken for one.
final _candidates = RegExp(
  r'(?<![\p{L}\p{N}_@./-])'
  r'(?:(?<web>(?:https?://|www\.)[^\s<>"]+)'
  r'|(?<email>[\p{L}\p{N}._%+-]+@[\p{L}\p{N}-]+(?:\.[\p{L}\p{N}-]+)*\.\p{L}{2,}))',
  caseSensitive: false,
  unicode: true,
);

/// Characters that end a sentence more often than they end an address.
const _trailingPunctuation = '.,;:!?\'"…';

/// [text] split into links and the text around them.
///
/// Web addresses that start with http://, https:// or www. and email
/// addresses are links. A bare name such as example.com is not: too many
/// ordinary words look like one (file.txt, e.g.). A link can only open a web
/// page or start an email, never another kind of address such as
/// `javascript:` or `intent:`.
List<TextPart> splitLinks(String text) {
  final parts = <TextPart>[];
  var plainFrom = 0;
  for (final match in _candidates.allMatches(text)) {
    final isWeb = match.namedGroup('web') != null;
    final address = _withoutTrailingPunctuation(match.group(0)!);
    final link = isWeb ? _webLink(address) : _emailLink(address);
    if (link == null) continue;
    if (match.start > plainFrom) {
      parts.add(TextPart(text.substring(plainFrom, match.start)));
    }
    parts.add(TextPart(address, link: link));
    plainFrom = match.start + address.length;
  }
  if (plainFrom < text.length) {
    parts.add(TextPart(text.substring(plainFrom)));
  }
  return parts;
}

/// [address] without the punctuation after it, and without closing brackets
/// it did not open, as in "(see https://example.com)".
String _withoutTrailingPunctuation(String address) {
  var end = address.length;
  while (end > 0) {
    final last = address[end - 1];
    final kept = address.substring(0, end);
    final unopened =
        (last == ')' && _count(kept, ')') > _count(kept, '(')) ||
        (last == ']' && _count(kept, ']') > _count(kept, '['));
    if (!_trailingPunctuation.contains(last) && !unopened) break;
    end--;
  }
  return address.substring(0, end);
}

int _count(String text, String character) => character.allMatches(text).length;

Uri? _webLink(String address) {
  final lower = address.toLowerCase();
  final String full;
  if (lower.startsWith('www.')) {
    full = 'https://$address';
  } else if (lower.startsWith('http://') || lower.startsWith('https://')) {
    full = address;
  } else {
    return null;
  }
  final uri = Uri.tryParse(full);
  final isWebPage =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      RegExp(r'^[^.]+(\.[^.]+)+$').hasMatch(uri.host);
  return isWebPage ? uri : null;
}

Uri? _emailLink(String address) =>
    address.contains('@') ? Uri(scheme: 'mailto', path: address) : null;
