import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../domain/settings/privacy_settings.dart';

sealed class PrivacyEvent extends Equatable {
  const PrivacyEvent();

  const factory PrivacyEvent.typingSharingChanged(bool share) =
      TypingSharingChanged;
  const factory PrivacyEvent.onlineSharingChanged(bool share) =
      OnlineSharingChanged;
}

final class TypingSharingChanged extends PrivacyEvent {
  final bool share;
  const TypingSharingChanged(this.share);
  @override
  List<Object?> get props => [share];
}

final class OnlineSharingChanged extends PrivacyEvent {
  final bool share;
  const OnlineSharingChanged(this.share);
  @override
  List<Object?> get props => [share];
}

/// The privacy settings the user chose, kept on this device between launches.
class PrivacyBloc extends HydratedBloc<PrivacyEvent, PrivacySettings>
    implements IPrivacySettingsReader {
  PrivacyBloc() : super(const PrivacySettings()) {
    on<PrivacyEvent>((event, emit) {
      switch (event) {
        case TypingSharingChanged(:final share):
          emit(state.copyWith(shareTyping: share));
        case OnlineSharingChanged(:final share):
          emit(state.copyWith(shareOnline: share));
      }
    });
  }

  @override
  PrivacySettings get privacy => state;

  @override
  Stream<PrivacySettings> get privacyChanges => stream;

  /// Both on, the defaults, for anything not saved by [toJson].
  @override
  PrivacySettings fromJson(Map<String, dynamic> json) => PrivacySettings(
    shareTyping: json['shareTyping'] as bool? ?? true,
    shareOnline: json['shareOnline'] as bool? ?? true,
  );

  @override
  Map<String, dynamic> toJson(PrivacySettings state) => {
    'shareTyping': state.shareTyping,
    'shareOnline': state.shareOnline,
  };
}
