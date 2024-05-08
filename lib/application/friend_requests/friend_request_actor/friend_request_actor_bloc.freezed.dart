// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_request_actor_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FriendRequestActorEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() usernameChanged,
    required TResult Function(String usernameInput) sent,
    required TResult Function(FriendRequest friendRequest) accepted,
    required TResult Function(FriendRequest friendRequest) declined,
    required TResult Function() rolledBackChanges,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? usernameChanged,
    TResult? Function(String usernameInput)? sent,
    TResult? Function(FriendRequest friendRequest)? accepted,
    TResult? Function(FriendRequest friendRequest)? declined,
    TResult? Function()? rolledBackChanges,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? usernameChanged,
    TResult Function(String usernameInput)? sent,
    TResult Function(FriendRequest friendRequest)? accepted,
    TResult Function(FriendRequest friendRequest)? declined,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_Sent value) sent,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Declined value) declined,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_Sent value)? sent,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Declined value)? declined,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_Sent value)? sent,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Declined value)? declined,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendRequestActorEventCopyWith<$Res> {
  factory $FriendRequestActorEventCopyWith(FriendRequestActorEvent value,
          $Res Function(FriendRequestActorEvent) then) =
      _$FriendRequestActorEventCopyWithImpl<$Res, FriendRequestActorEvent>;
}

/// @nodoc
class _$FriendRequestActorEventCopyWithImpl<$Res,
        $Val extends FriendRequestActorEvent>
    implements $FriendRequestActorEventCopyWith<$Res> {
  _$FriendRequestActorEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$UsernameChangedImplCopyWith<$Res> {
  factory _$$UsernameChangedImplCopyWith(_$UsernameChangedImpl value,
          $Res Function(_$UsernameChangedImpl) then) =
      __$$UsernameChangedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UsernameChangedImplCopyWithImpl<$Res>
    extends _$FriendRequestActorEventCopyWithImpl<$Res, _$UsernameChangedImpl>
    implements _$$UsernameChangedImplCopyWith<$Res> {
  __$$UsernameChangedImplCopyWithImpl(
      _$UsernameChangedImpl _value, $Res Function(_$UsernameChangedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UsernameChangedImpl implements _UsernameChanged {
  const _$UsernameChangedImpl();

  @override
  String toString() {
    return 'FriendRequestActorEvent.usernameChanged()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UsernameChangedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() usernameChanged,
    required TResult Function(String usernameInput) sent,
    required TResult Function(FriendRequest friendRequest) accepted,
    required TResult Function(FriendRequest friendRequest) declined,
    required TResult Function() rolledBackChanges,
  }) {
    return usernameChanged();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? usernameChanged,
    TResult? Function(String usernameInput)? sent,
    TResult? Function(FriendRequest friendRequest)? accepted,
    TResult? Function(FriendRequest friendRequest)? declined,
    TResult? Function()? rolledBackChanges,
  }) {
    return usernameChanged?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? usernameChanged,
    TResult Function(String usernameInput)? sent,
    TResult Function(FriendRequest friendRequest)? accepted,
    TResult Function(FriendRequest friendRequest)? declined,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (usernameChanged != null) {
      return usernameChanged();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_Sent value) sent,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Declined value) declined,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return usernameChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_Sent value)? sent,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Declined value)? declined,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return usernameChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_Sent value)? sent,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Declined value)? declined,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (usernameChanged != null) {
      return usernameChanged(this);
    }
    return orElse();
  }
}

abstract class _UsernameChanged implements FriendRequestActorEvent {
  const factory _UsernameChanged() = _$UsernameChangedImpl;
}

/// @nodoc
abstract class _$$SentImplCopyWith<$Res> {
  factory _$$SentImplCopyWith(
          _$SentImpl value, $Res Function(_$SentImpl) then) =
      __$$SentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String usernameInput});
}

