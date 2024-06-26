// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'users_watcher_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UsersWatcherEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(KtList<UniqueId> ids) watchStarted,
    required TResult Function(
            Either<UserFailure, KtList<User>> failureOrFriendRequests)
        friendRequestsReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(KtList<UniqueId> ids)? watchStarted,
    TResult? Function(
            Either<UserFailure, KtList<User>> failureOrFriendRequests)?
        friendRequestsReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(KtList<UniqueId> ids)? watchStarted,
    TResult Function(Either<UserFailure, KtList<User>> failureOrFriendRequests)?
        friendRequestsReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_WatchStarted value) watchStarted,
    required TResult Function(_FriendRequestsReceived value)
        friendRequestsReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchStarted,
    TResult? Function(_FriendRequestsReceived value)? friendRequestsReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchStarted,
    TResult Function(_FriendRequestsReceived value)? friendRequestsReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsersWatcherEventCopyWith<$Res> {
  factory $UsersWatcherEventCopyWith(
          UsersWatcherEvent value, $Res Function(UsersWatcherEvent) then) =
      _$UsersWatcherEventCopyWithImpl<$Res, UsersWatcherEvent>;
}

/// @nodoc
class _$UsersWatcherEventCopyWithImpl<$Res, $Val extends UsersWatcherEvent>
    implements $UsersWatcherEventCopyWith<$Res> {
  _$UsersWatcherEventCopyWithImpl(this._value, this._then);

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
  @useResult
  $Res call({KtList<UniqueId> ids});
}

/// @nodoc
class __$$WatchStartedImplCopyWithImpl<$Res>
    extends _$UsersWatcherEventCopyWithImpl<$Res, _$WatchStartedImpl>
    implements _$$WatchStartedImplCopyWith<$Res> {
  __$$WatchStartedImplCopyWithImpl(
      _$WatchStartedImpl _value, $Res Function(_$WatchStartedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ids = null,
  }) {
    return _then(_$WatchStartedImpl(
      null == ids
          ? _value.ids
          : ids // ignore: cast_nullable_to_non_nullable
              as KtList<UniqueId>,
    ));
  }
}

/// @nodoc

class _$WatchStartedImpl implements _WatchStarted {
  const _$WatchStartedImpl(this.ids);

  @override
  final KtList<UniqueId> ids;

  @override
  String toString() {
    return 'UsersWatcherEvent.watchStarted(ids: $ids)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchStartedImpl &&
            (identical(other.ids, ids) || other.ids == ids));
  }

  @override
  int get hashCode => Object.hash(runtimeType, ids);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchStartedImplCopyWith<_$WatchStartedImpl> get copyWith =>
      __$$WatchStartedImplCopyWithImpl<_$WatchStartedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(KtList<UniqueId> ids) watchStarted,
    required TResult Function(
            Either<UserFailure, KtList<User>> failureOrFriendRequests)
        friendRequestsReceived,
  }) {
    return watchStarted(ids);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(KtList<UniqueId> ids)? watchStarted,
    TResult? Function(
            Either<UserFailure, KtList<User>> failureOrFriendRequests)?
        friendRequestsReceived,
  }) {
    return watchStarted?.call(ids);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(KtList<UniqueId> ids)? watchStarted,
    TResult Function(Either<UserFailure, KtList<User>> failureOrFriendRequests)?
        friendRequestsReceived,
    required TResult orElse(),
  }) {
    if (watchStarted != null) {
      return watchStarted(ids);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_WatchStarted value) watchStarted,
    required TResult Function(_FriendRequestsReceived value)
        friendRequestsReceived,
  }) {
    return watchStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchStarted,
    TResult? Function(_FriendRequestsReceived value)? friendRequestsReceived,
  }) {
    return watchStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchStarted,
    TResult Function(_FriendRequestsReceived value)? friendRequestsReceived,
    required TResult orElse(),
  }) {
    if (watchStarted != null) {
      return watchStarted(this);
    }
    return orElse();
  }
}

abstract class _WatchStarted implements UsersWatcherEvent {
  const factory _WatchStarted(final KtList<UniqueId> ids) = _$WatchStartedImpl;

