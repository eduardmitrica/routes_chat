import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/shared/user/value_objects.dart';

part 'placeholder_fetcher_event.dart';

part 'placeholder_fetcher_state.dart';

part 'placeholder_fetcher_bloc.freezed.dart';

@injectable
class PlaceholderFetcherBloc
    extends HydratedBloc<PlaceholderFetcherEvent, PlaceholderFetcherState> {
  final IAuthFacade _authFacade;

  PlaceholderFetcherBloc(this._authFacade)
      : super(PlaceholderFetcherState.initial()) {
    on<PlaceholderFetcherEvent>((event, emit) async {
      await event.map(started: (_) async {
        await state.imagePath.value.fold((_) async {
          final userImagePlaceHolderString =
              await fetchPlaceholderImageString();
          emit(state.copyWith(
              imagePath: ImagePath.fromUrl(userImagePlaceHolderString)));
        }, (_) {});
      });
    });
  }

  @preResolve
  Future<String> fetchPlaceholderImageString() async {
    final userImagePlaceHolderString =
        await _authFacade.fetchUserImagePlaceHolder();
    return userImagePlaceHolderString;
  }

  @override
  PlaceholderFetcherState? fromJson(Map<String, dynamic> json) {
    if (json['imagePath'] != null) {
      return PlaceholderFetcherState(
        imagePath: ImagePath.fromJson(json),
      );
    } else {
      return PlaceholderFetcherState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(PlaceholderFetcherState state) {
    return state.imagePath.toJson();
  }
}
