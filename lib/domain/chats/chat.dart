import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import 'key_reset.dart';
import 'messages/message.dart';

part 'chat.freezed.dart';

@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required UniqueId id,
    required ParticipantsList participantsList,
    required Message lastMessage,

    /// Every time a participant reset their encryption keys, oldest first.
    @Default(KtList<KeyReset>.empty()) KtList<KeyReset> keyResets,
  }) = _Chat;
}
