import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/value_objects.dart';
import 'package:routes_chat/infrastructure/friend_requests/friend_request_data_transfer_object.dart';

FriendRequest _request({required String sender, required String receiver}) =>
    FriendRequest(
      id: UniqueId.fromUniqueString('pair'),
      senderId: UniqueId.fromUniqueString(sender),
      receiverId: UniqueId.fromUniqueString(receiver),
      status: Status(Pending()),
    );

void main() {
  // firestore.rules only lets the two parties read a request, and the watchers
  // query `participantIds arrayContains <uid>`. If this field is missing or
  // wrong, the create is denied and the request never shows up for either side.

  test('participantIds holds both parties, sorted', () {
    final dto = FriendRequestDataTransferObject.fromDomain(
      _request(sender: 'uid-zed', receiver: 'uid-amy'),
    );

    expect(dto.participantIds, ['uid-amy', 'uid-zed']);
  });

  test('participantIds is the same whichever side sent the request', () {
    final fromAmy = FriendRequestDataTransferObject.fromDomain(
      _request(sender: 'uid-amy', receiver: 'uid-zed'),
    );
    final fromZed = FriendRequestDataTransferObject.fromDomain(
      _request(sender: 'uid-zed', receiver: 'uid-amy'),
    );

    expect(fromAmy.participantIds, fromZed.participantIds);
  });

  test('participantIds is written to Firestore', () {
    final json = FriendRequestDataTransferObject.fromDomain(
      _request(sender: 'uid-amy', receiver: 'uid-zed'),
    ).toJson();

    expect(json['participantIds'], ['uid-amy', 'uid-zed']);
  });
}
