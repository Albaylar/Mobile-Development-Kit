---
paths:
  - "**/*.kt"
  - "**/*.kts"
  - "**/AndroidManifest.xml"
  - "**/res/**"
  - "**/gradle/**"
---

# Android Rules (Kotlin, Jetpack Compose, Navigation 3)

Android native is in the kit as a platform pack; whether a project uses it comes from the profile. Vendored Android skills (platform "android" in `.claude/skills/SOURCES.md`): `using-chrisbanes-skills` routes Kotlin/Compose work, `android-development` holds the NowInAndroid-style module and layer structure.

## Architecture (from the profile)
- Google's recommended architecture: Compose UI → ViewModel exposing `UiState` → repository → data source, **UDF in every layer**. ViewModels never hold `Context` or Compose types.
- Navigation 3 (Compose-first, the app owns the back stack). Not the old `NavController` graph in new code.
- Modules: profile B/C use `:feature:<name>:api` + `:feature:<name>:impl`, `:core:*`, convention plugins in `build-logic/`. Feature modules depend on `api` modules only.
- DI with Hilt (or Koin when the ADR says so); no service locators in ViewModels.

## Concurrency and state
- Coroutines + `Flow`/`StateFlow`, structured, lifecycle-aware collection (`collectAsStateWithLifecycle`). No raw `Thread`, `Executor`, `AsyncTask` (`kotlin-concurrency-and-flow`).
- State is immutable data classes; sealed classes for results and UI events, exhaustive `when` (`kotlin-control-flow`).
- Compose: state hoisted, side effects only in effect handlers, stable parameters, deferred reads for frame-rate state (`compose-state-and-effects`, `compose-performance`).

## Performance
- Release build with R8 for every measurement. App-specific Baseline Profile generated and regenerated whenever the startup or main-scroll path changes; Macrobenchmark in CI (`android-benchmark-comparison`).
- Secrets in EncryptedSharedPreferences / Keystore; nothing in `strings.xml` or `BuildConfig` that must stay private.

## Verification
- `./gradlew lint testDebugUnitTest` + Compose UI tests (`compose-ui-testing-patterns`) + screenshot tests in profile B/C. `gradle-run` skill owns how Gradle is invoked.
- Play Data Safety form, account deletion and target SDK level are checked in `/release`.