/// @nodoc
class __$$SentImplCopyWithImpl<$Res>
    extends _$FriendRequestActorEventCopyWithImpl<$Res, _$SentImpl>
    implements _$$SentImplCopyWith<$Res> {
  __$$SentImplCopyWithImpl(_$SentImpl _value, $Res Function(_$SentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usernameInput = null,
  }) {
    return _then(_$SentImpl(
      null == usernameInput
          ? _value.usernameInput
          : usernameInput // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SentImpl implements _Sent {
  const _$SentImpl(this.usernameInput);

  @override
  final String usernameInput;

  @override
  String toString() {
    return 'FriendRequestActorEvent.sent(usernameInput: $usernameInput)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SentImpl &&
            (identical(other.usernameInput, usernameInput) ||
                other.usernameInput == usernameInput));
  }

  @override
  int get hashCode => Object.hash(runtimeType, usernameInput);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SentImplCopyWith<_$SentImpl> get copyWith =>
      __$$SentImplCopyWithImpl<_$SentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() usernameChanged,
    required TResult Function(String usernameInput) sent,
    required TResult Function(FriendRequest friendRequest) accepted,
    required TResult Function(FriendRequest friendRequest) declined,
    required TResult Function() rolledBackChanges,
  }) {
    return sent(usernameInput);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? usernameChanged,
    TResult? Function(String usernameInput)? sent,
    TResult? Function(FriendRequest friendRequest)? accepted,
    TResult? Function(FriendRequest friendRequest)? declined,
    TResult? Function()? rolledBackChanges,
  }) {
    return sent?.call(usernameInput);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? usernameChanged,
    TResult Function(String usernameInput)? sent,
    TResult Function(FriendRequest friendRequest)? accepted,
    TResult Function(FriendRequest friendRequest)? declined,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (sent != null) {
      return sent(usernameInput);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_Sent value) sent,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Declined value) declined,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return sent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_Sent value)? sent,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Declined value)? declined,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return sent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_Sent value)? sent,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Declined value)? declined,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (sent != null) {
      return sent(this);
    }
    return orElse();
  }
}

abstract class _Sent implements FriendRequestActorEvent {
  const factory _Sent(final String usernameInput) = _$SentImpl;

  String get usernameInput;
  @JsonKey(ignore: true)
  _$$SentImplCopyWith<_$SentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AcceptedImplCopyWith<$Res> {
  factory _$$AcceptedImplCopyWith(
          _$AcceptedImpl value, $Res Function(_$AcceptedImpl) then) =
      __$$AcceptedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FriendRequest friendRequest});

  $FriendRequestCopyWith<$Res> get friendRequest;
}

/// @nodoc
class __$$AcceptedImplCopyWithImpl<$Res>
    extends _$FriendRequestActorEventCopyWithImpl<$Res, _$AcceptedImpl>
    implements _$$AcceptedImplCopyWith<$Res> {
  __$$AcceptedImplCopyWithImpl(
      _$AcceptedImpl _value, $Res Function(_$AcceptedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friendRequest = null,
  }) {
    return _then(_$AcceptedImpl(
      null == friendRequest
          ? _value.friendRequest
          : friendRequest // ignore: cast_nullable_to_non_nullable
              as FriendRequest,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $FriendRequestCopyWith<$Res> get friendRequest {
    return $FriendRequestCopyWith<$Res>(_value.friendRequest, (value) {
      return _then(_value.copyWith(friendRequest: value));
    });
  }
}

/// @nodoc

class _$AcceptedImpl implements _Accepted {
  const _$AcceptedImpl(this.friendRequest);

  @override
  final FriendRequest friendRequest;

  @override
  String toString() {
    return 'FriendRequestActorEvent.accepted(friendRequest: $friendRequest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcceptedImpl &&
            (identical(other.friendRequest, friendRequest) ||
                other.friendRequest == friendRequest));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendRequest);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AcceptedImplCopyWith<_$AcceptedImpl> get copyWith =>
      __$$AcceptedImplCopyWithImpl<_$AcceptedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() usernameChanged,
    required TResult Function(String usernameInput) sent,
    required TResult Function(FriendRequest friendRequest) accepted,
    required TResult Function(FriendRequest friendRequest) declined,
    required TResult Function() rolledBackChanges,
  }) {
    return accepted(friendRequest);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? usernameChanged,
    TResult? Function(String usernameInput)? sent,
    TResult? Function(FriendRequest friendRequest)? accepted,
    TResult? Function(FriendRequest friendRequest)? declined,
    TResult? Function()? rolledBackChanges,
  }) {
    return accepted?.call(friendRequest);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? usernameChanged,
    TResult Function(String usernameInput)? sent,
    TResult Function(FriendRequest friendRequest)? accepted,
    TResult Function(FriendRequest friendRequest)? declined,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (accepted != null) {
      return accepted(friendRequest);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_Sent value) sent,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Declined value) declined,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return accepted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_Sent value)? sent,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Declined value)? declined,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return accepted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_Sent value)? sent,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Declined value)? declined,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (accepted != null) {
      return accepted(this);
    }
    return orElse();
  }
}

