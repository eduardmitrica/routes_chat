import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart' show Either, left, right;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/messages/message_actor/message_actor_bloc.dart';
import 'package:routes_chat/application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'package:routes_chat/application/groups/group_activity_bloc.dart';
import 'package:routes_chat/application/groups/groups_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_changes.dart';
import 'package:routes_chat/domain/chats/messages/voice_recorder_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart'
    show EditTimeExpired;
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/groups/group_activity.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/injection.dart';

import '../chats/open_chat.dart';
import '../chats/widgets/chat_timeline.dart';
import '../chats/widgets/media_failure_message.dart';
import '../chats/widgets/message_actions.dart';
import '../chats/widgets/message_bubble.dart';
import '../chats/widgets/message_reactions.dart';
import '../chats/widgets/message_composer.dart';
import '../chats/widgets/messages_skeleton.dart';
import '../chats/widgets/outgoing_message_bubble.dart';
import '../chats/widgets/swipe_to_reply.dart';
import 'group_info_page.dart';
import 'widgets/group_avatar.dart';
import 'package:routes_chat/domain/groups/group_event.dart';

/// A group's messages and the box to write in.
///
/// Messages with photos, replies and reactions, which their senders edit and
/// delete, who is typing, and who has seen the user's newest message: as in
/// a chat, for many people.
class GroupChatPage extends StatefulWidget {
  static const groupChatPageRoute = '/home/groups/chat';

  final UniqueId groupId;

  const GroupChatPage({super.key, required this.groupId});

