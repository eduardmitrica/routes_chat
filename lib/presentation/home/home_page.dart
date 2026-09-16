import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/presence/presence_reporter.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/notifications/app_notification.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/domain/shared/user/user_repository_interface.dart';
import 'package:routes_chat/presentation/home/chats/open_chat.dart';
import 'package:routes_chat/presentation/home/chats/requests_page.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_page.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/application/user/user_form/user_form_bloc.dart';
import 'package:routes_chat/presentation/home/profile/profile_page.dart';
import 'package:routes_chat/presentation/home/search/search_page.dart';
import 'package:routes_chat/presentation/sign_in/sign_in_page.dart';

import '../../application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import '../../application/chats/outbox/message_outbox.dart';
import '../../application/safety/block_list_bloc.dart';
import '../../application/chats/message_requests/message_requests_bloc.dart';
import '../../application/groups/groups_watcher_bloc.dart';
import '../../injection.dart';
import 'chats/chats_page.dart';
import 'friend_requests/friend_requests_page.dart';

class HomePage extends StatefulWidget {
  static const homePageRoute = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _outbox = getIt<MessageOutbox>();
  final _presence = getIt<PresenceReporter>();
  final _notifications = getIt<INotificationEvents>();
  StreamSubscription<AppNotification>? _opened;
  StreamSubscription<AppNotification>? _received;
  Timer? _bannerTimer;
  final friendRequestActorBloc = getIt<FriendRequestActorBloc>();
  final userFormBloc = getIt<UserFormBloc>();
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Signed in, with the keys unlocked: messages left on their way when the
    // app closed are sent now.
    unawaited(_outbox.resume());
    // Who the user blocked, for every screen that keeps them out of sight.
    getIt<BlockListBloc>().add(const BlockListEvent.started());
    // What the user decided about chats from people who are not friends.
    getIt<MessageRequestsBloc>().add(const MessageRequestsEvent.started());
    // The groups the user is in; invitations from friends join by themselves.
    getIt<GroupsWatcherBloc>().add(const GroupsWatcherEvent.started());
    WidgetsBinding.instance.addObserver(this);
    _presence.appResumed();
    _opened = _notifications.opened.listen(_open);
    _received = _notifications.received.listen(_showBanner);
    // Started by tapping a notification.
    unawaited(
      _notifications.openedAppFrom().then((notification) {
        if (notification != null && mounted) _open(notification);
      }),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_opened?.cancel());
    unawaited(_received?.cancel());
    _bannerTimer?.cancel();
    _presence.appPaused();
    super.dispose();
  }

  /// Back on the screen: messages waiting to try again go now, and friends
  /// see the user online. Off the screen, they see when the user left.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _outbox.retryNow();
        _presence.appResumed();
      case AppLifecycleState.paused ||
          AppLifecycleState.hidden ||
          AppLifecycleState.detached:
        _presence.appPaused();
      case AppLifecycleState.inactive:
        // A dialog or the notification shade; still on screen.
        break;
    }
  }

  /// Shows what a tapped notification is about.
  void _open(AppNotification notification) {
    switch (notification) {
      case MessageNotification(:final chatId):
        unawaited(_openChat(chatId));
      case MessageRequestNotification():
        Navigator.of(
          context,
        ).popUntil(ModalRoute.withName(HomePage.homePageRoute));
        setState(() => _currentTabIndex = 0);
        unawaited(Navigator.of(context).push(RequestsPage.route()));
      case FriendRequestNotification():
        Navigator.of(
          context,
        ).popUntil(ModalRoute.withName(HomePage.homePageRoute));
        setState(() => _currentTabIndex = 3);
    }
  }

  Future<void> _openChat(UniqueId chatId) async {
    if (OpenChat.id == chatId.getOrCrash()) return;
    final myId = getIt<ICurrentUserSession>().current?.id;
    final otherId = chatId
        .getOrCrash()
        .split('_')
        .where((id) => id != myId)
        .firstOrNull;
    if (myId == null || otherId == null) return;
    User? otherUser;
    try {
      final found = await getIt<IUserRepository>()
          .watchUsersWithIds(KtList.of(UniqueId.fromUniqueString(otherId)))
          .first
          .timeout(const Duration(seconds: 15));
      otherUser = found.fold((_) => null, (users) => users.firstOrNull());
    } on Exception catch (exception) {
      debugPrint('Chat not opened: ${exception.runtimeType}');
    }
    if (otherUser == null || !mounted) return;
    final navigator = Navigator.of(context)
      ..popUntil(ModalRoute.withName(HomePage.homePageRoute));
    setState(() => _currentTabIndex = 0);
    unawaited(
      navigator.push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<ChatsWatcherBloc>()
                  ..add(const ChatsWatcherEvent.watchAllStarted()),
            child: const ChatPage(),
          ),
          settings: RouteSettings(arguments: otherUser),
        ),
      ),
    );
  }

  /// A notification that arrived while the app is on screen, which the phone
  /// does not show: a banner, unless it is about the chat already open.
  void _showBanner(AppNotification notification) {
    if (notification case MessageNotification(
      :final chatId,
    ) when OpenChat.id == chatId.getOrCrash()) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final (icon, text) = switch (notification) {
      MessageNotification(:final senderName) => (
        Icons.chat_bubble_outline_rounded,
        '$senderName sent you a message',
      ),
      MessageRequestNotification(:final senderName) => (
        Icons.mark_email_unread_outlined,
        '$senderName sent you a message request',
      ),
      FriendRequestNotification(:final senderName) => (
        Icons.person_add_alt_outlined,
        '$senderName sent you a friend request',
      ),
    };
    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          leading: Icon(icon),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('Dismiss'),
            ),
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
                _open(notification);
              },
              child: const Text('Open'),
            ),
          ],
        ),
      );
    _bannerTimer?.cancel();
    // Long enough to read it and reach for Open.
    _bannerTimer = Timer(
      const Duration(seconds: 10),
      messenger.hideCurrentMaterialBanner,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(
            context,
          ).pushReplacementNamed(SignInPage.signInPageRoute);
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => friendRequestActorBloc),
          BlocProvider(create: (_) => userFormBloc),
        ],
        child: Scaffold(
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentTabIndex,
            onDestinationSelected: (selectedTabIndex) {
              setState(() {
                final previousTabIndex = _currentTabIndex;
                _currentTabIndex = selectedTabIndex;
                if (previousTabIndex != selectedTabIndex &&
                    previousTabIndex == 1) {
                  friendRequestActorBloc.add(
                    const FriendRequestActorEvent.rolledBackChanges(),
                  );
                }
                if (previousTabIndex != selectedTabIndex &&
                    previousTabIndex == 2) {
                  userFormBloc.add(const UserFormEvent.rolledBackChanges());
                }
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Chats',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications_rounded),
                label: 'Friend requests',
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentTabIndex,
            children: const [
              ChatsPage(),
              SearchPage(),
              ProfilePage(),
              FriendRequestsPage(),
            ],
          ),
        ),
      ),
    );
  }
}
