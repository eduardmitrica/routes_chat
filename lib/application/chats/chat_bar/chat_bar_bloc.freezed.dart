// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_bar_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatBarEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contentString) messageContentChanged,
    required TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds)
        newChatCreated,
    required TResult Function(String content, UniqueId chatId)
        newMessageAddedToChatWithId,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contentString)? messageContentChanged,
    TResult? Function(KtList<UniqueId> otherThanCurrentParticipantIds)?
        newChatCreated,
    TResult? Function(String content, UniqueId chatId)?
        newMessageAddedToChatWithId,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contentString)? messageContentChanged,
    TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds)?
        newChatCreated,
    TResult Function(String content, UniqueId chatId)?
        newMessageAddedToChatWithId,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_MessageContentChanged value)
        messageContentChanged,
    required TResult Function(_NewChatCreated value) newChatCreated,
    required TResult Function(_NewMessageAddedToChatWithId value)
        newMessageAddedToChatWithId,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MessageContentChanged value)? messageContentChanged,
    TResult? Function(_NewChatCreated value)? newChatCreated,
    TResult? Function(_NewMessageAddedToChatWithId value)?
        newMessageAddedToChatWithId,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MessageContentChanged value)? messageContentChanged,
    TResult Function(_NewChatCreated value)? newChatCreated,
    TResult Function(_NewMessageAddedToChatWithId value)?
        newMessageAddedToChatWithId,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatBarEventCopyWith<$Res> {
  factory $ChatBarEventCopyWith(
          ChatBarEvent value, $Res Function(ChatBarEvent) then) =
      _$ChatBarEventCopyWithImpl<$Res, ChatBarEvent>;
}

/// @nodoc
class _$ChatBarEventCopyWithImpl<$Res, $Val extends ChatBarEvent>
    implements $ChatBarEventCopyWith<$Res> {
  _$ChatBarEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MessageContentChangedImplCopyWith<$Res> {
  factory _$$MessageContentChangedImplCopyWith(
          _$MessageContentChangedImpl value,
          $Res Function(_$MessageContentChangedImpl) then) =
      __$$MessageContentChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String contentString});
}

/// @nodoc
class __$$MessageContentChangedImplCopyWithImpl<$Res>
    extends _$ChatBarEventCopyWithImpl<$Res, _$MessageContentChangedImpl>
    implements _$$MessageContentChangedImplCopyWith<$Res> {
  __$$MessageContentChangedImplCopyWithImpl(_$MessageContentChangedImpl _value,
      $Res Function(_$MessageContentChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentString = null,
  }) {
    return _then(_$MessageContentChangedImpl(
      null == contentString
          ? _value.contentString
          : contentString // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MessageContentChangedImpl implements _MessageContentChanged {
  const _$MessageContentChangedImpl(this.contentString);

  @override
  final String contentString;

  @override
  String toString() {
    return 'ChatBarEvent.messageContentChanged(contentString: $contentString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageContentChangedImpl &&
            (identical(other.contentString, contentString) ||
                other.contentString == contentString));
  }

  @override
  int get hashCode => Object.hash(runtimeType, contentString);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageContentChangedImplCopyWith<_$MessageContentChangedImpl>
      get copyWith => __$$MessageContentChangedImplCopyWithImpl<
          _$MessageContentChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contentString) messageContentChanged,
    required TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds)
        newChatCreated,
    required TResult Function(String content, UniqueId chatId)
        newMessageAddedToChatWithId,
  }) {
    return messageContentChanged(contentString);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contentString)? messageContentChanged,
    TResult? Function(KtList<UniqueId> otherThanCurrentParticipantIds)?
        newChatCreated,
    TResult? Function(String content, UniqueId chatId)?
        newMessageAddedToChatWithId,
  }) {
    return messageContentChanged?.call(contentString);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contentString)? messageContentChanged,
    TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds)?
        newChatCreated,
    TResult Function(String content, UniqueId chatId)?
        newMessageAddedToChatWithId,
    required TResult orElse(),
  }) {
    if (messageContentChanged != null) {
      return messageContentChanged(contentString);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_MessageContentChanged value)
        messageContentChanged,
    required TResult Function(_NewChatCreated value) newChatCreated,
    required TResult Function(_NewMessageAddedToChatWithId value)
        newMessageAddedToChatWithId,
  }) {
    return messageContentChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MessageContentChanged value)? messageContentChanged,
    TResult? Function(_NewChatCreated value)? newChatCreated,
    TResult? Function(_NewMessageAddedToChatWithId value)?
        newMessageAddedToChatWithId,
  }) {
    return messageContentChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MessageContentChanged value)? messageContentChanged,
    TResult Function(_NewChatCreated value)? newChatCreated,
    TResult Function(_NewMessageAddedToChatWithId value)?
        newMessageAddedToChatWithId,
    required TResult orElse(),
  }) {
    if (messageContentChanged != null) {
      return messageContentChanged(this);
    }
    return orElse();
  }
}