abstract class _Accepted implements FriendRequestActorEvent {
  const factory _Accepted(final FriendRequest friendRequest) = _$AcceptedImpl;

  FriendRequest get friendRequest;
  @JsonKey(ignore: true)
  _$$AcceptedImplCopyWith<_$AcceptedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeclinedImplCopyWith<$Res> {
  factory _$$DeclinedImplCopyWith(
          _$DeclinedImpl value, $Res Function(_$DeclinedImpl) then) =
      __$$DeclinedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FriendRequest friendRequest});

  $FriendRequestCopyWith<$Res> get friendRequest;
}

/// @nodoc
class __$$DeclinedImplCopyWithImpl<$Res>
    extends _$FriendRequestActorEventCopyWithImpl<$Res, _$DeclinedImpl>
    implements _$$DeclinedImplCopyWith<$Res> {
  __$$DeclinedImplCopyWithImpl(
      _$DeclinedImpl _value, $Res Function(_$DeclinedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friendRequest = null,
  }) {
    return _then(_$DeclinedImpl(
      null == friendRequest
          ? _value.friendRequest
          : friendRequest // ignore: cast_nullable_to_non_nullable
              as FriendRequest,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $FriendRequestCopyWith<$Res> get friendRequest {
    return $FriendRequestCopyWith<$Res>(_value.friendRequest, (value) {
      return _then(_value.copyWith(friendRequest: value));
    });
  }
}

/// @nodoc

class _$DeclinedImpl implements _Declined {
  const _$DeclinedImpl(this.friendRequest);

  @override
  final FriendRequest friendRequest;

  @override
  String toString() {
    return 'FriendRequestActorEvent.declined(friendRequest: $friendRequest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeclinedImpl &&
            (identical(other.friendRequest, friendRequest) ||
                other.friendRequest == friendRequest));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendRequest);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeclinedImplCopyWith<_$DeclinedImpl> get copyWith =>
      __$$DeclinedImplCopyWithImpl<_$DeclinedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() usernameChanged,
    required TResult Function(String usernameInput) sent,
    required TResult Function(FriendRequest friendRequest) accepted,
    required TResult Function(FriendRequest friendRequest) declined,
    required TResult Function() rolledBackChanges,
  }) {
    return declined(friendRequest);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? usernameChanged,
    TResult? Function(String usernameInput)? sent,
    TResult? Function(FriendRequest friendRequest)? accepted,
    TResult? Function(FriendRequest friendRequest)? declined,
    TResult? Function()? rolledBackChanges,
  }) {
    return declined?.call(friendRequest);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? usernameChanged,
    TResult Function(String usernameInput)? sent,
    TResult Function(FriendRequest friendRequest)? accepted,
    TResult Function(FriendRequest friendRequest)? declined,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (declined != null) {
      return declined(friendRequest);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_Sent value) sent,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Declined value) declined,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return declined(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_Sent value)? sent,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Declined value)? declined,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return declined?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_Sent value)? sent,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Declined value)? declined,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (declined != null) {
      return declined(this);
    }
    return orElse();
  }
}

