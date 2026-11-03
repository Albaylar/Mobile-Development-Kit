# Architecture Profile

> One file per project. Written by `/architecture` on the first feature, changed only through a new ADR. Every builder and reviewer reads it before touching code. Nothing in it is a suggestion: it is the contract the code must follow.

| | |
|---|---|
| **Project** | |
| **Profile size** | A (small) / B (medium) / C (large, long-lived) |
| **Decided** | YYYY-MM-DD, ADR-001 |
| **Reviewed by** | _name, or "owner (self-reviewed)" on a one-person project_ |

## Platforms
| Platform | In scope | Minimum OS | Toolchain |
|---|---|---|---|
| iOS (SwiftUI) | yes / no | iOS 17 | Xcode 26, Swift 6.2 |
| Android (Compose) | yes / no | API 26 | AGP x, Kotlin x |
| Flutter | yes / no | from the PRD (default iOS 17 / API 26) | Flutter 3.4x, Dart 3.1x |
| Shared core (KMP) | yes / no | | |

## State and layer model
<!-- Exactly one per platform. Options from docs/architecture-catalog.md §2. -->
| Platform | Model | Navigation | DI | Modules |
|---|---|---|---|---|
| iOS | MVVM-C + `@Observable` / TCA 1.x | NavigationStack, coordinator | initializer injection | single target / SPM packages `Features/* Core/* Platform/*` |
| Android | Compose + ViewModel + UDF | Navigation 3 | Hilt | single module / `:feature:*:api,:impl` + `:core:*` |
| Flutter | View → ViewModel/Notifier/Cubit → Repository → Service, Riverpod 3 / Bloc 9 | go_router | Riverpod providers / get_it | single package feature-first / Melos monorepo |

Domain layer (use cases): **no** / **yes, because** …

## Data model
| Question | Answer |
|---|---|
| Source of truth | server only / server + local cache / local DB (offline-first) |
| Local store | SwiftData / GRDB / Room / Drift / Isar / none |
| Sync | none / stale-while-revalidate / queue of pending writes / sync engine (PowerSync, …) |
| Backend | none / Supabase / Firebase / own API (name) |
| Auth | none / email+password / Sign in with Apple + Google / SSO |
| Personal data stored on device | list, or "none" |

## Errors and concurrency
- Error type at layer boundaries: Swift `Result`/typed throws · Dart `Result<T>` + sealed `AppFailure` · Kotlin sealed `Result`
- Off-main work: `@concurrent`/actors · isolates · coroutines with `Dispatchers.IO/Default`
- Logging and crash reporting: none / Sentry / Crashlytics (needs privacy entry)

## Performance budgets (measured by `/perf` on the lowest supported device)
| Budget | Value |
|---|---|
| Cold start to first interaction | ≤ 400 ms |
| Scroll, dropped frames in the main list | ≤ 1 % at 60 Hz |
| Memory after 5 min of use | ≤ … MB |
| App size (download) | ≤ … MB |
| Network write survives app kill | yes / n/a (no network writes) |

## Quality gates
- Build: `xcodebuild … build test` warnings as errors / `flutter analyze` + `dart format` / `./gradlew lint test`
- Tests required per AC: unit + screen test; golden/snapshot from profile B; integration/UI test for cross-screen criteria
- Accessibility: Dynamic Type XXXL, VoiceOver/TalkBack labels, contrast 4.5:1
- Localization: languages …, source of truth: ARB / String Catalog / strings.xml

## Monetization (only if the app sells something; ADR-00n)
| Question | Answer |
|---|---|
| Platform | none / RevenueCat / Adapty |
| Products and entitlements | see `docs/monetization-setup.md` |
| Server-gated features | none / list |
| Entitlement store | RevenueCat Firebase extension (Firestore + custom claims) / Cloud Function → `entitlements/{uid}` / Supabase Edge Function → `entitlements` table / own API |
| State model | `docs/monetization.md` §3 |
| Grace period | Apple on / Google … days |

## Store and release
- Distribution: TestFlight + App Store / Play internal track + Play Store / enterprise
- Required: privacy manifest, Data Safety form, account deletion, Sign in with Apple (if third-party login), ATT (if tracking)
- Release tooling: `asc` CLI / fastlane / Gradle Play Publisher; signing is done by _name_

## Skills active for this profile
<!-- Which vendored skills builders load. Remove what the profile does not use. -->
- iOS: `swift-architecture`, `swiftui-pro`, `swift-concurrency-pro`, `swift-testing-pro`, `swiftdata-pro` (if SwiftData), `swift-security`, `ios-accessibility`, `swiftui-performance-audit`, `ios-simulator`, `appstore-review`, `asc-*`
- Flutter: `flutter-skills-index`, `flutter-architecture`, `flutter-state-management`, `flutter-riverpod3` (if Riverpod), `flutter-result-errors`, `flutter-dart-style`, `flutter-testing`, `flutter-performance`, plus the official `dart-flutter` plugin
- Android: `using-chrisbanes-skills` (router), `android-development`, `compose-*`, `kotlin-*`, `gradle-run`, `android-benchmark-comparison`
