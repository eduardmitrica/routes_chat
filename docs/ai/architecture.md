# Architecture

## Stack

- Flutter, pinned in CI (`.github/workflows/tests.yml`) to the version the
  project is developed with. Bump both together.
- State: `flutter_bloc` (plus `hydrated_bloc` for state kept between launches).
- Kept on the phone: unsent drafts and messages on their way, encrypted by
  `LocalVault` and deleted on sign-out (`LocalChatStore`). `MessageOutbox`, an
  application service, sends them.
- Functional types: `dartz` (`Either`, `Option`, `Unit`) and `kt_dart`
  immutable collections (`KtList`).
- Data classes: `freezed` + `json_serializable`. Unions (events, most states)
  are hand-written `sealed` classes with `equatable`.
- Wiring: `get_it`, registered by hand in `lib/injection.dart` (no
  `injectable`).
- Firebase: Auth, Firestore, Storage, Messaging, Cloud Functions.
- Encryption: `cryptography` + `cryptography_flutter` (native on Android/iOS).
- UI helpers: `super_sliver_list` (jump to a message in a long reversed list),
  `url_launcher` (links), `image_picker`.

## Layers

```
presentation ──▶ application ──▶ domain ◀── infrastructure
      │                                          ▲
      └──────────── lib/injection.dart ──────────┘  (composition root)
```

| Layer | Holds | May depend on |
|---|---|---|
| `lib/domain` | Entities (`Chat`, `Message`, `FriendRequest`, `User`), value objects, failures, repository interfaces (`I…`), pure logic (search matching, link detection, quotes, composite ids) | Dart and small packages only. Keep new domain code free of Flutter. |
| `lib/application` | Blocs, one per use case | `domain` |
| `lib/infrastructure` | Firebase implementations of the domain interfaces, data transfer objects, encryption, session, environment | `domain` |
| `lib/presentation` | Pages, widgets, theme, routes | `application`, `domain`, `getIt` |

`lib/injection.dart` creates the external instances (Firebase, Google
Sign-In, secure storage), binds each infrastructure class to its domain
interface, and registers every bloc as a factory. When a constructor changes,
update the registration by hand.

### Domain

- **Value objects** extend `ValueObject<T>`: `value` is
  `Either<ValueFailure<T>, T>`, validated in the factory. `getOrCrash()` is for
  values already known to be valid; forms read `value.fold(...)`.
- **Failures** are sealed classes per area (`ChatFailure`, `MessageFailure`,
  `EncryptionFailure`, …). Screens switch over them exhaustively to pick a
  message.
- **Repository interfaces** return `Either<Failure, T>` (or a stream of them).
  They never throw at the caller.
- **Entities** are `@freezed` for equality and `copyWith`.

### Application

- A bloc handles `on<TheSealedEvent>` with a `switch` over the event classes.
  Events are declared as `const factory Event.name(...) = ConcreteClass;` so
  call sites read `MessagesWatcherEvent.searchChanged(query)`.
- Naming by role: `…WatcherBloc` listens to data, `…ActorBloc` performs
  actions, `…FormBloc` holds a form.
- States with many fields use `@freezed` (for `copyWith`); others are
  hand-written `Equatable` classes with their own `copyWith`.
- Handlers run concurrently (the flutter_bloc default). Work that must not run
  twice is joined through a stored future, as `_loadOlderPage` does in
  `MessagesWatcherBloc`.
- A state that can hold decrypted text overrides `toString()` to print counts
  only.

### Infrastructure

- **Data transfer objects** (`…DataTransferObject`) are `@freezed` +
  `@JsonSerializable`, with `fromDomain`, `toDomain` and `fromFirestore`. Their
  JSON keys must match the rules' field lists (tests check this).
- **Repositories** catch exceptions and map them to failures. A Firestore
  document in an unexpected format is skipped with a `debugPrint` of the
  format error only, so one bad document never hides a whole list.
- **Session:** `ICurrentUserSession` starts after sign-in and ends before
  Firebase sign-out. Every Firestore listener ends with the session:
  `.snapshots()` is always followed by `.takeUntil(_session.ended)`.
  Sign-out order is: unregister the push token, end the session, then sign out
  of Firebase.
- **Encryption:** `ChatCipher` is pure cryptography (sealing chat keys,
  encrypting message payloads). `ChatKeyring` finds and caches chat keys.
  `UserKeyManager` and `FirebaseEncryptionRepository` manage a user's own keys.
  See [firebase-and-security.md](firebase-and-security.md) and
  [docs/e2ee.md](../e2ee.md).
- **Core helpers:** `Environment` (compile-time config), `chunked` (Firestore
  `in` queries in groups of 30), `singleFlight` (one in-flight future per key).

### Presentation

- Pages create their blocs with `BlocProvider(create: (_) => getIt<X>())`.
  That is a deliberate choice, not something to refactor away.
- Named routes are in `lib/presentation/core/routes/routes.dart`. The flow is
  Splash → Sign in / Register → Encryption gate → Home (tabs: Chats, Search,
  Profile, Friend requests). A chat opens with `MaterialPageRoute` and the other
  `User` as its argument.
- Theme: `lib/presentation/core/theme` (`AppTheme`, `AppColors`). Shared
  widgets: `lib/presentation/core/widgets`.
- A widget tested on its own lives in its own public file; small helpers stay
  private in the page that uses them.

## Generated code

`*.freezed.dart` and `*.g.dart` are committed; CI does not generate them. After
changing a `@freezed` or `@JsonSerializable` class:

```
dart run build_runner build --delete-conflicting-outputs
```

and commit the regenerated files with the change.

## Directory map

```
lib/
  main.dart                  startup: Environment check, hydrated storage, Firebase, wiring
  injection.dart             composition root (the only getIt registrations)
  firebase_options.dart      reads Environment; never literal values
  domain/
    authentication/ chats/ chats/messages/ core/ encryption/
    friend_requests/ notifications/ shared/user/
  application/
    authentication/ chats/ encryption/ friend_requests/
    settings/appearance/ shared/ user/
  infrastructure/
    authentication/ chats/ chats/messages/ core/ encryption/
    friend_requests/ notifications/ shared/user/
  presentation/
    core/ (routes, theme, widgets)  encryption/  home/ (chats, friend_requests,
    profile, search)  register/  sign_in/  splash/
test/                        mirrors lib/, plus architecture/ and helpers/
functions/                   Cloud Functions (push notifications), Node, node --test
docs/                        e2ee.md (encryption spec), ai/ (this guide)
firestore.rules  firestore.indexes.json  storage.rules
```
