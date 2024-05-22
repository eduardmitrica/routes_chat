import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

part 'chat.freezed.dart';

@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required UniqueId id,
    required ParticipantsList participantsList,
}) = _Chat;
}