  KtList<UniqueId> get ids;
  @JsonKey(ignore: true)
  _$$WatchStartedImplCopyWith<_$WatchStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendRequestsReceivedImplCopyWith<$Res> {
  factory _$$FriendRequestsReceivedImplCopyWith(
          _$FriendRequestsReceivedImpl value,
          $Res Function(_$FriendRequestsReceivedImpl) then) =
      __$$FriendRequestsReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Either<UserFailure, KtList<User>> failureOrFriendRequests});
}

/// @nodoc
class __$$FriendRequestsReceivedImplCopyWithImpl<$Res>
    extends _$UsersWatcherEventCopyWithImpl<$Res, _$FriendRequestsReceivedImpl>
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
              as Either<UserFailure, KtList<User>>,
    ));
  }
}

/// @nodoc

class _$FriendRequestsReceivedImpl implements _FriendRequestsReceived {
  const _$FriendRequestsReceivedImpl(this.failureOrFriendRequests);

  @override
  final Either<UserFailure, KtList<User>> failureOrFriendRequests;

  @override
  String toString() {
    return 'UsersWatcherEvent.friendRequestsReceived(failureOrFriendRequests: $failureOrFriendRequests)';
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
    required TResult Function(KtList<UniqueId> ids) watchStarted,
    required TResult Function(
            Either<UserFailure, KtList<User>> failureOrFriendRequests)
        friendRequestsReceived,
  }) {
    return friendRequestsReceived(failureOrFriendRequests);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(KtList<UniqueId> ids)? watchStarted,
    TResult? Function(
            Either<UserFailure, KtList<User>> failureOrFriendRequests)?
        friendRequestsReceived,
  }) {
    return friendRequestsReceived?.call(failureOrFriendRequests);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(KtList<UniqueId> ids)? watchStarted,
    TResult Function(Either<UserFailure, KtList<User>> failureOrFriendRequests)?
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
    required TResult Function(_WatchStarted value) watchStarted,
    required TResult Function(_FriendRequestsReceived value)
        friendRequestsReceived,
  }) {
    return friendRequestsReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchStarted,
    TResult? Function(_FriendRequestsReceived value)? friendRequestsReceived,
  }) {
    return friendRequestsReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchStarted,
    TResult Function(_FriendRequestsReceived value)? friendRequestsReceived,
    required TResult orElse(),
  }) {
    if (friendRequestsReceived != null) {
      return friendRequestsReceived(this);
    }
    return orElse();
  }
}

abstract class _FriendRequestsReceived implements UsersWatcherEvent {
  const factory _FriendRequestsReceived(
          final Either<UserFailure, KtList<User>> failureOrFriendRequests) =
      _$FriendRequestsReceivedImpl;

  Either<UserFailure, KtList<User>> get failureOrFriendRequests;
  @JsonKey(ignore: true)
  _$$FriendRequestsReceivedImplCopyWith<_$FriendRequestsReceivedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UsersWatcherState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loadInProgress,
    required TResult Function(KtList<User> users) loadSuccess,
    required TResult Function(UserFailure failure) loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<User> users)? loadSuccess,
    TResult? Function(UserFailure failure)? loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<User> users)? loadSuccess,
    TResult Function(UserFailure failure)? loadFailure,
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
abstract class $UsersWatcherStateCopyWith<$Res> {
  factory $UsersWatcherStateCopyWith(
          UsersWatcherState value, $Res Function(UsersWatcherState) then) =
      _$UsersWatcherStateCopyWithImpl<$Res, UsersWatcherState>;
}

/// @nodoc
class _$UsersWatcherStateCopyWithImpl<$Res, $Val extends UsersWatcherState>
    implements $UsersWatcherStateCopyWith<$Res> {
  _$UsersWatcherStateCopyWithImpl(this._value, this._then);

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
    extends _$UsersWatcherStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'UsersWatcherState.initial()';
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
    required TResult Function(KtList<User> users) loadSuccess,
    required TResult Function(UserFailure failure) loadFailure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<User> users)? loadSuccess,
    TResult? Function(UserFailure failure)? loadFailure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<User> users)? loadSuccess,
    TResult Function(UserFailure failure)? loadFailure,
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

