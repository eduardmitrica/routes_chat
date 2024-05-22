// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_watcher_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MessagesWatcherEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UniqueId chatId) watchAllStartedForChatWithId,
    required TResult Function(
            Either<MessageFailure, KtList<Message>> failureOrMessages)
        messagesReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UniqueId chatId)? watchAllStartedForChatWithId,
    TResult? Function(
            Either<MessageFailure, KtList<Message>> failureOrMessages)?
        messagesReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UniqueId chatId)? watchAllStartedForChatWithId,
    TResult Function(Either<MessageFailure, KtList<Message>> failureOrMessages)?
        messagesReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_WatchStarted value) watchAllStartedForChatWithId,
    required TResult Function(_MessagesReceived value) messagesReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchAllStartedForChatWithId,
    TResult? Function(_MessagesReceived value)? messagesReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchAllStartedForChatWithId,
    TResult Function(_MessagesReceived value)? messagesReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessagesWatcherEventCopyWith<$Res> {
  factory $MessagesWatcherEventCopyWith(MessagesWatcherEvent value,
          $Res Function(MessagesWatcherEvent) then) =
      _$MessagesWatcherEventCopyWithImpl<$Res, MessagesWatcherEvent>;
}

/// @nodoc
class _$MessagesWatcherEventCopyWithImpl<$Res,
        $Val extends MessagesWatcherEvent>
    implements $MessagesWatcherEventCopyWith<$Res> {
  _$MessagesWatcherEventCopyWithImpl(this._value, this._then);

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
  $Res call({UniqueId chatId});
}

/// @nodoc
class __$$WatchStartedImplCopyWithImpl<$Res>
    extends _$MessagesWatcherEventCopyWithImpl<$Res, _$WatchStartedImpl>
    implements _$$WatchStartedImplCopyWith<$Res> {
  __$$WatchStartedImplCopyWithImpl(
      _$WatchStartedImpl _value, $Res Function(_$WatchStartedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = null,
  }) {
    return _then(_$WatchStartedImpl(
      null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as UniqueId,
    ));
  }
}

/// @nodoc

class _$WatchStartedImpl implements _WatchStarted {
  const _$WatchStartedImpl(this.chatId);

  @override
  final UniqueId chatId;

  @override
  String toString() {
    return 'MessagesWatcherEvent.watchAllStartedForChatWithId(chatId: $chatId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchStartedImpl &&
            (identical(other.chatId, chatId) || other.chatId == chatId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, chatId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchStartedImplCopyWith<_$WatchStartedImpl> get copyWith =>
      __$$WatchStartedImplCopyWithImpl<_$WatchStartedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UniqueId chatId) watchAllStartedForChatWithId,
    required TResult Function(
            Either<MessageFailure, KtList<Message>> failureOrMessages)
        messagesReceived,
  }) {
    return watchAllStartedForChatWithId(chatId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UniqueId chatId)? watchAllStartedForChatWithId,
    TResult? Function(
            Either<MessageFailure, KtList<Message>> failureOrMessages)?
        messagesReceived,
  }) {
    return watchAllStartedForChatWithId?.call(chatId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UniqueId chatId)? watchAllStartedForChatWithId,
    TResult Function(Either<MessageFailure, KtList<Message>> failureOrMessages)?
        messagesReceived,
    required TResult orElse(),
  }) {
    if (watchAllStartedForChatWithId != null) {
      return watchAllStartedForChatWithId(chatId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_WatchStarted value) watchAllStartedForChatWithId,
    required TResult Function(_MessagesReceived value) messagesReceived,
  }) {
    return watchAllStartedForChatWithId(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchAllStartedForChatWithId,
    TResult? Function(_MessagesReceived value)? messagesReceived,
  }) {
    return watchAllStartedForChatWithId?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchAllStartedForChatWithId,
    TResult Function(_MessagesReceived value)? messagesReceived,
    required TResult orElse(),
  }) {
    if (watchAllStartedForChatWithId != null) {
      return watchAllStartedForChatWithId(this);
    }
    return orElse();
  }
}

abstract class _WatchStarted implements MessagesWatcherEvent {
  const factory _WatchStarted(final UniqueId chatId) = _$WatchStartedImpl;

  UniqueId get chatId;
  @JsonKey(ignore: true)
  _$$WatchStartedImplCopyWith<_$WatchStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessagesReceivedImplCopyWith<$Res> {
  factory _$$MessagesReceivedImplCopyWith(_$MessagesReceivedImpl value,
          $Res Function(_$MessagesReceivedImpl) then) =
      __$$MessagesReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Either<MessageFailure, KtList<Message>> failureOrMessages});
}

