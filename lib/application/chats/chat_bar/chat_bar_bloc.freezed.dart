// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_bar_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatBarState {

 Content get content; bool get isSubmitting; bool get showErrorMessages; Option<Either<ChatFailure, Unit>> get chatCreationFailureOrSuccessOption;/// The outcome of the last message sent to an existing chat. At most one
/// of this and [chatCreationFailureOrSuccessOption] is set: each send
/// clears the other, so the page only ever reports the latest attempt.
 Option<Either<message_failure.MessageFailure, Unit>> get messageSendFailureOrSuccessOption;/// The message the next one sent answers, while the user is replying.
 MessageQuote? get replyingTo;/// Photos and GIFs chosen for the next message, ready to send.
 KtList<MediaDraft> get media;/// Whether chosen photos are still being made ready.
 bool get preparingMedia;/// Why the last photos chosen could not all be added.
 Option<MediaFailure> get mediaFailureOption;
/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatBarStateCopyWith<ChatBarState> get copyWith => _$ChatBarStateCopyWithImpl<ChatBarState>(this as ChatBarState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatBarState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatBarState&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.isSubmitting, _this.isSubmitting) || other.isSubmitting == _this.isSubmitting)&&(identical(other.showErrorMessages, _this.showErrorMessages) || other.showErrorMessages == _this.showErrorMessages)&&(identical(other.chatCreationFailureOrSuccessOption, _this.chatCreationFailureOrSuccessOption) || other.chatCreationFailureOrSuccessOption == _this.chatCreationFailureOrSuccessOption)&&(identical(other.messageSendFailureOrSuccessOption, _this.messageSendFailureOrSuccessOption) || other.messageSendFailureOrSuccessOption == _this.messageSendFailureOrSuccessOption)&&(identical(other.replyingTo, _this.replyingTo) || other.replyingTo == _this.replyingTo)&&(identical(other.media, _this.media) || other.media == _this.media)&&(identical(other.preparingMedia, _this.preparingMedia) || other.preparingMedia == _this.preparingMedia)&&(identical(other.mediaFailureOption, _this.mediaFailureOption) || other.mediaFailureOption == _this.mediaFailureOption));
}


@override
int get hashCode {
  final _this = this as ChatBarState;
  return Object.hash(runtimeType,_this.content,_this.isSubmitting,_this.showErrorMessages,_this.chatCreationFailureOrSuccessOption,_this.messageSendFailureOrSuccessOption,_this.replyingTo,_this.media,_this.preparingMedia,_this.mediaFailureOption);
}

@override
String toString() {
  final _this = this as ChatBarState;
  return 'ChatBarState(content: ${_this.content}, isSubmitting: ${_this.isSubmitting}, showErrorMessages: ${_this.showErrorMessages}, chatCreationFailureOrSuccessOption: ${_this.chatCreationFailureOrSuccessOption}, messageSendFailureOrSuccessOption: ${_this.messageSendFailureOrSuccessOption}, replyingTo: ${_this.replyingTo}, media: ${_this.media}, preparingMedia: ${_this.preparingMedia}, mediaFailureOption: ${_this.mediaFailureOption})';
}


}

