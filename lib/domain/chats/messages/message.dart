import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';

import '../../core/value_objects.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  const factory Message(
      {required UniqueId id,
      required UniqueId senderId,
      required KtList<ImageUrl> imageUrls,
      required KtList<UniqueId> reactions,
      required Content content,
      required UniqueId repliedMessageId,
      required DateTime? lastUpdatedAt,
      required bool isEdited}) = _Message;
}
