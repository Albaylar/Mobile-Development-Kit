# Verification ladder: fast loops without losing correctness

> Why builder runs take hours, what was measured, and the structure that replaces "full build and test after every step". Every builder, `/qa` and `/audit` follow this file. The commands live in `scripts/verify.sh`.

## 1. What was measured

The first app built with the kit (native iOS, profile B, Supabase, two infrastructure features) was traced through its Claude Code transcripts: every tool call, its duration and its command.

| Where the wall-clock time went | Minutes | Calls |
|---|---|---|
| `xcodebuild … test` on the whole scheme (unit + snapshot + XCUITest) | 229 | 88 |
| `supabase test db` on the whole test directory | 45 | 59 |
| `supabase start` between tasks | 15 | 9 |
| `sleep`/`pgrep` polling loops around builds that hit the 10-minute tool limit | 43 | 62 |
| Targeted test runs (`-only-testing:`) | 32 | 8 |
| Compile-only runs | 21 | 39 |

One `/ui` run of three tasks lasted 102 minutes; 65 of them were 18 full-scheme test runs of 4 to 10 minutes each. The same project through `scripts/verify.sh`, same machine, same day, warm DerivedData:

| Rung | Command | Wall time | Tests |
|---|---|---|---|
| L0 first compile into a cold `.build/DerivedData` (app, six packages, backend SDK, snapshot macros) | `verify.sh compile` | 109 s, once | |
| L1 one suite of the app target | `verify.sh only <App>Tests/LocalizationTests` | 62 s (28 s testing, the rest the incremental `build-for-testing`) | 3 |
| L2 one core package | `verify.sh suite Packages/Core/Account` | 26 s | 22 |
| L2 app target without UI tests (unit + snapshot) | `verify.sh suite` | 22 s alone, 56 s while another `xcodebuild` ran on the same checkout | 30 |

Against 4 to 10 minutes per full-scheme run before: roughly ten times less waiting per red→green step, with the same tests.

Where the minutes came from, in order of weight:

1. **The rule itself.** `BUILDER.md` said "full build and test command of the profile passes" and the platform rule named a single `xcodebuild … build test` command. A builder that follows the rule literally runs app, unit tests, 185 snapshot images and seven XCUITests on a simulator after each red→green step. Correct, and six to ten times slower than needed.
2. **UI tests inside the default scheme.** The app scheme's test action listed the XCUITest target, so every "run the tests" launched the app on the simulator seven times.
3. **Fresh DerivedData per package.** Running `xcodebuild` from inside each local package, sometimes with a scratch `-derivedDataPath`, rebuilt `swift-syntax` (a macro dependency of the snapshot library) once per package: minutes each time.
4. **The 10-minute tool limit.** A full run longer than 10 minutes was cut off, re-run in the background, polled with `sleep 10` loops, and killed with `pkill xcodebuild` before the next attempt. Killed builds leave partial products, which made the next run slower again.
5. **Sabotage by the builder.** Builders proved "red" by breaking working code and running the full suite (13 runs), although the test written before the code is already the red proof. Sabotage is `/qa`'s tool.
6. **Resumes.** Builders were restarted 13 times over two features (context compaction, a network cut, a stop without a report). Each resume re-read every document and re-ran a suite "to see where it is": 10 to 15 minutes per resume.
7. **Ceremony on a one-person project.** 29 of 43 commits were documentation; PROJ-1 spent 36 minutes and 12 commits on spec → sign-off → design (no screens) → architecture → refine → sign-off → design → refine → tasks before the first line of code.
8. **Infrastructure before product.** Two setup features carried 49 acceptance criteria, 18 edge cases, 54 tasks and 12 `[HUMAN]` tasks; no product screen existed after 17 working hours.
9. **Account work inside the loop.** Docker, the backend plan, the developer account and the team id were discovered as blockers inside builder runs instead of before PROJ-1.
10. **Two sessions on one checkout.** QA in one, design in another, which left uncommitted code from an interrupted run in the working tree and a branch nobody owned.

## 2. The ladder

Verification is tiered. Each rung has a scope, a budget and an owner. A rung is never skipped upward, and a lower rung is never replaced by a higher one "to be safe".

| Rung | When | Scope | Budget | Owner |
|---|---|---|---|---|
| **L0 compile** | after every edit | type-check / analyze what changed | seconds | builder |
| **L1 targeted** | per task, twice (red, then green) | only the tests named with the task's AC/EC ids | < 2 min per run | builder |
| **L2 suite** | once per level, before the commit | every unit and screen test of the modules the level touched; no UI tests, no device matrix | < 5 min | builder |
| **L3 full** | once, before the builder reports | the profile's full command without UI/integration tests, every module | < 10 min, detached | builder |
| **L4 device** | `/qa` and `/perf` only | UI/integration tests, snapshot matrix, poses, accessibility, sabotage | as needed | main session |

What each rung proves:

- L0: the code still compiles with warnings as errors. Nothing about behavior.
- L1: the criterion's test fails before the code exists (red for the right reason) and passes after. This is the red→green evidence in the coverage table. **Red is proven by running the new test before the code, never by sabotage** (sabotage is for fix mode, where the code already exists, and for `/qa`).
- L2: the level did not break the module's other tests.
- L3: the feature did not break the app. **0 tests run counts as failed**: read the executed count.
- L4: the app behaves on a device the way the spec says, and the tests can fail (sabotage of two AC tests).

