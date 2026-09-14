import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/user/user_form/user_form_bloc.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/domain/shared/user/user_failure.dart';
import 'package:routes_chat/domain/shared/user/user_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/user_utils_interface.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart'
    as value_objects;

/// Records every profile the bloc asks to save.
class _FakeUserRepository implements IUserRepository {
  final saved = <User>[];

  @override
  Future<Either<UserFailure, Unit>> update(User user) async {
    saved.add(user);
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Treats every name in [taken] as claimed, and counts the lookups.
class _FakeUserUtils implements IUserUtils {
  _FakeUserUtils(this.taken);

  final Set<String> taken;
  var lookups = 0;

  @override
  Future<bool> checkIfUsernameAlreadyExists(String username) async {
    lookups++;
    return taken.contains(username);
  }
}

User _profile() => User(
  id: UniqueId.fromUniqueString('uid-eduard'),
  imageUrl: value_objects.ImageUrl('https://example.com/avatar.jpg'),
  username: value_objects.Username('eduard'),
  description: value_objects.Description('old bio'),
);

void main() {
  late _FakeUserRepository repository;
  late _FakeUserUtils userUtils;
  late UserFormBloc bloc;

  setUp(() {
    repository = _FakeUserRepository();
    // The user's own name is claimed in the usernames index, exactly as in
    // production, so any uniqueness check of it says "already exists".
    userUtils = _FakeUserUtils({'eduard', 'someone'});
    bloc = UserFormBloc(repository, userUtils)
      ..add(UserFormEvent.initialized(some(_profile())));
  });

  tearDown(() => bloc.close());

  test('a description-only edit is saved', () async {
    // Regression: the unchanged username was checked against the database,
    // came back "already exists" (it is this user's own claim), and the save
    // was silently skipped.
    bloc
      ..add(const UserFormEvent.descriptionChanged('new bio'))
      ..add(const UserFormEvent.saved());
    await pumpEventQueue();

    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.description.getOrCrash(), 'new bio');
    expect(repository.saved.single.username.getOrCrash(), 'eduard');
    expect(
      userUtils.lookups,
      0,
      reason: 'an unchanged username must not be checked for uniqueness',
    );
  });

  test('a new username that is already taken is not saved', () async {
    bloc
      ..add(const UserFormEvent.usernameChanged('someone'))
      ..add(const UserFormEvent.saved());
    await pumpEventQueue();

    expect(repository.saved, isEmpty);
    expect(userUtils.lookups, 1);
    expect(
      bloc.state.user.username.value.fold((failure) => failure, (_) => null),
      isA<UsernameAlreadyExists>(),
    );
  });

  test('a new username that is free is saved', () async {
    bloc
      ..add(const UserFormEvent.usernameChanged('eduard2'))
      ..add(const UserFormEvent.saved());
    await pumpEventQueue();

    expect(userUtils.lookups, 1);
    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.username.getOrCrash(), 'eduard2');
  });
}
