import 'dart:async';

import 'package:dartz/dartz.dart' show Either, left, right;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_activity/chat_activity_bloc.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/domain/core/composite_id.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'package:routes_chat/application/chats/messages/message_actor/message_actor_bloc.dart';
import 'package:routes_chat/domain/chats/messages/message_changes.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart'
    show EditTimeExpired;
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_links.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/injection.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../open_chat.dart';
import 'activity_label.dart';
import 'chat_timeline.dart';
import 'emoji_picker_sheet.dart';
import 'message_reactions.dart';
import 'reaction_bar.dart';
import 'media_failure_message.dart';
import 'message_bubble.dart';
import 'message_composer.dart';
import 'messages_skeleton.dart';
import 'open_link_dialog.dart';
import 'outgoing_message_bubble.dart';
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

/// The chat with [otherUser]: its messages, a page at a time, a search over
/// them, and replies to them, with the user's messages on their way below.
/// [chat] is null until the first message arrives.
class _ChatView extends StatefulWidget {
  final Chat? chat;
  final User otherUser;

  const _ChatView({required this.chat, required this.otherUser});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> with WidgetsBindingObserver {
  /// How close to the oldest loaded message, in pixels, the next page loads.
  static const _loadOlderWithin = 800.0;

  final _scrollController = ScrollController();
  final _listController = ListController();
  final _searchField = TextEditingController();
  final _composerFocus = FocusNode();

  /// Here rather than with the composer: replies start from the messages,
  /// and the messages on their way show among them.
  final _chatBar = getIt<ChatBarBloc>();
  final _media = getIt<IMediaRepository>();
  final _activity = getIt<ChatActivityBloc>();
  final _actor = getIt<MessageActorBloc>();
  UniqueId? _chatId;

  Timer? _searchDebounce;
  Timer? _highlightTimer;
  var _searchOpen = false;
  String? _highlightedMessageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_loadOlderIfNearTop);
    // Brings back what the user wrote here and did not send.
    _chatBar.add(ChatBarEvent.started(widget.otherUser.id));
    final myId = getIt<ICurrentUserSession>().current?.id;
    if (myId != null) {
      final chatId = compositeId([
        UniqueId.fromUniqueString(myId),
        widget.otherUser.id,
      ]);
      _chatId = chatId;
      OpenChat.opened(chatId);
      _activity.add(
        ChatActivityEvent.started(
          chatId: chatId,
          otherUserId: widget.otherUser.id,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_loadOlderIfNearTop)
      ..dispose();
    _listController.dispose();
    _searchField.dispose();
    _composerFocus.dispose();
    _searchDebounce?.cancel();
    _highlightTimer?.cancel();
    unawaited(_activity.close());
    unawaited(_actor.close());
    if (_chatId case final chatId?) OpenChat.closed(chatId);
    super.dispose();
  }

  MessagesWatcherBloc? get _messages =>
      widget.chat == null ? null : context.read<MessagesWatcherBloc>();

  /// Back on screen with the chat open: what it shows is read now.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reportShown();
  }

