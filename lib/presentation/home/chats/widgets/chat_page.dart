import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart' as chat_failure;
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart'
    as message_failure;
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/injection.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'chat_timeline.dart';
import 'message_bubble.dart';
import 'message_composer.dart';
import 'messages_skeleton.dart';
import 'swipe_to_reply.dart';

class ChatPage extends StatelessWidget {
  static const chatPageRoute = '/home/chats/chat';

  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    return BlocBuilder<ChatsWatcherBloc, ChatsWatcherState>(
      builder: (context, state) {
        if (state is! ChatsWatcherLoadSuccess) {
          return const Center(child: CircularProgressIndicator());
        }
        final chat = state.chats.find(
          (chat) => chat.participantsList
              .getOrCrash()
              .map((participant) => participant.value1.getOrCrash())
              .contains(user.id.getOrCrash()),
        );
        if (chat == null) {
          return _ChatView(chat: null, otherUser: user);
        }
        return BlocProvider(
          key: ValueKey(chat.id.getOrCrash()),
          create: (_) =>
              getIt<MessagesWatcherBloc>()
                ..add(MessagesWatcherEvent.watchStarted(chat.id)),
          child: _ChatView(chat: chat, otherUser: user),
        );
      },
    );
  }
}

enum _MessageAction { reply, copy }

/// The chat with [otherUser]: its messages, a page at a time, a search over
/// them, and replies to them. [chat] is null until the first message is sent.
class _ChatView extends StatefulWidget {
  final Chat? chat;
  final User otherUser;

  const _ChatView({required this.chat, required this.otherUser});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  /// How close to the oldest loaded message, in pixels, the next page loads.
  static const _loadOlderWithin = 800.0;

  final _scrollController = ScrollController();
  final _listController = ListController();
  final _searchField = TextEditingController();
  final _composerFocus = FocusNode();

  /// Here rather than with the composer: replies start from the messages.
  final _chatBar = getIt<ChatBarBloc>();

