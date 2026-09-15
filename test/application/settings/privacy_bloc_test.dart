import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:routes_chat/application/settings/privacy/privacy_bloc.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

/// Keeps hydrated state in memory.
class _MemoryStorage implements Storage {
  final values = <String, dynamic>{};

  @override
  dynamic read(String key) => values[key];

  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> close() async {}
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());

  test('both are shared until the user says otherwise', () {
    final bloc = PrivacyBloc();
    addTearDown(bloc.close);

    expect(bloc.privacy, const PrivacySettings());
    expect(bloc.privacy.shareTyping, isTrue);
    expect(bloc.privacy.shareOnline, isTrue);
  });

  test('each switch changes only itself, and is kept', () async {
    final bloc = PrivacyBloc();
    addTearDown(bloc.close);

    bloc.add(const PrivacyEvent.typingSharingChanged(false));
    await pumpEventQueue();
    expect(bloc.privacy, const PrivacySettings(shareTyping: false));

    final again = PrivacyBloc();
    addTearDown(again.close);
    expect(again.privacy, const PrivacySettings(shareTyping: false));
  });

  test('changes reach whoever listens', () async {
    final bloc = PrivacyBloc();
    addTearDown(bloc.close);

    final next = bloc.privacyChanges.first;
    bloc.add(const PrivacyEvent.onlineSharingChanged(false));

    expect(await next, const PrivacySettings(shareOnline: false));
  });
}
