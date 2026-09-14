import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'appearance_event.dart';

/// Whether the app follows the phone's light or dark setting, or keeps one
/// of its own.
enum Appearance { system, light, dark }

/// The appearance the user chose. It is kept on this device between launches,
/// not with the account.
class AppearanceBloc extends HydratedBloc<AppearanceEvent, Appearance> {
  AppearanceBloc() : super(Appearance.system) {
    on<AppearanceEvent>((event, emit) {
      switch (event) {
        case AppearanceChanged(:final appearance):
          emit(appearance);
      }
    });
  }

  /// Null, so the phone's setting is followed, for anything not saved by
  /// [toJson].
  @override
  Appearance? fromJson(Map<String, dynamic> json) =>
      Appearance.values.asNameMap()[json['appearance']];

  @override
  Map<String, dynamic>? toJson(Appearance state) => {'appearance': state.name};
}
