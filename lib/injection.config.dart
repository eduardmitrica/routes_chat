// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i5;
import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:firebase_storage/firebase_storage.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i3;
import 'package:injectable/injectable.dart' as _i2;

import 'application/authentication/authentication_bloc.dart' as _i16;
import 'application/authentication/register_form/register_form_bloc.dart'
    as _i17;
import 'application/authentication/sign_in_form/sign_in_form_bloc.dart' as _i18;
import 'application/chats/friends_watcher/friends_watcher_bloc.dart' as _i23;
import 'application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart'
    as _i15;
import 'application/friend_requests/pending_friend_requests_watcher/pending_friend_requests_watcher_bloc.dart'
    as _i24;
import 'application/friend_requests/received_friend_requests_watcher/received_friend_requests_watcher_bloc.dart'
    as _i25;
import 'application/shared/picture_placeholder_fetcher/placeholder_fetcher_bloc.dart'
    as _i19;
import 'application/shared/users_watcher/users_watcher_bloc.dart' as _i22;
import 'application/user/user_form/user_form_bloc.dart' as _i20;
import 'application/user/user_watcher/user_watcher_bloc.dart' as _i21;
import 'domain/authentication/authentication_facade_interface.dart' as _i13;
import 'domain/friend_requests/friend_requests_repository_interface.dart'
    as _i11;
import 'domain/shared/user/user_repository_interface.dart' as _i9;
import 'domain/shared/user/user_utils_interface.dart' as _i7;
import 'infrastructure/authentication/authentication_facade.dart' as _i14;
import 'infrastructure/core/firebase_injectable_module.dart' as _i26;
import 'infrastructure/friend_requests/friend_request_repository.dart' as _i12;
import 'infrastructure/shared/user/user_repository.dart' as _i10;
import 'infrastructure/shared/user/user_utils.dart' as _i8;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final firebaseInjectableModule = _$FirebaseInjectableModule();
    gh.factory<_i3.GoogleSignIn>(() => firebaseInjectableModule.googleSignIn);
    gh.factory<_i4.FirebaseAuth>(() => firebaseInjectableModule.firebaseAuth);
    gh.factory<_i5.FirebaseFirestore>(() => firebaseInjectableModule.firestore);
    gh.factory<_i6.FirebaseStorage>(
        () => firebaseInjectableModule.firebaseStorage);
    gh.singleton<_i7.IUserUtils>(
        () => _i8.UserUtils(gh<_i5.FirebaseFirestore>()));
    gh.lazySingleton<_i9.IUserRepository>(() => _i10.UserFacade(
          gh<_i5.FirebaseFirestore>(),
          gh<_i6.FirebaseStorage>(),
        ));
    gh.lazySingleton<_i11.IFriendRequestsRepository>(
        () => _i12.FriendRequestRepository(gh<_i5.FirebaseFirestore>()));
    gh.singleton<_i13.IAuthFacade>(() => _i14.AuthFacade(
          gh<_i4.FirebaseAuth>(),
          gh<_i3.GoogleSignIn>(),
          gh<_i5.FirebaseFirestore>(),
          gh<_i6.FirebaseStorage>(),
        ));
    gh.factory<_i15.FriendRequestActorBloc>(() => _i15.FriendRequestActorBloc(
          gh<_i11.IFriendRequestsRepository>(),
          gh<_i9.IUserRepository>(),
          gh<_i13.IAuthFacade>(),
        ));
    gh.factory<_i16.AuthenticationBloc>(
        () => _i16.AuthenticationBloc(gh<_i13.IAuthFacade>()));
    gh.factory<_i17.RegisterFormBloc>(
        () => _i17.RegisterFormBloc(gh<_i13.IAuthFacade>()));
    gh.factory<_i18.SignInFormBloc>(
        () => _i18.SignInFormBloc(gh<_i13.IAuthFacade>()));
    gh.factory<_i19.PlaceholderFetcherBloc>(
        () => _i19.PlaceholderFetcherBloc(gh<_i13.IAuthFacade>()));
    gh.factory<_i20.UserFormBloc>(
        () => _i20.UserFormBloc(gh<_i9.IUserRepository>()));
    gh.factory<_i21.UserWatcherBloc>(
        () => _i21.UserWatcherBloc(gh<_i9.IUserRepository>()));
    gh.factory<_i22.UsersWatcherBloc>(
        () => _i22.UsersWatcherBloc(gh<_i9.IUserRepository>()));
    gh.factory<_i23.FriendsWatcherBloc>(() => _i23.FriendsWatcherBloc(
          gh<_i11.IFriendRequestsRepository>(),
          gh<_i13.IAuthFacade>(),
        ));
    gh.factory<_i24.PendingFriendRequestsWatcherBloc>(() =>
        _i24.PendingFriendRequestsWatcherBloc(
            gh<_i11.IFriendRequestsRepository>()));
    gh.factory<_i25.ReceivedFriendRequestsWatcherBloc>(() =>
        _i25.ReceivedFriendRequestsWatcherBloc(
            gh<_i11.IFriendRequestsRepository>()));
    return this;
  }
}

class _$FirebaseInjectableModule extends _i26.FirebaseInjectableModule {}
