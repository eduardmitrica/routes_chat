import 'package:equatable/equatable.dart';

/// A group's name and photo, encrypted with the group's key so only the
/// people in it see them. See docs/e2ee.md.
final class GroupProfile extends Equatable {
  /// The longest name, in UTF-16 code units.
  static const maxNameLength = 64;

  /// The photo's side in pixels. Small enough to travel inside the group
  /// itself, encrypted along with the name.
  static const photoSide = 256;

  /// The name, trimmed; empty when the group has none.
  final String name;

  /// The photo as a JPEG, or null.
  final List<int>? photo;

  const GroupProfile({this.name = '', this.photo});

  bool get hasName => name.isNotEmpty;

  bool get isEmpty => name.isEmpty && photo == null;

  @override
  List<Object?> get props => [name, photo];

  /// Neither the name nor the photo reaches the logs.
  @override
  String toString() =>
      'GroupProfile(name: ${hasName ? 'set' : 'none'}, '
      'photo: ${photo == null ? 'none' : 'set'})';
}

/// [name] as a group's name: trimmed, and null when it is too long.
String? groupNameOf(String name) {
  final trimmed = name.trim();
  return trimmed.length > GroupProfile.maxNameLength ? null : trimmed;
}
