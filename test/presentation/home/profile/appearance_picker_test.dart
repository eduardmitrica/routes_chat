import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:routes_chat/application/settings/appearance/appearance_bloc.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/profile/widgets/appearance_picker.dart';

import '../../../helpers/memory_storage.dart';

void main() {
  testWidgets('switches the whole app between device, light and dark', (
    tester,
  ) async {
    HydratedBloc.storage = MemoryStorage();
    final bloc = AppearanceBloc();
    addTearDown(bloc.close);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    // Wired the way AppWidget wires it.
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: BlocBuilder<AppearanceBloc, Appearance>(
          builder: (context, appearance) => MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: appearance.themeMode,
            home: const Scaffold(body: AppearancePicker()),
          ),
        ),
      ),
    );
    Brightness brightness() =>
        Theme.of(tester.element(find.byType(AppearancePicker))).brightness;

    expect(brightness(), Brightness.dark, reason: 'follows the dark phone');

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(bloc.state, Appearance.light);
    expect(brightness(), Brightness.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(bloc.state, Appearance.dark);
    expect(brightness(), Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.tap(find.text('Device'));
    await tester.pumpAndSettle();
    expect(bloc.state, Appearance.system);
    expect(brightness(), Brightness.light, reason: 'follows the light phone');
  });
}
