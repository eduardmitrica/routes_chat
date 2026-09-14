import 'package:equatable/equatable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/key_reset.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';

/// One row of a chat's message list.
sealed class ChatTimelineItem extends Equatable {
  const ChatTimelineItem();
}

final class MessageItem extends ChatTimelineItem {
  final Message message;

  const MessageItem(this.message);

  @override
  List<Object?> get props => [message];
}

/// Messages in a row that this device cannot decrypt, shown as one line.
final class UnreadableMessagesItem extends ChatTimelineItem {
  final int count;

  const UnreadableMessagesItem(this.count);

  @override
  List<Object?> get props => [count];
}

/// A participant reset their encryption keys.
final class KeyResetItem extends ChatTimelineItem {
  final KeyReset reset;

  const KeyResetItem(this.reset);

  @override
  List<Object?> get props => [reset];
}

/// The rows of a chat: [messages] in order, with each run of unreadable ones
/// collapsed into one row, and each of [keyResets] before the first message
/// sent under its key generation, or at the end if none has been sent yet.
///
/// [messages] may be only the latest part of the chat. Unless they
/// [reachStart], a reset that would come before the first of them is left
/// out: it may belong anywhere in the part not loaded yet.
List<ChatTimelineItem> chatTimeline(
  KtList<Message> messages,
  KtList<KeyReset> keyResets, {
  bool reachStart = true,
}) {
  final pendingResets = keyResets.asList().toList()
    ..sort((a, b) => a.keyGeneration.compareTo(b.keyGeneration));
  final items = <ChatTimelineItem>[];
  var unreadable = 0;

  void addUnreadable() {
    if (unreadable > 0) {
      items.add(UnreadableMessagesItem(unreadable));
      unreadable = 0;
    }
  }

  var placedMessage = false;
  for (final message in messages.iter) {
    while (pendingResets.isNotEmpty &&
        pendingResets.first.keyGeneration <= message.keyGeneration) {
      addUnreadable();
      final reset = pendingResets.removeAt(0);
      if (placedMessage || reachStart) {
        items.add(KeyResetItem(reset));
      }
    }
    placedMessage = true;
    if (message.isReadable) {
      addUnreadable();
      items.add(MessageItem(message));
    } else {
      unreadable++;
    }
  }
  addUnreadable();
  if (placedMessage || reachStart) {
    items.addAll(pendingResets.map(KeyResetItem.new));
  }
  return items;
}
