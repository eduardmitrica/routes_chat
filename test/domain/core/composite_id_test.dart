import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/composite_id.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

UniqueId _id(String value) => UniqueId.fromUniqueString(value);

void main() {
  test('is the same whichever member comes first', () {
    // A friend request from B to A must land on the same document as one from
    // A to B; that is what makes the duplicate impossible.
    expect(
      compositeId([_id('alice'), _id('bob')]).getOrCrash(),
      compositeId([_id('bob'), _id('alice')]).getOrCrash(),
    );
  });

  test('sorts and joins with an underscore, as firestore.rules expects', () {
    expect(compositeId([_id('zed'), _id('amy')]).getOrCrash(), 'amy_zed');
  });

  test('uses case-sensitive ordering, matching string comparison in rules', () {
    // Firebase uids mix upper and lower case; uppercase sorts first both here
    // and in the rules' `<` comparison.
    expect(compositeId([_id('b'), _id('A')]).getOrCrash(), 'A_b');
  });

  test('differs for different pairs', () {
    expect(
      compositeId([_id('alice'), _id('bob')]).getOrCrash(),
      isNot(compositeId([_id('alice'), _id('carol')]).getOrCrash()),
    );
  });
}
