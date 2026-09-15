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

  PresenceReporter reporterFor(dynamic session) => PresenceReporter(
    presence,
    privacy,
    session,
    heartbeat: const Duration(milliseconds: 20),
  );

  test('on screen, it says so, and keeps saying so', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    final reporter = reporterFor(session);

    reporter.appResumed();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    reporter.appPaused();

    expect(presence.calls.first, 'online');
    expect(
      presence.calls.where((call) => call == 'online').length,
      greaterThan(1),
    );
    expect(presence.calls.last, 'offline');
  });

  test('off screen, it says nothing more', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    final reporter = reporterFor(session)..appResumed();
    await pumpEventQueue();
    reporter.appPaused();
    final said = presence.calls.length;

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(presence.calls.length, said);
  });

  test('hiding it deletes what friends see, and stops saying it', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    final reporter = reporterFor(session)..appResumed();
    await pumpEventQueue();

    privacy.change(const PrivacySettings(shareOnline: false));
    await pumpEventQueue();
    final said = presence.calls.length;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    reporter.appPaused();

    expect(presence.calls.last, 'cleared uid-alice');
    expect(presence.calls.length, said);
  });

  test('showing it again while on screen says so at once', () async {
    privacy = FakePrivacy(const PrivacySettings(shareOnline: false));
    final session = signedInAlice();
    addTearDown(session.end);
    final reporter = reporterFor(session)..appResumed();
    await pumpEventQueue();
    expect(presence.calls, isEmpty);

    privacy.change(const PrivacySettings());
    await pumpEventQueue();
    reporter.appPaused();

    expect(presence.calls.first, 'online');
  });

  test('signed out, it says nothing', () async {
    final session = signedInAlice();
    final reporter = reporterFor(session)..appResumed();
    await pumpEventQueue();

    session.end();
    final said = presence.calls.length;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    reporter.appPaused();

    expect(presence.calls.length, said);
  });
}
