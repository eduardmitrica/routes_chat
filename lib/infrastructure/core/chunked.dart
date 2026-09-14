import 'dart:math';

/// Splits [items] into consecutive groups of at most [size] items, in order.
///
/// Used to stay within Firestore's limit on values in a single `in` filter.
List<List<T>> chunked<T>(List<T> items, int size) {
  if (size < 1) {
    throw ArgumentError.value(size, 'size', 'must be at least 1');
  }
  return [
    for (var start = 0; start < items.length; start += size)
      items.sublist(start, min(start + size, items.length)),
  ];
}
