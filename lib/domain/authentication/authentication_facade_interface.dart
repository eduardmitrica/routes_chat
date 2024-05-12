import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart';
import 'package:routes_chat/domain/authentication/sign_in_failure.dart';
import 'package:routes_chat/domain/shared/user/user.dart';

import '../shared/user/value_objects.dart';

abstract interface class IAuthFacade {
  Future<Either<RegistrationFailure, Unit>> register(
      {required ImagePath imagePath,
      required EmailAddress emailAddress,
      required Username username,
      required Description description,
      required Password password});

  Future<Either<SignInFailure, Unit>> signInWithEmailAndPassword(
      {required EmailAddress emailAddress, required Password password});

  Future<Either<RegistrationFailure, EmailAddress>> registerWithGoogle(ImagePath imagePath);

  Future<Either<SignInFailure, Unit>> signInWithGoogle();

  Future<Option<User>> getSignedInUser();

  Future<void> signOut();

  Future<String> fetchUserImagePlaceHolder();
}