abstract class _Initial implements UsersWatcherState {
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
    extends _$UsersWatcherStateCopyWithImpl<$Res, _$LoadInProgressImpl>
    implements _$$LoadInProgressImplCopyWith<$Res> {
  __$$LoadInProgressImplCopyWithImpl(
      _$LoadInProgressImpl _value, $Res Function(_$LoadInProgressImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadInProgressImpl implements _LoadInProgress {
  const _$LoadInProgressImpl();

  @override
  String toString() {
    return 'UsersWatcherState.loadInProgress()';
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
    required TResult Function(KtList<User> users) loadSuccess,
    required TResult Function(UserFailure failure) loadFailure,
  }) {
    return loadInProgress();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<User> users)? loadSuccess,
    TResult? Function(UserFailure failure)? loadFailure,
  }) {
    return loadInProgress?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<User> users)? loadSuccess,
    TResult Function(UserFailure failure)? loadFailure,
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

abstract class _LoadInProgress implements UsersWatcherState {
  const factory _LoadInProgress() = _$LoadInProgressImpl;
}

/// @nodoc
abstract class _$$LoadSuccessImplCopyWith<$Res> {
  factory _$$LoadSuccessImplCopyWith(
          _$LoadSuccessImpl value, $Res Function(_$LoadSuccessImpl) then) =
      __$$LoadSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({KtList<User> users});
}

/// @nodoc
class __$$LoadSuccessImplCopyWithImpl<$Res>
    extends _$UsersWatcherStateCopyWithImpl<$Res, _$LoadSuccessImpl>
    implements _$$LoadSuccessImplCopyWith<$Res> {
  __$$LoadSuccessImplCopyWithImpl(
      _$LoadSuccessImpl _value, $Res Function(_$LoadSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
  }) {
    return _then(_$LoadSuccessImpl(
      null == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as KtList<User>,
    ));
  }
}

/// @nodoc

class _$LoadSuccessImpl implements _LoadSuccess {
  const _$LoadSuccessImpl(this.users);

  @override
  final KtList<User> users;

  @override
  String toString() {
    return 'UsersWatcherState.loadSuccess(users: $users)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadSuccessImpl &&
            (identical(other.users, users) || other.users == users));
  }

  @override
  int get hashCode => Object.hash(runtimeType, users);

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
    required TResult Function(KtList<User> users) loadSuccess,
    required TResult Function(UserFailure failure) loadFailure,
  }) {
    return loadSuccess(users);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<User> users)? loadSuccess,
    TResult? Function(UserFailure failure)? loadFailure,
  }) {
    return loadSuccess?.call(users);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<User> users)? loadSuccess,
    TResult Function(UserFailure failure)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadSuccess != null) {
      return loadSuccess(users);
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

abstract class _LoadSuccess implements UsersWatcherState {
  const factory _LoadSuccess(final KtList<User> users) = _$LoadSuccessImpl;

  KtList<User> get users;
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
  $Res call({UserFailure failure});
}

/// @nodoc
class __$$LoadFailureImplCopyWithImpl<$Res>
    extends _$UsersWatcherStateCopyWithImpl<$Res, _$LoadFailureImpl>
    implements _$$LoadFailureImplCopyWith<$Res> {
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
              as UserFailure,
    ));
  }
}

/// @nodoc

class _$LoadFailureImpl implements _LoadFailure {
  const _$LoadFailureImpl(this.failure);

  @override
  final UserFailure failure;

  @override
  String toString() {
    return 'UsersWatcherState.loadFailure(failure: $failure)';
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
    required TResult Function(KtList<User> users) loadSuccess,
    required TResult Function(UserFailure failure) loadFailure,
  }) {
    return loadFailure(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<User> users)? loadSuccess,
    TResult? Function(UserFailure failure)? loadFailure,
  }) {
    return loadFailure?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<User> users)? loadSuccess,
    TResult Function(UserFailure failure)? loadFailure,
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

abstract class _LoadFailure implements UsersWatcherState {
  const factory _LoadFailure(final UserFailure failure) = _$LoadFailureImpl;

  UserFailure get failure;
  @JsonKey(ignore: true)
  _$$LoadFailureImplCopyWith<_$LoadFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
