// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'received_friend_requests_watcher_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReceivedFriendRequestsWatcherEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() watchAllStarted,
    required TResult Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)
        friendRequestsReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? watchAllStarted,
    TResult? Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)?
        friendRequestsReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? watchAllStarted,
    TResult Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)?
        friendRequestsReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_WatchStarted value) watchAllStarted,
    required TResult Function(_FriendRequestsReceived value)
        friendRequestsReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchAllStarted,
    TResult? Function(_FriendRequestsReceived value)? friendRequestsReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchAllStarted,
    TResult Function(_FriendRequestsReceived value)? friendRequestsReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceivedFriendRequestsWatcherEventCopyWith<$Res> {
  factory $ReceivedFriendRequestsWatcherEventCopyWith(
          ReceivedFriendRequestsWatcherEvent value,
          $Res Function(ReceivedFriendRequestsWatcherEvent) then) =
      _$ReceivedFriendRequestsWatcherEventCopyWithImpl<$Res,
          ReceivedFriendRequestsWatcherEvent>;
}

/// @nodoc
class _$ReceivedFriendRequestsWatcherEventCopyWithImpl<$Res,
        $Val extends ReceivedFriendRequestsWatcherEvent>
    implements $ReceivedFriendRequestsWatcherEventCopyWith<$Res> {
  _$ReceivedFriendRequestsWatcherEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$WatchStartedImplCopyWith<$Res> {
  factory _$$WatchStartedImplCopyWith(
          _$WatchStartedImpl value, $Res Function(_$WatchStartedImpl) then) =
      __$$WatchStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WatchStartedImplCopyWithImpl<$Res>
    extends _$ReceivedFriendRequestsWatcherEventCopyWithImpl<$Res,
        _$WatchStartedImpl> implements _$$WatchStartedImplCopyWith<$Res> {
  __$$WatchStartedImplCopyWithImpl(
      _$WatchStartedImpl _value, $Res Function(_$WatchStartedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$WatchStartedImpl implements _WatchStarted {
  const _$WatchStartedImpl();

  @override
  String toString() {
    return 'ReceivedFriendRequestsWatcherEvent.watchAllStarted()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WatchStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() watchAllStarted,
    required TResult Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)
        friendRequestsReceived,
  }) {
    return watchAllStarted();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? watchAllStarted,
    TResult? Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)?
        friendRequestsReceived,
  }) {
    return watchAllStarted?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? watchAllStarted,
    TResult Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)?
        friendRequestsReceived,
    required TResult orElse(),
  }) {
    if (watchAllStarted != null) {
      return watchAllStarted();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_WatchStarted value) watchAllStarted,
    required TResult Function(_FriendRequestsReceived value)
        friendRequestsReceived,
  }) {
    return watchAllStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchAllStarted,
    TResult? Function(_FriendRequestsReceived value)? friendRequestsReceived,
  }) {
    return watchAllStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchAllStarted,
    TResult Function(_FriendRequestsReceived value)? friendRequestsReceived,
    required TResult orElse(),
  }) {
    if (watchAllStarted != null) {
      return watchAllStarted(this);
    }
    return orElse();
  }
}

abstract class _WatchStarted implements ReceivedFriendRequestsWatcherEvent {
  const factory _WatchStarted() = _$WatchStartedImpl;
}

/// @nodoc
abstract class _$$FriendRequestsReceivedImplCopyWith<$Res> {
  factory _$$FriendRequestsReceivedImplCopyWith(
          _$FriendRequestsReceivedImpl value,
          $Res Function(_$FriendRequestsReceivedImpl) then) =
      __$$FriendRequestsReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {Either<FriendRequestFailure, KtList<FriendRequest>>
          failureOrFriendRequests});
}

/// @nodoc
class __$$FriendRequestsReceivedImplCopyWithImpl<$Res>
    extends _$ReceivedFriendRequestsWatcherEventCopyWithImpl<$Res,
        _$FriendRequestsReceivedImpl>
    implements _$$FriendRequestsReceivedImplCopyWith<$Res> {
  __$$FriendRequestsReceivedImplCopyWithImpl(
      _$FriendRequestsReceivedImpl _value,
      $Res Function(_$FriendRequestsReceivedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failureOrFriendRequests = null,
  }) {
    return _then(_$FriendRequestsReceivedImpl(
      null == failureOrFriendRequests
          ? _value.failureOrFriendRequests
          : failureOrFriendRequests // ignore: cast_nullable_to_non_nullable
              as Either<FriendRequestFailure, KtList<FriendRequest>>,
    ));
  }
}

