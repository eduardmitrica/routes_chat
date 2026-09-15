import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:routes_chat/application/settings/privacy/privacy_bloc.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

import '../../helpers/memory_storage.dart';

void main() {
  setUp(() => HydratedBloc.storage = MemoryStorage());

  test('read receipts are shared until the user says otherwise', () {
    final bloc = PrivacyBloc();
    addTearDown(bloc.close);

    expect(bloc.privacy.shareReadReceipts, isTrue);
  });

  test('settings saved before read receipts existed share them', () {
    final bloc = PrivacyBloc();
    addTearDown(bloc.close);

    expect(
      bloc.fromJson({'shareTyping': false, 'shareOnline': true}),
      const PrivacySettings(shareTyping: false),
    );
  });

  test('turning them off changes only them, and is kept', () async {
    final bloc = PrivacyBloc();
    addTearDown(bloc.close);

    bloc.add(const PrivacyEvent.readReceiptsSharingChanged(false));
    await pumpEventQueue();

    expect(bloc.privacy, const PrivacySettings(shareReadReceipts: false));
    expect(
      bloc.fromJson(bloc.toJson(bloc.privacy)),
      const PrivacySettings(shareReadReceipts: false),
    );
  });
}