abstract class _MessageContentChanged implements ChatBarEvent {
  const factory _MessageContentChanged(final String contentString) =
      _$MessageContentChangedImpl;

  String get contentString;
  @JsonKey(ignore: true)
  _$$MessageContentChangedImplCopyWith<_$MessageContentChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NewChatCreatedImplCopyWith<$Res> {
  factory _$$NewChatCreatedImplCopyWith(_$NewChatCreatedImpl value,
          $Res Function(_$NewChatCreatedImpl) then) =
      __$$NewChatCreatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({KtList<UniqueId> otherThanCurrentParticipantIds});
}

/// @nodoc
class __$$NewChatCreatedImplCopyWithImpl<$Res>
    extends _$ChatBarEventCopyWithImpl<$Res, _$NewChatCreatedImpl>
    implements _$$NewChatCreatedImplCopyWith<$Res> {
  __$$NewChatCreatedImplCopyWithImpl(
      _$NewChatCreatedImpl _value, $Res Function(_$NewChatCreatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otherThanCurrentParticipantIds = null,
  }) {
    return _then(_$NewChatCreatedImpl(
      null == otherThanCurrentParticipantIds
          ? _value.otherThanCurrentParticipantIds
          : otherThanCurrentParticipantIds // ignore: cast_nullable_to_non_nullable
              as KtList<UniqueId>,
    ));
  }
}

/// @nodoc

class _$NewChatCreatedImpl implements _NewChatCreated {
  const _$NewChatCreatedImpl(this.otherThanCurrentParticipantIds);

  @override
  final KtList<UniqueId> otherThanCurrentParticipantIds;

  @override
  String toString() {
    return 'ChatBarEvent.newChatCreated(otherThanCurrentParticipantIds: $otherThanCurrentParticipantIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewChatCreatedImpl &&
            (identical(other.otherThanCurrentParticipantIds,
                    otherThanCurrentParticipantIds) ||
                other.otherThanCurrentParticipantIds ==
                    otherThanCurrentParticipantIds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, otherThanCurrentParticipantIds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NewChatCreatedImplCopyWith<_$NewChatCreatedImpl> get copyWith =>
      __$$NewChatCreatedImplCopyWithImpl<_$NewChatCreatedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contentString) messageContentChanged,
    required TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds)
        newChatCreated,
    required TResult Function(String content, UniqueId chatId)
        newMessageAddedToChatWithId,
  }) {
    return newChatCreated(otherThanCurrentParticipantIds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contentString)? messageContentChanged,
    TResult? Function(KtList<UniqueId> otherThanCurrentParticipantIds)?
        newChatCreated,
    TResult? Function(String content, UniqueId chatId)?
        newMessageAddedToChatWithId,
  }) {
    return newChatCreated?.call(otherThanCurrentParticipantIds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contentString)? messageContentChanged,
    TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds)?
        newChatCreated,
    TResult Function(String content, UniqueId chatId)?
        newMessageAddedToChatWithId,
    required TResult orElse(),
  }) {
    if (newChatCreated != null) {
      return newChatCreated(otherThanCurrentParticipantIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_MessageContentChanged value)
        messageContentChanged,
    required TResult Function(_NewChatCreated value) newChatCreated,
    required TResult Function(_NewMessageAddedToChatWithId value)
        newMessageAddedToChatWithId,
  }) {
    return newChatCreated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MessageContentChanged value)? messageContentChanged,
    TResult? Function(_NewChatCreated value)? newChatCreated,
    TResult? Function(_NewMessageAddedToChatWithId value)?
        newMessageAddedToChatWithId,
  }) {
    return newChatCreated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MessageContentChanged value)? messageContentChanged,
    TResult Function(_NewChatCreated value)? newChatCreated,
    TResult Function(_NewMessageAddedToChatWithId value)?
        newMessageAddedToChatWithId,
    required TResult orElse(),
  }) {
    if (newChatCreated != null) {
      return newChatCreated(this);
    }
    return orElse();
  }
}

