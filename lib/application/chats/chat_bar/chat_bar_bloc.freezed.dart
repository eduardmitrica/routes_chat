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
mixin _$ChatBarState implements DiagnosticableTreeMixin {

/// The chat being written in, known once the bloc has started.
 UniqueId? get chatId;/// What the user has typed.
 String get text;/// Counts the times [text] was set from outside the field, such as from a
/// restored draft, so the field shows the new text rather than keeping its
/// own.
 int get textRevision;/// The message the next one sent answers, while the user is replying.
 MessageQuote? get replyingTo;/// Photos and GIFs chosen for the next message, ready to send.
 KtList<MediaDraft> get media;/// Whether chosen photos are still being made ready.
 bool get preparingMedia;/// Why the last photos chosen could not all be added.
 Option<MediaFailure> get mediaFailureOption;/// The messages of this chat on their way, in the order they were sent.
 KtList<OutgoingMessage> get outgoing;/// Counts the messages the user asked to delete while they were being
/// sent, which were not deleted, so the page can say so each time.
 int get discardsRefused;/// The message the user is editing. Meanwhile [text] is its new text,
/// and the draft waits, to come back once the edit ends.
 Message? get editing;/// Whether the edit is being saved.
 bool get savingEdit;/// Why the last edit could not be saved.
 MessageFailure? get lastEditFailure;/// Counts the edits that could not be saved, so the page can say so each
/// time.
 int get editFailures;/// The message edited last, as it is now.
 Message? get lastEdited;
/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatBarStateCopyWith<ChatBarState> get copyWith => _$ChatBarStateCopyWithImpl<ChatBarState>(this as ChatBarState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as ChatBarState;
  properties
    ..add(DiagnosticsProperty('type', 'ChatBarState'))
    ..add(DiagnosticsProperty('chatId', _this.chatId))..add(DiagnosticsProperty('text', _this.text))..add(DiagnosticsProperty('textRevision', _this.textRevision))..add(DiagnosticsProperty('replyingTo', _this.replyingTo))..add(DiagnosticsProperty('media', _this.media))..add(DiagnosticsProperty('preparingMedia', _this.preparingMedia))..add(DiagnosticsProperty('mediaFailureOption', _this.mediaFailureOption))..add(DiagnosticsProperty('outgoing', _this.outgoing))..add(DiagnosticsProperty('discardsRefused', _this.discardsRefused))..add(DiagnosticsProperty('editing', _this.editing))..add(DiagnosticsProperty('savingEdit', _this.savingEdit))..add(DiagnosticsProperty('lastEditFailure', _this.lastEditFailure))..add(DiagnosticsProperty('editFailures', _this.editFailures))..add(DiagnosticsProperty('lastEdited', _this.lastEdited));
}

@override
bool operator ==(Object other) {
  final _this = this as ChatBarState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatBarState&&(identical(other.chatId, _this.chatId) || other.chatId == _this.chatId)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.textRevision, _this.textRevision) || other.textRevision == _this.textRevision)&&(identical(other.replyingTo, _this.replyingTo) || other.replyingTo == _this.replyingTo)&&(identical(other.media, _this.media) || other.media == _this.media)&&(identical(other.preparingMedia, _this.preparingMedia) || other.preparingMedia == _this.preparingMedia)&&(identical(other.mediaFailureOption, _this.mediaFailureOption) || other.mediaFailureOption == _this.mediaFailureOption)&&(identical(other.outgoing, _this.outgoing) || other.outgoing == _this.outgoing)&&(identical(other.discardsRefused, _this.discardsRefused) || other.discardsRefused == _this.discardsRefused)&&(identical(other.editing, _this.editing) || other.editing == _this.editing)&&(identical(other.savingEdit, _this.savingEdit) || other.savingEdit == _this.savingEdit)&&(identical(other.lastEditFailure, _this.lastEditFailure) || other.lastEditFailure == _this.lastEditFailure)&&(identical(other.editFailures, _this.editFailures) || other.editFailures == _this.editFailures)&&(identical(other.lastEdited, _this.lastEdited) || other.lastEdited == _this.lastEdited));
}


@override
int get hashCode {
  final _this = this as ChatBarState;
  return Object.hash(runtimeType,_this.chatId,_this.text,_this.textRevision,_this.replyingTo,_this.media,_this.preparingMedia,_this.mediaFailureOption,_this.outgoing,_this.discardsRefused,_this.editing,_this.savingEdit,_this.lastEditFailure,_this.editFailures,_this.lastEdited);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as ChatBarState;
  return 'ChatBarState(chatId: ${_this.chatId}, text: ${_this.text}, textRevision: ${_this.textRevision}, replyingTo: ${_this.replyingTo}, media: ${_this.media}, preparingMedia: ${_this.preparingMedia}, mediaFailureOption: ${_this.mediaFailureOption}, outgoing: ${_this.outgoing}, discardsRefused: ${_this.discardsRefused}, editing: ${_this.editing}, savingEdit: ${_this.savingEdit}, lastEditFailure: ${_this.lastEditFailure}, editFailures: ${_this.editFailures}, lastEdited: ${_this.lastEdited})';
}


}

