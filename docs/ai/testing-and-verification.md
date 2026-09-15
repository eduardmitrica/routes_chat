# Testing and verification

## Commands

```
flutter analyze                     # must print "No issues found!"
flutter test                        # the whole suite, a few seconds
cd functions && npm test            # Cloud Functions helpers
dart format <files you changed>     # format only what you touched
dart run build_runner build --delete-conflicting-outputs   # after @freezed / @JsonSerializable changes
flutter build apk --debug --dart-define-from-file=.env     # a build to install on a device
```

- **Analyzer output:** read the issue lines, not only the count. On Windows
  they look like `info - message - file:line:col - code`, with dashes. Stop if
  analyze is not clean.
- **Formatting:** running `dart format lib test` can reflow files unrelated to
  the change. Revert those rather than committing the noise.
- **Presentation code:** bloc tests do not compile presentation files, so a
  broken widget can pass `flutter test`. `flutter analyze` or a build catches
  it.
- **Installing:** only install a build after its output says "Built".

CI (`.github/workflows/tests.yml`) runs `flutter analyze` and `flutter test`
(job `flutter test`, a required check on `main`) and `npm test` (job
`functions test`) on pull requests to `main`. Renaming the `flutter test` job
would leave the required check unsatisfiable.

## Guard tests

These tests encode rules that would otherwise only fail in production.

| Test | Keeps |
|---|---|
| `architecture/no_service_locator_outside_composition_root_test.dart` | `getIt` only in `injection.dart` and `presentation/` |
| `architecture/firestore_listeners_end_with_session_test.dart` | every `.snapshots()` followed by `.takeUntil(_session.ended)` |
| `architecture/firestore_rules_allow_reading_missing_docs_test.dart` | chat and friend-request get rules never read `resource` |
| `architecture/firestore_indexes_match_queries_test.dart` | queries have their composite indexes |
| `architecture/no_hardcoded_client_config_test.dart` | no Firebase or OAuth config literals in `lib/` |
| `architecture/run_configurations_pass_env_test.dart` | shared IDE run configurations pass `--dart-define-from-file=.env` |
| `architecture/presentation_styles_come_from_theme_test.dart` | no named colors in screens, no `ElevatedButton` |
| `infrastructure/chats/chat_fields_match_rules_test.dart` | chat and message JSON keys equal the rules' field lists; encrypted-format checks in the rules; a deleted message's fields, the edit window and the reaction format agree with the app |
| `infrastructure/shared/user/profile_fields_test.dart` | profile JSON keys equal the rules' list |
| `infrastructure/encryption/bundle_fields_match_rules_test.dart` | key bundle fields equal the rules' list |
| `infrastructure/core/environment_test.dart` | `.env.example` keys equal `Environment` |
| `infrastructure/encryption/chat_cipher_interop_test.dart` | the app reads what the independent Node implementation writes |
| `infrastructure/encryption/strict_native_hmac_test.dart` | HMAC keys that Android's native implementation accepts |

When one of these fails, first suspect the change, not the test.

## Writing tests

- **Layout:** `test/` mirrors `lib/`. Name a test file after the behaviour or
  the class, and word test names as sentences about behaviour ("a page that
  fails keeps the messages shown").
- **Fakes:** implement the domain interface and add
  `noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);`,
  so only the methods the test uses need a body. Record calls in public lists
  (`pagesRequestedBefore`, `sent`) and assert on them.
- **Blocs:** add events and `await pumpEventQueue()`; no bloc_test package.
  Tear down with `addTearDown(bloc.close)`.
- **Hydrated blocs:** set `HydratedBloc.storage = MemoryStorage()` from
  `test/helpers/memory_storage.dart`.
- **Widgets:** pump `MaterialApp(theme: AppTheme.light, home: …)`. Use
  `tester.platformDispatcher.platformBrightnessTestValue` for dark mode,
  `find.text(…, findRichText: true)` for `Text.rich`, and dispose a
  `SemanticsHandle` inside the test body, since tear-downs run too late.
  Tap the text itself rather than a full-width row, whose centre can miss it.
- **Cryptography:** besides round trips, build ciphertext by hand from the
  spec (associated data and all), and test that altered or relabelled data
  fails.
- **Proving a guard works:** break the code once on purpose and watch the new
  test fail, then restore it. Say in the pull request that you did.

## On a device

Unit and widget tests do not cover Firebase, native crypto or platform
integrations. For changes that touch them:

1. Build a debug APK with `.env` and install it on an Android emulator.
2. Use a kept test account for the app, and a throwaway second user driven
   over the Firebase REST APIs for the other side of a conversation. That
   second client implements the message format independently, so a message
   passing both ways also proves compatibility.
3. Check the emulator log for the app's process: `PERMISSION_DENIED`,
   `FormatException`, `RenderFlex overflowed`, uncaught exceptions. None should
   appear.
4. Confirm writes server-side over REST rather than trusting the screen.
   For encryption changes, check that the stored document holds no plaintext.
5. Delete the throwaway user and their data afterwards.

Report in the pull request what was checked on the device, and what was not.
