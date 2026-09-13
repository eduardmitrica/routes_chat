part of 'placeholder_fetcher_bloc.dart';

sealed class PlaceholderFetcherEvent extends Equatable {
  const PlaceholderFetcherEvent();

  const factory PlaceholderFetcherEvent.started() = PlaceholderFetcherStarted;

  @override
  List<Object?> get props => const [];
}

final class PlaceholderFetcherStarted extends PlaceholderFetcherEvent {
  const PlaceholderFetcherStarted();
}