/// @nodoc
abstract mixin class $ChatBarStateCopyWith<$Res>  {
  factory $ChatBarStateCopyWith(ChatBarState value, $Res Function(ChatBarState) _then) = _$ChatBarStateCopyWithImpl;
@useResult
$Res call({
 UniqueId? chatId, String text, int textRevision, MessageQuote? replyingTo, KtList<MediaDraft> media, bool preparingMedia, Option<MediaFailure> mediaFailureOption, KtList<OutgoingMessage> outgoing, int discardsRefused, Message? editing, bool savingEdit, MessageFailure? lastEditFailure, int editFailures, Message? lastEdited
});


$MessageCopyWith<$Res>? get editing;$MessageCopyWith<$Res>? get lastEdited;

}
/// @nodoc
class _$ChatBarStateCopyWithImpl<$Res>
    implements $ChatBarStateCopyWith<$Res> {
  _$ChatBarStateCopyWithImpl(this._self, this._then);

  final ChatBarState _self;
  final $Res Function(ChatBarState) _then;

/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chatId = freezed,Object? text = null,Object? textRevision = null,Object? replyingTo = freezed,Object? media = null,Object? preparingMedia = null,Object? mediaFailureOption = null,Object? outgoing = null,Object? discardsRefused = null,Object? editing = freezed,Object? savingEdit = null,Object? lastEditFailure = freezed,Object? editFailures = null,Object? lastEdited = freezed,}) {
  return _then(ChatBarState(
chatId: freezed == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as UniqueId?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,textRevision: null == textRevision ? _self.textRevision : textRevision // ignore: cast_nullable_to_non_nullable
as int,replyingTo: freezed == replyingTo ? _self.replyingTo : replyingTo // ignore: cast_nullable_to_non_nullable
as MessageQuote?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as KtList<MediaDraft>,preparingMedia: null == preparingMedia ? _self.preparingMedia : preparingMedia // ignore: cast_nullable_to_non_nullable
as bool,mediaFailureOption: null == mediaFailureOption ? _self.mediaFailureOption : mediaFailureOption // ignore: cast_nullable_to_non_nullable
as Option<MediaFailure>,outgoing: null == outgoing ? _self.outgoing : outgoing // ignore: cast_nullable_to_non_nullable
as KtList<OutgoingMessage>,discardsRefused: null == discardsRefused ? _self.discardsRefused : discardsRefused // ignore: cast_nullable_to_non_nullable
as int,editing: freezed == editing ? _self.editing : editing // ignore: cast_nullable_to_non_nullable
as Message?,savingEdit: null == savingEdit ? _self.savingEdit : savingEdit // ignore: cast_nullable_to_non_nullable
as bool,lastEditFailure: freezed == lastEditFailure ? _self.lastEditFailure : lastEditFailure // ignore: cast_nullable_to_non_nullable
as MessageFailure?,editFailures: null == editFailures ? _self.editFailures : editFailures // ignore: cast_nullable_to_non_nullable
as int,lastEdited: freezed == lastEdited ? _self.lastEdited : lastEdited // ignore: cast_nullable_to_non_nullable
as Message?,
  ));
}
/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get editing {
    if (_self.editing == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.editing!, (value) {
    return _then(_self.copyWith(editing: value));
  });
}/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get lastEdited {
    if (_self.lastEdited == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.lastEdited!, (value) {
    return _then(_self.copyWith(lastEdited: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UniqueId? chatId,  String text,  int textRevision,  MessageQuote? replyingTo,  KtList<MediaDraft> media,  bool preparingMedia,  Option<MediaFailure> mediaFailureOption,  KtList<OutgoingMessage> outgoing,  int discardsRefused,  Message? editing,  bool savingEdit,  MessageFailure? lastEditFailure,  int editFailures,  Message? lastEdited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatBarState() when $default != null:
return $default(_that.chatId,_that.text,_that.textRevision,_that.replyingTo,_that.media,_that.preparingMedia,_that.mediaFailureOption,_that.outgoing,_that.discardsRefused,_that.editing,_that.savingEdit,_that.lastEditFailure,_that.editFailures,_that.lastEdited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UniqueId? chatId,  String text,  int textRevision,  MessageQuote? replyingTo,  KtList<MediaDraft> media,  bool preparingMedia,  Option<MediaFailure> mediaFailureOption,  KtList<OutgoingMessage> outgoing,  int discardsRefused,  Message? editing,  bool savingEdit,  MessageFailure? lastEditFailure,  int editFailures,  Message? lastEdited)  $default,) {final _that = this;
switch (_that) {
case _ChatBarState():
return $default(_that.chatId,_that.text,_that.textRevision,_that.replyingTo,_that.media,_that.preparingMedia,_that.mediaFailureOption,_that.outgoing,_that.discardsRefused,_that.editing,_that.savingEdit,_that.lastEditFailure,_that.editFailures,_that.lastEdited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UniqueId? chatId,  String text,  int textRevision,  MessageQuote? replyingTo,  KtList<MediaDraft> media,  bool preparingMedia,  Option<MediaFailure> mediaFailureOption,  KtList<OutgoingMessage> outgoing,  int discardsRefused,  Message? editing,  bool savingEdit,  MessageFailure? lastEditFailure,  int editFailures,  Message? lastEdited)?  $default,) {final _that = this;
switch (_that) {
case _ChatBarState() when $default != null:
return $default(_that.chatId,_that.text,_that.textRevision,_that.replyingTo,_that.media,_that.preparingMedia,_that.mediaFailureOption,_that.outgoing,_that.discardsRefused,_that.editing,_that.savingEdit,_that.lastEditFailure,_that.editFailures,_that.lastEdited);case _:
  return null;

}
}

}

/// @nodoc


class _ChatBarState with DiagnosticableTreeMixin implements ChatBarState {
  const _ChatBarState({this.chatId, this.text = '', this.textRevision = 0, this.replyingTo, this.media = const KtList<MediaDraft>.empty(), this.preparingMedia = false, required this.mediaFailureOption, this.outgoing = const KtList<OutgoingMessage>.empty(), this.discardsRefused = 0, this.editing, this.savingEdit = false, this.lastEditFailure, this.editFailures = 0, this.lastEdited});
  

/// The chat being written in, known once the bloc has started.
@override final  UniqueId? chatId;
/// What the user has typed.
@override@JsonKey() final  String text;
/// Counts the times [text] was set from outside the field, such as from a
/// restored draft, so the field shows the new text rather than keeping its
/// own.
@override@JsonKey() final  int textRevision;
/// The message the next one sent answers, while the user is replying.
@override final  MessageQuote? replyingTo;
/// Photos and GIFs chosen for the next message, ready to send.
@override@JsonKey() final  KtList<MediaDraft> media;
/// Whether chosen photos are still being made ready.
@override@JsonKey() final  bool preparingMedia;
/// Why the last photos chosen could not all be added.
@override final  Option<MediaFailure> mediaFailureOption;
/// The messages of this chat on their way, in the order they were sent.
@override@JsonKey() final  KtList<OutgoingMessage> outgoing;
/// Counts the messages the user asked to delete while they were being
/// sent, which were not deleted, so the page can say so each time.
@override@JsonKey() final  int discardsRefused;
/// The message the user is editing. Meanwhile [text] is its new text,
/// and the draft waits, to come back once the edit ends.
@override final  Message? editing;
/// Whether the edit is being saved.
@override@JsonKey() final  bool savingEdit;
/// Why the last edit could not be saved.
@override final  MessageFailure? lastEditFailure;
/// Counts the edits that could not be saved, so the page can say so each
/// time.
@override@JsonKey() final  int editFailures;
/// The message edited last, as it is now.
@override final  Message? lastEdited;

/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatBarStateCopyWith<_ChatBarState> get copyWith => __$ChatBarStateCopyWithImpl<_ChatBarState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'ChatBarState'))
    ..add(DiagnosticsProperty('chatId', chatId))..add(DiagnosticsProperty('text', text))..add(DiagnosticsProperty('textRevision', textRevision))..add(DiagnosticsProperty('replyingTo', replyingTo))..add(DiagnosticsProperty('media', media))..add(DiagnosticsProperty('preparingMedia', preparingMedia))..add(DiagnosticsProperty('mediaFailureOption', mediaFailureOption))..add(DiagnosticsProperty('outgoing', outgoing))..add(DiagnosticsProperty('discardsRefused', discardsRefused))..add(DiagnosticsProperty('editing', editing))..add(DiagnosticsProperty('savingEdit', savingEdit))..add(DiagnosticsProperty('lastEditFailure', lastEditFailure))..add(DiagnosticsProperty('editFailures', editFailures))..add(DiagnosticsProperty('lastEdited', lastEdited));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatBarState&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.text, text) || other.text == text)&&(identical(other.textRevision, textRevision) || other.textRevision == textRevision)&&(identical(other.replyingTo, replyingTo) || other.replyingTo == replyingTo)&&(identical(other.media, media) || other.media == media)&&(identical(other.preparingMedia, preparingMedia) || other.preparingMedia == preparingMedia)&&(identical(other.mediaFailureOption, mediaFailureOption) || other.mediaFailureOption == mediaFailureOption)&&(identical(other.outgoing, outgoing) || other.outgoing == outgoing)&&(identical(other.discardsRefused, discardsRefused) || other.discardsRefused == discardsRefused)&&(identical(other.editing, editing) || other.editing == editing)&&(identical(other.savingEdit, savingEdit) || other.savingEdit == savingEdit)&&(identical(other.lastEditFailure, lastEditFailure) || other.lastEditFailure == lastEditFailure)&&(identical(other.editFailures, editFailures) || other.editFailures == editFailures)&&(identical(other.lastEdited, lastEdited) || other.lastEdited == lastEdited));
}


