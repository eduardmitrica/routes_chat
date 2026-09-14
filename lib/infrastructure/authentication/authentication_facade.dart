import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart'
    as registration_failure;
import 'package:routes_chat/domain/authentication/sign_in_failure.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/user.dart' as domain_user;
import 'package:routes_chat/infrastructure/core/firestore_helpers.dart';
import 'package:routes_chat/infrastructure/shared/user/firebase_user_mapper.dart';
import 'package:routes_chat/infrastructure/shared/user/user_data_transfer_object.dart';
import 'package:uuid/uuid.dart';

import '../../domain/shared/user/user_utils_interface.dart';
import '../../domain/shared/user/value_objects.dart';

class AuthFacade implements IAuthFacade {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseStorage _firebaseStorage;
  final IUserUtils _userUtils;

  const AuthFacade(
    this._firebaseAuth,
    this._googleSignIn,
    this._firebaseFirestore,
    this._firebaseStorage,
    this._userUtils,
  );

  @override
  Future<Either<registration_failure.RegistrationFailure, Unit>> register({
    required ImagePath imagePath,
    required EmailAddress emailAddress,
    required Username username,
    required Description description,
    required Password password,
  }) async {
    final imagePathString = imagePath.getOrCrash();
    final emailAddressString = emailAddress.getOrCrash();
    final usernameString = username.getOrCrash();
    final descriptionString = description.getOrCrash();
    final passwordString = password.getOrCrash();

    try {
      final userCredentials = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: emailAddressString,
            password: passwordString,
          );
      final uid = userCredentials.user!.uid;

      try {
        var imageUrlString = imagePathString;
        if (!imagePath.comesFromUrl()) {
          final storageRef = _firebaseStorage
              .ref()
              .child('user_images')
              .child('$uid.jpg');
          await storageRef.putFile(File(imagePathString));
          imageUrlString = await storageRef.getDownloadURL();
        }

        await _createProfile(
          domain_user.User(
            id: UniqueId.fromUniqueString(uid),
            imageUrl: ImageUrl(imageUrlString),
            username: Username(usernameString),
            description: Description(descriptionString),
          ),
        );
      } on FirebaseException catch (_) {
        // The account exists but its profile does not, most likely because
        // the username was claimed by someone else between the uniqueness
        // check and this write. Remove the account rather than leave the email
        // registered with no profile behind it.
        await userCredentials.user?.delete();
        return Left(registration_failure.ServerError());
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
  Future<Either<SignInFailure, Unit>> signInWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  }) async {
    final emailAddressString = emailAddress.getOrCrash();
    final passwordString = password.getOrCrash();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: emailAddressString,
        password: passwordString,
      );

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
      final googleUser = await _googleSignIn.authenticate();

      final googleAuthentication = googleUser.authentication;
      final authenticationCredential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
      );

      // Sign in first, then look for the caller's own profile. Searching
      // `users` by email beforehand ran signed out, which forced `users`, and
      // every email address in it, to be publicly readable.
      final userCredentials = await _firebaseAuth.signInWithCredential(
        authenticationCredential,
      );
      final uid = userCredentials.user!.uid;

      final existingProfile = await _firebaseFirestore
          .collection('users')
          .doc(uid)
          .get();
      if (existingProfile.exists) {
        await signOut();
        return Left(registration_failure.UserAlreadyRegistered());
      }

      final emailAddressString = googleUser.email;
      final generatedUsername = const Uuid().v1();
      final user = domain_user.User(
        id: UniqueId.fromUniqueString(uid),
        imageUrl: ImageUrl(imagePath.getOrCrash()),
        username: Username(
          generatedUsername.substring(generatedUsername.length - 12),
        ),
        description: Description(''),
      );

      try {
        await _createProfile(user);
      } on FirebaseException catch (_) {
        if (userCredentials.additionalUserInfo?.isNewUser ?? false) {
          await userCredentials.user?.delete();
        }
        await signOut();
        return Left(registration_failure.ServerError());
      }

      return Right(EmailAddress(emailAddressString));
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return Left(registration_failure.CancelledByUser());
      }
      return Left(registration_failure.SignInWithGoogleFailed());
    } on FirebaseAuthException catch (error) {
      if (error.code == 'sign_in_failed') {
        return Left(registration_failure.SignInWithGoogleFailed());
      } else {
        return Left(registration_failure.GoogleError());
      }
    } on FirebaseException catch (_) {
      await signOut();
      return Left(registration_failure.ServerError());
    }
  }

  @override
  Future<Option<domain_user.User>> getSignedInUser() async {
    // No readable profile (for example an Auth account whose registration
    // never completed) means not signed in, as far as the app is concerned.
    final user = await _firebaseAuth.currentUser?.toDomain(
      _firebaseFirestore,
      _userUtils,
    );
    return optionOf(user);
  }

  @override
  Future<void> signOut() async =>
      Future.wait([_googleSignIn.signOut(), _firebaseAuth.signOut()]);

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
      final googleUser = await _googleSignIn.authenticate();

      final googleAuthentication = googleUser.authentication;
      final authenticationCredential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
      );

      // As in registerWithGoogle: sign in, then check for the caller's own
      // profile, instead of searching `users` by email while signed out.
      final userCredentials = await _firebaseAuth.signInWithCredential(
        authenticationCredential,
      );
      final existingProfile = await _firebaseFirestore
          .collection('users')
          .doc(userCredentials.user!.uid)
          .get();
      if (existingProfile.exists) {
        return const Right(unit);
      }

      // Never registered. Signing in with the credential created a bare Auth
      // account; delete it so a refused sign-in leaves nothing behind.
      if (userCredentials.additionalUserInfo?.isNewUser ?? false) {
        await userCredentials.user?.delete();
      }
      await signOut();
      return Left(InvalidUser());
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return Left(CancelledByUser());
      }
      return Left(SignInFailed());
    } on FirebaseAuthException catch (error) {
      if (error.code == 'sign_in_failed') {
        return Left(SignInFailed());
      } else {
        return Left(GoogleError());
      }
    } on FirebaseException catch (_) {
      await signOut();
      return Left(ServerError());
    }
  }

  /// Writes a new profile and claims its username in a single batch.
  ///
  /// Security rules accept the profile only if the `usernames` entry for its
  /// username belongs to the same uid after the write, and accept the entry
  /// only if the profile carries that username, so neither can land alone. A
  /// username that is already claimed turns the entry write into an update of
  /// another user's document, which the rules deny, failing the whole batch.
  Future<void> _createProfile(domain_user.User user) {
    final uid = user.id.getOrCrash();
    final batch = _firebaseFirestore.batch()
      ..set(
        _firebaseFirestore.collection('users').doc(uid),
        UserDataTransferObject.fromDomain(user).toJson(),
      )
      ..set(_firebaseFirestore.usernameDocument(user.username.getOrCrash()), {
        'uid': uid,
      });
    return batch.commit();
  }
}