abstract class _NewChatCreated implements ChatBarEvent {
  const factory _NewChatCreated(
          final KtList<UniqueId> otherThanCurrentParticipantIds) =
      _$NewChatCreatedImpl;

  KtList<UniqueId> get otherThanCurrentParticipantIds;
  @JsonKey(ignore: true)
  _$$NewChatCreatedImplCopyWith<_$NewChatCreatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NewMessageAddedToChatWithIdImplCopyWith<$Res> {
  factory _$$NewMessageAddedToChatWithIdImplCopyWith(
          _$NewMessageAddedToChatWithIdImpl value,
          $Res Function(_$NewMessageAddedToChatWithIdImpl) then) =
      __$$NewMessageAddedToChatWithIdImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String content, UniqueId chatId});
}

/// @nodoc
class __$$NewMessageAddedToChatWithIdImplCopyWithImpl<$Res>
    extends _$ChatBarEventCopyWithImpl<$Res, _$NewMessageAddedToChatWithIdImpl>
    implements _$$NewMessageAddedToChatWithIdImplCopyWith<$Res> {
  __$$NewMessageAddedToChatWithIdImplCopyWithImpl(
      _$NewMessageAddedToChatWithIdImpl _value,
      $Res Function(_$NewMessageAddedToChatWithIdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? chatId = null,
  }) {
    return _then(_$NewMessageAddedToChatWithIdImpl(
      null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as UniqueId,
    ));
  }
}

/// @nodoc

class _$NewMessageAddedToChatWithIdImpl
    implements _NewMessageAddedToChatWithId {
  const _$NewMessageAddedToChatWithIdImpl(this.content, this.chatId);

  @override
  final String content;
  @override
  final UniqueId chatId;

  @override
  String toString() {
    return 'ChatBarEvent.newMessageAddedToChatWithId(content: $content, chatId: $chatId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewMessageAddedToChatWithIdImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.chatId, chatId) || other.chatId == chatId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content, chatId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NewMessageAddedToChatWithIdImplCopyWith<_$NewMessageAddedToChatWithIdImpl>
      get copyWith => __$$NewMessageAddedToChatWithIdImplCopyWithImpl<
          _$NewMessageAddedToChatWithIdImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String contentString) messageContentChanged,
    required TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds)
        newChatCreated,
    required TResult Function(String content, UniqueId chatId)
        newMessageAddedToChatWithId,
  }) {
    return newMessageAddedToChatWithId(content, chatId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String contentString)? messageContentChanged,
    TResult? Function(KtList<UniqueId> otherThanCurrentParticipantIds)?
        newChatCreated,
    TResult? Function(String content, UniqueId chatId)?
        newMessageAddedToChatWithId,
  }) {
    return newMessageAddedToChatWithId?.call(content, chatId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String contentString)? messageContentChanged,
    TResult Function(KtList<UniqueId> otherThanCurrentParticipantIds)?
        newChatCreated,
    TResult Function(String content, UniqueId chatId)?
        newMessageAddedToChatWithId,
    required TResult orElse(),
  }) {
    if (newMessageAddedToChatWithId != null) {
      return newMessageAddedToChatWithId(content, chatId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_MessageContentChanged value)
        messageContentChanged,
    required TResult Function(_NewChatCreated value) newChatCreated,
    required TResult Function(_NewMessageAddedToChatWithId value)
        newMessageAddedToChatWithId,
  }) {
    return newMessageAddedToChatWithId(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MessageContentChanged value)? messageContentChanged,
    TResult? Function(_NewChatCreated value)? newChatCreated,
    TResult? Function(_NewMessageAddedToChatWithId value)?
        newMessageAddedToChatWithId,
  }) {
    return newMessageAddedToChatWithId?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MessageContentChanged value)? messageContentChanged,
    TResult Function(_NewChatCreated value)? newChatCreated,
    TResult Function(_NewMessageAddedToChatWithId value)?
        newMessageAddedToChatWithId,
    required TResult orElse(),
  }) {
    if (newMessageAddedToChatWithId != null) {
      return newMessageAddedToChatWithId(this);
    }
    return orElse();
  }
}

abstract class _NewMessageAddedToChatWithId implements ChatBarEvent {
  const factory _NewMessageAddedToChatWithId(
          final String content, final UniqueId chatId) =
      _$NewMessageAddedToChatWithIdImpl;

