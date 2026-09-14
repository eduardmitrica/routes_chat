/// Whether [text] contains [query], ignoring case and diacritics, so "sa"
/// finds "Să" and "sarbatori" finds "sărbători". A blank query matches
/// nothing.
bool matchesSearch(String text, String query) {
  final folded = foldForSearch(query.trim());
  return folded.isNotEmpty && foldForSearch(text).contains(folded);
}

/// [text] in lower case, with accented Latin letters replaced by their base
/// letters.
String foldForSearch(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final character = String.fromCharCode(rune);
    buffer.write(_baseLetters[character] ?? character);
  }
  return buffer.toString();
}

const _baseLetters = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ă': 'a', //
  'ą': 'a', 'ā': 'a', 'ç': 'c', 'ć': 'c', 'č': 'c', 'ď': 'd', 'đ': 'd', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ę': 'e', 'ě': 'e', 'ē': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'ł': 'l', 'ñ': 'n', //
  'ń': 'n', 'ň': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
  'ő': 'o', 'ø': 'o', 'ř': 'r', 'ś': 's', 'š': 's', 'ș': 's', 'ş': 's', //
  'ť': 't', 'ț': 't', 'ţ': 't', 'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', //
  'ű': 'u', 'ů': 'u', 'ū': 'u', 'ý': 'y', 'ÿ': 'y', 'ź': 'z', 'ż': 'z', //
  'ž': 'z', 'ß': 'ss',
};
