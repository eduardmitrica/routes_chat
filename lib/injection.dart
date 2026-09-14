import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'application/authentication/authentication_bloc.dart';
import 'application/authentication/register_form/register_form_bloc.dart';
import 'application/authentication/sign_in_form/sign_in_form_bloc.dart';
import 'application/chats/chat_actor/chat_actor_bloc.dart';
import 'application/chats/chat_bar/chat_bar_bloc.dart';
import 'application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'application/chats/friends_watcher/friends_watcher_bloc.dart';
import 'application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import 'application/friend_requests/pending_friend_requests_watcher/pending_friend_requests_watcher_bloc.dart';
import 'application/friend_requests/received_friend_requests_watcher/received_friend_requests_watcher_bloc.dart';
import 'application/shared/picture_placeholder_fetcher/placeholder_fetcher_bloc.dart';
import 'application/shared/users_watcher/users_watcher_bloc.dart';
import 'application/user/user_form/user_form_bloc.dart';
import 'application/user/user_watcher/user_watcher_bloc.dart';
import 'domain/authentication/authentication_facade_interface.dart';
import 'domain/chats/chat_repository_interface.dart';
import 'domain/chats/messages/message_repository_interface.dart';
import 'domain/friend_requests/friend_requests_repository_interface.dart';
import 'domain/shared/user/current_user_session_interface.dart';
import 'domain/shared/user/user_repository_interface.dart';
import 'domain/shared/user/user_utils_interface.dart';
import 'infrastructure/authentication/authentication_facade.dart';
import 'infrastructure/chats/chat_repository.dart';
import 'infrastructure/chats/messages/message_repository.dart';
import 'infrastructure/friend_requests/friend_request_repository.dart';
import 'infrastructure/shared/user/current_user_session.dart';
import 'infrastructure/shared/user/user_repository.dart';
import 'infrastructure/shared/user/user_utils.dart';

final getIt = GetIt.instance;

/// This project's Firestore database is a *named* database, not the reserved
/// `(default)` one — `(default)` does not exist here at all.
///
/// That means `FirebaseFirestore.instance` resolves to a database that is not
/// there and every call fails, so the instance must always be built with
/// [FirebaseFirestore.instanceFor]. Deploys need it too: `firestore` in
/// firebase.json names this database, otherwise the CLI targets `(default)`
/// and 404s.
const firestoreDatabaseId = 'routes';

/// Wires the object graph. Replaces the previous `injectable`-generated
/// `injection.config.dart`; keep this in sync when constructors change.
void configureDependencies() {
  // ─── External (Firebase / Google) ─────────────────────────────────────
  getIt
    ..registerFactory<GoogleSignIn>(() => GoogleSignIn.instance)
    ..registerFactory<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerFactory<FirebaseFirestore>(
      () => FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: firestoreDatabaseId,
      ),
    )
    ..registerFactory<FirebaseStorage>(() => FirebaseStorage.instance);

  // ─── Session ──────────────────────────────────────────────────────────
  // Holds the signed-in user. Registered once here and injected into whoever
  // needs it; nothing registers or unregisters it at runtime.
  getIt.registerLazySingleton<ICurrentUserSession>(() => CurrentUserSession());

  // ─── Infrastructure ───────────────────────────────────────────────────
  getIt
    ..registerSingleton<IUserUtils>(UserUtils(getIt<FirebaseFirestore>()))
    ..registerSingleton<IAuthFacade>(
      AuthFacade(
        getIt<FirebaseAuth>(),
        getIt<GoogleSignIn>(),
        getIt<FirebaseFirestore>(),
        getIt<FirebaseStorage>(),
      ),
    )
    ..registerLazySingleton<IUserRepository>(
      () => UserFacade(
        getIt<FirebaseFirestore>(),
        getIt<FirebaseStorage>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerLazySingleton<IMessageRepository>(
      () => MessageRepository(
        getIt<FirebaseFirestore>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerLazySingleton<IChatRepository>(
      () => ChatRepository(
        getIt<FirebaseFirestore>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerLazySingleton<IFriendRequestsRepository>(
      () => FriendRequestRepository(
        getIt<FirebaseFirestore>(),
        getIt<ICurrentUserSession>(),
      ),
    );

  // ─── Blocs ────────────────────────────────────────────────────────────
  getIt
    ..registerFactory<AuthenticationBloc>(
      () => AuthenticationBloc(getIt<IAuthFacade>(), getIt<ICurrentUserSession>()),
    )
    ..registerFactory<RegisterFormBloc>(
      () => RegisterFormBloc(getIt<IAuthFacade>(), getIt<IUserUtils>()),
    )
    ..registerFactory<SignInFormBloc>(
      () => SignInFormBloc(getIt<IAuthFacade>()),
    )
    ..registerFactory<PlaceholderFetcherBloc>(
      () => PlaceholderFetcherBloc(getIt<IAuthFacade>()),
    )
    ..registerFactory<UsersWatcherBloc>(
      () => UsersWatcherBloc(getIt<IUserRepository>()),
    )
    ..registerFactory<UserFormBloc>(
      () => UserFormBloc(getIt<IUserRepository>(), getIt<IUserUtils>()),
    )
    ..registerFactory<UserWatcherBloc>(
      () => UserWatcherBloc(getIt<IUserRepository>()),
    )
    ..registerFactory<ChatBarBloc>(
      () => ChatBarBloc(
        getIt<IChatRepository>(),
        getIt<IMessageRepository>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerFactory<ChatActorBloc>(
      () => ChatActorBloc(getIt<IChatRepository>(), getIt<ICurrentUserSession>()),
    )
    ..registerFactory<ChatsWatcherBloc>(
      () => ChatsWatcherBloc(
        getIt<IChatRepository>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerFactory<MessagesWatcherBloc>(
      () => MessagesWatcherBloc(getIt<IMessageRepository>()),
    )
    ..registerFactory<FriendRequestActorBloc>(
      () => FriendRequestActorBloc(
        getIt<IFriendRequestsRepository>(),
        getIt<IUserRepository>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerFactory<FriendsWatcherBloc>(
      () => FriendsWatcherBloc(
        getIt<IFriendRequestsRepository>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerFactory<PendingFriendRequestsWatcherBloc>(
      () =>
          PendingFriendRequestsWatcherBloc(getIt<IFriendRequestsRepository>()),
    )
    ..registerFactory<ReceivedFriendRequestsWatcherBloc>(
      () =>
          ReceivedFriendRequestsWatcherBloc(getIt<IFriendRequestsRepository>()),
    );
}
