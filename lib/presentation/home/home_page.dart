import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/application/user/user_form/user_form_bloc.dart';
import 'package:routes_chat/presentation/home/profile/profile_page.dart';
import 'package:routes_chat/presentation/home/search/search_page.dart';
import 'package:routes_chat/presentation/sign_in/sign_in_page.dart';

import '../../application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import '../../application/chats/outbox/message_outbox.dart';
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
  final friendRequestActorBloc = getIt<FriendRequestActorBloc>();
  final userFormBloc = getIt<UserFormBloc>();
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Signed in, with the keys unlocked: messages left on their way when the
    // app closed are sent now.
    unawaited(_outbox.resume());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back on the screen: messages waiting to try again go now.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _outbox.retryNow();
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