/// @nodoc

class _$FriendRequestsReceivedImpl implements _FriendRequestsReceived {
  const _$FriendRequestsReceivedImpl(this.failureOrFriendRequests);

  @override
  final Either<FriendRequestFailure, KtList<FriendRequest>>
      failureOrFriendRequests;

  @override
  String toString() {
    return 'ReceivedFriendRequestsWatcherEvent.friendRequestsReceived(failureOrFriendRequests: $failureOrFriendRequests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestsReceivedImpl &&
            (identical(
                    other.failureOrFriendRequests, failureOrFriendRequests) ||
                other.failureOrFriendRequests == failureOrFriendRequests));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failureOrFriendRequests);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestsReceivedImplCopyWith<_$FriendRequestsReceivedImpl>
      get copyWith => __$$FriendRequestsReceivedImplCopyWithImpl<
          _$FriendRequestsReceivedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() watchAllStarted,
    required TResult Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)
        friendRequestsReceived,
  }) {
    return friendRequestsReceived(failureOrFriendRequests);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? watchAllStarted,
    TResult? Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)?
        friendRequestsReceived,
  }) {
    return friendRequestsReceived?.call(failureOrFriendRequests);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? watchAllStarted,
    TResult Function(
            Either<FriendRequestFailure, KtList<FriendRequest>>
                failureOrFriendRequests)?
        friendRequestsReceived,
    required TResult orElse(),
  }) {
    if (friendRequestsReceived != null) {
      return friendRequestsReceived(failureOrFriendRequests);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_WatchStarted value) watchAllStarted,
    required TResult Function(_FriendRequestsReceived value)
        friendRequestsReceived,
  }) {
    return friendRequestsReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchAllStarted,
    TResult? Function(_FriendRequestsReceived value)? friendRequestsReceived,
  }) {
    return friendRequestsReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchAllStarted,
    TResult Function(_FriendRequestsReceived value)? friendRequestsReceived,
    required TResult orElse(),
  }) {
    if (friendRequestsReceived != null) {
      return friendRequestsReceived(this);
    }
    return orElse();
  }
}

abstract class _FriendRequestsReceived
    implements ReceivedFriendRequestsWatcherEvent {
  const factory _FriendRequestsReceived(
      final Either<FriendRequestFailure, KtList<FriendRequest>>
          failureOrFriendRequests) = _$FriendRequestsReceivedImpl;

  Either<FriendRequestFailure, KtList<FriendRequest>>
      get failureOrFriendRequests;
  @JsonKey(ignore: true)
  _$$FriendRequestsReceivedImplCopyWith<_$FriendRequestsReceivedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReceivedFriendRequestsWatcherState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loadInProgress,
    required TResult Function(KtList<FriendRequest> friendRequests) loadSuccess,
    required TResult Function(FriendRequestFailure failure) loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult? Function(FriendRequestFailure failure)? loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult Function(FriendRequestFailure failure)? loadFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_LoadInProgress value) loadInProgress,
    required TResult Function(_LoadSuccess value) loadSuccess,
    required TResult Function(_LoadFailure value) loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_LoadInProgress value)? loadInProgress,
    TResult? Function(_LoadSuccess value)? loadSuccess,
    TResult? Function(_LoadFailure value)? loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_LoadInProgress value)? loadInProgress,
    TResult Function(_LoadSuccess value)? loadSuccess,
    TResult Function(_LoadFailure value)? loadFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceivedFriendRequestsWatcherStateCopyWith<$Res> {
  factory $ReceivedFriendRequestsWatcherStateCopyWith(
          ReceivedFriendRequestsWatcherState value,
          $Res Function(ReceivedFriendRequestsWatcherState) then) =
      _$ReceivedFriendRequestsWatcherStateCopyWithImpl<$Res,
          ReceivedFriendRequestsWatcherState>;
}