  /// Says the chat shows messages up to the newest loaded, while the app is
  /// on screen. A message that arrives with the app in the background is not
  /// read until the user comes back.
  void _reportShown([MessagesWatcherState? state]) {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) return;
    final newest = (state ?? _messages?.state)?.messages.lastOrNull();
    if (newest != null) {
      _activity.add(ChatActivityEvent.messagesShown(newest));
    }
  }

  bool _isFromOtherUser(UniqueId senderId) =>
      senderId.getOrCrash() == widget.otherUser.id.getOrCrash();

  String? get _myId => getIt<ICurrentUserSession>().current?.id;

  void _tell(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

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

  void _startEdit(Message message) {
    _chatBar.add(ChatBarEvent.editStarted(message));
    _composerFocus.requestFocus();
  }

  void _react(Message message, String emoji) {
    final chat = widget.chat;
    if (chat == null) return;
    _actor.add(
      MessageActorEvent.reactionPicked(
        chatId: chat.id,
        message: message,
        emoji: emoji,
      ),
    );
  }

  Future<void> _pickReaction(Message message) async {
    final emoji = await pickEmoji(context);
    if (emoji != null && mounted) _react(message, emoji);
  }

  /// Asks first: deleting a message cannot be undone.
  Future<void> _confirmDelete(Message message) async {
    final chat = widget.chat;
    if (chat == null) return;
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Delete for everyone?'),
          content: Text(
            'The message will be deleted for you and for '
            '${widget.otherUser.username.getOrCrash()}, with its photos and '
            'reactions. This can\'t be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: AppTheme.destructiveButton(scheme),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (delete == true && mounted) {
      _actor.add(
        MessageActorEvent.deleteRequested(chatId: chat.id, message: message),
      );
    }
  }

  /// Who reacted to [message] with what. The user can take theirs back here.
  Future<void> _showReactions(Message message) async {
    final myId = _myId;
    final chat = widget.chat;
    if (myId == null || chat == null) return;
    bool isMine(MessageReaction reaction) =>
        reaction.userId.getOrCrash() == myId;
    // The user's own first.
    final reactions = [
      ...message.reactions.iter.where(isMine),
      ...message.reactions.iter.where((reaction) => !isMine(reaction)),
    ];
    final remove = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Reactions', style: textTheme.titleMedium),
                ),
              ),
              for (final reaction in reactions)
                if (isMine(reaction))
                  ListTile(
                    leading: Text(
                      reaction.emoji,
                      style: textTheme.headlineSmall,
                    ),
                    title: const Text('You'),
                    subtitle: const Text('Tap to remove'),
                    onTap: () => Navigator.of(context).pop(true),
                  )
                else
                  ListTile(
                    leading: Text(
                      reaction.emoji,
                      style: textTheme.headlineSmall,
                    ),
                    title: Text(widget.otherUser.username.getOrCrash()),
                  ),
            ],
          ),
        );
      },
    );
    if (remove == true && mounted) {
      _actor.add(
        MessageActorEvent.reactionRemoved(chatId: chat.id, message: message),
      );
    }
  }

  Future<void> _showMessageActions(Message message) async {
    final myId = _myId;
    if (message.isDeleted || myId == null) return;
    final text = message.content.getOrCrash();
    final attachments = message.attachments;
    // A few at most: the sheet is for this message, not a list of links.
    final links = {
      for (final part in splitLinks(text))
        if (part.link != null) part.text,
    }.take(3);
    final myReaction = message.reactions
        .firstOrNull((reaction) => reaction.userId.getOrCrash() == myId)
        ?.emoji;
    // Emojis sent since the chat opened count too.
    _actor.add(const MessageActorEvent.quickEmojisRequested());
    // Each item returns what to do once the sheet has closed.
    final action = await showModalBottomSheet<VoidCallback>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.canBeReactedTo) ...[
              BlocBuilder<MessageActorBloc, MessageActorState>(
                bloc: _actor,
                buildWhen: (previous, current) =>
                    previous.quickEmojis != current.quickEmojis,
                builder: (context, state) => ReactionBar(
                  favourites: state.quickEmojis,
                  current: myReaction,
                  onPicked: (emoji) =>
                      Navigator.of(context).pop(() => _react(message, emoji)),
                  onMore: () =>
                      Navigator.of(context).pop(() => _pickReaction(message)),
                ),
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Reply'),
              onTap: () =>
                  Navigator.of(context).pop(() => _startReply(message)),
            ),
            if (message.canBeEditedBy(myId, DateTime.now()))
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () =>
                    Navigator.of(context).pop(() => _startEdit(message)),
              ),
            if (text.trim().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy text'),
                onTap: () => Navigator.of(
                  context,
                ).pop(() => _copy(text, 'Message copied')),
              ),
            if (attachments.isNotEmpty())
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: Text(_saveLabel(attachments)),
                onTap: () =>
                    Navigator.of(context).pop(() => _saveAll(attachments)),
              ),
            for (final link in links)
              ListTile(
                leading: const Icon(Icons.link_rounded),
                title: const Text('Copy link'),
                subtitle: Text(
                  link,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () =>
                    Navigator.of(context).pop(() => _copy(link, 'Link copied')),
              ),
            if (message.canBeDeletedBy(myId))
              Builder(
                builder: (context) {
                  final error = Theme.of(context).colorScheme.error;
                  return ListTile(
                    leading: Icon(Icons.delete_outline_rounded, color: error),
                    title: Text(
                      'Delete for everyone',
                      style: TextStyle(color: error),
                    ),
                    onTap: () => Navigator.of(
                      context,
                    ).pop(() => _confirmDelete(message)),
                  );
                },
              ),
          ],
        ),
      ),
    );
    if (mounted) action?.call();
  }

  static String _saveLabel(KtList<MessageAttachment> attachments) =>
      attachments.size > 1
      ? 'Save all ${attachments.size}'
      : attachments.first().kind == AttachmentKind.gif
      ? 'Save GIF'
      : 'Save photo';

  /// Adds [attachments] to the phone's photos, one after another, and says
  /// how it went.
  Future<void> _saveAll(KtList<MessageAttachment> attachments) async {
    final chat = widget.chat;
    if (chat == null) return;
    final messenger = ScaffoldMessenger.of(context);
    MediaFailure? failure;
    var saved = 0;
    for (final attachment in attachments.iter) {
      (await _media.saveToPhotos(
        chat.id,
        attachment,
      )).fold<void>((problem) => failure ??= problem, (_) => saved++);
      // Without permission, the rest would fail the same way.
      if (failure is PhotoAccessDenied) break;
    }
    final problem = failure;
    final kinds = attachments.iter.map((attachment) => attachment.kind);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            problem == null
                ? '${describeAttachments(kinds)} saved to your photos'
                : saved == 0
                ? mediaFailureMessage(problem)
                : '$saved of ${attachments.size} saved. '
                      '${mediaFailureMessage(problem)}',
          ),
        ),
      );
  }

  Future<void> _copy(String text, String confirmation) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(confirmation)));
  }

  /// What can be done with a message on its way: try again now, copy its
  /// text, or give up sending it.
  Future<void> _showOutgoingActions(OutgoingMessage entry) async {
    final text = entry.message.content.getOrCrash();
    final action = await showModalBottomSheet<VoidCallback>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (entry.status != OutgoingStatus.sending)
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Try again now'),
                onTap: () => Navigator.of(context).pop(
                  () => _chatBar.add(ChatBarEvent.retryRequested(entry.id)),
                ),
              ),
            if (text.trim().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy text'),
                onTap: () => Navigator.of(
                  context,
                ).pop(() => _copy(text, 'Message copied')),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Delete message'),
              subtitle: const Text('It won\'t be sent'),
              onTap: () => Navigator.of(context).pop(
                () => _chatBar.add(ChatBarEvent.discardRequested(entry.id)),
              ),
            ),
          ],
        ),
      ),
    );
    if (mounted) action?.call();
  }

  /// A photo of a message on its way, from the phone.
  Future<Either<MediaFailure, Uint8List>> _loadOutgoing(
    OutgoingMessage entry,
    MessageAttachment attachment,
  ) async {
    final draft = entry.media.firstOrNull((draft) => draft.id == attachment.id);
    if (draft == null) return left(const MediaUnavailable());
    // Once the message arrives, its photo shows without downloading it.
    _media.remember(entry.chatId, draft.id, draft.bytes);
    return right(draft.bytes);
  }

  /// Asks first, then opens [link]: a web page in a browser tab over the
  /// app, an email address in the mail app.
  ///
  /// The tab is the browser's own (Custom Tabs on Android, Safari View
  /// Controller on iOS), not a web view inside the app. The page keeps the
  /// browser's protections, such as Safe Browsing, and the app cannot see what
  /// is typed into it. Closing the tab returns to the chat.
  Future<void> _openLink(Uri link) async {
    if (!await confirmOpenLink(context, link) || !mounted) return;
    bool opened;
    try {
      opened = link.scheme == 'mailto'
          ? await launchUrl(link, mode: LaunchMode.externalApplication)
          : await launchUrl(link, mode: LaunchMode.inAppBrowserView) ||
                // Without a browser that supports tabs, the browser itself.
                await launchUrl(link, mode: LaunchMode.externalApplication);
    } on PlatformException {
      opened = false;
    }
    if (opened || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('No app on this phone can open that link'),
        ),
      );
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
    // The messages on their way are below the rest.
    final outgoing = _stillOutgoing(
      _chatBar.state.outgoing,
      messages.state.messages,
    );
    _listController.jumpToItem(
      index: outgoing.length + items.length - 1 - itemIndex,
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

  /// The messages on their way that are not among [messages] yet, so one
  /// that just arrived shows once.
  static List<OutgoingMessage> _stillOutgoing(
    KtList<OutgoingMessage> outgoing,
    KtList<Message> messages,
  ) {
    final arrived = {
      for (final message in messages.iter) message.id.getOrCrash(),
    };
    return [
      for (final entry in outgoing.iter)
        if (!arrived.contains(entry.id.getOrCrash())) entry,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    return BlocProvider(
      create: (_) => _chatBar,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatBarBloc, ChatBarState>(
            bloc: _chatBar,
            listenWhen: (previous, current) =>
                previous.editFailures != current.editFailures,
            listener: (context, state) => _tell(switch (state.lastEditFailure) {
              EditTimeExpired() =>
                'Messages can be edited for ${messageEditWindow.inMinutes} '
                    'minutes after they are sent.',
              _ =>
                'Your edit couldn\'t be saved. Check your connection and try '
                    'again.',
            }),
          ),
          // An edit or a deletion shows at once, even on an older page, which
          // does not update by itself.
          BlocListener<ChatBarBloc, ChatBarState>(
            bloc: _chatBar,
            listenWhen: (previous, current) =>
                current.lastEdited != null &&
                previous.lastEdited != current.lastEdited,
            listener: (context, state) => _messages?.add(
              MessagesWatcherEvent.messageChanged(state.lastEdited!),
            ),
          ),
          BlocListener<MessageActorBloc, MessageActorState>(
            bloc: _actor,
            listenWhen: (previous, current) =>
                current.lastDeleted != null &&
                previous.lastDeleted != current.lastDeleted,
            listener: (context, state) {
              final deleted = state.lastDeleted!;
              _messages?.add(MessagesWatcherEvent.messageChanged(deleted));
              if (_chatBar.state.editing?.id == deleted.id) {
                _chatBar.add(const ChatBarEvent.editCancelled());
              }
            },
          ),
          BlocListener<MessageActorBloc, MessageActorState>(
            bloc: _actor,
            listenWhen: (previous, current) =>
                current.lastProblem != null &&
                previous.lastProblem != current.lastProblem,
            listener: (context, state) => _tell(switch (state.lastProblem!) {
              MessageProblem(action: MessageAction.delete) =>
                'The message couldn\'t be deleted. Check your connection and '
                    'try again.',
              MessageProblem(action: MessageAction.react) =>
                'Your reaction couldn\'t be saved. Check your connection and '
                    'try again.',
            }),
          ),
        ],
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
                      ? _firstMessages()
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
      ),
    );
  }

  PreferredSizeWidget _titleBar({required bool canSearch}) => AppBar(
    leading: IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded),
    ),
    title: _ChatTitle(
      name: widget.otherUser.username.getOrCrash(),
      activity: _activity,
    ),
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

  /// A chat not started yet: nothing, or the first messages on their way.
  Widget _firstMessages() => BlocBuilder<ChatBarBloc, ChatBarState>(
    bloc: _chatBar,
    buildWhen: (previous, current) => previous.outgoing != current.outgoing,
    builder: (context, state) {
      if (state.outgoing.isEmpty()) {
        return const Center(child: Text('You have no messages with this user'));
      }
      final outgoing = state.outgoing.asList();
      return ListView.builder(
        reverse: true,
        itemCount: outgoing.length,
        itemBuilder: (context, index) =>
            _outgoingRow(outgoing[outgoing.length - 1 - index]),
      );
    },
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
          _reportShown(state);
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

  Widget _messagesView(Chat chat, MessagesWatcherState state) =>
      BlocBuilder<ChatBarBloc, ChatBarState>(
        bloc: _chatBar,
        buildWhen: (previous, current) => previous.outgoing != current.outgoing,
        builder: (context, chatBar) {
          final items = _timeline(chat, state);
          final outgoing = _stillOutgoing(chatBar.outgoing, state.messages);
          // "Seen" goes under the newest message when the user sent it, and
          // nothing of theirs is still on its way below it.
          final newest = state.messages.lastOrNull();
          final seenCandidateId =
              outgoing.isEmpty &&
                  newest != null &&
                  !newest.isDeleted &&
                  !_isFromOtherUser(newest.senderId)
              ? newest.id.getOrCrash()
              : null;
          return Stack(
            fit: StackFit.expand,
            children: [
              SuperListView.builder(
                controller: _scrollController,
                listController: _listController,
                // Newest at the bottom, the messages on their way below the
                // rest. An older page is added at the far end, so the
                // messages in view do not move when it arrives.
                reverse: true,
                itemCount:
                    outgoing.length +
                    items.length +
                    (state.loadingOlder ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < outgoing.length) {
                    return _outgoingRow(outgoing[outgoing.length - 1 - index]);
                  }
                  final itemIndex = index - outgoing.length;
                  return itemIndex < items.length
                      ? _row(
                          items[items.length - 1 - itemIndex],
                          seenCandidateId: seenCandidateId,
                        )
                      : const MessagesSkeleton.older();
                },
              ),
              // Older pages load above, out of sight, while finding the
              // message a reply quotes.
              if (state.revealingMessage)
                const Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        },
      );

  Widget _row(ChatTimelineItem item, {String? seenCandidateId}) {
    final otherUser = widget.otherUser;
    return switch (item) {
      MessageItem(:final message) => _messageRow(
        message,
        seenCandidate: message.id.getOrCrash() == seenCandidateId,
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
        text: _isFromOtherUser(reset.userId)
            ? '${otherUser.username.getOrCrash()} reset their encryption '
                  'keys.'
            : 'You reset your encryption keys.',
      ),
    };
  }

  String? _quoteAuthor(Message message) {
    final quote = message.replyTo;
    if (quote == null) return null;
    return _isFromOtherUser(quote.senderId)
        ? widget.otherUser.username.getOrCrash()
        : 'You';
  }

  /// [message] in the chat, with "Seen" under it once the other person has
  /// read it, when it is the [seenCandidate].
  Widget _messageRow(Message message, {bool seenCandidate = false}) {
    final sentAt = message.lastUpdatedAt;
    // Always a column, so a message that stops being the newest keeps its
    // state, such as which photo a carousel shows.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _bubbleRow(message),
        if (seenCandidate && sentAt != null)
          _SeenLabel(activity: _activity, sentAt: sentAt),
      ],
    );
  }

  Widget _bubbleRow(Message message) {
    final id = message.id.getOrCrash();
    final quote = message.replyTo;
    final bubble = MessageBubble(
      message: message,
      sent: !_isFromOtherUser(message.senderId),
      highlighted: id == _highlightedMessageId,
      quoteAuthor: _quoteAuthor(message),
      onQuoteTap: quote == null ? null : () => _revealMessage(quote.messageId),
      onLongPress: message.isDeleted
          ? null
          : () => _showMessageActions(message),
      onOpenLink: _openLink,
      loadAttachment: (attachment) => _media.load(widget.chat!.id, attachment),
      saveAttachment: (attachment) =>
          _media.saveToPhotos(widget.chat!.id, attachment),
      reactions: message.reactions.isEmpty()
          ? null
          : MessageReactions(
              reactions: message.reactions,
              onTap: () => _showReactions(message),
            ),
    );
    // Nothing is left of it to reply to.
    if (message.isDeleted) {
      return KeyedSubtree(key: ValueKey(id), child: bubble);
    }
    return Semantics(
      // Swiping is not available to everyone; this is the same as a swipe.
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Reply'): () => _startReply(message),
      },
      child: SwipeToReply(
        // Its own state per message, such as which photo a carousel shows.
        key: ValueKey(id),
        onReply: () => _startReply(message),
        // Faded while it is being deleted.
        child: BlocBuilder<MessageActorBloc, MessageActorState>(
          bloc: _actor,
          buildWhen: (previous, current) =>
              previous.deleting.contains(id) != current.deleting.contains(id),
          builder: (context, state) => AnimatedOpacity(
            opacity: state.deleting.contains(id) ? 0.5 : 1,
            duration: const Duration(milliseconds: 200),
            child: bubble,
          ),
        ),
      ),
    );
  }

  Widget _outgoingRow(OutgoingMessage entry) => OutgoingMessageBubble(
    key: ValueKey('outgoing ${entry.id.getOrCrash()}'),
    entry: entry,
    quoteAuthor: _quoteAuthor(entry.message),
    loadAttachment: (attachment) => _loadOutgoing(entry, attachment),
    onOptions: () => _showOutgoingActions(entry),
  );
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
                summaryOf(
                  message.content.getOrCrash(),
                  message.attachments.iter.map((file) => file.kind),
                ),
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

