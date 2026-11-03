# Skills catalog (evaluated 2026-11-03)

What was found, what was vendored into `.claude/skills/` (flat folders: Claude Code does not discover skills nested inside group folders), what was left out and why. Provenance (repo, commit, date, license) is in `.claude/skills/SOURCES.md`. Re-vendor with `scripts/vendor-skills.sh`.

Selection rules: (1) prefer the platform team's own material or an author with a track record on that platform; (2) verified against a named toolchain version within the last 6 months; (3) a `SKILL.md` that routes to references rather than a 2.000-line wall; (4) no overlap between two vendored skills on the same topic; (5) MIT or Apache-2.0.

## Vendored

### iOS
| Skill | Source | Why | Used by |
|---|---|---|---|
| `swiftui-pro` | Paul Hudson (twostraws), v2.0, Oct 2026 | Review procedure over 10 reference files: deprecated API, data flow, navigation, resizability, accessibility, localization, performance. The most current SwiftUI reference found | `/ui`, `/qa` |
| `swiftdata-pro` | Paul Hudson, Oct 2026 | SwiftData incl. iOS 26 changes, `@ModelActor`, CloudKit | `/core` |
| `swift-concurrency-pro` | Paul Hudson, May 2026 | Swift 6.2 approachable concurrency, MainActor default, `@concurrent` | `/core`, `/ui` |
| `swift-testing-pro` | Paul Hudson, May 2026 | Swift Testing + XCTest coexistence | every builder, `/qa` |
| `swift-architecture` | efremidze, Sep 2026 | The only iOS skill with a **selection guide**: fit check per feature, playbooks for MVVM, MVI, TCA, Clean, Coordinator. Matches the kit's profile idea | `/architecture` |
| `swiftui-performance-audit`, `swiftui-view-refactor` | Dimillian (Ice Cubes author), Mar 2026 | Body-recompute and identity audits with Instruments; view splitting | `/perf`, `/ui` |
| `swift-security` | ivan-magda, Jun 2026 | Keychain, ATS, biometrics, CryptoKit, Sign in with Apple | `/platform`, `/qa` |
| `ios-accessibility` | dadederk, Mar 2026 | VoiceOver, Dynamic Type, audit checklist | `/ui`, `/qa` |
| `appstore-review` | 3 Paws AI, Jul 2026 | Submission audit ordered by rejection frequency: privacy manifest, entitlements, paywall copy, metadata. Manual trigger only | `/release` |
| `ios-simulator` | conorluddy, Oct 2026 | Drive `simctl` for screenshots, taps, logs | `/qa`, `/perf` |
| `asc-cli-usage`, `asc-release-flow`, `asc-testflight` | rudrankriyam, Oct 2026 | App Store Connect CLI: builds, TestFlight groups, submission. 23 more `asc-*` skills exist in the repo; add on demand | `/release` |

