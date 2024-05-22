// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_actor_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatActorEvent {
  KtList<UniqueId> get otherThanCurrentParticipantIds =>
      throw _privateConstructorUsedError;
  Message get firstMessage => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds,
            Message firstMessage)
        created,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(KtList<UniqueId> otherThanCurrentParticipantIds,
            Message firstMessage)?
        created,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds,
            Message firstMessage)?
        created,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Created value) created,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Created value)? created,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Created value)? created,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChatActorEventCopyWith<ChatActorEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatActorEventCopyWith<$Res> {
  factory $ChatActorEventCopyWith(
          ChatActorEvent value, $Res Function(ChatActorEvent) then) =
      _$ChatActorEventCopyWithImpl<$Res, ChatActorEvent>;
  @useResult
  $Res call(
      {KtList<UniqueId> otherThanCurrentParticipantIds, Message firstMessage});

  $MessageCopyWith<$Res> get firstMessage;
}

/// @nodoc
class _$ChatActorEventCopyWithImpl<$Res, $Val extends ChatActorEvent>
    implements $ChatActorEventCopyWith<$Res> {
  _$ChatActorEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otherThanCurrentParticipantIds = null,
    Object? firstMessage = null,
  }) {
    return _then(_value.copyWith(
      otherThanCurrentParticipantIds: null == otherThanCurrentParticipantIds
          ? _value.otherThanCurrentParticipantIds
          : otherThanCurrentParticipantIds // ignore: cast_nullable_to_non_nullable
              as KtList<UniqueId>,
      firstMessage: null == firstMessage
          ? _value.firstMessage
          : firstMessage // ignore: cast_nullable_to_non_nullable
              as Message,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res> get firstMessage {
    return $MessageCopyWith<$Res>(_value.firstMessage, (value) {
      return _then(_value.copyWith(firstMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreatedImplCopyWith<$Res>
    implements $ChatActorEventCopyWith<$Res> {
  factory _$$CreatedImplCopyWith(
          _$CreatedImpl value, $Res Function(_$CreatedImpl) then) =
      __$$CreatedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {KtList<UniqueId> otherThanCurrentParticipantIds, Message firstMessage});

  @override
  $MessageCopyWith<$Res> get firstMessage;
}

/// @nodoc
class __$$CreatedImplCopyWithImpl<$Res>
    extends _$ChatActorEventCopyWithImpl<$Res, _$CreatedImpl>
    implements _$$CreatedImplCopyWith<$Res> {
  __$$CreatedImplCopyWithImpl(
      _$CreatedImpl _value, $Res Function(_$CreatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otherThanCurrentParticipantIds = null,
    Object? firstMessage = null,
  }) {
    return _then(_$CreatedImpl(
      null == otherThanCurrentParticipantIds
          ? _value.otherThanCurrentParticipantIds
          : otherThanCurrentParticipantIds // ignore: cast_nullable_to_non_nullable
              as KtList<UniqueId>,
      null == firstMessage
          ? _value.firstMessage
          : firstMessage // ignore: cast_nullable_to_non_nullable
              as Message,
    ));
  }
}

/// @nodoc

class _$CreatedImpl implements _Created {
  const _$CreatedImpl(this.otherThanCurrentParticipantIds, this.firstMessage);

  @override
  final KtList<UniqueId> otherThanCurrentParticipantIds;
  @override
  final Message firstMessage;

  @override
  String toString() {
    return 'ChatActorEvent.created(otherThanCurrentParticipantIds: $otherThanCurrentParticipantIds, firstMessage: $firstMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatedImpl &&
            (identical(other.otherThanCurrentParticipantIds,
                    otherThanCurrentParticipantIds) ||
                other.otherThanCurrentParticipantIds ==
                    otherThanCurrentParticipantIds) &&
            (identical(other.firstMessage, firstMessage) ||
                other.firstMessage == firstMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, otherThanCurrentParticipantIds, firstMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatedImplCopyWith<_$CreatedImpl> get copyWith =>
      __$$CreatedImplCopyWithImpl<_$CreatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds,
            Message firstMessage)
        created,
  }) {
    return created(otherThanCurrentParticipantIds, firstMessage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(KtList<UniqueId> otherThanCurrentParticipantIds,
            Message firstMessage)?
        created,
  }) {
    return created?.call(otherThanCurrentParticipantIds, firstMessage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds,
            Message firstMessage)?
        created,
    required TResult orElse(),
  }) {
    if (created != null) {
      return created(otherThanCurrentParticipantIds, firstMessage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Created value) created,
  }) {
    return created(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Created value)? created,
  }) {
    return created?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Created value)? created,
    required TResult orElse(),
  }) {
    if (created != null) {
      return created(this);
    }
    return orElse();
  }
}

abstract class _Created implements ChatActorEvent {
  const factory _Created(final KtList<UniqueId> otherThanCurrentParticipantIds,
      final Message firstMessage) = _$CreatedImpl;

  @override
  KtList<UniqueId> get otherThanCurrentParticipantIds;
  @override
  Message get firstMessage;
  @override
  @JsonKey(ignore: true)
  _$$CreatedImplCopyWith<_$CreatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatActorState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function(ChatFailure noteFailure) creationFailure,
    required TResult Function() creationSuccess,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function(ChatFailure noteFailure)? creationFailure,
    TResult? Function()? creationSuccess,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function(ChatFailure noteFailure)? creationFailure,
    TResult Function()? creationSuccess,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_CreationFailure value) creationFailure,
    required TResult Function(_CreationSuccess value) creationSuccess,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_CreationFailure value)? creationFailure,
    TResult? Function(_CreationSuccess value)? creationSuccess,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_CreationFailure value)? creationFailure,
    TResult Function(_CreationSuccess value)? creationSuccess,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatActorStateCopyWith<$Res> {
  factory $ChatActorStateCopyWith(
          ChatActorState value, $Res Function(ChatActorState) then) =
      _$ChatActorStateCopyWithImpl<$Res, ChatActorState>;
}

