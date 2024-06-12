import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart'
    as registration_failure;
import 'package:routes_chat/domain/authentication/sign_in_failure.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/user.dart' as domain_user;
import 'package:routes_chat/infrastructure/shared/user/firebase_user_mapper.dart';
import 'package:routes_chat/infrastructure/shared/user/user_data_transfer_object.dart';
import 'package:uuid/uuid.dart';

import '../../domain/shared/user/user_utils_interface.dart';
import '../../domain/shared/user/value_objects.dart';
import '../../injection.dart';

@Singleton(as: IAuthFacade)
class AuthFacade implements IAuthFacade {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseStorage _firebaseStorage;

  const AuthFacade(this._firebaseAuth, this._googleSignIn,
      this._firebaseFirestore, this._firebaseStorage);

  @override
  Future<Either<registration_failure.RegistrationFailure, Unit>> register(
      {required ImagePath imagePath,
      required EmailAddress emailAddress,
      required Username username,
      required Description description,
      required Password password}) async {
    final imagePathString = imagePath.getOrCrash();
    final emailAddressString = emailAddress.getOrCrash();
    final usernameString = username.getOrCrash();
    final descriptionString = description.getOrCrash();
    final passwordString = password.getOrCrash();

    try {
      final userCredentials =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: emailAddressString, password: passwordString);

      if (!imagePath.comesFromUrl()) {
        final storageRef = _firebaseStorage
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(File(imagePathString)).whenComplete(
          () async {
            final imageUrl = await storageRef.getDownloadURL();
            final user = domain_user.User(
              id: UniqueId.fromUniqueString(userCredentials.user!.uid),
              emailAddress: EmailAddress(emailAddressString),
              imageUrl: ImageUrl(imageUrl),
              username: Username(usernameString),
              description: Description(descriptionString),
            );
            await _firebaseFirestore
                .collection('users')
                .doc(userCredentials.user!.uid)
                .set(UserDataTransferObject.fromDomain(user).toJson());
          },
        );
      } else {
        final user = domain_user.User(
          id: UniqueId.fromUniqueString(userCredentials.user!.uid),
          emailAddress: EmailAddress(emailAddressString),
          imageUrl: ImageUrl(imagePathString),
          username: Username(usernameString),
          description: Description(descriptionString),
        );
        await _firebaseFirestore
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set(UserDataTransferObject.fromDomain(user).toJson());
      }

      return const Right(unit);
    } on FirebaseAuthException catch (exception) {
      if (exception.code == 'email-already-in-use') {
        return Left(registration_failure.EmailAlreadyInUse());
      }

      return Left(registration_failure.ServerError());
    }
  }

  @override
  Future<Either<SignInFailure, Unit>> signInWithEmailAndPassword(
      {required EmailAddress emailAddress, required Password password}) async {
    final emailAddressString = emailAddress.getOrCrash();
    final passwordString = password.getOrCrash();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: emailAddressString, password: passwordString);

      return const Right(unit);
    } on FirebaseAuthException catch (exception) {
      if (exception.code == 'invalid-email' ||
          exception.code == 'wrong-password' ||
          exception.code == 'invalid-credential') {
        return Left(InvalidEmailAndPasswordCombination());
      }

      return Left(ServerError());
    }
  }

  @override
  Future<Either<registration_failure.RegistrationFailure, EmailAddress>>
      registerWithGoogle(ImagePath imagePath) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(registration_failure.CancelledByUser());
      }

      final googleAuthentication = await googleUser.authentication;
      final authenticationCredential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken,
      );

      final emailExists = await getIt<IUserUtils>()
          .checkIfEmailAddressAlreadyExists(googleUser.email);
      if (!emailExists) {
        final userCredentials =
            await _firebaseAuth.signInWithCredential(authenticationCredential);

        final emailAddressString = googleUser.email;
        final imageUrlString = imagePath.getOrCrash();
        final generatedUsername = const Uuid().v1();
        final usernameString =
            Username(generatedUsername.substring(generatedUsername.length - 12))
                .getOrCrash();
        final descriptionString = Description('').getOrCrash();
        final user = domain_user.User(
          id: UniqueId.fromUniqueString(userCredentials.user!.uid),
          emailAddress: EmailAddress(emailAddressString),
          imageUrl: ImageUrl(imageUrlString),
          username: Username(usernameString),
          description: Description(descriptionString),
        );

        await _firebaseFirestore
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set(UserDataTransferObject.fromDomain(user).toJson());

        return Right(EmailAddress(emailAddressString));
      } else {
        await _googleSignIn.signOut();
        return Left(registration_failure.UserAlreadyRegistered());
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'sign_in_failed') {
        return Left(registration_failure.SignInWithGoogleFailed());
      } else {
        return Left(registration_failure.GoogleError());
      }
    } on FirebaseException catch (_) {
      await _googleSignIn.signOut();
      return Left(registration_failure.ServerError());
    }
  }

  @override
  Future<Option<domain_user.User>> getSignedInUser() async {
    final user = await _firebaseAuth.currentUser?.toDomain(_firebaseFirestore);
    if (user != null && user.emailAddress.isValid()) {
      return optionOf(user);
    } else {
      return none();
    }
  }

  @override
  Future<void> signOut() async => Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);

  @override
  Future<String> fetchUserImagePlaceHolder() async {
    return await _firebaseStorage
        .ref()
        .child('placeholders')
        .child('user_profile_image_placeholder.jpg')
        .getDownloadURL();
  }

  @override
  Future<Either<SignInFailure, Unit>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(CancelledByUser());
      }

      final googleAuthentication = await googleUser.authentication;
      final authenticationCredential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken,
      );

      final emailExists = await getIt<IUserUtils>()
          .checkIfEmailAddressAlreadyExists(googleUser.email);
      if (emailExists) {
        await _firebaseAuth.signInWithCredential(authenticationCredential);
        return const Right(unit);
      } else {
        await _googleSignIn.signOut();
        return Left(InvalidUser());
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'sign_in_failed') {
        return Left(SignInFailed());
      } else {
        return Left(GoogleError());
      }
    } on FirebaseException catch (_) {
      await _googleSignIn.signOut();
      return Left(ServerError());
    }
  }
}
