import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/settings/appearance/appearance_bloc.dart';

/// Chooses between following the phone's light or dark setting and keeping
/// the app always light or always dark.
class AppearancePicker extends StatelessWidget {
  const AppearancePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppearanceBloc, Appearance>(
      builder: (context, appearance) => SegmentedButton<Appearance>(
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: Appearance.system,
            icon: Icon(Icons.brightness_auto_outlined),
            label: Text('System'),
          ),
          ButtonSegment(
            value: Appearance.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Light'),
          ),
          ButtonSegment(
            value: Appearance.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Dark'),
          ),
        ],
        selected: {appearance},
        onSelectionChanged: (selection) => BlocProvider.of<AppearanceBloc>(
          context,
        ).add(AppearanceEvent.changed(selection.single)),
      ),
    );
  }
}
