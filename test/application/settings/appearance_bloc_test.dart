import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:routes_chat/application/settings/appearance/appearance_bloc.dart';

import '../../helpers/memory_storage.dart';

void main() {
  late MemoryStorage storage;

  setUp(() {
    storage = MemoryStorage();
    HydratedBloc.storage = storage;
  });

  test('follows the phone until the user chooses', () {
    final bloc = AppearanceBloc();
    addTearDown(bloc.close);

    expect(bloc.state, Appearance.system);
  });

  test('a choice is kept for the next launch', () async {
    final bloc = AppearanceBloc();
    bloc.add(const AppearanceEvent.changed(Appearance.dark));
    await pumpEventQueue();
    await bloc.close();

    final relaunched = AppearanceBloc();
    addTearDown(relaunched.close);

    expect(relaunched.state, Appearance.dark);
  });

  test('something unrecognised on disk falls back to the phone', () {
    storage.values['AppearanceBloc'] = {'appearance': 'sepia'};

    final bloc = AppearanceBloc();
    addTearDown(bloc.close);

    expect(bloc.state, Appearance.system);
  });
}
