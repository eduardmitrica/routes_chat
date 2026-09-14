# Conventions and workflow

## Code

- **Match the file you are in:** its naming, its comment density, its idioms.
  New code should read as if the same person wrote the whole file.
- **Names are spelled out:** `messageRepository`, not `msgRepo`.
  Private members start with `_`.
- **Comments explain why, or what something is for,** in plain full
  sentences. Doc comments (`///`) on public classes and non-obvious members;
  none that repeat the code. Reference other code with `[brackets]`.
- **Errors:** repositories return `Either`; blocs turn failures into state;
  screens show a plain sentence for each failure (snackbar or inline). A write
  that fails must never look like success.
- **User-facing text:** sentence case, short, friendly, and specific about
  what happened and what to do.
- **Imports:** in a file that declares a `StatefulWidget`, import `dartz` with
  `show` (for example `show optionOf`). dartz exports its own `State`, which
  clashes with Flutter's.
- **Theme:** colors come from `Theme.of(context).colorScheme` or
  `AppColors.of(context)`, never `Colors.x` or `Color(0x…)` in a screen.
  Component text styles in the theme come from
  `Typography.material2021().englishLike`, because `ThemeData().textTheme` has
  no sizes until the theme is applied.
- **Buttons:** `FilledButton` for the main action, `OutlinedButton` for an
  alternative, `TextButton` for a way around.
- **Accessibility:** tap targets of at least 48; semantics for custom gestures
  (for example a "Reply" custom action alongside swipe-to-reply); honour
  `MediaQuery.disableAnimationsOf`.
- **Privacy in code:** no logging of decrypted content, keys, tokens or search
  queries; `toString()` overrides on classes that hold them.

## Git

- **Branches:** `feature/…`, `fix/…`, `chore/…`, `docs/…`, created from
  `develop`.
- **Merging:** merge into `develop` with `git merge --no-ff`, then open a pull
  request from `develop` to `main`, assigned to the project owner. The owner
  merges.
- **`main` is protected:** the `flutter test` check is required and direct
  pushes are blocked. Never force-push `develop` or `main`, and do not turn on
  automatic deletion of head branches (every pull request's head is
  `develop`).
- **Deleting branches:** delete merged branches only when the owner asks.
- **Commit messages:** `type(scope): subject` (`feat(chat): …`,
  `fix(e2ee): …`, `chore(functions): …`), then a body that explains what
  changed for the user and why, in plain sentences or short bullets. Write the
  message to a file and use `git commit -F <file>`; a heredoc chained with
  `&&` can swallow the subject line.
- **Staging:** stage explicit paths. Do not stash files whose only difference
  is line endings; a stash can be created and then dropped by mistake.
- **Stashes:** never drop or pop stashes you did not create.
- **Pull request description:** what changed, how it was tested (commands,
  counts, device checks), anything deployed, and anything left for the owner.

## Never commit

- `.env`, `functions/.env`, `firebase.json`, `google-services.json`,
  `GoogleService-Info.plist`, or literal values in `firebase_options.dart`.
- Assistant-local files: `CLAUDE.md` and `.claude/`.
- Scratch scripts, screenshots or test vectors that contain throwaway keys.
  Paste only the vector fields a test needs.

## Ask the owner first

- Deploying rules, indexes, Storage rules or functions.
- Deleting data, users, branches or build artifacts.
- Anything that sends messages or notifications to real users.
- Changing branch protection, CI job names, billing or cloud policies.
- A decision with a real trade-off (privacy, cost, user experience): present
  the options with a recommendation.
