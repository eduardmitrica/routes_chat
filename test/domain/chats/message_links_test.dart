import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/message_links.dart';

/// The links in [text], as the text they show and where they lead.
List<(String, String)> _links(String text) => [
  for (final part in splitLinks(text))
    if (part.link case final link?) (part.text, link.toString()),
];

void main() {
  test('text without links is one plain part', () {
    expect(splitLinks('Ne vedem mâine la 10'), [
      const TextPart('Ne vedem mâine la 10'),
    ]);
  });

  test('an empty message has no parts', () {
    expect(splitLinks(''), isEmpty);
  });

  test('a link in a sentence is split from the words around it', () {
    expect(splitLinks('Uite aici: https://example.ro/pagina?x=1 și zi-mi'), [
      const TextPart('Uite aici: '),
      TextPart(
        'https://example.ro/pagina?x=1',
        link: Uri.parse('https://example.ro/pagina?x=1'),
      ),
      const TextPart(' și zi-mi'),
    ]);
  });

  test('an address starting with www. opens over https', () {
    expect(_links('pe www.example.com/meniu'), [
      ('www.example.com/meniu', 'https://www.example.com/meniu'),
    ]);
  });

  test('http links and capital letters are links too', () {
    expect(_links('http://example.com și HTTPS://EXAMPLE.COM/A'), [
      ('http://example.com', 'http://example.com'),
      ('HTTPS://EXAMPLE.COM/A', 'https://example.com/A'),
    ]);
  });

  test('punctuation after a link stays out of it', () {
    for (final ending in ['.', ',', '!', '?', ':', ';', '…', '"', '...']) {
      expect(_links('Vezi https://example.com/a$ending'), [
        ('https://example.com/a', 'https://example.com/a'),
      ], reason: ending);
    }
  });

  test('a closing bracket belongs to the link only if the link opened it', () {
    expect(_links('(vezi https://en.wikipedia.org/wiki/Mars_(planet))'), [
      (
        'https://en.wikipedia.org/wiki/Mars_(planet)',
        'https://en.wikipedia.org/wiki/Mars_(planet)',
      ),
    ]);
    expect(_links('[https://example.com]'), [
      ('https://example.com', 'https://example.com'),
    ]);
  });

  test('an email address starts an email', () {
    expect(_links('Scrie-mi la ana.pop@example.ro.'), [
      ('ana.pop@example.ro', 'mailto:ana.pop@example.ro'),
    ]);
  });

  test('several links in one message are each a link', () {
    expect(
      _links('https://a.example.com, www.b.example.com și c@example.com'),
      hasLength(3),
    );
  });

  test('only web pages and email can be opened', () {
    for (final text in [
      'javascript:alert(1)',
      'intent://scan/#Intent;scheme=zxing;end',
      'file:///sdcard/photo.jpg',
      'ftp://example.com/file',
      'tel:+40700000000',
      'data:text/html,<b>hi</b>',
    ]) {
      expect(_links(text), isEmpty, reason: text);
    }
  });

  test('an address with no real host is not a link', () {
    for (final text in ['http://', 'https://.', 'www.', 'https://localhost']) {
      expect(_links(text), isEmpty, reason: text);
    }
  });

  test('a bare name like example.com is not taken for a link', () {
    expect(_links('am salvat raport.txt, e.g. pe example.com'), isEmpty);
  });

  test('www. in the middle of a word is not a link', () {
    expect(_links('abcwww.example.com'), isEmpty);
  });

  test('putting the parts back together gives the message', () {
    for (final text in [
      'Uite (https://example.com/a_(b)). Și www.x.ro!',
      'ana@example.ro, https://example.com?q="x"',
      '👋 https://example.ro/ăîșț 👍🏽',
    ]) {
      expect(splitLinks(text).map((part) => part.text).join(), text);
    }
  });
}
