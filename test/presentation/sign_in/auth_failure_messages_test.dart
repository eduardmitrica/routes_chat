import 'package:dartz/dartz.dart' show Either, Left;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/application/authentication/sign_in_form/sign_in_form_bloc.dart';
import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart'
    as registration;
import 'package:routes_chat/domain/authentication/sign_in_failure.dart'
    as sign_in;
import 'package:routes_chat/domain/encryption/encryption_repository_interface.dart';
import 'package:routes_chat/domain/notifications/push_token_registry_interface.dart';
import 'package:routes_chat/domain/presence/presence_repository_interface.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/register/register_page.dart';
import 'package:routes_chat/presentation/register/widgets/registration_failure_message.dart';
import 'package:routes_chat/presentation/sign_in/widgets/sign_in_failure_message.dart';
import 'package:routes_chat/presentation/sign_in/widgets/sign_in_form.dart';

/// Answers Google sign-in with [googleFailure].
class _FakeAuthFacade implements IAuthFacade {
  sign_in.SignInFailure googleFailure = sign_in.InvalidUser();

  @override
  Future<Either<sign_in.SignInFailure, Never>> signInWithGoogle() async =>
      Left(googleFailure);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Unused
    implements IPushTokenRegistry, IEncryptionRepository, IPresenceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('messages', () {
    test('every sign-in failure but cancelling says what to do', () {
      final failures = <sign_in.SignInFailure>[
        sign_in.InvalidEmailAndPasswordCombination(),
        sign_in.ServerError(),
        sign_in.InvalidUser(),
        sign_in.SignInFailed(),
        sign_in.GoogleError(),
      ];

      for (final failure in failures) {
        expect(signInFailureMessage(failure), isNotEmpty, reason: '$failure');
      }
      expect(signInFailureMessage(sign_in.CancelledByUser()), isNull);
    });

    test('every registration failure but cancelling says what to do', () {
      final failures = <registration.RegistrationFailure>[
        registration.EmailAlreadyInUse(),
        registration.UsernameTaken(),
        registration.ServerError(),
        registration.UserAlreadyRegistered(),
        registration.SignInWithGoogleFailed(),
        registration.GoogleError(),
      ];

      for (final failure in failures) {
        expect(
          registrationFailureMessage(failure),
          isNotEmpty,
          reason: '$failure',
        );
      }
      expect(
        registrationFailureMessage(registration.CancelledByUser()),
        isNull,
      );
    });

    test('registering an account that exists offers to sign in', () {
      expect(alreadyHasAccount(registration.EmailAlreadyInUse()), isTrue);
      expect(alreadyHasAccount(registration.UserAlreadyRegistered()), isTrue);
      expect(alreadyHasAccount(registration.UsernameTaken()), isFalse);
    });
  });

  group('the sign-in form', () {
    late _FakeAuthFacade facade;

    setUp(() => facade = _FakeAuthFacade());

    Future<void> show(WidgetTester tester) async {
      final signInForm = SignInFormBloc(facade);
      final authentication = AuthenticationBloc(
        facade,
        CurrentUserSession(),
        _Unused(),
        _Unused(),
        _Unused(),
      );
      addTearDown(signInForm.close);
      addTearDown(authentication.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          routes: {
            RegisterPage.registerPageRoute: (_) =>
                const Scaffold(body: Text('Registration')),
          },
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: signInForm),
                BlocProvider.value(value: authentication),
              ],
              child: const SignInForm(),
            ),
          ),
        ),
      );
    }

    testWidgets('a Google account not registered yet is offered registration', (
      tester,
    ) async {
      await show(tester);

      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text(signInFailureMessage(sign_in.InvalidUser())!),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(SnackBarAction, 'Register'));
      await tester.pumpAndSettle();

      expect(find.text('Registration'), findsOneWidget);
    });

    testWidgets('cancelling Google sign-in says nothing', (tester) async {
      facade.googleFailure = sign_in.CancelledByUser();
      await show(tester);

      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('other failures say what went wrong, without an action', (
      tester,
    ) async {
      facade.googleFailure = sign_in.GoogleError();
      await show(tester);

      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text(signInFailureMessage(sign_in.GoogleError())!),
        findsOneWidget,
      );
      expect(find.byType(SnackBarAction), findsNothing);
    });
  });
}