/// Where the user writes. The first message sent starts the chat when [chat]
/// is null.
class _ChatBar extends StatelessWidget {
  final Chat? chat;
  final User otherUser;
  final FocusNode focusNode;

  const _ChatBar({
    required this.chat,
    required this.otherUser,
    required this.focusNode,
  });

  static void _tell(BuildContext context, String text) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBarBloc, ChatBarState>(
          listenWhen: (previous, current) =>
              previous.mediaFailureOption != current.mediaFailureOption,
          listener: (context, state) => state.mediaFailureOption.fold<void>(
            () {},
            (failure) => _tell(context, mediaFailureMessage(failure)),
          ),
        ),
        BlocListener<ChatBarBloc, ChatBarState>(
          listenWhen: (previous, current) =>
              previous.discardsRefused != current.discardsRefused,
          listener: (context, _) => _tell(
            context,
            'That message is being sent right now. Try again in a moment.',
          ),
        ),
      ],
      child: BlocBuilder<ChatBarBloc, ChatBarState>(
        buildWhen: (previous, current) =>
            previous.replyingTo != current.replyingTo ||
            previous.media != current.media ||
            previous.preparingMedia != current.preparingMedia ||
            previous.textRevision != current.textRevision ||
            previous.editing != current.editing ||
            previous.savingEdit != current.savingEdit,
        builder: (context, state) {
          final chatBar = BlocProvider.of<ChatBarBloc>(context);
          final replyingTo = state.replyingTo;
          final editing = state.editing;
          return MessageComposer(
            focusNode: focusNode,
            text: state.text,
            textRevision: state.textRevision,
            replyingTo: replyingTo,
            media: state.media.asList(),
            preparingMedia: state.preparingMedia,
            editing: editing != null,
            savingEdit: state.savingEdit,
            canSaveEmpty: editing?.attachments.isNotEmpty() ?? false,
            onCancelEdit: () => chatBar.add(const ChatBarEvent.editCancelled()),
            onAddMedia: () => _pickMedia(context, chatBar),
            onRemoveMedia: (id) => chatBar.add(ChatBarEvent.mediaRemoved(id)),
            replyingToName:
                replyingTo != null &&
                    replyingTo.senderId.getOrCrash() ==
                        otherUser.id.getOrCrash()
                ? otherUser.username.getOrCrash()
                : 'yourself',
            onCancelReply: () =>
                chatBar.add(const ChatBarEvent.replyCancelled()),
            onChanged: (value) =>
                chatBar.add(ChatBarEvent.messageContentChanged(value)),
            onSend: (value) =>
                chatBar.add(ChatBarEvent.sent(value, chatExists: chat != null)),
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

/// Asks where the photos come from, then hands the chosen files to [chatBar].
Future<void> _pickMedia(BuildContext context, ChatBarBloc chatBar) async {
  final messenger = ScaffoldMessenger.of(context);
  final room = MediaLimits.maxPerMessage - chatBar.state.media.size;
  if (room <= 0) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'A message can hold up to ${MediaLimits.maxPerMessage} photos and '
            'GIFs.',
          ),
        ),
      );
    return;
  }
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Photos and GIFs'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
        ],
      ),
    ),
  );
  if (source == null) return;
  final picker = ImagePicker();
  try {
    // The files are re-encoded before sending, so their metadata is not
    // needed, and asking for it needs more permissions on iOS.
    final files = source == ImageSource.camera
        ? [
            ?await picker.pickImage(
              source: ImageSource.camera,
              requestFullMetadata: false,
            ),
          ]
        : await picker.pickMultiImage(limit: room, requestFullMetadata: false);
    if (files.isNotEmpty) {
      chatBar.add(
        ChatBarEvent.mediaPicked([for (final file in files) file.path]),
      );
    }
  } on PlatformException {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Photos could not be opened. Check the app\'s permissions.',
          ),
        ),
      );
  }
}

/// The other person's name, and under it whether they are typing, online, or
/// when they were last seen.
class _ChatTitle extends StatelessWidget {
  final String name;
  final ChatActivityBloc activity;

  const _ChatTitle({required this.name, required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ChatActivityBloc, ChatActivityState>(
      bloc: activity,
      builder: (context, state) {
        final label = activityLabel(state, DateTime.now());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (label != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: state.typing
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// "Seen" under the user's newest message, once the other person has read
/// it, as far as both share read receipts.
class _SeenLabel extends StatelessWidget {
  final ChatActivityBloc activity;

  /// When the message was sent.
  final DateTime sentAt;

  const _SeenLabel({required this.activity, required this.sentAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ChatActivityBloc, ChatActivityState>(
      bloc: activity,
      buildWhen: (previous, current) => previous.seenUpTo != current.seenUpTo,
      builder: (context, state) {
        final seenUpTo = state.seenUpTo;
        final seen = seenUpTo != null && !seenUpTo.isBefore(sentAt);
        return Semantics(
          liveRegion: true,
          child: seen
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 18, 4),
                  child: Text(
                    'Seen',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
