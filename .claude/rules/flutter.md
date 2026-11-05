---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
  - "**/analysis_options.yaml"
  - "**/l10n.yaml"
  - "**/melos.yaml"
---

# Flutter Rules (Dart 3.13+, Flutter 3.4x, Impeller)

The vendored Flutter skills (platform "flutter" in `.claude/skills/SOURCES.md`) own the detail; `flutter-skills-index` says which one to load. The official Flutter plugin (`claude plugin marketplace add flutter/agent-plugins`, then `dart-flutter@dart-flutter`) adds the Dart/Flutter MCP server and the task skills (widget tests, integration tests, layout fixes, routing, localization). Install it per machine; it is not vendored.

## Architecture (from the profile)
- Layering follows the official guide: **View → ViewModel/Notifier/Cubit → Repository → Service**. Widgets are dumb, data flows one way, repositories are abstract classes with fakes for tests, repositories never depend on each other (`flutter-architecture`).
- Folder structure is **feature-first** at the top (`lib/features/<name>/`), layers inside the feature. This overrides the "data by type, UI by feature" Compass layout shown in the vendored `flutter-architecture` skill; the skill owns everything else. Profile C: one Dart package per feature in a pub workspace / Melos monorepo.
- A **domain layer (entities, use cases)** exists only in profile C or where the ADR names complex, shared business logic. In profile A/B the ViewModel calls the repository directly; adding use cases there is overengineering.
- State management is one of **Riverpod 3** (default; `flutter-riverpod3`, no codegen unless the ADR says so) or **Bloc 9** (large team, auditable event log). Never both, never GetX, never `setState` for cross-screen state (`flutter-state-management`).
- State models are immutable (`freezed` sealed classes, or plain `final` classes + `==`/`hashCode`). No mutable lists inside state.

## Errors
- Repositories and data sources return **`Result<T>` with a sealed `AppFailure`** (`flutter-result-errors`); exactly one guard catches infrastructure exceptions. `Either<Failure, T>` from `dartz` is not used: the package is unmaintained; `result_dart` or the app's own sealed type gives the same guarantee with exhaustive `switch`.
- Presentation folds the `Result` into UI state; it never shows `exception.toString()`.

## Performance
- `const` constructors wherever possible (lint `prefer_const_constructors` is an error, not a hint). No work in `build()`. `ListView.builder` / slivers for any list that can exceed one screen. `RepaintBoundary` around animated or frequently repainted subtrees; `cacheWidth`/`cacheHeight` on network images (`flutter-performance`).
- CPU-heavy work (JSON > ~100 KB, image processing, crypto) runs in an isolate (`compute` / `Isolate.run`), never on the UI isolate.
- Impeller is the renderer on both platforms; shader warm-up checked in `/perf`. Performance is measured only in `--profile` builds.
- Foldables (iPhone Duo, Android): treat the app as a resizable window (`LayoutBuilder`, breakpoints by width, no device checks). `MediaQuery.displayFeatures` is populated only on Android; fold-aware layout on the iPhone Duo needs a plugin named in an ADR (`docs/iphone-duo.md`).

## Verification
- `flutter analyze` with `very_good_analysis` (or `flutter_lints` + the kit's extra rules) and `dart format --set-exit-if-changed` pass before a task is done.
- Commands through `scripts/verify.sh` (`docs/verification-ladder.md`): L0 `verify.sh compile lib/features/<name>` = `dart analyze` + `dart format` on the path; L1 `verify.sh only test/<file>_test.dart "<test name>"`; L2 `verify.sh suite test/features/<name>`; L3 `verify.sh full` (analyze + every test, goldens compared, never `--update-goldens` inside the loop); L4 `verify.sh ui` = `integration_test` on a device in `/qa`.
- Tests (`flutter-testing`): unit for repositories and notifiers with fakes, widget tests per screen, golden tests (Alchemist) for profile B/C: per screen one light, one dark, one smallest-device-at-large-font image; `integration_test` (or Patrol for native dialogs) for every AC that crosses screens, run in L4 only.
- Localization through `flutter_localizations` + `intl` ARB files from the first screen; `l10n.yaml` present.