  Timer? _searchDebounce;
  Timer? _highlightTimer;
  var _searchOpen = false;
  String? _highlightedMessageId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadOlderIfNearTop);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadOlderIfNearTop)
      ..dispose();
    _listController.dispose();
    _searchField.dispose();
    _composerFocus.dispose();
    _searchDebounce?.cancel();
    _highlightTimer?.cancel();
    super.dispose();
  }

  MessagesWatcherBloc? get _messages =>
      widget.chat == null ? null : context.read<MessagesWatcherBloc>();

  bool _isFromOtherUser(UniqueId senderId) =>
      senderId.getOrCrash() == widget.otherUser.id.getOrCrash();

  /// The list is reversed, newest at the bottom, so the oldest loaded
  /// messages are at the far end of the scroll extent.
  void _loadOlderIfNearTop() {
    final messages = _messages;
    if (messages == null || !_scrollController.hasClients) return;
    final state = messages.state;
    if (state.loadingOlder || state.reachedStart) return;
    // Also true when the loaded messages do not fill the screen, so a chat
    // of short messages still loads until it can scroll.
    if (_scrollController.position.extentAfter < _loadOlderWithin) {
      messages.add(const MessagesWatcherEvent.olderRequested());
    }
  }

  void _openSearch() => setState(() => _searchOpen = true);

  void _closeSearch() {
    _searchDebounce?.cancel();
    _searchField.clear();
    _messages?.add(const MessagesWatcherEvent.searchClosed());
    setState(() => _searchOpen = false);
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    // Each new query may load older pages, so wait for a pause in typing.
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _messages?.add(MessagesWatcherEvent.searchChanged(query)),
    );
  }

  /// Leaves the search and scrolls the chat to [message]. The search already
  /// loaded every page up to it.
  void _showInChat(Message message) {
    _closeSearch();
    _highlightAndJump(message.id.getOrCrash());
  }

  void _startReply(Message message) {
    _chatBar.add(ChatBarEvent.replyStarted(message));
    _composerFocus.requestFocus();
  }

  Future<void> _showMessageActions(Message message) async {
    final action = await showModalBottomSheet<_MessageAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Reply'),
              onTap: () => Navigator.of(context).pop(_MessageAction.reply),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy text'),
              onTap: () => Navigator.of(context).pop(_MessageAction.copy),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _MessageAction.reply:
        _startReply(message);
      case _MessageAction.copy:
        await Clipboard.setData(
          ClipboardData(text: message.content.getOrCrash()),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Message copied')));
      case null:
        break;
    }
  }

  /// Asks for the message a reply quotes, loading older pages if it is not
  /// loaded yet. [_onRevealed] scrolls to it.
  void _revealMessage(UniqueId messageId) =>
      _messages?.add(MessagesWatcherEvent.messageRevealRequested(messageId));

  void _onRevealed(MessageReveal reveal) {
    final message = reveal.message;
    final problem = switch (message) {
      null => 'The original message is not in this chat.',
      Message(isReadable: false) =>
        'The original message can\'t be read on this device.',
      _ => null,
    };
    if (message == null || problem != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(problem!)));
      return;
    }
    _highlightAndJump(message.id.getOrCrash());
  }

  /// Scrolls the chat to [messageId], highlighted for a moment.
  void _highlightAndJump(String messageId) {
    _highlightTimer?.cancel();
    setState(() => _highlightedMessageId = messageId);
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlightedMessageId = null);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpTo(messageId));
  }

  void _jumpTo(String messageId) {
    final chat = widget.chat;
    final messages = _messages;
    if (chat == null ||
        messages == null ||
        !mounted ||
        !_listController.isAttached ||
        !_scrollController.hasClients) {
      return;
    }
    final items = _timeline(chat, messages.state);
    final itemIndex = items.indexWhere(
      (item) =>
          item is MessageItem && item.message.id.getOrCrash() == messageId,
    );
    if (itemIndex < 0) return;
    _listController.jumpToItem(
      index: items.length - 1 - itemIndex,
      scrollController: _scrollController,
      alignment: 0.5,
    );
  }

  static List<ChatTimelineItem> _timeline(
    Chat chat,
    MessagesWatcherState state,
  ) => chatTimeline(
    state.messages,
    chat.keyResets,
    reachStart: state.reachedStart,
  );

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    return BlocProvider(
      create: (_) => _chatBar,
      child: PopScope(
        // Back leaves the search first, then the chat.
        canPop: !_searchOpen,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _closeSearch();
        },
        child: Scaffold(
          appBar: _searchOpen
              ? _searchBar()
              : _titleBar(canSearch: chat != null),
          body: Column(
            children: [
              Expanded(
                child: chat == null
                    ? const Center(
                        child: Text('You have no messages with this user'),
                      )
                    // The messages stay underneath the search, so closing it
                    // returns to where the chat was scrolled.
                    : IndexedStack(
                        index: _searchOpen ? 1 : 0,
                        sizing: StackFit.expand,
                        children: [
                          _messageList(chat),
                          if (_searchOpen)
                            _SearchResults(
                              otherUser: widget.otherUser,
                              onSelected: _showInChat,
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
              ),
              // Hidden, not removed, so a half-typed message survives a
              // search.
              Offstage(
                offstage: _searchOpen,
                child: _ChatBar(
                  chat: chat,
                  otherUser: widget.otherUser,
                  focusNode: _composerFocus,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _titleBar({required bool canSearch}) => AppBar(
    leading: IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded),
    ),
    title: Text(widget.otherUser.username.getOrCrash()),
    actions: [
      if (canSearch)
        IconButton(
          tooltip: 'Search this chat',
          onPressed: _openSearch,
          icon: const Icon(Icons.search),
        ),
      Padding(
        padding: const EdgeInsets.only(left: 4, right: 12),
        child: CircleAvatar(
          foregroundImage: NetworkImage(widget.otherUser.imageUrl.getOrCrash()),
        ),
      ),
    ],
  );

  PreferredSizeWidget _searchBar() => AppBar(
    leading: IconButton(
      tooltip: 'Close search',
      onPressed: _closeSearch,
      icon: const Icon(Icons.arrow_back_rounded),
    ),
    title: TextField(
      controller: _searchField,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search this chat',
        border: InputBorder.none,
      ),
      onChanged: _onSearchChanged,
    ),
  );

  Widget _messageList(Chat chat) {
    return BlocListener<MessagesWatcherBloc, MessagesWatcherState>(
      listenWhen: (previous, current) =>
          current.lastReveal != null &&
          previous.lastReveal != current.lastReveal,
      listener: (context, state) => _onRevealed(state.lastReveal!),
      child: BlocConsumer<MessagesWatcherBloc, MessagesWatcherState>(
        listenWhen: (previous, current) =>
            previous.messages != current.messages ||
            previous.failureOption != current.failureOption,
        listener: (context, state) {
          if (state.status == MessagesStatus.loaded &&
              state.failureOption.isSome()) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Older messages could not be loaded'),
                ),
              );
          }
          // A new page may still not fill the screen.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _loadOlderIfNearTop(),
          );
        },
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.messages != current.messages ||
            previous.loadingOlder != current.loadingOlder ||
            previous.reachedStart != current.reachedStart ||
            previous.revealingMessage != current.revealingMessage,
        builder: (context, state) => switch (state.status) {
          MessagesStatus.initial ||
          MessagesStatus.loading => const MessagesSkeleton(),
          MessagesStatus.failure when state.messages.isEmpty() => const Center(
            child: Text('Messages could not be loaded'),
          ),
          _ => _messagesView(chat, state),
        },
      ),
    );
  }

  Widget _messagesView(Chat chat, MessagesWatcherState state) {
    final items = _timeline(chat, state);
    return Stack(
      fit: StackFit.expand,
      children: [
        SuperListView.builder(
          controller: _scrollController,
          listController: _listController,
          // Newest at the bottom. An older page is added at the far end, so
          // the messages in view do not move when it arrives.
          reverse: true,
          itemCount: items.length + (state.loadingOlder ? 1 : 0),
          itemBuilder: (context, index) => index < items.length
              ? _row(items[items.length - 1 - index])
              : const MessagesSkeleton.older(),
        ),
        // Older pages load above, out of sight, while finding the message a
        // reply quotes.
        if (state.revealingMessage)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _row(ChatTimelineItem item) {
    final otherUser = widget.otherUser;
    return switch (item) {
      MessageItem(:final message) => _messageRow(message),
      UnreadableMessagesItem(:final count) => _ChatNotice(
        icon: Icons.lock_outline,
        text: count == 1
            ? '1 earlier message can\'t be read here. It was encrypted with '
                  'keys that have since been reset.'
            : '$count earlier messages can\'t be read here. They were '
                  'encrypted with keys that have since been reset.',
      ),
      KeyResetItem(:final reset) => _ChatNotice(
        icon: Icons.key_outlined,
        text: _isFromOtherUser(reset.userId)
            ? '${otherUser.username.getOrCrash()} reset their encryption '
                  'keys.'
            : 'You reset your encryption keys.',
      ),
    };
  }

  Widget _messageRow(Message message) {
    final quote = message.replyTo;
    return Semantics(
      // Swiping is not available to everyone; this is the same as a swipe.
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Reply'): () => _startReply(message),
      },
      child: SwipeToReply(
        onReply: () => _startReply(message),
        child: MessageBubble(
          message: message,
          sent: !_isFromOtherUser(message.senderId),
          highlighted: message.id.getOrCrash() == _highlightedMessageId,
          quoteAuthor: quote == null
              ? null
              : _isFromOtherUser(quote.senderId)
              ? widget.otherUser.username.getOrCrash()
              : 'You',
          onQuoteTap: quote == null
              ? null
              : () => _revealMessage(quote.messageId),
          onLongPress: () => _showMessageActions(message),
        ),
      ),
    );
  }
}

/// The messages that match the search, newest first. The search looks
/// through older pages too, which this says while it is still loading them.
class _SearchResults extends StatelessWidget {
  final User otherUser;
  final ValueChanged<Message> onSelected;

  const _SearchResults({required this.otherUser, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(color: Theme.of(context).colorScheme.outline);
    return BlocBuilder<MessagesWatcherBloc, MessagesWatcherState>(
      builder: (context, state) {
        if (state.searchQuery.trim().isEmpty) {
          return Center(
            child: Text('Search the messages in this chat.', style: muted),
          );
        }
        final results = state.searchResults;
        return ListView.builder(
          itemCount: results.size + 1,
          itemBuilder: (context, index) {
            if (index == results.size) {
              if (state.searchingOlder) {
                return const ListTile(
                  leading: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  title: Text('Searching older messages…'),
                );
              }
              return ListTile(
                title: Text(
                  !state.reachedStart
                      ? 'Older messages could not be searched.'
                      : results.isEmpty()
                      ? 'No messages found.'
                      : 'That is the whole chat.',
                  style: muted,
                ),
              );
            }
            final message = results[index];
            final fromOtherUser =
                message.senderId.getOrCrash() == otherUser.id.getOrCrash();
            return ListTile(
              title: Text(
                fromOtherUser ? otherUser.username.getOrCrash() : 'You',
              ),
              subtitle: Text(
                message.content.getOrCrash(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(_sentAt(message.lastUpdatedAt), style: muted),
              onTap: () => onSelected(message),
            );
          },
        );
      },
    );
  }

  /// The time for a message sent today, otherwise the date.
  static String _sentAt(DateTime? time) {
    if (time == null) return '';
    final local = time.toLocal();
    final now = DateTime.now();
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    final today =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    return today
        ? '${twoDigits(local.hour)}:${twoDigits(local.minute)}'
        : '${twoDigits(local.day)}.${twoDigits(local.month)}.${local.year}';
  }
}

/// Where the user writes. It starts the chat when [chat] is null.
class _ChatBar extends StatelessWidget {
  final Chat? chat;
  final User otherUser;
  final FocusNode focusNode;

  const _ChatBar({
    required this.chat,
    required this.otherUser,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBarBloc, ChatBarState>(
      listenWhen: (previousState, currentState) =>
          previousState.chatCreationFailureOrSuccessOption !=
              currentState.chatCreationFailureOrSuccessOption ||
          previousState.messageSendFailureOrSuccessOption !=
              currentState.messageSendFailureOrSuccessOption,
      listener: (context, state) {
        final failureMessage = _sendFailureMessage(state);
        if (failureMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failureMessage)));
        }
      },
      buildWhen: (previousState, currentState) =>
          previousState.replyingTo != currentState.replyingTo,
      builder: (context, state) {
        final chat = this.chat;
        final chatBar = BlocProvider.of<ChatBarBloc>(context);
        final replyingTo = state.replyingTo;
        return MessageComposer(
          focusNode: focusNode,
          replyingTo: replyingTo,
          replyingToName:
              replyingTo != null &&
                  replyingTo.senderId.getOrCrash() == otherUser.id.getOrCrash()
              ? otherUser.username.getOrCrash()
              : 'yourself',
          onCancelReply: () => chatBar.add(const ChatBarEvent.replyCancelled()),
          onChanged: (value) =>
              chatBar.add(ChatBarEvent.messageContentChanged(value)),
          onSend: (value) {
            if (chat == null) {
              chatBar.add(
                ChatBarEvent.newChatCreated([otherUser.id].toImmutableList()),
              );
            } else {
              chatBar.add(
                ChatBarEvent.newMessageAddedToChatWithId(value, chat.id),
              );
            }
          },
        );
      },
    );
  }
}

class _ChatNotice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ChatNotice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// The snackbar text for the chat bar's latest failed send, or null when the
/// latest send succeeded or nothing has been sent since the last keystroke.
///
/// The composer clears its text as soon as Send is tapped, so this is the
/// only sign a message did not go through.
String? _sendFailureMessage(ChatBarState state) {
  final chat_failure.ChatFailure? chatFailure = state
      .chatCreationFailureOrSuccessOption
      .fold(
        () => null,
        (either) => either.fold((failure) => failure, (_) => null),
      );
  if (chatFailure != null) {
    return switch (chatFailure) {
      chat_failure.InsufficientPermissions() =>
        'You are not allowed to start this chat',
      chat_failure.Unexpected() => 'The chat could not be started, try again',
    };
  }

  final message_failure.MessageFailure? messageFailure = state
      .messageSendFailureOrSuccessOption
      .fold(
        () => null,
        (either) => either.fold((failure) => failure, (_) => null),
      );
  return switch (messageFailure) {
    null => null,
    message_failure.InsufficientPermissions() =>
      'You are not allowed to send messages in this chat',
    message_failure.Unexpected() => 'The message could not be sent, try again',
  };
}