/// @nodoc
abstract mixin class $ChatBarStateCopyWith<$Res>  {
  factory $ChatBarStateCopyWith(ChatBarState value, $Res Function(ChatBarState) _then) = _$ChatBarStateCopyWithImpl;
@useResult
$Res call({
 Content content, bool isSubmitting, bool showErrorMessages, Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption, Option<Either<message_failure.MessageFailure, Unit>> messageSendFailureOrSuccessOption, MessageQuote? replyingTo, KtList<MediaDraft> media, bool preparingMedia, Option<MediaFailure> mediaFailureOption
});




}
/// @nodoc
class _$ChatBarStateCopyWithImpl<$Res>
    implements $ChatBarStateCopyWith<$Res> {
  _$ChatBarStateCopyWithImpl(this._self, this._then);

  final ChatBarState _self;
  final $Res Function(ChatBarState) _then;

/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? isSubmitting = null,Object? showErrorMessages = null,Object? chatCreationFailureOrSuccessOption = null,Object? messageSendFailureOrSuccessOption = null,Object? replyingTo = freezed,Object? media = null,Object? preparingMedia = null,Object? mediaFailureOption = null,}) {
  return _then(ChatBarState(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Content,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,showErrorMessages: null == showErrorMessages ? _self.showErrorMessages : showErrorMessages // ignore: cast_nullable_to_non_nullable
as bool,chatCreationFailureOrSuccessOption: null == chatCreationFailureOrSuccessOption ? _self.chatCreationFailureOrSuccessOption : chatCreationFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<ChatFailure, Unit>>,messageSendFailureOrSuccessOption: null == messageSendFailureOrSuccessOption ? _self.messageSendFailureOrSuccessOption : messageSendFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<message_failure.MessageFailure, Unit>>,replyingTo: freezed == replyingTo ? _self.replyingTo : replyingTo // ignore: cast_nullable_to_non_nullable
as MessageQuote?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as KtList<MediaDraft>,preparingMedia: null == preparingMedia ? _self.preparingMedia : preparingMedia // ignore: cast_nullable_to_non_nullable
as bool,mediaFailureOption: null == mediaFailureOption ? _self.mediaFailureOption : mediaFailureOption // ignore: cast_nullable_to_non_nullable
as Option<MediaFailure>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatBarState].
extension ChatBarStatePatterns on ChatBarState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatBarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatBarState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatBarState value)  $default,){
final _that = this;
switch (_that) {
case _ChatBarState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatBarState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatBarState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Content content,  bool isSubmitting,  bool showErrorMessages,  Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption,  Option<Either<message_failure.MessageFailure, Unit>> messageSendFailureOrSuccessOption,  MessageQuote? replyingTo,  KtList<MediaDraft> media,  bool preparingMedia,  Option<MediaFailure> mediaFailureOption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatBarState() when $default != null:
return $default(_that.content,_that.isSubmitting,_that.showErrorMessages,_that.chatCreationFailureOrSuccessOption,_that.messageSendFailureOrSuccessOption,_that.replyingTo,_that.media,_that.preparingMedia,_that.mediaFailureOption);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Content content,  bool isSubmitting,  bool showErrorMessages,  Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption,  Option<Either<message_failure.MessageFailure, Unit>> messageSendFailureOrSuccessOption,  MessageQuote? replyingTo,  KtList<MediaDraft> media,  bool preparingMedia,  Option<MediaFailure> mediaFailureOption)  $default,) {final _that = this;
switch (_that) {
case _ChatBarState():
return $default(_that.content,_that.isSubmitting,_that.showErrorMessages,_that.chatCreationFailureOrSuccessOption,_that.messageSendFailureOrSuccessOption,_that.replyingTo,_that.media,_that.preparingMedia,_that.mediaFailureOption);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Content content,  bool isSubmitting,  bool showErrorMessages,  Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption,  Option<Either<message_failure.MessageFailure, Unit>> messageSendFailureOrSuccessOption,  MessageQuote? replyingTo,  KtList<MediaDraft> media,  bool preparingMedia,  Option<MediaFailure> mediaFailureOption)?  $default,) {final _that = this;
switch (_that) {
case _ChatBarState() when $default != null:
return $default(_that.content,_that.isSubmitting,_that.showErrorMessages,_that.chatCreationFailureOrSuccessOption,_that.messageSendFailureOrSuccessOption,_that.replyingTo,_that.media,_that.preparingMedia,_that.mediaFailureOption);case _:
  return null;

}
}

}

/// @nodoc


class _ChatBarState implements ChatBarState {
  const _ChatBarState({required this.content, required this.isSubmitting, required this.showErrorMessages, required this.chatCreationFailureOrSuccessOption, required this.messageSendFailureOrSuccessOption, this.replyingTo, this.media = const KtList<MediaDraft>.empty(), this.preparingMedia = false, required this.mediaFailureOption});
  

@override final  Content content;
@override final  bool isSubmitting;
@override final  bool showErrorMessages;
@override final  Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption;
/// The outcome of the last message sent to an existing chat. At most one
/// of this and [chatCreationFailureOrSuccessOption] is set: each send
/// clears the other, so the page only ever reports the latest attempt.
@override final  Option<Either<message_failure.MessageFailure, Unit>> messageSendFailureOrSuccessOption;
/// The message the next one sent answers, while the user is replying.
@override final  MessageQuote? replyingTo;
/// Photos and GIFs chosen for the next message, ready to send.
@override@JsonKey() final  KtList<MediaDraft> media;
/// Whether chosen photos are still being made ready.
@override@JsonKey() final  bool preparingMedia;
/// Why the last photos chosen could not all be added.
@override final  Option<MediaFailure> mediaFailureOption;

/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatBarStateCopyWith<_ChatBarState> get copyWith => __$ChatBarStateCopyWithImpl<_ChatBarState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatBarState&&(identical(other.content, content) || other.content == content)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.showErrorMessages, showErrorMessages) || other.showErrorMessages == showErrorMessages)&&(identical(other.chatCreationFailureOrSuccessOption, chatCreationFailureOrSuccessOption) || other.chatCreationFailureOrSuccessOption == chatCreationFailureOrSuccessOption)&&(identical(other.messageSendFailureOrSuccessOption, messageSendFailureOrSuccessOption) || other.messageSendFailureOrSuccessOption == messageSendFailureOrSuccessOption)&&(identical(other.replyingTo, replyingTo) || other.replyingTo == replyingTo)&&(identical(other.media, media) || other.media == media)&&(identical(other.preparingMedia, preparingMedia) || other.preparingMedia == preparingMedia)&&(identical(other.mediaFailureOption, mediaFailureOption) || other.mediaFailureOption == mediaFailureOption));
}


