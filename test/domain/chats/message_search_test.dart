import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/message_search.dart';

void main() {
  test('matches regardless of case', () {
    expect(matchesSearch('Salut, ce faci?', 'CE FACI'), isTrue);
  });

  test('matches Romanian and other accented letters without the accents', () {
    expect(matchesSearch('Să mergem la mare', 'sa mergem'), isTrue);
    expect(matchesSearch('Sărbători fericite', 'sarbatori'), isTrue);
    expect(matchesSearch('Ștefan și Țuțu', 'stefan si tutu'), isTrue);
    expect(matchesSearch('Crème brûlée', 'creme brulee'), isTrue);
  });

  test('matches accented queries against plain text too', () {
    expect(matchesSearch('sarbatori fericite', 'Sărbători'), isTrue);
  });

  test('does not match text that is not there', () {
    expect(matchesSearch('Salut', 'pa'), isFalse);
  });

  test('a blank query matches nothing', () {
    expect(matchesSearch('Salut', ''), isFalse);
    expect(matchesSearch('Salut', '   '), isFalse);
  });

  test('surrounding spaces in the query are ignored', () {
    expect(matchesSearch('ne vedem mâine', '  maine '), isTrue);
  });
}
