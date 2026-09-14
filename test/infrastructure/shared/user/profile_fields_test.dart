import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart'
    as value_objects;
import 'package:routes_chat/infrastructure/shared/user/user_data_transfer_object.dart';

Map<String, dynamic> _storedProfile() => UserDataTransferObject.fromDomain(
  User(
    id: UniqueId.fromUniqueString('uid-1'),
    imageUrl: value_objects.ImageUrl('https://example.com/avatar.jpg'),
    username: value_objects.Username('eduard'),
    description: value_objects.Description('hello'),
  ),
).toJson();

Set<String> _fieldsAllowedByRules() {
  final rules = File('firestore.rules').readAsStringSync();
  final function = RegExp(
    r'function profileFields\(\)\s*\{\s*return\s*\[([^\]]*)\]',
  ).firstMatch(rules);
  expect(function, isNotNull, reason: 'profileFields() not found in rules');
  return RegExp(
    r"'([^']+)'",
  ).allMatches(function!.group(1)!).map((match) => match.group(1)!).toSet();
}

void main() {
  // Any signed-in user can read any profile (username search needs it), so a
  // profile must hold only what everyone may see. Email addresses used to be
  // stored here, readable by every signed-in user through the API.

  test('a stored profile holds no email address', () {
    expect(_storedProfile().keys, isNot(contains('emailAddress')));
  });

  test('the stored profile fields are exactly what firestore.rules allows', () {
    // The rules use keys().hasOnly(profileFields()). If the DTO gains a field
    // the rules do not list, every registration and profile save is denied in
    // production while the app still compiles.
    expect(_storedProfile().keys.toSet(), _fieldsAllowedByRules());
  });
}
