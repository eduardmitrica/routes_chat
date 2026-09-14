# Guide for AI coding assistants

Orientation for an assistant, or a new contributor, working on routes_chat:
what lives where, which rules the code keeps, and how a change is proven to
work. Each page is short; read the one for the area you are about to touch.

| Page | Read it before |
|---|---|
| [architecture.md](architecture.md) | adding or moving code: layers, dependency rules, blocs, repositories, wiring |
| [features.md](features.md) | changing a feature: where each one lives, from domain to screen |
| [firebase-and-security.md](firebase-and-security.md) | touching Firestore, rules, Storage, Cloud Functions or encryption |
| [testing-and-verification.md](testing-and-verification.md) | proving a change works: commands, test patterns, guard tests, device checks |
| [conventions-and-workflow.md](conventions-and-workflow.md) | writing code, comments, commits, branches and pull requests |
| [pitfalls.md](pitfalls.md) | debugging something that should work but does not |

[docs/e2ee.md](../e2ee.md) is the end-to-end encryption specification. It is
authoritative for anything cryptographic; these pages only summarise it.

## The short version

- Flutter app, Domain-Driven Design layers (`domain`, `application`,
  `infrastructure`, `presentation`), BLoC for state, Firebase behind repository
  interfaces.
- Messages are end-to-end encrypted. The server stores ciphertext only, and no
  new feature may put message content or message metadata outside the
  encryption.
- `getIt` is used only in `lib/injection.dart` and `lib/presentation/`.
- Firestore is a named database, never `(default)`.
- Many rules are enforced by tests in `test/architecture/` and by tests that
  compare Dart classes with `firestore.rules`. A red test there usually means a
  production failure was prevented, not that the test is wrong.
- Work goes on a branch, is merged into `develop`, and reaches `main` through a
  pull request that CI must pass.

## Keeping this guide true

When a change moves a rule, a file or a workflow described here, update the
page in the same pull request. A guide that is out of date costs more than no
guide.