### Flutter
| Skill | Source | Why | Used by |
|---|---|---|---|
| `flutter-skills-index`, `flutter-architecture`, `flutter-dart-style`, `flutter-state-management`, `flutter-testing`, `flutter-performance` | abugeek/flutter-skills, Nov 2026 | Verified against Flutter 3.47 / Dart 3.13 with a dated "verified" line in every skill; weekly refresh script with compile checks; sources are the Flutter team, VGV, LeanCode, riverpod.dev, bloclibrary.dev. Architecture skill scales structure by project size exactly like the kit's profile A/B/C | `/architecture`, `/ui`, `/core`, `/perf`, `/qa` |
| `flutter-result-errors`, `flutter-riverpod3` | Ethiel97, Oct 2026 | Sealed `AppFailure` + `Result` typedefs with one catch boundary (the kit's "errors are values" rule, replaces `Either`); Riverpod 3 without codegen | `/core` |

Not vendored but **installed per machine**: the official `flutter/agent-plugins` (Flutter team, updated 2026-11-03) and `dart-lang/skills`. They bundle the Dart/Flutter MCP server plus task skills (`flutter-add-widget-test`, `flutter-add-integration-test`, `flutter-fix-layout-issues`, `flutter-setup-declarative-routing`, `flutter-setup-localization`, `flutter-apply-architecture-best-practices`, `dart-run-static-analysis`, `dart-add-unit-test`, …). The plugin is the maintained channel; copying it would go stale.

```bash
claude plugin marketplace add flutter/agent-plugins
```
```bash
claude plugin install dart-flutter@dart-flutter
```

### Android
| Skill | Source | Why | Used by |
|---|---|---|---|
| `using-chrisbanes-skills` + `compose-state-and-effects`, `compose-performance`, `compose-component-design`, `compose-ui-testing-patterns`, `compose-animations`, `compose-focus-navigation`, `kotlin-concurrency-and-flow`, `kotlin-control-flow`, `kotlin-api-design`, `gradle-run`, `android-benchmark-comparison` | Chris Banes (ex-Google Android/Compose), Nov 2026, Apache-2.0 | Evidence-first procedures (measure one transition, change one axis); routing skill decides which to load; 395 reference files | `/ui`, `/core`, `/perf`, `/qa` |
| `android-development` | dpconde, Dec 2025 | NowInAndroid module structure (`api`/`impl`), Hilt, Room, Gradle convention plugins, templates. Older, kept for the structure only; Compose detail comes from chrisbanes | `/architecture` |

Left out of the chrisbanes pack on purpose: `shepherd`, `to-plan`, `implement-with-subagents`, `subagent-delegation`, `deliver-spec`, `run-github-project`, `release-kotlin-library`, `changelog`, `grounded-writing`. They are workflow skills that compete with the kit's own `/tasks`, `/qa`, `/release`; their rows are removed from the router skill (noted in `SOURCES.md`).

## Evaluated and not taken
| Candidate | Reason |
|---|---|
| koshkinvv/ios-agent-skills (9 skills, 23.500 lines) | Good breadth, but Swift 5.9 / pre-6.2 concurrency, last update Mar 2026, and every topic overlaps a vendored skill that is newer. Candidate for `ios-networking` if a project needs a URLSession client playbook |
| fal3/claude-skills-collection | iOS 18 baseline, Xcode 16; overlaps. `swiftdata-core-data-migrations` is worth pulling for a Core Data migration project |
| Jeffallan `swift-expert`, `flutter-expert` (installed globally on this Mac) | Generic single-file skills, Riverpod 2 / Bloc 8, Flutter 3.19. Superseded by the vendored packs. Consider disabling globally so they do not compete |
| vp-k/flutter-craft, Arcturus91/claude-flutter-skill, 9evxxx/flutter-skill, zero-labsco | Opinionated full-clean-architecture or Firebase-centric; not verified against a toolchain version |
| `write-swift`, `swift-concurrency`, `swiftui-liquid-glass`, `ios-hig-design`, `mobile-ios-design` (installed globally) | Keep; they complement rather than overlap (`write-swift` is language style, `swiftui-liquid-glass` iOS 26 UI). `ios-hig-design` and `mobile-ios-design` overlap each other: keep one |
| alinaqi/claude-bootstrap android-kotlin, claudskills android-* | Short general prompts, no references |
| Dimillian `review-swarm`, `bug-hunt-swarm`, `ios-debugger-agent` | Workflow/multi-agent skills; revisit when the kit's `/qa` needs a debugger agent |

## Gaps (no good skill found; write our own)
- **Offline-first sync engine** (PowerSync / own queue) for iOS and Flutter: nothing beyond vendor docs. Write it from the profile's sync decision; an own queue needs the rules: entries deleted only after server confirmation, server-side IDs, idempotent retries, storage-full handling.
- **KMP shared core + native UI** profile: no skill; JetBrains docs only.
- **Store policy as rules** (`rules/store.md`): `appstore-review` covers iOS submission; Play Data Safety, target SDK and account-deletion rules have no equivalent skill.
- **`/perf` procedure** that reads the profile's budgets and runs Instruments / Macrobenchmark / DevTools: assemble from `swiftui-performance-audit`, `compose-performance`, `flutter-performance`.
- **`/release`** orchestration (fastlane or `asc-*` + Gradle Play Publisher): write as a kit skill with `[HUMAN]` steps for signing.

## Keeping skills current
`scripts/vendor-skills.sh` re-clones every source at depth 1 and rewrites `SOURCES.md`. Run it before a new project starts; diff the result; read the changed `SKILL.md` files before committing. abugeek's pack ships its own `update.py`; the Flutter plugin updates through `claude plugin update`.
