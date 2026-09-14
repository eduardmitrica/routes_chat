import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'application/authentication/authentication_bloc.dart';
import 'application/authentication/register_form/register_form_bloc.dart';
import 'application/authentication/sign_in_form/sign_in_form_bloc.dart';
import 'application/chats/chat_bar/chat_bar_bloc.dart';
import 'application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'application/chats/friends_watcher/friends_watcher_bloc.dart';
import 'application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'application/encryption/encryption_bloc.dart';
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
import 'domain/encryption/encryption_repository_interface.dart';
import 'domain/friend_requests/friend_requests_repository_interface.dart';
import 'domain/notifications/push_token_registry_interface.dart';
import 'domain/shared/user/current_user_session_interface.dart';
import 'domain/shared/user/user_repository_interface.dart';
import 'domain/shared/user/user_utils_interface.dart';
import 'infrastructure/authentication/authentication_facade.dart';
import 'infrastructure/chats/chat_repository.dart';
import 'infrastructure/chats/messages/message_repository.dart';
import 'infrastructure/core/environment.dart';
import 'infrastructure/encryption/chat_cipher.dart';
import 'infrastructure/encryption/chat_keyring.dart';
import 'infrastructure/encryption/firebase_encryption_repository.dart';
import 'infrastructure/encryption/user_key_manager.dart';
import 'infrastructure/friend_requests/friend_request_repository.dart';
import 'infrastructure/notifications/firebase_push_token_registry.dart';
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
///
/// The id itself comes from `FIRESTORE_DATABASE_ID` in `.env`; see [Environment].
const firestoreDatabaseId = Environment.firestoreDatabaseId;

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
    ..registerFactory<FirebaseMessaging>(() => FirebaseMessaging.instance)
    ..registerFactory<FirebaseStorage>(() => FirebaseStorage.instance)
    ..registerFactory<FlutterSecureStorage>(() => const FlutterSecureStorage());

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
        getIt<ChatKeyring>(),
        getIt<ChatCipher>(),
      ),
    )
    ..registerLazySingleton<IChatRepository>(
      () => ChatRepository(
        getIt<FirebaseFirestore>(),
        getIt<ICurrentUserSession>(),
        getIt<ChatKeyring>(),
        getIt<ChatCipher>(),
      ),
    )
    ..registerLazySingleton<IFriendRequestsRepository>(
      () => FriendRequestRepository(
        getIt<FirebaseFirestore>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    // A singleton: it owns the session's token-refresh subscription.
    ..registerLazySingleton<IPushTokenRegistry>(
      () => FirebasePushTokenRegistry(
        getIt<FirebaseMessaging>(),
        getIt<FirebaseFirestore>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerLazySingleton<UserKeyManager>(UserKeyManager.new)
    // One instance behind both registrations: the encryption gate unlocks the
    // keys through IEncryptionRepository, and the chat keyring reads them.
    ..registerLazySingleton<FirebaseEncryptionRepository>(
      () => FirebaseEncryptionRepository(
        getIt<FirebaseFirestore>(),
        getIt<FlutterSecureStorage>(),
        getIt<UserKeyManager>(),
        getIt<ICurrentUserSession>(),
      ),
    )
    ..registerLazySingleton<IEncryptionRepository>(
      () => getIt<FirebaseEncryptionRepository>(),
    )
    ..registerLazySingleton<ChatCipher>(ChatCipher.new)
    // A singleton: it holds the session's opened chat keys.
    ..registerLazySingleton<ChatKeyring>(
      () => ChatKeyring(
        getIt<FirebaseFirestore>(),
        getIt<ChatCipher>(),
        getIt<FirebaseEncryptionRepository>(),
        getIt<ICurrentUserSession>(),
      ),
    );

  // ─── Blocs ────────────────────────────────────────────────────────────
  getIt
    ..registerFactory<AuthenticationBloc>(
      () => AuthenticationBloc(
        getIt<IAuthFacade>(),
        getIt<ICurrentUserSession>(),
        getIt<IPushTokenRegistry>(),
        getIt<IEncryptionRepository>(),
      ),
    )
    ..registerFactory<EncryptionBloc>(
      () =>
          EncryptionBloc(getIt<IEncryptionRepository>(), getIt<IAuthFacade>()),
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
