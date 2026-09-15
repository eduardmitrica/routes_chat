import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/presence/presence_reporter.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/presence_fakes.dart';

void main() {
  late FakePresence presence;
  late FakePrivacy privacy;

  setUp(() {
    presence = FakePresence();
    privacy = FakePrivacy();
    addTearDown(presence.close);
    addTearDown(privacy.close);
  });

  test('turning read receipts off deletes how far the user read', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    PresenceReporter(presence, privacy, session);

    privacy.change(const PrivacySettings(shareReadReceipts: false));
    await pumpEventQueue();

    expect(presence.calls, contains('cleared reads'));
  });

  test('other changes while they are off delete nothing again', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    privacy = FakePrivacy(const PrivacySettings(shareReadReceipts: false));
    PresenceReporter(presence, privacy, session);

    privacy.change(
      const PrivacySettings(shareReadReceipts: false, shareTyping: false),
    );
    privacy.change(const PrivacySettings(shareReadReceipts: true));
    await pumpEventQueue();

    expect(presence.calls, isNot(contains('cleared reads')));
  });
}
