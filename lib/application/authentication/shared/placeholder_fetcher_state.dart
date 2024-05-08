part of 'placeholder_fetcher_bloc.dart';

@freezed
class PlaceholderFetcherState with _$PlaceholderFetcherState {
  const factory PlaceholderFetcherState({
    required ImagePath imagePath,
  }) = _PlaceholderFetcherState;

  factory PlaceholderFetcherState.initial() => PlaceholderFetcherState(
    imagePath: ImagePath.fromUrl(''),
  );
}
