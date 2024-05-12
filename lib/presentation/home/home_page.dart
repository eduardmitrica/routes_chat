import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/application/user/user_form/user_form_bloc.dart';
import 'package:routes_chat/presentation/home/profile/profile_page.dart';
import 'package:routes_chat/presentation/home/search/search_page.dart';
import 'package:routes_chat/presentation/sign_in/sign_in_page.dart';

import '../../application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import '../../injection.dart';
import 'chats/chats_page.dart';
import 'friend_requests/friend_requests_page.dart';

class HomePage extends StatefulWidget {
  static const homePageRoute = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final friendRequestActorBloc = getIt<FriendRequestActorBloc>();
  final userFormBloc = getIt<UserFormBloc>();
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        state.maybeMap(
            unauthenticated: (_) => Navigator.of(context)
                .pushReplacementNamed(SignInPage.signInPageRoute),
            orElse: () {});
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => friendRequestActorBloc),
          BlocProvider(create: (_) => userFormBloc),
        ],
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            fixedColor: Colors.black,
            currentIndex: _currentTabIndex,
            onTap: (selectedTabIndex) {
              setState(() {
                final previousTabIndex= _currentTabIndex;
                _currentTabIndex = selectedTabIndex;
                if (previousTabIndex != selectedTabIndex && previousTabIndex == 1) {
                  friendRequestActorBloc.add(const FriendRequestActorEvent.rolledBackChanges());
                }
                if (previousTabIndex != selectedTabIndex && previousTabIndex == 2) {
                  userFormBloc.add(const UserFormEvent.rolledBackChanges());
                }
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.deepPurpleAccent,
                  ),
                  label: 'Chats'),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search_rounded,
                  color: Colors.deepPurpleAccent,
                ),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    color: Colors.deepPurpleAccent,
                  ),
                  label: 'Profile'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.deepPurpleAccent,
                  ),
                  label: 'Friend requests'),
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