/// @nodoc
class _$ReceivedFriendRequestsWatcherStateCopyWithImpl<$Res,
        $Val extends ReceivedFriendRequestsWatcherState>
    implements $ReceivedFriendRequestsWatcherStateCopyWith<$Res> {
  _$ReceivedFriendRequestsWatcherStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ReceivedFriendRequestsWatcherStateCopyWithImpl<$Res,
        _$InitialImpl> implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ReceivedFriendRequestsWatcherState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loadInProgress,
    required TResult Function(KtList<FriendRequest> friendRequests) loadSuccess,
    required TResult Function(FriendRequestFailure failure) loadFailure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult? Function(FriendRequestFailure failure)? loadFailure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult Function(FriendRequestFailure failure)? loadFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_LoadInProgress value) loadInProgress,
    required TResult Function(_LoadSuccess value) loadSuccess,
    required TResult Function(_LoadFailure value) loadFailure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_LoadInProgress value)? loadInProgress,
    TResult? Function(_LoadSuccess value)? loadSuccess,
    TResult? Function(_LoadFailure value)? loadFailure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_LoadInProgress value)? loadInProgress,
    TResult Function(_LoadSuccess value)? loadSuccess,
    TResult Function(_LoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ReceivedFriendRequestsWatcherState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadInProgressImplCopyWith<$Res> {
  factory _$$LoadInProgressImplCopyWith(_$LoadInProgressImpl value,
          $Res Function(_$LoadInProgressImpl) then) =
      __$$LoadInProgressImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadInProgressImplCopyWithImpl<$Res>
    extends _$ReceivedFriendRequestsWatcherStateCopyWithImpl<$Res,
        _$LoadInProgressImpl> implements _$$LoadInProgressImplCopyWith<$Res> {
  __$$LoadInProgressImplCopyWithImpl(
      _$LoadInProgressImpl _value, $Res Function(_$LoadInProgressImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadInProgressImpl implements _LoadInProgress {
  const _$LoadInProgressImpl();

  @override
  String toString() {
    return 'ReceivedFriendRequestsWatcherState.loadInProgress()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadInProgressImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loadInProgress,
    required TResult Function(KtList<FriendRequest> friendRequests) loadSuccess,
    required TResult Function(FriendRequestFailure failure) loadFailure,
  }) {
    return loadInProgress();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult? Function(FriendRequestFailure failure)? loadFailure,
  }) {
    return loadInProgress?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult Function(FriendRequestFailure failure)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadInProgress != null) {
      return loadInProgress();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_LoadInProgress value) loadInProgress,
    required TResult Function(_LoadSuccess value) loadSuccess,
    required TResult Function(_LoadFailure value) loadFailure,
  }) {
    return loadInProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_LoadInProgress value)? loadInProgress,
    TResult? Function(_LoadSuccess value)? loadSuccess,
    TResult? Function(_LoadFailure value)? loadFailure,
  }) {
    return loadInProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_LoadInProgress value)? loadInProgress,
    TResult Function(_LoadSuccess value)? loadSuccess,
    TResult Function(_LoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadInProgress != null) {
      return loadInProgress(this);
    }
    return orElse();
  }
}

abstract class _LoadInProgress implements ReceivedFriendRequestsWatcherState {
  const factory _LoadInProgress() = _$LoadInProgressImpl;
}

/// @nodoc
abstract class _$$LoadSuccessImplCopyWith<$Res> {
  factory _$$LoadSuccessImplCopyWith(
          _$LoadSuccessImpl value, $Res Function(_$LoadSuccessImpl) then) =
      __$$LoadSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({KtList<FriendRequest> friendRequests});
}

/// @nodoc
class __$$LoadSuccessImplCopyWithImpl<$Res>
    extends _$ReceivedFriendRequestsWatcherStateCopyWithImpl<$Res,
        _$LoadSuccessImpl> implements _$$LoadSuccessImplCopyWith<$Res> {
  __$$LoadSuccessImplCopyWithImpl(
      _$LoadSuccessImpl _value, $Res Function(_$LoadSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friendRequests = null,
  }) {
    return _then(_$LoadSuccessImpl(
      null == friendRequests
          ? _value.friendRequests
          : friendRequests // ignore: cast_nullable_to_non_nullable
              as KtList<FriendRequest>,
    ));
  }
}

/// @nodoc

class _$LoadSuccessImpl implements _LoadSuccess {
  const _$LoadSuccessImpl(this.friendRequests);

  @override
  final KtList<FriendRequest> friendRequests;

