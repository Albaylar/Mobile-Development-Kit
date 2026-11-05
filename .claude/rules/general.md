# General Engineering Rules (mobile kit)

These rules apply to every project built with this kit, on every platform. Platform rules live in `ios.md`, `flutter.md`, `android.md` and load only when files of that platform are edited. The architecture a project uses is not fixed by the kit: it is chosen per project in `docs/architecture-profile.md` (see "Architecture profile").

## Before any work
- `docs/PRD.md` still a template → run `/init`, write no code.
- `docs/architecture-profile.md` missing → the first feature that reaches `/architecture` writes it (profile + ADR-001). No UI or data code before the profile exists.
- A feature not in `features/INDEX.md` → `/write-spec` first.
- Read `features/INDEX.md`, `docs/system.md`, `docs/architecture-profile.md` and the feature folder before starting. After context compaction read them again plus `git diff`.

## Architecture profile (the one rule that replaces "pick a stack")
- The profile names: platform(s), state/layer model, data model (server-only / cached / offline-first + sync engine), minimum OS, performance budgets. `/architecture` picks it from the catalog in `docs/architecture-research.md` §2 and records an ADR under `docs/adr/`.
- Every builder follows the profile. Deviating is a change request (`/refine`), never a silent choice. The matching platform skill (`swift-architecture`, `flutter-architecture`, `android-development`) is loaded with the profile, not by guess.
- Separation of concerns is non-negotiable in every profile: UI never talks to the network or storage directly; business logic has no UI imports; data access goes through repositories.

## Code quality and verification
- Always read an existing file before modifying it. Never guess type names, module names, package versions or API signatures: read the project, `Package.swift`, `pubspec.yaml`, `build.gradle.kts`, or current docs (Context7, else the official docs, and say so).
- A task is not complete while the type checker, analyzer or compiler reports an error or a new warning. Zero new warnings, not "mostly green".
- Test first: every AC and EC in a spec has a test that fails before the code exists and passes after (unit, widget/Compose/SwiftUI snapshot, or integration/UI test). Red is proven by running the new test before the code; sabotage is `/qa`'s tool (and the builder's only in fix mode, where the code already exists). Never weaken an assertion to go green. 0 tests run counts as failed.
- **Verification ladder** (`docs/verification-ladder.md`, commands in `scripts/verify.sh`): L0 compile after every edit, L1 only the task's tests (red, then green), L2 the touched module's suite once per level, L3 the full command once before the builder reports (detached, UI tests excluded), L4 UI/integration tests, snapshot matrix, device poses and sabotage in `/qa`. Nobody runs the full suite after a single step; nobody skips L3 before reporting. One DerivedData per repository, no `clean`, no `sleep` polling, no `pkill` on builds. A run over its budget is reported as "test loop too slow", never answered by weakening a rung.
- No overengineering: the simplest thing that satisfies the spec and the profile. No abstraction, option, dependency or layer nobody asked for. A domain/use-case layer exists only where the profile says so.
- Errors are values at layer boundaries (Swift `Result`/typed `throws`, Dart `Result<T>`/sealed failure, Kotlin `Result`/sealed class). Nothing throws across a layer boundary; the UI never sees raw HTTP codes or exception text.
- Immutable state models. The UI renders state, it does not mutate models.
- Concurrency is explicit: work that is not UI runs off the main thread with the platform's structured concurrency (Swift `async`/actors, Dart isolates, Kotlin coroutines). No legacy threading primitives (GCD/`DispatchQueue`, raw `Thread`, `Timer` polling) in new code.
- Performance budgets from the profile are measured, not assumed (`/perf`): cold start to first interaction, scroll jank, memory on the lowest supported device. Debug builds are never the basis of a performance claim.

## Mobile specifics that web rules do not cover
- Secrets never ship in the bundle: no API keys in source, plist, `strings.xml`, Dart constants or `.env` copied into assets. Use Keychain / EncryptedSharedPreferences / `flutter_secure_storage`; the server holds third-party keys.
- Permissions are requested at the moment of use with a usage string in every supported language (notifications have no usage string: the in-app explanation before the prompt takes its place); the app works when a permission is denied.
- Offline, slow network and app-kill mid-request are normal states, not edge cases: every network write survives them (queue or retry) when the profile is "cached" or "offline-first".
- Every user-visible string is localized from day one (`String(localized:)`, `AppLocalizations`, `strings.xml`). No hardcoded UI text.
- Accessibility is part of done: Dynamic Type / font scaling, VoiceOver / TalkBack labels, contrast 4.5:1, reduce motion.
- Store readiness is a gate (`rules/store.md`, `appstore-review` skill): privacy manifest, data safety / nutrition labels, account deletion, Sign in with Apple when third-party login exists.

## Documents and status
- `features/INDEX.md` is the only place for status, owner, priority, dependencies, effort. Specs carry no status or effort; dates appear only in the Decisions table and the sign-off lines. File names (`spec.md`, `architecture.md`, `tasks.md`, `qa-report.md`, `perf-report.md`) stay fixed whatever the document language; template headings stay as in the template, body text is in the document language.
- Each feature: `features/PROJ-X-name/` (lower-case kebab name in the document language) with `spec.md` (contract: user stories, AC-n, EC-n, out of scope, decisions, sign-offs), `architecture.md` (how, within the profile), `tasks.md` (task plan with coverage table), `qa-report.md`.
- `docs/system.md` describes the current state of the app (modules, screens, data, tests). Builders update it; nobody appends history.
- Always read a file before changing it; write status changes with the Edit tool; re-read to verify.

## Gates
Roadmap → Planned → **Signed Off** → (Designed) → Architected → In Progress → In Review → Approved → **Accepted** → Released (in review) → Released
- Gate 1: the client approved the spec. Gate 2: the client accepted the build (TestFlight / internal track link). Never skip a gate.
- **Solo mode:** when the PRD names the reviewer as "owner (self-reviewed)", the gates stay but the ceremony goes: `/signoff` records in one step without an interview, `/design` is skipped for features without a screen, `/architecture` and `/tasks` ask once at the end, each documentation step commits once. Infrastructure features carry at most 8 AC and 4 EC; the roadmap shows a product-visible screen by the third feature.
- `/ui`, `/core`, `/platform`, `/backend` refuse to start without `tasks.md`. Sub-agents never ask: they stop and report.
- `/qa` decides, never a builder: it runs in the main conversation (simulator) with the independent `qa-engineer` agent in parallel; neither fixes anything. Fix loop: In Progress → builder (failing test first) → `/qa` → acceptance again.
- Store review is outside our control: `/release` records submission and outcome, a rejection reopens the fix loop.

## Git
- Branches `feat/PROJ-X-name` from `dev`, `fix/name`, `chore/name`. Never commit to `main` or `dev`. Claude never merges. Commits `type(PROJ-X): description`.
- Build numbers (`CFBundleVersion`, `versionCode`, `version+build` in `pubspec.yaml`) change only in `/release`.

## Human in the loop
- One question at a time, always with a recommended answer. Ask before finalizing a deliverable; suggest the next command instead of asking permission for it. Account, tool and dashboard work is collected once in the `[HUMAN]` pre-flight list from `/init`, not discovered inside builder runs.
- One Claude Code session per checkout. Parallel work runs as sub-agents inside it, never as a second session on the same working tree.
- Builders commit after every task and leave a one-line progress note, so a resume costs a minute: it reads ticks and `git log`, it does not re-run suites to find out where it is. A run that ends without a report was cut off (limit, network, compaction): resume the same builder. `maxTurns` in the agent files is a runaway guard, never a budget for a run.