@override
int get hashCode {
    return Object.hash(runtimeType,chatId,text,textRevision,replyingTo,media,preparingMedia,mediaFailureOption,outgoing,discardsRefused,editing,savingEdit,lastEditFailure,editFailures,lastEdited);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'ChatBarState(chatId: $chatId, text: $text, textRevision: $textRevision, replyingTo: $replyingTo, media: $media, preparingMedia: $preparingMedia, mediaFailureOption: $mediaFailureOption, outgoing: $outgoing, discardsRefused: $discardsRefused, editing: $editing, savingEdit: $savingEdit, lastEditFailure: $lastEditFailure, editFailures: $editFailures, lastEdited: $lastEdited)';
}


}

/// @nodoc
abstract mixin class _$ChatBarStateCopyWith<$Res> implements $ChatBarStateCopyWith<$Res> {
  factory _$ChatBarStateCopyWith(_ChatBarState value, $Res Function(_ChatBarState) _then) = __$ChatBarStateCopyWithImpl;
@override @useResult
$Res call({
 UniqueId? chatId, String text, int textRevision, MessageQuote? replyingTo, KtList<MediaDraft> media, bool preparingMedia, Option<MediaFailure> mediaFailureOption, KtList<OutgoingMessage> outgoing, int discardsRefused, Message? editing, bool savingEdit, MessageFailure? lastEditFailure, int editFailures, Message? lastEdited
});


@override $MessageCopyWith<$Res>? get editing;@override $MessageCopyWith<$Res>? get lastEdited;

}
/// @nodoc
class __$ChatBarStateCopyWithImpl<$Res>
    implements _$ChatBarStateCopyWith<$Res> {
  __$ChatBarStateCopyWithImpl(this._self, this._then);

  final _ChatBarState _self;
  final $Res Function(_ChatBarState) _then;

/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chatId = freezed,Object? text = null,Object? textRevision = null,Object? replyingTo = freezed,Object? media = null,Object? preparingMedia = null,Object? mediaFailureOption = null,Object? outgoing = null,Object? discardsRefused = null,Object? editing = freezed,Object? savingEdit = null,Object? lastEditFailure = freezed,Object? editFailures = null,Object? lastEdited = freezed,}) {
  return _then(_ChatBarState(
chatId: freezed == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as UniqueId?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,textRevision: null == textRevision ? _self.textRevision : textRevision // ignore: cast_nullable_to_non_nullable
as int,replyingTo: freezed == replyingTo ? _self.replyingTo : replyingTo // ignore: cast_nullable_to_non_nullable
as MessageQuote?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as KtList<MediaDraft>,preparingMedia: null == preparingMedia ? _self.preparingMedia : preparingMedia // ignore: cast_nullable_to_non_nullable
as bool,mediaFailureOption: null == mediaFailureOption ? _self.mediaFailureOption : mediaFailureOption // ignore: cast_nullable_to_non_nullable
as Option<MediaFailure>,outgoing: null == outgoing ? _self.outgoing : outgoing // ignore: cast_nullable_to_non_nullable
as KtList<OutgoingMessage>,discardsRefused: null == discardsRefused ? _self.discardsRefused : discardsRefused // ignore: cast_nullable_to_non_nullable
as int,editing: freezed == editing ? _self.editing : editing // ignore: cast_nullable_to_non_nullable
as Message?,savingEdit: null == savingEdit ? _self.savingEdit : savingEdit // ignore: cast_nullable_to_non_nullable
as bool,lastEditFailure: freezed == lastEditFailure ? _self.lastEditFailure : lastEditFailure // ignore: cast_nullable_to_non_nullable
as MessageFailure?,editFailures: null == editFailures ? _self.editFailures : editFailures // ignore: cast_nullable_to_non_nullable
as int,lastEdited: freezed == lastEdited ? _self.lastEdited : lastEdited // ignore: cast_nullable_to_non_nullable
as Message?,
  ));
}

/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get editing {
    if (_self.editing == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.editing!, (value) {
    return _then(_self.copyWith(editing: value));
  });
}/// Create a copy of ChatBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get lastEdited {
    if (_self.lastEdited == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.lastEdited!, (value) {
    return _then(_self.copyWith(lastEdited: value));
  });
}
}

// dart format on
