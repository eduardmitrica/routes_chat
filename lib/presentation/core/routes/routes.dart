import 'package:routes_chat/presentation/chats/chats_page.dart';
import 'package:routes_chat/presentation/home/home_page.dart';
import 'package:routes_chat/presentation/profile/profile_page.dart';
import 'package:routes_chat/presentation/register/register_with_google_page.dart';
import 'package:routes_chat/presentation/search/search_page.dart';

import '../../register/register_page.dart';
import '../../sign_in/sign_in_page.dart';
import '../../splash/splash_page.dart';

final routes = {
  '/': (_) => const SplashPage(),
  '/auth/register': (_) => const RegisterPage(),
  '/auth/register/register-with-google': (_) => const RegisterWithGooglePage(),
  '/auth/sign-in': (_) => const SignInPage(),
  '/home': (_) => const HomePage(),
  '/home/chats': (_) => const ChatsPage(),
  '/home/search': (_) => const SearchPage(),
  '/home/profile': (_) => const ProfilePage(),
};