abstract class _Declined implements FriendRequestActorEvent {
  const factory _Declined(final FriendRequest friendRequest) = _$DeclinedImpl;

  FriendRequest get friendRequest;
  @JsonKey(ignore: true)
  _$$DeclinedImplCopyWith<_$DeclinedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RolledBackChangesImplCopyWith<$Res> {
  factory _$$RolledBackChangesImplCopyWith(_$RolledBackChangesImpl value,
          $Res Function(_$RolledBackChangesImpl) then) =
      __$$RolledBackChangesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RolledBackChangesImplCopyWithImpl<$Res>
    extends _$FriendRequestActorEventCopyWithImpl<$Res, _$RolledBackChangesImpl>
    implements _$$RolledBackChangesImplCopyWith<$Res> {
  __$$RolledBackChangesImplCopyWithImpl(_$RolledBackChangesImpl _value,
      $Res Function(_$RolledBackChangesImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RolledBackChangesImpl implements _RolledBackChanges {
  const _$RolledBackChangesImpl();

  @override
  String toString() {
    return 'FriendRequestActorEvent.rolledBackChanges()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RolledBackChangesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() usernameChanged,
    required TResult Function(String usernameInput) sent,
    required TResult Function(FriendRequest friendRequest) accepted,
    required TResult Function(FriendRequest friendRequest) declined,
    required TResult Function() rolledBackChanges,
  }) {
    return rolledBackChanges();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? usernameChanged,
    TResult? Function(String usernameInput)? sent,
    TResult? Function(FriendRequest friendRequest)? accepted,
    TResult? Function(FriendRequest friendRequest)? declined,
    TResult? Function()? rolledBackChanges,
  }) {
    return rolledBackChanges?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? usernameChanged,
    TResult Function(String usernameInput)? sent,
    TResult Function(FriendRequest friendRequest)? accepted,
    TResult Function(FriendRequest friendRequest)? declined,
    TResult Function()? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (rolledBackChanges != null) {
      return rolledBackChanges();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UsernameChanged value) usernameChanged,
    required TResult Function(_Sent value) sent,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Declined value) declined,
    required TResult Function(_RolledBackChanges value) rolledBackChanges,
  }) {
    return rolledBackChanges(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UsernameChanged value)? usernameChanged,
    TResult? Function(_Sent value)? sent,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Declined value)? declined,
    TResult? Function(_RolledBackChanges value)? rolledBackChanges,
  }) {
    return rolledBackChanges?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UsernameChanged value)? usernameChanged,
    TResult Function(_Sent value)? sent,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Declined value)? declined,
    TResult Function(_RolledBackChanges value)? rolledBackChanges,
    required TResult orElse(),
  }) {
    if (rolledBackChanges != null) {
      return rolledBackChanges(this);
    }
    return orElse();
  }
}

abstract class _RolledBackChanges implements FriendRequestActorEvent {
  const factory _RolledBackChanges() = _$RolledBackChangesImpl;
}

/// @nodoc
mixin _$FriendRequestActorState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendRequestActorStateCopyWith<$Res> {
  factory $FriendRequestActorStateCopyWith(FriendRequestActorState value,
          $Res Function(FriendRequestActorState) then) =
      _$FriendRequestActorStateCopyWithImpl<$Res, FriendRequestActorState>;
}