  String get content;
  UniqueId get chatId;
  @JsonKey(ignore: true)
  _$$NewMessageAddedToChatWithIdImplCopyWith<_$NewMessageAddedToChatWithIdImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChatBarState {
  Content get content => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get showErrorMessages => throw _privateConstructorUsedError;
  Option<Either<ChatFailure, Unit>> get chatCreationFailureOrSuccessOption =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChatBarStateCopyWith<ChatBarState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatBarStateCopyWith<$Res> {
  factory $ChatBarStateCopyWith(
          ChatBarState value, $Res Function(ChatBarState) then) =
      _$ChatBarStateCopyWithImpl<$Res, ChatBarState>;
  @useResult
  $Res call(
      {Content content,
      bool isSubmitting,
      bool showErrorMessages,
      Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption});
}

/// @nodoc
class _$ChatBarStateCopyWithImpl<$Res, $Val extends ChatBarState>
    implements $ChatBarStateCopyWith<$Res> {
  _$ChatBarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? isSubmitting = null,
    Object? showErrorMessages = null,
    Object? chatCreationFailureOrSuccessOption = null,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Content,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      showErrorMessages: null == showErrorMessages
          ? _value.showErrorMessages
          : showErrorMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      chatCreationFailureOrSuccessOption: null ==
              chatCreationFailureOrSuccessOption
          ? _value.chatCreationFailureOrSuccessOption
          : chatCreationFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
              as Option<Either<ChatFailure, Unit>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatBarStateImplCopyWith<$Res>
    implements $ChatBarStateCopyWith<$Res> {
  factory _$$ChatBarStateImplCopyWith(
          _$ChatBarStateImpl value, $Res Function(_$ChatBarStateImpl) then) =
      __$$ChatBarStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Content content,
      bool isSubmitting,
      bool showErrorMessages,
      Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption});
}

/// @nodoc
class __$$ChatBarStateImplCopyWithImpl<$Res>
    extends _$ChatBarStateCopyWithImpl<$Res, _$ChatBarStateImpl>
    implements _$$ChatBarStateImplCopyWith<$Res> {
  __$$ChatBarStateImplCopyWithImpl(
      _$ChatBarStateImpl _value, $Res Function(_$ChatBarStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? isSubmitting = null,
    Object? showErrorMessages = null,
    Object? chatCreationFailureOrSuccessOption = null,
  }) {
    return _then(_$ChatBarStateImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Content,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      showErrorMessages: null == showErrorMessages
          ? _value.showErrorMessages
          : showErrorMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      chatCreationFailureOrSuccessOption: null ==
              chatCreationFailureOrSuccessOption
          ? _value.chatCreationFailureOrSuccessOption
          : chatCreationFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
              as Option<Either<ChatFailure, Unit>>,
    ));
  }
}

/// @nodoc

class _$ChatBarStateImpl implements _ChatBarState {
  const _$ChatBarStateImpl(
      {required this.content,
      required this.isSubmitting,
      required this.showErrorMessages,
      required this.chatCreationFailureOrSuccessOption});

  @override
  final Content content;
  @override
  final bool isSubmitting;
  @override
  final bool showErrorMessages;
  @override
  final Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption;

  @override
  String toString() {
    return 'ChatBarState(content: $content, isSubmitting: $isSubmitting, showErrorMessages: $showErrorMessages, chatCreationFailureOrSuccessOption: $chatCreationFailureOrSuccessOption)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatBarStateImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.showErrorMessages, showErrorMessages) ||
                other.showErrorMessages == showErrorMessages) &&
            (identical(other.chatCreationFailureOrSuccessOption,
                    chatCreationFailureOrSuccessOption) ||
                other.chatCreationFailureOrSuccessOption ==
                    chatCreationFailureOrSuccessOption));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content, isSubmitting,
      showErrorMessages, chatCreationFailureOrSuccessOption);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatBarStateImplCopyWith<_$ChatBarStateImpl> get copyWith =>
      __$$ChatBarStateImplCopyWithImpl<_$ChatBarStateImpl>(this, _$identity);
}

abstract class _ChatBarState implements ChatBarState {
  const factory _ChatBarState(
      {required final Content content,
      required final bool isSubmitting,
      required final bool showErrorMessages,
      required final Option<Either<ChatFailure, Unit>>
          chatCreationFailureOrSuccessOption}) = _$ChatBarStateImpl;

  @override
  Content get content;
  @override
  bool get isSubmitting;
  @override
  bool get showErrorMessages;
  @override
  Option<Either<ChatFailure, Unit>> get chatCreationFailureOrSuccessOption;
  @override
  @JsonKey(ignore: true)
  _$$ChatBarStateImplCopyWith<_$ChatBarStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
