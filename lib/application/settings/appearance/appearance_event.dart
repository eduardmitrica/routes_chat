part of 'appearance_bloc.dart';

sealed class AppearanceEvent extends Equatable {
  const AppearanceEvent();

  const factory AppearanceEvent.changed(Appearance appearance) =
      AppearanceChanged;

  @override
  List<Object?> get props => const [];
}

final class AppearanceChanged extends AppearanceEvent {
  final Appearance appearance;

  const AppearanceChanged(this.appearance);

  @override
  List<Object?> get props => [appearance];
}