/// @nodoc
class _$FriendRequestActorStateCopyWithImpl<$Res,
        $Val extends FriendRequestActorState>
    implements $FriendRequestActorStateCopyWith<$Res> {
  _$FriendRequestActorStateCopyWithImpl(this._value, this._then);

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
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$InitialImpl>
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
    return 'FriendRequestActorState.initial()';
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
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
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
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements FriendRequestActorState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$ActionInProgressImplCopyWith<$Res> {
  factory _$$ActionInProgressImplCopyWith(_$ActionInProgressImpl value,
          $Res Function(_$ActionInProgressImpl) then) =
      __$$ActionInProgressImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ActionInProgressImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$ActionInProgressImpl>
    implements _$$ActionInProgressImplCopyWith<$Res> {
  __$$ActionInProgressImplCopyWithImpl(_$ActionInProgressImpl _value,
      $Res Function(_$ActionInProgressImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ActionInProgressImpl implements _ActionInProgress {
  const _$ActionInProgressImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.actionInProgress()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ActionInProgressImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return actionInProgress();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return actionInProgress?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (actionInProgress != null) {
      return actionInProgress();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return actionInProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return actionInProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (actionInProgress != null) {
      return actionInProgress(this);
    }
    return orElse();
  }
}

abstract class _ActionInProgress implements FriendRequestActorState {
  const factory _ActionInProgress() = _$ActionInProgressImpl;
}

/// @nodoc
abstract class _$$SendingFailureImplCopyWith<$Res> {
  factory _$$SendingFailureImplCopyWith(_$SendingFailureImpl value,
          $Res Function(_$SendingFailureImpl) then) =
      __$$SendingFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SendingFailureImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$SendingFailureImpl>
    implements _$$SendingFailureImplCopyWith<$Res> {
  __$$SendingFailureImplCopyWithImpl(
      _$SendingFailureImpl _value, $Res Function(_$SendingFailureImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SendingFailureImpl implements _SendingFailure {
  const _$SendingFailureImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.sendingFailure()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SendingFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return sendingFailure();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return sendingFailure?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (sendingFailure != null) {
      return sendingFailure();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return sendingFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return sendingFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (sendingFailure != null) {
      return sendingFailure(this);
    }
    return orElse();
  }
}

abstract class _SendingFailure implements FriendRequestActorState {
  const factory _SendingFailure() = _$SendingFailureImpl;
}

/// @nodoc
abstract class _$$SendingSuccessImplCopyWith<$Res> {
  factory _$$SendingSuccessImplCopyWith(_$SendingSuccessImpl value,
          $Res Function(_$SendingSuccessImpl) then) =
      __$$SendingSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SendingSuccessImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$SendingSuccessImpl>
    implements _$$SendingSuccessImplCopyWith<$Res> {
  __$$SendingSuccessImplCopyWithImpl(
      _$SendingSuccessImpl _value, $Res Function(_$SendingSuccessImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SendingSuccessImpl implements _SendingSuccess {
  const _$SendingSuccessImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.sendingSuccess()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SendingSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return sendingSuccess();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return sendingSuccess?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (sendingSuccess != null) {
      return sendingSuccess();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return sendingSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return sendingSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (sendingSuccess != null) {
      return sendingSuccess(this);
    }
    return orElse();
  }
}

abstract class _SendingSuccess implements FriendRequestActorState {
  const factory _SendingSuccess() = _$SendingSuccessImpl;
}

/// @nodoc
abstract class _$$AcceptingSuccessImplCopyWith<$Res> {
  factory _$$AcceptingSuccessImplCopyWith(_$AcceptingSuccessImpl value,
          $Res Function(_$AcceptingSuccessImpl) then) =
      __$$AcceptingSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AcceptingSuccessImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$AcceptingSuccessImpl>
    implements _$$AcceptingSuccessImplCopyWith<$Res> {
  __$$AcceptingSuccessImplCopyWithImpl(_$AcceptingSuccessImpl _value,
      $Res Function(_$AcceptingSuccessImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AcceptingSuccessImpl implements _AcceptingSuccess {
  const _$AcceptingSuccessImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.acceptingSuccess()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AcceptingSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return acceptingSuccess();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return acceptingSuccess?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (acceptingSuccess != null) {
      return acceptingSuccess();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return acceptingSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return acceptingSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (acceptingSuccess != null) {
      return acceptingSuccess(this);
    }
    return orElse();
  }
}

abstract class _AcceptingSuccess implements FriendRequestActorState {
  const factory _AcceptingSuccess() = _$AcceptingSuccessImpl;
}

/// @nodoc
abstract class _$$AcceptingFailureImplCopyWith<$Res> {
  factory _$$AcceptingFailureImplCopyWith(_$AcceptingFailureImpl value,
          $Res Function(_$AcceptingFailureImpl) then) =
      __$$AcceptingFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AcceptingFailureImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$AcceptingFailureImpl>
    implements _$$AcceptingFailureImplCopyWith<$Res> {
  __$$AcceptingFailureImplCopyWithImpl(_$AcceptingFailureImpl _value,
      $Res Function(_$AcceptingFailureImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AcceptingFailureImpl implements _AcceptingFailure {
  const _$AcceptingFailureImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.acceptingFailure()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AcceptingFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return acceptingFailure();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return acceptingFailure?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (acceptingFailure != null) {
      return acceptingFailure();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return acceptingFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return acceptingFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (acceptingFailure != null) {
      return acceptingFailure(this);
    }
    return orElse();
  }
}

abstract class _AcceptingFailure implements FriendRequestActorState {
  const factory _AcceptingFailure() = _$AcceptingFailureImpl;
}

/// @nodoc
abstract class _$$DecliningSuccessImplCopyWith<$Res> {
  factory _$$DecliningSuccessImplCopyWith(_$DecliningSuccessImpl value,
          $Res Function(_$DecliningSuccessImpl) then) =
      __$$DecliningSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DecliningSuccessImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$DecliningSuccessImpl>
    implements _$$DecliningSuccessImplCopyWith<$Res> {
  __$$DecliningSuccessImplCopyWithImpl(_$DecliningSuccessImpl _value,
      $Res Function(_$DecliningSuccessImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DecliningSuccessImpl implements _DecliningSuccess {
  const _$DecliningSuccessImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.decliningSuccess()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DecliningSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return decliningSuccess();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return decliningSuccess?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (decliningSuccess != null) {
      return decliningSuccess();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return decliningSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return decliningSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (decliningSuccess != null) {
      return decliningSuccess(this);
    }
    return orElse();
  }
}

abstract class _DecliningSuccess implements FriendRequestActorState {
  const factory _DecliningSuccess() = _$DecliningSuccessImpl;
}

/// @nodoc
abstract class _$$DecliningFailureImplCopyWith<$Res> {
  factory _$$DecliningFailureImplCopyWith(_$DecliningFailureImpl value,
          $Res Function(_$DecliningFailureImpl) then) =
      __$$DecliningFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DecliningFailureImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$DecliningFailureImpl>
    implements _$$DecliningFailureImplCopyWith<$Res> {
  __$$DecliningFailureImplCopyWithImpl(_$DecliningFailureImpl _value,
      $Res Function(_$DecliningFailureImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DecliningFailureImpl implements _DecliningFailure {
  const _$DecliningFailureImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.decliningFailure()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DecliningFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return decliningFailure();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return decliningFailure?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (decliningFailure != null) {
      return decliningFailure();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return decliningFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return decliningFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (decliningFailure != null) {
      return decliningFailure(this);
    }
    return orElse();
  }
}

abstract class _DecliningFailure implements FriendRequestActorState {
  const factory _DecliningFailure() = _$DecliningFailureImpl;
}

/// @nodoc
abstract class _$$RequestAlreadySentImplCopyWith<$Res> {
  factory _$$RequestAlreadySentImplCopyWith(_$RequestAlreadySentImpl value,
          $Res Function(_$RequestAlreadySentImpl) then) =
      __$$RequestAlreadySentImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RequestAlreadySentImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res,
        _$RequestAlreadySentImpl>
    implements _$$RequestAlreadySentImplCopyWith<$Res> {
  __$$RequestAlreadySentImplCopyWithImpl(_$RequestAlreadySentImpl _value,
      $Res Function(_$RequestAlreadySentImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RequestAlreadySentImpl implements _RequestAlreadySent {
  const _$RequestAlreadySentImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.requestAlreadySent()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RequestAlreadySentImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return requestAlreadySent();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return requestAlreadySent?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (requestAlreadySent != null) {
      return requestAlreadySent();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return requestAlreadySent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return requestAlreadySent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (requestAlreadySent != null) {
      return requestAlreadySent(this);
    }
    return orElse();
  }
}

abstract class _RequestAlreadySent implements FriendRequestActorState {
  const factory _RequestAlreadySent() = _$RequestAlreadySentImpl;
}

/// @nodoc
abstract class _$$AlreadyFriendsImplCopyWith<$Res> {
  factory _$$AlreadyFriendsImplCopyWith(_$AlreadyFriendsImpl value,
          $Res Function(_$AlreadyFriendsImpl) then) =
      __$$AlreadyFriendsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AlreadyFriendsImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$AlreadyFriendsImpl>
    implements _$$AlreadyFriendsImplCopyWith<$Res> {
  __$$AlreadyFriendsImplCopyWithImpl(
      _$AlreadyFriendsImpl _value, $Res Function(_$AlreadyFriendsImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AlreadyFriendsImpl implements _AlreadyFriends {
  const _$AlreadyFriendsImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.alreadyFriends()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AlreadyFriendsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return alreadyFriends();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return alreadyFriends?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (alreadyFriends != null) {
      return alreadyFriends();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return alreadyFriends(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return alreadyFriends?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (alreadyFriends != null) {
      return alreadyFriends(this);
    }
    return orElse();
  }
}

abstract class _AlreadyFriends implements FriendRequestActorState {
  const factory _AlreadyFriends() = _$AlreadyFriendsImpl;
}

/// @nodoc
abstract class _$$FriendRequestAlreadySentFromReceiverImplCopyWith<$Res> {
  factory _$$FriendRequestAlreadySentFromReceiverImplCopyWith(
          _$FriendRequestAlreadySentFromReceiverImpl value,
          $Res Function(_$FriendRequestAlreadySentFromReceiverImpl) then) =
      __$$FriendRequestAlreadySentFromReceiverImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FriendRequestAlreadySentFromReceiverImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res,
        _$FriendRequestAlreadySentFromReceiverImpl>
    implements _$$FriendRequestAlreadySentFromReceiverImplCopyWith<$Res> {
  __$$FriendRequestAlreadySentFromReceiverImplCopyWithImpl(
      _$FriendRequestAlreadySentFromReceiverImpl _value,
      $Res Function(_$FriendRequestAlreadySentFromReceiverImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$FriendRequestAlreadySentFromReceiverImpl
    implements _FriendRequestAlreadySentFromReceiver {
  const _$FriendRequestAlreadySentFromReceiverImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.friendRequestAlreadySentFromReceiver()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestAlreadySentFromReceiverImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return friendRequestAlreadySentFromReceiver();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return friendRequestAlreadySentFromReceiver?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (friendRequestAlreadySentFromReceiver != null) {
      return friendRequestAlreadySentFromReceiver();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return friendRequestAlreadySentFromReceiver(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return friendRequestAlreadySentFromReceiver?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (friendRequestAlreadySentFromReceiver != null) {
      return friendRequestAlreadySentFromReceiver(this);
    }
    return orElse();
  }
}

abstract class _FriendRequestAlreadySentFromReceiver
    implements FriendRequestActorState {
  const factory _FriendRequestAlreadySentFromReceiver() =
      _$FriendRequestAlreadySentFromReceiverImpl;
}

/// @nodoc
abstract class _$$ResetToInitialImplCopyWith<$Res> {
  factory _$$ResetToInitialImplCopyWith(_$ResetToInitialImpl value,
          $Res Function(_$ResetToInitialImpl) then) =
      __$$ResetToInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ResetToInitialImplCopyWithImpl<$Res>
    extends _$FriendRequestActorStateCopyWithImpl<$Res, _$ResetToInitialImpl>
    implements _$$ResetToInitialImplCopyWith<$Res> {
  __$$ResetToInitialImplCopyWithImpl(
      _$ResetToInitialImpl _value, $Res Function(_$ResetToInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ResetToInitialImpl implements _ResetToInitial {
  const _$ResetToInitialImpl();

  @override
  String toString() {
    return 'FriendRequestActorState.resetToInitial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ResetToInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function() sendingFailure,
    required TResult Function() sendingSuccess,
    required TResult Function() acceptingSuccess,
    required TResult Function() acceptingFailure,
    required TResult Function() decliningSuccess,
    required TResult Function() decliningFailure,
    required TResult Function() requestAlreadySent,
    required TResult Function() alreadyFriends,
    required TResult Function() friendRequestAlreadySentFromReceiver,
    required TResult Function() resetToInitial,
  }) {
    return resetToInitial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function()? sendingFailure,
    TResult? Function()? sendingSuccess,
    TResult? Function()? acceptingSuccess,
    TResult? Function()? acceptingFailure,
    TResult? Function()? decliningSuccess,
    TResult? Function()? decliningFailure,
    TResult? Function()? requestAlreadySent,
    TResult? Function()? alreadyFriends,
    TResult? Function()? friendRequestAlreadySentFromReceiver,
    TResult? Function()? resetToInitial,
  }) {
    return resetToInitial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function()? sendingFailure,
    TResult Function()? sendingSuccess,
    TResult Function()? acceptingSuccess,
    TResult Function()? acceptingFailure,
    TResult Function()? decliningSuccess,
    TResult Function()? decliningFailure,
    TResult Function()? requestAlreadySent,
    TResult Function()? alreadyFriends,
    TResult Function()? friendRequestAlreadySentFromReceiver,
    TResult Function()? resetToInitial,
    required TResult orElse(),
  }) {
    if (resetToInitial != null) {
      return resetToInitial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_SendingFailure value) sendingFailure,
    required TResult Function(_SendingSuccess value) sendingSuccess,
    required TResult Function(_AcceptingSuccess value) acceptingSuccess,
    required TResult Function(_AcceptingFailure value) acceptingFailure,
    required TResult Function(_DecliningSuccess value) decliningSuccess,
    required TResult Function(_DecliningFailure value) decliningFailure,
    required TResult Function(_RequestAlreadySent value) requestAlreadySent,
    required TResult Function(_AlreadyFriends value) alreadyFriends,
    required TResult Function(_FriendRequestAlreadySentFromReceiver value)
        friendRequestAlreadySentFromReceiver,
    required TResult Function(_ResetToInitial value) resetToInitial,
  }) {
    return resetToInitial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_SendingFailure value)? sendingFailure,
    TResult? Function(_SendingSuccess value)? sendingSuccess,
    TResult? Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult? Function(_AcceptingFailure value)? acceptingFailure,
    TResult? Function(_DecliningSuccess value)? decliningSuccess,
    TResult? Function(_DecliningFailure value)? decliningFailure,
    TResult? Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult? Function(_AlreadyFriends value)? alreadyFriends,
    TResult? Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult? Function(_ResetToInitial value)? resetToInitial,
  }) {
    return resetToInitial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_SendingFailure value)? sendingFailure,
    TResult Function(_SendingSuccess value)? sendingSuccess,
    TResult Function(_AcceptingSuccess value)? acceptingSuccess,
    TResult Function(_AcceptingFailure value)? acceptingFailure,
    TResult Function(_DecliningSuccess value)? decliningSuccess,
    TResult Function(_DecliningFailure value)? decliningFailure,
    TResult Function(_RequestAlreadySent value)? requestAlreadySent,
    TResult Function(_AlreadyFriends value)? alreadyFriends,
    TResult Function(_FriendRequestAlreadySentFromReceiver value)?
        friendRequestAlreadySentFromReceiver,
    TResult Function(_ResetToInitial value)? resetToInitial,
    required TResult orElse(),
  }) {
    if (resetToInitial != null) {
      return resetToInitial(this);
    }
    return orElse();
  }
}

abstract class _ResetToInitial implements FriendRequestActorState {
  const factory _ResetToInitial() = _$ResetToInitialImpl;
}
