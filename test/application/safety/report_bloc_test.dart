import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/safety/report_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/safety/safety_repository_interface.dart';

import '../../helpers/safety_fakes.dart';

void main() {
  final bob = UniqueId.fromUniqueString('uid-bob');
  final chat = UniqueId.fromUniqueString('uid-alice_uid-bob');
  late FakeSafety safety;
  late ReportBloc bloc;

  setUp(() {
    safety = FakeSafety();
    bloc = ReportBloc(safety);
    addTearDown(bloc.close);
  });

  ReportedMessage message(int number) => ReportedMessage(
    messageId: UniqueId.fromUniqueString('message-$number'),
    senderId: bob,
    text: 'Mesaj $number',
    sentAt: DateTime.utc(2026, 9, 16, 12, number),
  );

  Future<void> report({bool alsoBlock = false, int messages = 0}) async {
    bloc.add(
      ReportEvent.submitted(
        reportedId: bob,
        chatId: chat,
        reason: ReportReason.harassment,
        messages: [
          for (var number = 0; number < messages; number++) message(number),
        ],
        alsoBlock: alsoBlock,
      ),
    );
    await pumpEventQueue();
  }

  test('sends the report with the messages the user chose to share', () async {
    await report(messages: 5);

    expect(safety.reports.single, (
      reportedId: 'uid-bob',
      chatId: 'uid-alice_uid-bob',
      reason: ReportReason.harassment,
      messages: 5,
    ));
    expect(safety.calls, ['report uid-bob']);
    expect(bloc.state.sent, 1);
    expect(bloc.state.lastAlsoBlocked, isFalse);
  });

  test('blocks them too when asked', () async {
    await report(alsoBlock: true);

    expect(safety.calls, ['report uid-bob', 'block uid-bob']);
    expect(bloc.state.lastAlsoBlocked, isTrue);
  });

  test('says each time it failed, and still blocks when asked', () async {
    safety.failure = SafetyUnexpected();

    await report(alsoBlock: true);
    await report();

    expect(bloc.state.failures, 2);
    expect(bloc.state.sent, 0);
    expect(safety.calls, ['report uid-bob', 'block uid-bob', 'report uid-bob']);
  });

  test('reasons are stored as the rules expect, literally', () {
    expect(
      [for (final reason in ReportReason.values) reason.storedName],
      ['spam', 'harassment', 'inappropriate', 'impersonation', 'other'],
    );
  });
}
