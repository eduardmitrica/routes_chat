/// Who is typing in a group, as a line under its name: "Ana is typing…",
/// "Ana and Radu are typing…", "3 people are typing…". Null when nobody is.
String? describeGroupTyping(List<String> names) => switch (names) {
  [] => null,
  [final one] => '$one is typing…',
  [final one, final two] => '$one and $two are typing…',
  _ => '${names.length} people are typing…',
};

/// Who has read a message the user sent to a group, [names] in the order
/// they read it: "Seen by Ana", "Seen by Ana and Radu", "Seen by Ana, Radu
/// and Bogdan", then "Seen by 5". "Seen by everyone" once all [othersInGroup]
/// people have, in a group of more than two. Null when nobody has.
String? describeGroupSeen(List<String> names, {required int othersInGroup}) {
  if (names.isEmpty) return null;
  if (othersInGroup > 1 && names.length >= othersInGroup) {
    return 'Seen by everyone';
  }
  return switch (names) {
    [final one] => 'Seen by $one',
    [final one, final two] => 'Seen by $one and $two',
    [final one, final two, final three] => 'Seen by $one, $two and $three',
    _ => 'Seen by ${names.length}',
  };
}