  @override
  String toString() {
    return 'ReceivedFriendRequestsWatcherState.loadSuccess(friendRequests: $friendRequests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadSuccessImpl &&
            (identical(other.friendRequests, friendRequests) ||
                other.friendRequests == friendRequests));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendRequests);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadSuccessImplCopyWith<_$LoadSuccessImpl> get copyWith =>
      __$$LoadSuccessImplCopyWithImpl<_$LoadSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loadInProgress,
    required TResult Function(KtList<FriendRequest> friendRequests) loadSuccess,
    required TResult Function(FriendRequestFailure failure) loadFailure,
  }) {
    return loadSuccess(friendRequests);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult? Function(FriendRequestFailure failure)? loadFailure,
  }) {
    return loadSuccess?.call(friendRequests);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult Function(FriendRequestFailure failure)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadSuccess != null) {
      return loadSuccess(friendRequests);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_LoadInProgress value) loadInProgress,
    required TResult Function(_LoadSuccess value) loadSuccess,
    required TResult Function(_LoadFailure value) loadFailure,
  }) {
    return loadSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_LoadInProgress value)? loadInProgress,
    TResult? Function(_LoadSuccess value)? loadSuccess,
    TResult? Function(_LoadFailure value)? loadFailure,
  }) {
    return loadSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_LoadInProgress value)? loadInProgress,
    TResult Function(_LoadSuccess value)? loadSuccess,
    TResult Function(_LoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadSuccess != null) {
      return loadSuccess(this);
    }
    return orElse();
  }
}

abstract class _LoadSuccess implements ReceivedFriendRequestsWatcherState {
  const factory _LoadSuccess(final KtList<FriendRequest> friendRequests) =
      _$LoadSuccessImpl;

  KtList<FriendRequest> get friendRequests;
  @JsonKey(ignore: true)
  _$$LoadSuccessImplCopyWith<_$LoadSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadFailureImplCopyWith<$Res> {
  factory _$$LoadFailureImplCopyWith(
          _$LoadFailureImpl value, $Res Function(_$LoadFailureImpl) then) =
      __$$LoadFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FriendRequestFailure failure});
}

/// @nodoc
class __$$LoadFailureImplCopyWithImpl<$Res>
    extends _$ReceivedFriendRequestsWatcherStateCopyWithImpl<$Res,
        _$LoadFailureImpl> implements _$$LoadFailureImplCopyWith<$Res> {
  __$$LoadFailureImplCopyWithImpl(
      _$LoadFailureImpl _value, $Res Function(_$LoadFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$LoadFailureImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as FriendRequestFailure,
    ));
  }
}

/// @nodoc

class _$LoadFailureImpl implements _LoadFailure {
  const _$LoadFailureImpl(this.failure);

  @override
  final FriendRequestFailure failure;

  @override
  String toString() {
    return 'ReceivedFriendRequestsWatcherState.loadFailure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadFailureImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadFailureImplCopyWith<_$LoadFailureImpl> get copyWith =>
      __$$LoadFailureImplCopyWithImpl<_$LoadFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loadInProgress,
    required TResult Function(KtList<FriendRequest> friendRequests) loadSuccess,
    required TResult Function(FriendRequestFailure failure) loadFailure,
  }) {
    return loadFailure(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult? Function(FriendRequestFailure failure)? loadFailure,
  }) {
    return loadFailure?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<FriendRequest> friendRequests)? loadSuccess,
    TResult Function(FriendRequestFailure failure)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadFailure != null) {
      return loadFailure(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_LoadInProgress value) loadInProgress,
    required TResult Function(_LoadSuccess value) loadSuccess,
    required TResult Function(_LoadFailure value) loadFailure,
  }) {
    return loadFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_LoadInProgress value)? loadInProgress,
    TResult? Function(_LoadSuccess value)? loadSuccess,
    TResult? Function(_LoadFailure value)? loadFailure,
  }) {
    return loadFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_LoadInProgress value)? loadInProgress,
    TResult Function(_LoadSuccess value)? loadSuccess,
    TResult Function(_LoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadFailure != null) {
      return loadFailure(this);
    }
    return orElse();
  }
}

abstract class _LoadFailure implements ReceivedFriendRequestsWatcherState {
  const factory _LoadFailure(final FriendRequestFailure failure) =
      _$LoadFailureImpl;

  FriendRequestFailure get failure;
  @JsonKey(ignore: true)
  _$$LoadFailureImplCopyWith<_$LoadFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