/// @nodoc
class __$$MessagesReceivedImplCopyWithImpl<$Res>
    extends _$MessagesWatcherEventCopyWithImpl<$Res, _$MessagesReceivedImpl>
    implements _$$MessagesReceivedImplCopyWith<$Res> {
  __$$MessagesReceivedImplCopyWithImpl(_$MessagesReceivedImpl _value,
      $Res Function(_$MessagesReceivedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failureOrMessages = null,
  }) {
    return _then(_$MessagesReceivedImpl(
      null == failureOrMessages
          ? _value.failureOrMessages
          : failureOrMessages // ignore: cast_nullable_to_non_nullable
              as Either<MessageFailure, KtList<Message>>,
    ));
  }
}

/// @nodoc

class _$MessagesReceivedImpl implements _MessagesReceived {
  const _$MessagesReceivedImpl(this.failureOrMessages);

  @override
  final Either<MessageFailure, KtList<Message>> failureOrMessages;

  @override
  String toString() {
    return 'MessagesWatcherEvent.messagesReceived(failureOrMessages: $failureOrMessages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagesReceivedImpl &&
            (identical(other.failureOrMessages, failureOrMessages) ||
                other.failureOrMessages == failureOrMessages));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failureOrMessages);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagesReceivedImplCopyWith<_$MessagesReceivedImpl> get copyWith =>
      __$$MessagesReceivedImplCopyWithImpl<_$MessagesReceivedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UniqueId chatId) watchAllStartedForChatWithId,
    required TResult Function(
            Either<MessageFailure, KtList<Message>> failureOrMessages)
        messagesReceived,
  }) {
    return messagesReceived(failureOrMessages);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UniqueId chatId)? watchAllStartedForChatWithId,
    TResult? Function(
            Either<MessageFailure, KtList<Message>> failureOrMessages)?
        messagesReceived,
  }) {
    return messagesReceived?.call(failureOrMessages);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UniqueId chatId)? watchAllStartedForChatWithId,
    TResult Function(Either<MessageFailure, KtList<Message>> failureOrMessages)?
        messagesReceived,
    required TResult orElse(),
  }) {
    if (messagesReceived != null) {
      return messagesReceived(failureOrMessages);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_WatchStarted value) watchAllStartedForChatWithId,
    required TResult Function(_MessagesReceived value) messagesReceived,
  }) {
    return messagesReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_WatchStarted value)? watchAllStartedForChatWithId,
    TResult? Function(_MessagesReceived value)? messagesReceived,
  }) {
    return messagesReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_WatchStarted value)? watchAllStartedForChatWithId,
    TResult Function(_MessagesReceived value)? messagesReceived,
    required TResult orElse(),
  }) {
    if (messagesReceived != null) {
      return messagesReceived(this);
    }
    return orElse();
  }
}

abstract class _MessagesReceived implements MessagesWatcherEvent {
  const factory _MessagesReceived(
          final Either<MessageFailure, KtList<Message>> failureOrMessages) =
      _$MessagesReceivedImpl;

  Either<MessageFailure, KtList<Message>> get failureOrMessages;
  @JsonKey(ignore: true)
  _$$MessagesReceivedImplCopyWith<_$MessagesReceivedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MessagesWatcherState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loadInProgress,
    required TResult Function(KtList<Message> messages) loadSuccess,
    required TResult Function(MessageFailure failure) loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<Message> messages)? loadSuccess,
    TResult? Function(MessageFailure failure)? loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<Message> messages)? loadSuccess,
    TResult Function(MessageFailure failure)? loadFailure,
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
abstract class $MessagesWatcherStateCopyWith<$Res> {
  factory $MessagesWatcherStateCopyWith(MessagesWatcherState value,
          $Res Function(MessagesWatcherState) then) =
      _$MessagesWatcherStateCopyWithImpl<$Res, MessagesWatcherState>;
}

