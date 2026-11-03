---
name: core
description: "Work through the [CORE] tasks of a feature: models, repositories, services, local store, sync and state holders (ViewModels, notifiers, stores) with unit tests, inside the project's architecture profile, in an isolated sub-agent. After /tasks (and /backend if the feature has [BE] tasks), before /ui."
argument-hint: "PROJ-X"
context: fork
agent: core-dev
background: false
---

# Core Developer

Build the non-UI layers for feature $ARGUMENTS. Follow `.claude/skills/BUILDER.md` for the procedure; this file adds what is specific to [CORE].

## Specific rules
- Layer order from the profile: service (one per external source) → repository (source of truth, abstract + fake) → state holder (one per screen, no UI imports). Domain/use-case layer only if the profile says so.
- Errors are values: Swift `Result`/typed throws, Dart `Result<T>` + sealed `AppFailure` (`flutter-result-errors`), Kotlin sealed result. One guard at the data-source boundary.
- Concurrency explicit and off-main: `swift-concurrency-pro` (actors, `@concurrent`), isolates for heavy Dart work, coroutine dispatchers (`kotlin-concurrency-and-flow`).
- Data store and sync exactly as the profile names (`swiftdata-pro`, Room, Drift, GRDB, PowerSync). Offline queues: entries removed only after server confirmation, server-side IDs, idempotent retries, storage-full handled.
- Models immutable. No `Map<String, dynamic>` or `[String: Any]` past the service boundary.
- Secrets in Keychain / Keystore / `flutter_secure_storage`, never in source or prefs.
- Purchases: one `EntitlementService` behind a protocol wrapping the platform SDK (RevenueCat / Adapty); `logIn` with the backend user id after sign-in, `logOut` on sign-out; UI reads entitlement state from it; server-gated data is never unlocked from the client flag alone (`rules/monetization.md`).

## Tests
Unit tests with fakes (not mocks of internals) for every repository and state holder: happy path, failure path per `AppFailure` case, offline/retry, concurrent double call. Test command from the platform rule file; `swift-testing-pro` / `flutter-testing` / `compose-ui-testing-patterns` for patterns.

## Handoff
Next: "`/ui PROJ-X`" (or `/platform` if no [UI] tasks remain, else `/qa`).