@override
int get hashCode {
    return Object.hash(runtimeType,content,isSubmitting,showErrorMessages,chatCreationFailureOrSuccessOption,messageSendFailureOrSuccessOption,replyingTo,media,preparingMedia,mediaFailureOption);
}

@override
String toString() {
    return 'ChatBarState(content: $content, isSubmitting: $isSubmitting, showErrorMessages: $showErrorMessages, chatCreationFailureOrSuccessOption: $chatCreationFailureOrSuccessOption, messageSendFailureOrSuccessOption: $messageSendFailureOrSuccessOption, replyingTo: $replyingTo, media: $media, preparingMedia: $preparingMedia, mediaFailureOption: $mediaFailureOption)';
}


}

/// @nodoc
abstract mixin class _$ChatBarStateCopyWith<$Res> implements $ChatBarStateCopyWith<$Res> {
  factory _$ChatBarStateCopyWith(_ChatBarState value, $Res Function(_ChatBarState) _then) = __$ChatBarStateCopyWithImpl;
@override @useResult
$Res call({
 Content content, bool isSubmitting, bool showErrorMessages, Option<Either<ChatFailure, Unit>> chatCreationFailureOrSuccessOption, Option<Either<message_failure.MessageFailure, Unit>> messageSendFailureOrSuccessOption, MessageQuote? replyingTo, KtList<MediaDraft> media, bool preparingMedia, Option<MediaFailure> mediaFailureOption
});




}
/// @nodoc
class __$ChatBarStateCopyWithImpl<$Res>
    implements _$ChatBarStateCopyWith<$Res> {
  __$ChatBarStateCopyWithImpl(this._self, this._then);

  final _ChatBarState _self;
  final $Res Function(_ChatBarState) _then;

/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? isSubmitting = null,Object? showErrorMessages = null,Object? chatCreationFailureOrSuccessOption = null,Object? messageSendFailureOrSuccessOption = null,Object? replyingTo = freezed,Object? media = null,Object? preparingMedia = null,Object? mediaFailureOption = null,}) {
  return _then(_ChatBarState(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Content,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,showErrorMessages: null == showErrorMessages ? _self.showErrorMessages : showErrorMessages // ignore: cast_nullable_to_non_nullable
as bool,chatCreationFailureOrSuccessOption: null == chatCreationFailureOrSuccessOption ? _self.chatCreationFailureOrSuccessOption : chatCreationFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<ChatFailure, Unit>>,messageSendFailureOrSuccessOption: null == messageSendFailureOrSuccessOption ? _self.messageSendFailureOrSuccessOption : messageSendFailureOrSuccessOption // ignore: cast_nullable_to_non_nullable
as Option<Either<message_failure.MessageFailure, Unit>>,replyingTo: freezed == replyingTo ? _self.replyingTo : replyingTo // ignore: cast_nullable_to_non_nullable
as MessageQuote?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as KtList<MediaDraft>,preparingMedia: null == preparingMedia ? _self.preparingMedia : preparingMedia // ignore: cast_nullable_to_non_nullable
as bool,mediaFailureOption: null == mediaFailureOption ? _self.mediaFailureOption : mediaFailureOption // ignore: cast_nullable_to_non_nullable
as Option<MediaFailure>,
  ));
}


}

// dart format on