Correctness is unchanged: every criterion still has a test that was red first, the whole suite still runs before anything is reported, QA still sabotages and still runs the device matrix. What changes is *how often* each rung runs and *how wide* it is.

## 3. Commands

`scripts/verify.sh` wraps the platform tools so every builder uses the same, warm, capped commands. It detects the platform from the repository (Xcode project, `pubspec.yaml`, `gradlew`).

```
scripts/verify.sh compile [module]                 L0
scripts/verify.sh only <Target/Suite[/test]>...    L1 (app target)
scripts/verify.sh only --module <path> <Suite>...  L1 (local package / module)
scripts/verify.sh suite [module]                   L2
scripts/verify.sh full                             L3, detached; then: scripts/verify.sh wait full
scripts/verify.sh ui                               L4, detached; then: scripts/verify.sh wait ui
scripts/verify.sh status
```

Behind it, per platform:

| Rung | iOS | Flutter | Android |
|---|---|---|---|
| L0 | `xcodebuild build-for-testing` into a fixed `.build/DerivedData` (`-skipMacroValidation -skipPackagePluginValidation -disableAutomaticPackageResolution`); package: `xcodebuild build -scheme <Pkg>` with the same DerivedData | `dart analyze <path>` + `dart format --set-exit-if-changed <path>` | `./gradlew :module:compileDebugKotlin` |
| L1 | `xcodebuild test-without-building -xctestrun … -only-testing:Target/Suite` ; package: `-scheme <Pkg> -only-testing:… test` | `flutter test <file> [--plain-name "…"]` | `./gradlew :module:testDebugUnitTest --tests 'Class'` |
| L2 | `test-without-building -skip-testing:<UI targets>`; package: `-scheme <Pkg> test` | `flutter test test/features/<name>` | `./gradlew :module:testDebugUnitTest` |
| L3 | app without UI targets + every package scheme, one shared DerivedData | `flutter analyze` + `flutter test` (goldens included) | `./gradlew lint testDebugUnitTest` |
| L4 | `-only-testing:<UI targets>`, snapshot matrix, Device Hub poses | `flutter test integration_test -d <device>`, Patrol | `connectedDebugAndroidTest`, screenshot tests, foldable emulator |

Rules that keep the ladder fast:

- **One DerivedData per repository** (`.build/DerivedData`, git-ignored). Never a scratch `-derivedDataPath`, never `clean`. Macro dependencies compile once: on the reference project the first `verify.sh compile` into a cold DerivedData (app, six local packages, Supabase SDK, snapshot library and its macros) took 109 seconds; later compiles are incremental.
- **UI and integration tests are not in the default test action** of the app scheme, or they are skipped by name in L1 to L3. They run in L4.
- **Snapshot tests are few and stable:** per screen one light, one dark, one smallest-device-at-XXXL image; no matrix per state. Images that differ between runs (hosted captures at regular width, animated glass) are not snapshots, they are `/qa` checks.
- **Never poll a build with `sleep`, never `pkill` a build.** `verify.sh` caps foreground rungs and runs L3 and L4 detached with a log and an exit file; `wait` reads them. A killed build is a finding, not a retry.
- **A single run over its budget is reported** under "Implementation notes" with the command and the time ("test loop too slow"); the fix is in the harness (scheme, DerivedData, test scope), never in weakening a rung.
- **Backend:** `supabase test db supabase/tests/<file>.sql` per task, the directory per level; `supabase start` once per session, `db reset` only after a migration changed.

## 4. The rest of the speed kit

The ladder fixes the build loop. Four more rules fix the process around it.

**Interruptible builders.** A builder commits after every task (not per level) and writes one line under "Implementation notes" (`T-n done, evidence, time`). A resume reads the ticks and `git log`, not the suites: orientation costs a minute, not fifteen. A builder that stops without a report has failed its run.

**Solo mode.** The PRD names the reviewer. When it is "owner (self-reviewed)": `/signoff` records the sign-off in one step without an interview; `/design` is skipped for Infrastructure features and for any feature without a screen; `/architecture` and `/tasks` ask for approval once, at the end; documentation steps commit once each.

**Infrastructure diet.** An Infrastructure feature has at most 8 acceptance criteria and 4 edge cases; the rest goes to "Out of scope" with the feature that will need it. The roadmap from `/init` shows a product-visible screen by the third feature at the latest. Backend setup starts with auth plus the first table the first product feature needs; promotion scripts, production projects and schedules come with the feature that needs them.

**Pre-flight, one session.** `/init` ends with a `[HUMAN]` pre-flight list (developer accounts, backend organization and plan, Docker, simulators, CLIs, dashboards), done before PROJ-1 is planned. One Claude Code session per checkout; parallel work goes to sub-agents inside it, never to a second session on the same working tree.

## 5. What `/audit` checks

Check 11 (speed): a `verify.sh` exists and its L1 completes under two minutes on the main target; no scratch DerivedData paths or `clean` in builder notes; no run over its budget without a "test loop too slow" note; builders commit per task; the ratio of `docs:` commits to code commits since the last audit; `[HUMAN]` account tasks appear only in the pre-flight list or in level 1 of the feature that needs them.
