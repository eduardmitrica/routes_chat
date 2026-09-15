# Pitfalls

Problems this project has already hit, what they looked like, and what fixes
them.

## Dart and Flutter

- **A deleted message vanished instead of showing as deleted.** A
  `JsonConverter` on a nullable field is still handed `null`, and the
  converter for encrypted content threw on it, so the document was left out
  as malformed. A nullable field needs a converter of the nullable type
  (`OptionalEncryptedContentConverter`).
- **"Superclass has no method named 'initState'" all over a file.**
  `package:dartz/dartz.dart` exports a `State` class. Import dartz with `show`
  in files that declare a `StatefulWidget`.
- **Theme text styles come out at 14 px.** `ThemeData().textTheme` has no font
  sizes until the theme is applied, and a button style replaces the default
  text style rather than merging with it. Build component styles from
  `Typography.material2021().englishLike`, or leave them unset.
- **A site name with non-ASCII letters looks plain ASCII in checks.**
  `Uri.parse` percent-encodes non-ASCII hosts (`%D0%B0pple.com`). Check for `%`
  and `xn--` too, and decode for display.
- **A future helper hangs forever.** `future.whenComplete(() => map.remove(key))`
  returns the awaited future, not the cleanup. Use `singleFlight`
  (`lib/infrastructure/core/single_flight.dart`).
- **Tapping "retry" does nothing, with no visible error.**
  `setState(() => _future = load())` passes a callback that returns a
  Future, which `setState` refuses by throwing. Use a block body:
  `setState(() { _future = load(); })`.
- **A retry shows the old failure until the new result arrives.**
  `FutureBuilder` keeps the previous `data` while the new future is waiting.
  Check `snapshot.connectionState` before reading `data`.
- **A list row shows another row's state** (a carousel on the wrong page, a
  half-finished animation). Lists reuse element state by position when rows
  have no keys. Give rows a `ValueKey` of their item's id, and reset state in
  `didUpdateWidget` when the item changes.
- **`expect(list, isEmpty)` on a `KtList` fails with a cast error.** The
  matcher reads an `isEmpty` getter, and `KtList.isEmpty` is a method. Use
  `expect(list.isEmpty(), isTrue)`, or `.asList()` first.
- **A widget test tap does nothing.** The widget's centre is not on the text,
  for example in a full-width row. Tap the text finder.
- **"A SemanticsHandle was active at the end of the test."** Dispose the
  handle in the test body, not in `addTearDown`.

## Cryptography

- **Encryption works in tests but hangs or fails on Android.** The native HMAC
  on Android rejects an empty key, which pure Dart accepts; HKDF with no salt
  uses one. Pass the explicit 32-zero-byte salt, map `PlatformException` to a
  failure, and check crypto changes on a device.
- **A key bundle "changed" when it did not.** The Firestore REST API returns
  map keys in varying order. Sort keys before comparing documents.

## Firestore

- **Every Firestore call fails right after startup.** The code used
  `FirebaseFirestore.instance`, but the database is named. Use `instanceFor`
  with the configured database id.
- **Starting a chat silently does nothing.** A get rule read
  `resource.data`, which is null for a document that does not exist yet, so the
  transaction's read was denied. Get rules must be decidable from the path.
- **A query is denied although every document would pass.** Rules are not
  filters; scope the query the way the rules require.
- **New rules seem to allow and deny at random.** Rules take a minute or two to
  propagate after a deploy. Wait before probing.
- **Two people created the same chat at once.** A query inside
  `runTransaction` is not tracked for conflicts. Use deterministic ids and
  `transaction.get`.
- **The app crashed on a document in an old format.** The device's Firestore
  cache can still hold documents deleted from the server. Repositories skip
  documents that fail to parse.
- **Registration quietly did nothing.** A signed-out read of a signed-in-only
  collection threw inside a bloc handler. Signed-out code reads `usernames`
  only.
- **A status stopped matching the rules in a release build.** Stored text came
  from `toString()`, which obfuscation changes. Write literals.
- **Recursive delete from the Firebase CLI fails on the named database.** Delete
  documents one by one over the REST API instead.

## Firebase tooling

- **`flutterfire configure` rewrites `lib/firebase_options.dart` with literal
  values,** and may skip writing the iOS plist. Restore the file with
  `git checkout`, put new values in `.env`, and fetch the plist with
  `firebase apps:sdkconfig IOS <app id> --out ios/Runner/GoogleService-Info.plist`.
- **`firebase deploy --only storage:rules` fails.** `:rules` is read as a
  target name; use `--only storage`.
- **The first functions deploy fails with an Eventarc permission error.** That
  is propagation on a new project; retry after a few minutes.

## Git and the shell (Windows, Git Bash)

- **A commit lost its subject line.** `git commit -F - <<EOF && …` swallowed
  it. Write the message to a file first.
- **"LF will be replaced by CRLF" warnings** are noise from line-ending
  settings, not changes. Compare with `git diff --ignore-cr-at-eol` when in
  doubt.
- **Formatting the whole tree reflowed unrelated files.** Format only the files
  you changed, or revert the rest.
- **A long heredoc fails with "unexpected EOF while looking for matching
  `''"**, and none of the command runs. Write the script to a file and run
  the file instead.

## Android emulator

- **Taps open a stylus handwriting sheet.** Use
  `adb shell input touchscreen tap X Y`, not `input tap`.
- **Chained taps land on the wrong screen.** One tap per command, then a
  screenshot, then the next step.
- **The app closed.** `input keyevent 4` (Back) closes it; so can editing key
  events. Use on-screen controls; HOME and relaunching are safe.
- **A link opened Chrome's setup screen instead of the page.** Chrome on a fresh
  emulator shows its first-run screen before any tab. Accepting it is the
  device owner's decision.