/// @nodoc
class _$MessagesWatcherStateCopyWithImpl<$Res,
        $Val extends MessagesWatcherState>
    implements $MessagesWatcherStateCopyWith<$Res> {
  _$MessagesWatcherStateCopyWithImpl(this._value, this._then);

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
    extends _$MessagesWatcherStateCopyWithImpl<$Res, _$InitialImpl>
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
    return 'MessagesWatcherState.initial()';
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
    required TResult Function(KtList<Message> messages) loadSuccess,
    required TResult Function(MessageFailure failure) loadFailure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<Message> messages)? loadSuccess,
    TResult? Function(MessageFailure failure)? loadFailure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<Message> messages)? loadSuccess,
    TResult Function(MessageFailure failure)? loadFailure,
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

abstract class _Initial implements MessagesWatcherState {
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
    extends _$MessagesWatcherStateCopyWithImpl<$Res, _$LoadInProgressImpl>
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
    return 'MessagesWatcherState.loadInProgress()';
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
    required TResult Function(KtList<Message> messages) loadSuccess,
    required TResult Function(MessageFailure failure) loadFailure,
  }) {
    return loadInProgress();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<Message> messages)? loadSuccess,
    TResult? Function(MessageFailure failure)? loadFailure,
  }) {
    return loadInProgress?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<Message> messages)? loadSuccess,
    TResult Function(MessageFailure failure)? loadFailure,
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

abstract class _LoadInProgress implements MessagesWatcherState {
  const factory _LoadInProgress() = _$LoadInProgressImpl;
}

/// @nodoc
abstract class _$$LoadSuccessImplCopyWith<$Res> {
  factory _$$LoadSuccessImplCopyWith(
          _$LoadSuccessImpl value, $Res Function(_$LoadSuccessImpl) then) =
      __$$LoadSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({KtList<Message> messages});
}

/// @nodoc
class __$$LoadSuccessImplCopyWithImpl<$Res>
    extends _$MessagesWatcherStateCopyWithImpl<$Res, _$LoadSuccessImpl>
    implements _$$LoadSuccessImplCopyWith<$Res> {
  __$$LoadSuccessImplCopyWithImpl(
      _$LoadSuccessImpl _value, $Res Function(_$LoadSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
  }) {
    return _then(_$LoadSuccessImpl(
      null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as KtList<Message>,
    ));
  }
}

/// @nodoc

class _$LoadSuccessImpl implements _LoadSuccess {
  const _$LoadSuccessImpl(this.messages);

  @override
  final KtList<Message> messages;

  @override
  String toString() {
    return 'MessagesWatcherState.loadSuccess(messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadSuccessImpl &&
            (identical(other.messages, messages) ||
                other.messages == messages));
  }

  @override
  int get hashCode => Object.hash(runtimeType, messages);

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
    required TResult Function(KtList<Message> messages) loadSuccess,
    required TResult Function(MessageFailure failure) loadFailure,
  }) {
    return loadSuccess(messages);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<Message> messages)? loadSuccess,
    TResult? Function(MessageFailure failure)? loadFailure,
  }) {
    return loadSuccess?.call(messages);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<Message> messages)? loadSuccess,
    TResult Function(MessageFailure failure)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadSuccess != null) {
      return loadSuccess(messages);
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

abstract class _LoadSuccess implements MessagesWatcherState {
  const factory _LoadSuccess(final KtList<Message> messages) =
      _$LoadSuccessImpl;

  KtList<Message> get messages;
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
  $Res call({MessageFailure failure});
}

/// @nodoc
class __$$LoadFailureImplCopyWithImpl<$Res>
    extends _$MessagesWatcherStateCopyWithImpl<$Res, _$LoadFailureImpl>
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
              as MessageFailure,
    ));
  }
}

/// @nodoc

class _$LoadFailureImpl implements _LoadFailure {
  const _$LoadFailureImpl(this.failure);

  @override
  final MessageFailure failure;

  @override
  String toString() {
    return 'MessagesWatcherState.loadFailure(failure: $failure)';
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
    required TResult Function(KtList<Message> messages) loadSuccess,
    required TResult Function(MessageFailure failure) loadFailure,
  }) {
    return loadFailure(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loadInProgress,
    TResult? Function(KtList<Message> messages)? loadSuccess,
    TResult? Function(MessageFailure failure)? loadFailure,
  }) {
    return loadFailure?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loadInProgress,
    TResult Function(KtList<Message> messages)? loadSuccess,
    TResult Function(MessageFailure failure)? loadFailure,
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

abstract class _LoadFailure implements MessagesWatcherState {
  const factory _LoadFailure(final MessageFailure failure) = _$LoadFailureImpl;

  MessageFailure get failure;
  @JsonKey(ignore: true)
  _$$LoadFailureImplCopyWith<_$LoadFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
