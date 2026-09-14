import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';

import '../../core/value_objects.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required UniqueId id,
    required UniqueId senderId,
    required KtList<ImageUrl> imageUrls,
    required KtList<UniqueId> reactions,
    required Content content,
    required UniqueId repliedMessageId,
    required DateTime? lastUpdatedAt,
    required bool isEdited,

    /// Whether this device could decrypt the message. When it could not, for
    /// example because it was sent before the user reset their keys,
    /// [content] is only a placeholder.
    @Default(true) bool isReadable,

    /// The generation of the chat's key it was encrypted under. It grows each
    /// time a participant resets their keys.
    @Default(1) int keyGeneration,
  }) = _Message;
}
