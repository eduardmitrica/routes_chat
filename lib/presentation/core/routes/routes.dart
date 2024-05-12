import 'package:routes_chat/presentation/home/chats/friends_search_page/friends_search_page.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_page.dart';
import 'package:routes_chat/presentation/home/home_page.dart';
import 'package:routes_chat/presentation/register/register_with_google_page.dart';

import '../../register/register_page.dart';
import '../../sign_in/sign_in_page.dart';
import '../../splash/splash_page.dart';

final routes = {
  '/': (_) => const SplashPage(),
  '/auth/register': (_) => const RegisterPage(),
  '/auth/register/register-with-google': (_) => const RegisterWithGooglePage(),
  '/auth/sign-in': (_) => const SignInPage(),
  '/home': (_) => const HomePage(),
  '/home/chats/friends-search-page': (_) => const FriendsSearchPage(),
  '/home/chats/chat': (_) => const ChatPage(),
};