  static Route<void> route(UniqueId groupId) => MaterialPageRoute(
    settings: const RouteSettings(name: groupChatPageRoute),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<MessagesWatcherBloc>()
                ..add(MessagesWatcherEvent.watchStarted(groupId)),
        ),
        BlocProvider(create: (_) => getIt<UsersWatcherBloc>()),
      ],
      child: GroupChatPage(groupId: groupId),
    ),
  );

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage>
    with WidgetsBindingObserver {
  /// How close to the oldest loaded message, in pixels, the next page loads.
  static const _loadOlderWithin = 800.0;

  final _chatBar = getIt<ChatBarBloc>();
  final _groups = getIt<GroupsWatcherBloc>();
  final _activity = getIt<GroupActivityBloc>();
  final _actor = getIt<MessageActorBloc>();
  final _media = getIt<IMediaRepository>();
  final _scrollController = ScrollController();
  final _composerFocus = FocusNode();
  final String? _myId = getIt<ICurrentUserSession>().current?.id;

  /// The members whose names are being looked up, so a new member asks again.
  var _lookedUp = const <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatBar.add(ChatBarEvent.startedInGroup(widget.groupId));
    _activity.add(GroupActivityEvent.started(widget.groupId));
    OpenChat.opened(widget.groupId);
    _scrollController.addListener(_loadOlderIfNearTop);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OpenChat.closed(widget.groupId);
    unawaited(_activity.close());
    unawaited(_actor.close());
    _scrollController
      ..removeListener(_loadOlderIfNearTop)
      ..dispose();
    _composerFocus.dispose();
    unawaited(_chatBar.close());
    super.dispose();
  }

  /// Back on screen with the group open: what it shows is read now.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reportShown();
  }

  /// Says the group shows messages up to the newest loaded, while the app is
  /// on screen.
  void _reportShown([MessagesWatcherState? state]) {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) return;
    final newest = (state ?? context.read<MessagesWatcherBloc>().state).messages
        .lastOrNull();
    if (newest != null) _activity.add(GroupActivityEvent.messagesShown(newest));
  }

  void _loadOlderIfNearTop() {
    if (!_scrollController.hasClients) return;
    final messages = context.read<MessagesWatcherBloc>();
    final state = messages.state;
    if (state.loadingOlder || state.reachedStart) return;
    if (_scrollController.position.extentAfter < _loadOlderWithin) {
      messages.add(const MessagesWatcherEvent.olderRequested());
    }
  }

  Group? _group(GroupsWatcherState state) => state.joined.find(
    (group) => group.id.getOrCrash() == widget.groupId.getOrCrash(),
  );

  /// Looks up the names of everyone in [group], and of everyone the loaded
  /// messages name, such as someone who has left since; again when someone
  /// new appears.
  void _lookUpNames(Group group) {
    final everyone = {
      ...group.everyone,
      for (final message
          in context.read<MessagesWatcherBloc>().state.messages.iter) ...[
        message.senderId.getOrCrash(),
        ?message.event?.subjectId,
      ],
    };
    if (everyone.difference(_lookedUp).isEmpty) return;
    _lookedUp = {..._lookedUp, ...everyone};
    context.read<UsersWatcherBloc>().add(
      UsersWatcherEvent.watchStarted(
        everyone.map(UniqueId.fromUniqueString).toImmutableList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupsWatcherBloc, GroupsWatcherState>(
      bloc: _groups,
      listener: (context, state) {
        final group = _group(state);
        if (group != null) _lookUpNames(group);
      },
      builder: (context, groups) {
        final group = _group(groups);
        if (group != null) _lookUpNames(group);
        return BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
          builder: (context, users) {
            final names = <String, String>{
              if (users is UsersWatcherLoadSuccess)
                for (final user in users.users.iter)
                  user.id.getOrCrash(): user.username.getOrCrash(),
            };
            // Taken out, or left from another phone: nothing more to read or
            // write here.
            final gone = groups.loaded && group == null;
            return MultiBlocListener(
              listeners: _listeners(),
              child: Scaffold(
                appBar: _titleBar(group, names),
                body: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: gone
                            ? const Center(
                                child: _Notice(
                                  'You\'re no longer in this group.',
                                ),
                              )
                            : _messages(names),
                      ),
                      if (!gone)
                        _Composer(
                          chatBar: _chatBar,
                          focusNode: _composerFocus,
                          nameOf: (id) =>
                              id == _myId ? 'yourself' : names[id] ?? 'someone',
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<BlocListener> _listeners() => [
    BlocListener<ChatBarBloc, ChatBarState>(
      bloc: _chatBar,
      listenWhen: (previous, current) =>
          previous.mediaFailureOption != current.mediaFailureOption,
      listener: (context, state) => state.mediaFailureOption.fold<void>(
        () {},
        (failure) => tellInSnackBar(context, mediaFailureMessage(failure)),
      ),
    ),
    BlocListener<ChatBarBloc, ChatBarState>(
      bloc: _chatBar,
      listenWhen: (previous, current) =>
          previous.discardsRefused != current.discardsRefused,
      listener: (context, _) => tellInSnackBar(
        context,
        'That message is being sent right now. Try again in a moment.',
      ),
    ),
    BlocListener<ChatBarBloc, ChatBarState>(
      bloc: _chatBar,
      listenWhen: (previous, current) =>
          previous.editFailures != current.editFailures,
      listener: (context, state) =>
          tellInSnackBar(context, switch (state.lastEditFailure) {
            EditTimeExpired() =>
              'Messages can be edited for ${messageEditWindow.inMinutes} '
                  'minutes after they are sent.',
            _ =>
              'Your edit couldn\'t be saved. Check your connection and try '
                  'again.',
          }),
    ),
    // An edit or a deletion shows at once, even on an older page, which does
    // not update by itself.
    BlocListener<ChatBarBloc, ChatBarState>(
      bloc: _chatBar,
      listenWhen: (previous, current) =>
          current.lastEdited != null &&
          previous.lastEdited != current.lastEdited,
      listener: (context, state) => context.read<MessagesWatcherBloc>().add(
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
        context.read<MessagesWatcherBloc>().add(
          MessagesWatcherEvent.messageChanged(deleted),
        );
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
      listener: (context, state) =>
          tellInSnackBar(context, switch (state.lastProblem!) {
            MessageProblem(action: MessageAction.delete) =>
              'The message couldn\'t be deleted. Check your connection and '
                  'try again.',
            MessageProblem(action: MessageAction.react) =>
              'Your reaction couldn\'t be saved. Check your connection and '
                  'try again.',
          }),
    ),
  ];

  PreferredSizeWidget _titleBar(Group? group, Map<String, String> names) {
    final theme = Theme.of(context);
    final others = [
      // The invited count too: they were chosen for the group.
      for (final id in group?.everyone ?? const <String>[])
        if (id != _myId) names[id] ?? '…',
    ];
    final invited = group?.invitedIds.length ?? 0;
    final members = group?.memberIds.length ?? 0;
    void openInfo() => unawaited(
      Navigator.of(context).push(GroupInfoPage.route(widget.groupId)),
    );
    return AppBar(
      actions: [
        if (group != null)
          IconButton(
            tooltip: 'Group info',
            onPressed: openInfo,
            icon: const Icon(Icons.info_outline_rounded),
          ),
        const SizedBox(width: 4),
      ],
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: group == null ? null : openInfo,
        child: Row(
          children: [
            GroupAvatar(group: group, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    group == null ? 'Group' : group.titleWith(others),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (group != null)
                    BlocBuilder<GroupActivityBloc, GroupActivityState>(
                      bloc: _activity,
                      buildWhen: (previous, current) =>
                          previous.typingIds != current.typingIds,
                      builder: (context, activity) {
                        final typing = describeGroupTyping([
                          for (final id in activity.typingIds)
                            if (group.memberIds.contains(id))
                              names[id] ?? 'Someone',
                        ]);
                        return Semantics(
                          liveRegion: true,
                          child: Text(
                            typing ??
                                [
                                  members == 1
                                      ? '1 member'
                                      : '$members members',
                                  if (invited > 0) '$invited invited',
                                ].join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: typing != null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messages(Map<String, String> names) {
    return BlocConsumer<MessagesWatcherBloc, MessagesWatcherState>(
      listenWhen: (previous, current) => previous.messages != current.messages,
      listener: (context, state) {
        _reportShown(state);
        if (_group(_groups.state) case final group?) _lookUpNames(group);
        // A new page may still not fill the screen.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _loadOlderIfNearTop(),
        );
      },
      builder: (context, state) => switch (state.status) {
        MessagesStatus.initial ||
        MessagesStatus.loading => const MessagesSkeleton(),
        MessagesStatus.failure when state.messages.isEmpty() => const Center(
          child: Text('Messages could not be loaded'),
        ),
        _ => BlocBuilder<ChatBarBloc, ChatBarState>(
          bloc: _chatBar,
          buildWhen: (previous, current) =>
              previous.outgoing != current.outgoing,
          builder: (context, chatBar) {
            final items = chatTimeline(
              state.messages,
              const KtList.empty(),
              reachStart: state.reachedStart,
            );
            final arrived = {
              for (final message in state.messages.iter)
                message.id.getOrCrash(),
            };
            final outgoing = [
              for (final entry in chatBar.outgoing.iter)
                if (!arrived.contains(entry.id.getOrCrash())) entry,
            ];
            if (items.isEmpty && outgoing.isEmpty) {
              return const _NoMessagesYet();
            }
            // "Seen by" goes under the newest message when the user sent
            // it, and nothing of theirs is still on its way below it.
            final newest = state.messages.lastOrNull(
              (message) => message.event == null,
            );
            final seenCandidateId =
                outgoing.isEmpty &&
                    newest != null &&
                    !newest.isDeleted &&
                    newest.senderId.getOrCrash() == _myId
                ? newest.id.getOrCrash()
                : null;
            return ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  outgoing.length + items.length + (state.loadingOlder ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < outgoing.length) {
                  return _outgoingRow(
                    outgoing[outgoing.length - 1 - index],
                    names,
                  );
                }
                final itemIndex = items.length - 1 - (index - outgoing.length);
                if (itemIndex < 0) return const MessagesSkeleton.older();
                final item = items[itemIndex];
                final previous = itemIndex > 0 ? items[itemIndex - 1] : null;
                return _row(
                  item,
                  previous,
                  names,
                  seenCandidateId: seenCandidateId,
                );
              },
            );
          },
        ),
      },
    );
  }

  Widget _row(
    ChatTimelineItem item,
    ChatTimelineItem? previous,
    Map<String, String> names, {
    String? seenCandidateId,
  }) => switch (item) {
    MessageItem(:final message) when message.event != null => _Notice(
      describeGroupEvent(
        message.event!,
        nameOf: (id) => names[id] ?? 'Someone',
        myId: _myId ?? '',
      ),
    ),
    MessageItem(:final message)
        when message.id.getOrCrash() == seenCandidateId &&
            message.lastUpdatedAt != null =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _messageRow(message, showName: false, names: names),
          _SeenByLabel(
            activity: _activity,
            groups: _groups,
            groupId: widget.groupId,
            sentAt: message.lastUpdatedAt!,
            nameOf: (id) => names[id] ?? 'Someone',
          ),
        ],
      ),
    MessageItem(:final message) => _messageRow(
      message,
      // A name over the first of each run of someone else's messages; an
      // event between two starts a new run.
      showName:
          message.senderId.getOrCrash() != _myId &&
          !(previous is MessageItem &&
              previous.message.event == null &&
              previous.message.senderId == message.senderId),
      names: names,
    ),
    // From before the user was added and not shared with them, or sent
    // under keys that were reset since.
    UnreadableMessagesItem(:final count) => _Notice(
      count == 1
          ? '1 earlier message isn\'t readable for you.'
          : '$count earlier messages aren\'t readable for you.',
    ),
    KeyResetItem() => const SizedBox.shrink(),
  };

  String? _quoteAuthor(Message message, Map<String, String> names) {
    final quote = message.replyTo;
    if (quote == null) return null;
    final id = quote.senderId.getOrCrash();
    return id == _myId ? 'You' : names[id] ?? 'Someone';
  }

  Widget _messageRow(
    Message message, {
    required bool showName,
    required Map<String, String> names,
  }) {
    final senderId = message.senderId.getOrCrash();
    final sent = senderId == _myId;
    final id = message.id.getOrCrash();
    final bubble = MessageBubble(
      message: message,
      sent: sent,
      quoteAuthor: _quoteAuthor(message, names),
      onLongPress: message.isDeleted
          ? null
          : () => unawaited(_showMessageActions(message, names)),
      onOpenLink: (link) => openMessageLink(context, link),
      loadAttachment: (attachment) => _media.load(widget.groupId, attachment),
      loadVoice: (attachment) =>
          _media.playableFile(widget.groupId, attachment),
      releaseVoice: _media.forgetPlayable,
      saveAttachment: (attachment) =>
          _media.saveToPhotos(widget.groupId, attachment),
      reactions: message.reactions.isEmpty()
          ? null
          : MessageReactions(
              reactions: message.reactions,
              onTap: () => unawaited(_showReactions(message, names)),
            ),
    );
    final theme = Theme.of(context);
    final row = Column(
      crossAxisAlignment: sent
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showName)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
            child: Text(
              names[senderId] ?? '…',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        // Faded while it is being deleted.
        BlocBuilder<MessageActorBloc, MessageActorState>(
          bloc: _actor,
          buildWhen: (previous, current) =>
              previous.deleting.contains(id) != current.deleting.contains(id),
          builder: (context, state) => AnimatedOpacity(
            opacity: state.deleting.contains(id) ? 0.5 : 1,
            duration: const Duration(milliseconds: 200),
            child: bubble,
          ),
        ),
      ],
    );
    // Nothing is left of it to reply to.
    if (message.isDeleted) {
      return KeyedSubtree(key: ValueKey(message.id.getOrCrash()), child: row);
    }
    return Semantics(
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Reply'): () => _startReply(message),
      },
      child: SwipeToReply(
        key: ValueKey(message.id.getOrCrash()),
        onReply: () => _startReply(message),
        child: row,
      ),
    );
  }

  void _startReply(Message message) {
    _chatBar.add(ChatBarEvent.replyStarted(message));
    _composerFocus.requestFocus();
  }

  void _react(Message message, String emoji) => _actor.add(
    MessageActorEvent.reactionPicked(
      chatId: widget.groupId,
      message: message,
      emoji: emoji,
    ),
  );

  Future<void> _showMessageActions(
    Message message,
    Map<String, String> names,
  ) async {
    final myId = _myId;
    if (myId == null) return;
    await showMessageActions(
      context,
      message: message,
      myId: myId,
      actor: _actor,
      onReact: (emoji) => _react(message, emoji),
      onReply: () => _startReply(message),
      onEdit: () {
        _chatBar.add(ChatBarEvent.editStarted(message));
        _composerFocus.requestFocus();
      },
      onSaveAll: () => unawaited(
        saveAttachmentsToPhotos(
          context,
          media: _media,
          chatId: widget.groupId,
          attachments: message.attachments,
        ),
      ),
      onDelete: () => unawaited(_confirmDelete(message)),
    );
  }

  Future<void> _confirmDelete(Message message) async {
    final delete = await confirmDeleteForEveryone(
      context,
      whoElse: 'for everyone in the group',
    );
    if (delete && mounted) {
      _actor.add(
        MessageActorEvent.deleteRequested(
          chatId: widget.groupId,
          message: message,
        ),
      );
    }
  }

  /// Who reacted to [message] with what. The user can take theirs back here.
  Future<void> _showReactions(
    Message message,
    Map<String, String> names,
  ) async {
    final myId = _myId;
    if (myId == null) return;
    final remove = await showReactionsSheet(
      context,
      message: message,
      myId: myId,
      nameOf: (id) => names[id] ?? 'Someone',
    );
    if (remove && mounted) {
      _actor.add(
        MessageActorEvent.reactionRemoved(
          chatId: widget.groupId,
          message: message,
        ),
      );
    }
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

  Widget _outgoingRow(OutgoingMessage entry, Map<String, String> names) =>
      OutgoingMessageBubble(
        key: ValueKey('outgoing ${entry.id.getOrCrash()}'),
        entry: entry,
        quoteAuthor: _quoteAuthor(entry.message, names),
        loadAttachment: (attachment) => _loadOutgoing(entry, attachment),
        loadVoice: (attachment) async {
          await _loadOutgoing(entry, attachment);
          return _media.playableFile(entry.chatId, attachment);
        },
        releaseVoice: _media.forgetPlayable,
        onOptions: () => unawaited(
          showOutgoingActions(context, entry: entry, chatBar: _chatBar),
        ),
      );
}

class _Composer extends StatelessWidget {
  final ChatBarBloc chatBar;
  final FocusNode focusNode;
  final String Function(String userId) nameOf;

  const _Composer({
    required this.chatBar,
    required this.focusNode,
    required this.nameOf,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBarBloc, ChatBarState>(
      bloc: chatBar,
      buildWhen: (previous, current) =>
          previous.replyingTo != current.replyingTo ||
          previous.media != current.media ||
          previous.preparingMedia != current.preparingMedia ||
          previous.textRevision != current.textRevision ||
          previous.editing != current.editing ||
          previous.savingEdit != current.savingEdit,
      builder: (context, state) {
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
          onAddMedia: () => pickMedia(context, chatBar),
          onRemoveMedia: (id) => chatBar.add(ChatBarEvent.mediaRemoved(id)),
          replyingToName: replyingTo == null
              ? ''
              : nameOf(replyingTo.senderId.getOrCrash()),
          onCancelReply: () => chatBar.add(const ChatBarEvent.replyCancelled()),
          onChanged: (value) =>
              chatBar.add(ChatBarEvent.messageContentChanged(value)),
          // The group exists before anyone can write in it.
          onSend: (value) =>
              chatBar.add(ChatBarEvent.sent(value, chatExists: true)),
          voiceRecorder: () => getIt<IVoiceRecorder>(),
          onVoiceRecorded: (recording) => chatBar.add(
            ChatBarEvent.voiceRecorded(recording, chatExists: true),
          ),
          onVoiceFailure: (failure) =>
              tellInSnackBar(context, mediaFailureMessage(failure)),
        );
      },
    );
  }
}

class _NoMessagesYet extends StatelessWidget {
  const _NoMessagesYet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No messages yet. People you added join when they accept; your '
          'friends join straight away.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;

  const _Notice(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// "Seen by …" under the user's newest message, naming the members who have
/// read it, as far as the user shares read receipts.
class _SeenByLabel extends StatelessWidget {
  final GroupActivityBloc activity;
  final GroupsWatcherBloc groups;
  final UniqueId groupId;

  /// When the message was sent.
  final DateTime sentAt;
  final String Function(String userId) nameOf;

  const _SeenByLabel({
    required this.activity,
    required this.groups,
    required this.groupId,
    required this.sentAt,
    required this.nameOf,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<GroupActivityBloc, GroupActivityState>(
      bloc: activity,
      buildWhen: (previous, current) => previous.readUpTo != current.readUpTo,
      builder: (context, state) {
        final group = groups.state.joined.find(
          (group) => group.id.getOrCrash() == groupId.getOrCrash(),
        );
        // Someone who left since is no longer counted.
        final members = group?.memberIds ?? const <String>[];
        final seenBy = [
          for (final id in state.seenBy(sentAt))
            if (members.contains(id)) nameOf(id),
        ];
        final label = describeGroupSeen(
          seenBy,
          othersInGroup: members.length - 1,
        );
        return Semantics(
          liveRegion: true,
          child: label == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 18, 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
