import 'dart:async';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
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
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/injection.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'chat_timeline.dart';
import 'package:routes_chat/presentation/core/theme/app_colors.dart';
import 'messages_skeleton.dart';

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

/// The chat with [otherUser]: its messages, a page at a time, and a search
/// over them. [chat] is null until the first message is sent.
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
    _searchDebounce?.cancel();
    _highlightTimer?.cancel();
    super.dispose();
  }

  MessagesWatcherBloc? get _messages =>
      widget.chat == null ? null : context.read<MessagesWatcherBloc>();

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

  /// Leaves the search and scrolls the chat to [message], highlighted for a
  /// moment. The search already loaded every page up to it.
  void _showInChat(Message message) {
    final id = message.id.getOrCrash();
    _closeSearch();
    _highlightTimer?.cancel();
    setState(() => _highlightedMessageId = id);
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlightedMessageId = null);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpTo(id));
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
    return PopScope(
      // Back leaves the search first, then the chat.
      canPop: !_searchOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Scaffold(
        appBar: _searchOpen ? _searchBar() : _titleBar(canSearch: chat != null),
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
            // Hidden, not removed, so a half-typed message survives a search.
            Offstage(
              offstage: _searchOpen,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _ChatBar(chat: chat, otherUser: widget.otherUser),
                ],
              ),
            ),
          ],
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
    return BlocConsumer<MessagesWatcherBloc, MessagesWatcherState>(
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
          previous.reachedStart != current.reachedStart,
      builder: (context, state) => switch (state.status) {
        MessagesStatus.initial ||
        MessagesStatus.loading => const MessagesSkeleton(),
        MessagesStatus.failure when state.messages.isEmpty() => const Center(
          child: Text('Messages could not be loaded'),
        ),
        _ => _messagesView(chat, state),
      },
    );
  }

  Widget _messagesView(Chat chat, MessagesWatcherState state) {
    final items = _timeline(chat, state);
    return SuperListView.builder(
      controller: _scrollController,
      listController: _listController,
      // Newest at the bottom. An older page is added at the far end, so the
      // messages in view do not move when it arrives.
      reverse: true,
      itemCount: items.length + (state.loadingOlder ? 1 : 0),
      itemBuilder: (context, index) => index < items.length
          ? _row(items[items.length - 1 - index])
          : const MessagesSkeleton.older(),
    );
  }

  Widget _row(ChatTimelineItem item) {
    final otherUser = widget.otherUser;
    return switch (item) {
      MessageItem(:final message) => _MessageBubble(
        message: message,
        sent: message.senderId.getOrCrash() != otherUser.id.getOrCrash(),
        highlighted: message.id.getOrCrash() == _highlightedMessageId,
      ),
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
        text: reset.userId.getOrCrash() == otherUser.id.getOrCrash()
            ? '${otherUser.username.getOrCrash()} reset their encryption '
                  'keys.'
            : 'You reset your encryption keys.',
      ),
    };
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

  const _ChatBar({required this.chat, required this.otherUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBarBloc>(),
      child: BlocConsumer<ChatBarBloc, ChatBarState>(
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
            previousState.showErrorMessages != currentState.showErrorMessages,
        builder: (context, state) {
          final chat = this.chat;
          final scheme = Theme.of(context).colorScheme;
          return MessageBar(
            messageBarColor: scheme.surfaceContainer,
            sendButtonColor: scheme.primary,
            textFieldTextStyle: TextStyle(color: scheme.onSurface),
            messageBarHintStyle: TextStyle(
              fontSize: 16,
              color: scheme.onSurfaceVariant,
            ),
            messageBarStyle: MessageBarStyle(
              fillColor: scheme.surfaceContainerHighest,
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide(color: scheme.primary),
              ),
            ),
            messageBarHintText: 'Start typing...',
            onTextChanged: (value) => BlocProvider.of<ChatBarBloc>(
              context,
            ).add(ChatBarEvent.messageContentChanged(value)),
            onSend: (value) {
              if (chat == null) {
                BlocProvider.of<ChatBarBloc>(context).add(
                  ChatBarEvent.newChatCreated([otherUser.id].toImmutableList()),
                );
              } else if (value.isNotEmpty) {
                BlocProvider.of<ChatBarBloc>(
                  context,
                ).add(ChatBarEvent.newMessageAddedToChatWithId(value, chat.id));
              }
            },
          );
        },
      ),
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
/// The message bar clears its text as soon as Send is tapped, so this is the
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

/// A message in the chat, on the side of whoever sent it.
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool sent;

  /// Whether the chat was just scrolled to it, from a search.
  final bool highlighted;

  const _MessageBubble({
    required this.message,
    required this.sent,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: highlighted ? colors.messageHighlight : Colors.transparent,
      child: BubbleSpecialThree(
        color: sent ? colors.sentBubble : colors.receivedBubble,
        textStyle: TextStyle(
          color: sent ? colors.onSentBubble : colors.onReceivedBubble,
        ),
        tail: false,
        text: message.content.getOrCrash(),
        isSender: sent,
      ),
    );
  }
}
