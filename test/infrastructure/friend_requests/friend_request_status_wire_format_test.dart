import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/value_validators.dart';
import 'package:routes_chat/infrastructure/friend_requests/friend_request_data_transfer_object.dart';

FriendRequest _request(FriendRequestStatus status) => FriendRequest(
  id: UniqueId.fromUniqueString('uid-a_uid-b'),
  senderId: UniqueId.fromUniqueString('uid-a'),
  receiverId: UniqueId.fromUniqueString('uid-b'),
  status: Status(status),
);

void main() {
  // The stored status used to be parsed out of the status object's toString(),
  // i.e. its class name. `flutter build --obfuscate` minifies class names, so an
  // obfuscated release would have stored something like "a2" and the rules
  // would have rejected every friend request write. These tests pin the stored
  // names to literals that do not depend on class names.

  test('the DTO stores literal status names', () {
    expect(
      FriendRequestDataTransferObject.fromDomain(_request(Pending())).status,
      'Pending',
    );
    expect(
      FriendRequestDataTransferObject.fromDomain(_request(Accepted())).status,
      'Accepted',
    );
  });

  test('every storable status survives a round trip', () {
    for (final status in <FriendRequestStatus>[Pending(), Accepted()]) {
      final parsed = Status.fromString(statusName(status));
      expect(parsed.isValid(), isTrue, reason: statusName(status));
      expect(parsed.getOrCrash().runtimeType, status.runtimeType);
    }
  });

  test('statusName is the exact inverse of statusMap', () {
    for (final entry in statusMap.entries) {
      expect(statusName(entry.value), entry.key);
    }
  });

  test('an incorrect status cannot be stored', () {
    expect(() => statusName(Incorrect()), throwsArgumentError);
  });

  test('firestore.rules checks exactly the stored names', () {
    // The rules compare status against string literals; if these drift apart,
    // every friend request create or accept is denied in production while the
    // app still compiles.
    final rules = File('firestore.rules').readAsStringSync();
    for (final status in <FriendRequestStatus>[Pending(), Accepted()]) {
      expect(
        rules,
        contains("status == '${statusName(status)}'"),
        reason: 'firestore.rules no longer checks "${statusName(status)}"',
      );
    }
  });
}