/// @nodoc
class _$ChatActorStateCopyWithImpl<$Res, $Val extends ChatActorState>
    implements $ChatActorStateCopyWith<$Res> {
  _$ChatActorStateCopyWithImpl(this._value, this._then);

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
    extends _$ChatActorStateCopyWithImpl<$Res, _$InitialImpl>
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
    return 'ChatActorState.initial()';
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
    required TResult Function(ChatFailure noteFailure) creationFailure,
    required TResult Function() creationSuccess,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function(ChatFailure noteFailure)? creationFailure,
    TResult? Function()? creationSuccess,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function(ChatFailure noteFailure)? creationFailure,
    TResult Function()? creationSuccess,
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
    required TResult Function(_CreationFailure value) creationFailure,
    required TResult Function(_CreationSuccess value) creationSuccess,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_CreationFailure value)? creationFailure,
    TResult? Function(_CreationSuccess value)? creationSuccess,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_CreationFailure value)? creationFailure,
    TResult Function(_CreationSuccess value)? creationSuccess,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ChatActorState {
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
    extends _$ChatActorStateCopyWithImpl<$Res, _$ActionInProgressImpl>
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
    return 'ChatActorState.actionInProgress()';
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
    required TResult Function(ChatFailure noteFailure) creationFailure,
    required TResult Function() creationSuccess,
  }) {
    return actionInProgress();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function(ChatFailure noteFailure)? creationFailure,
    TResult? Function()? creationSuccess,
  }) {
    return actionInProgress?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function(ChatFailure noteFailure)? creationFailure,
    TResult Function()? creationSuccess,
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
    required TResult Function(_CreationFailure value) creationFailure,
    required TResult Function(_CreationSuccess value) creationSuccess,
  }) {
    return actionInProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_CreationFailure value)? creationFailure,
    TResult? Function(_CreationSuccess value)? creationSuccess,
  }) {
    return actionInProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_CreationFailure value)? creationFailure,
    TResult Function(_CreationSuccess value)? creationSuccess,
    required TResult orElse(),
  }) {
    if (actionInProgress != null) {
      return actionInProgress(this);
    }
    return orElse();
  }
}

abstract class _ActionInProgress implements ChatActorState {
  const factory _ActionInProgress() = _$ActionInProgressImpl;
}

/// @nodoc
abstract class _$$CreationFailureImplCopyWith<$Res> {
  factory _$$CreationFailureImplCopyWith(_$CreationFailureImpl value,
          $Res Function(_$CreationFailureImpl) then) =
      __$$CreationFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ChatFailure noteFailure});
}

