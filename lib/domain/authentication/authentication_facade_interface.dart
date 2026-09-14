import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart';
import 'package:routes_chat/domain/authentication/sign_in_failure.dart';
import 'package:routes_chat/domain/authentication/sign_in_method.dart';
import 'package:routes_chat/domain/shared/user/user.dart';

import '../shared/user/value_objects.dart';

abstract interface class IAuthFacade {
  Future<Either<RegistrationFailure, Unit>> register({
    required ImagePath imagePath,
    required EmailAddress emailAddress,
    required Username username,
    required Description description,
    required Password password,
  });

  Future<Either<SignInFailure, Unit>> signInWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  });

  Future<Either<RegistrationFailure, EmailAddress>> registerWithGoogle(
    ImagePath imagePath,
  );

  Future<Either<SignInFailure, Unit>> signInWithGoogle();

  /// How the signed-in user signs in, or null when nobody is signed in.
  SignInMethod? currentSignInMethod();

  /// Confirms the signed-in user is at the device by checking their account
  /// [password] again. The sign-in then counts as recent, which resetting
  /// encryption keys requires.
  Future<Either<SignInFailure, Unit>> confirmSignInWithPassword(
    Password password,
  );

  /// Like [confirmSignInWithPassword], for a user who signs in with Google:
  /// they sign in with the same Google account again.
  Future<Either<SignInFailure, Unit>> confirmSignInWithGoogle();

  Future<Option<User>> getSignedInUser();

  Future<void> signOut();

  Future<String> fetchUserImagePlaceHolder();
}