/// @nodoc
class __$$CreationFailureImplCopyWithImpl<$Res>
    extends _$ChatActorStateCopyWithImpl<$Res, _$CreationFailureImpl>
    implements _$$CreationFailureImplCopyWith<$Res> {
  __$$CreationFailureImplCopyWithImpl(
      _$CreationFailureImpl _value, $Res Function(_$CreationFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? noteFailure = null,
  }) {
    return _then(_$CreationFailureImpl(
      null == noteFailure
          ? _value.noteFailure
          : noteFailure // ignore: cast_nullable_to_non_nullable
              as ChatFailure,
    ));
  }
}

/// @nodoc

class _$CreationFailureImpl implements _CreationFailure {
  const _$CreationFailureImpl(this.noteFailure);

  @override
  final ChatFailure noteFailure;

  @override
  String toString() {
    return 'ChatActorState.creationFailure(noteFailure: $noteFailure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreationFailureImpl &&
            (identical(other.noteFailure, noteFailure) ||
                other.noteFailure == noteFailure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, noteFailure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreationFailureImplCopyWith<_$CreationFailureImpl> get copyWith =>
      __$$CreationFailureImplCopyWithImpl<_$CreationFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function(ChatFailure noteFailure) creationFailure,
    required TResult Function() creationSuccess,
  }) {
    return creationFailure(noteFailure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function(ChatFailure noteFailure)? creationFailure,
    TResult? Function()? creationSuccess,
  }) {
    return creationFailure?.call(noteFailure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function(ChatFailure noteFailure)? creationFailure,
    TResult Function()? creationSuccess,
    required TResult orElse(),
  }) {
    if (creationFailure != null) {
      return creationFailure(noteFailure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_CreationFailure value) creationFailure,
    required TResult Function(_CreationSuccess value) creationSuccess,
  }) {
    return creationFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_CreationFailure value)? creationFailure,
    TResult? Function(_CreationSuccess value)? creationSuccess,
  }) {
    return creationFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_CreationFailure value)? creationFailure,
    TResult Function(_CreationSuccess value)? creationSuccess,
    required TResult orElse(),
  }) {
    if (creationFailure != null) {
      return creationFailure(this);
    }
    return orElse();
  }
}

abstract class _CreationFailure implements ChatActorState {
  const factory _CreationFailure(final ChatFailure noteFailure) =
      _$CreationFailureImpl;

  ChatFailure get noteFailure;
  @JsonKey(ignore: true)
  _$$CreationFailureImplCopyWith<_$CreationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CreationSuccessImplCopyWith<$Res> {
  factory _$$CreationSuccessImplCopyWith(_$CreationSuccessImpl value,
          $Res Function(_$CreationSuccessImpl) then) =
      __$$CreationSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CreationSuccessImplCopyWithImpl<$Res>
    extends _$ChatActorStateCopyWithImpl<$Res, _$CreationSuccessImpl>
    implements _$$CreationSuccessImplCopyWith<$Res> {
  __$$CreationSuccessImplCopyWithImpl(
      _$CreationSuccessImpl _value, $Res Function(_$CreationSuccessImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$CreationSuccessImpl implements _CreationSuccess {
  const _$CreationSuccessImpl();

  @override
  String toString() {
    return 'ChatActorState.creationSuccess()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CreationSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() actionInProgress,
    required TResult Function(ChatFailure noteFailure) creationFailure,
    required TResult Function() creationSuccess,
  }) {
    return creationSuccess();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? actionInProgress,
    TResult? Function(ChatFailure noteFailure)? creationFailure,
    TResult? Function()? creationSuccess,
  }) {
    return creationSuccess?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? actionInProgress,
    TResult Function(ChatFailure noteFailure)? creationFailure,
    TResult Function()? creationSuccess,
    required TResult orElse(),
  }) {
    if (creationSuccess != null) {
      return creationSuccess();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_ActionInProgress value) actionInProgress,
    required TResult Function(_CreationFailure value) creationFailure,
    required TResult Function(_CreationSuccess value) creationSuccess,
  }) {
    return creationSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_ActionInProgress value)? actionInProgress,
    TResult? Function(_CreationFailure value)? creationFailure,
    TResult? Function(_CreationSuccess value)? creationSuccess,
  }) {
    return creationSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_ActionInProgress value)? actionInProgress,
    TResult Function(_CreationFailure value)? creationFailure,
    TResult Function(_CreationSuccess value)? creationSuccess,
    required TResult orElse(),
  }) {
    if (creationSuccess != null) {
      return creationSuccess(this);
    }
    return orElse();
  }
}

abstract class _CreationSuccess implements ChatActorState {
  const factory _CreationSuccess() = _$CreationSuccessImpl;
}
