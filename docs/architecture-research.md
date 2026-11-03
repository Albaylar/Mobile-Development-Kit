# Mobile architecture research (2026)

> Date: 2026-11-03. Sources: Apple, Google and Flutter official documentation, JetBrains and Point-Free announcements, practitioner articles from 2025–2026 (listed at the end). Figures from non-official sources (start-up gains and similar) are marked "reported". The decision rules derived from this research are in `architecture-catalog.md`; this file is the evidence behind them.

## 0. Principle: the architecture is a profile, not a fixed stack

The kit is not nailed to one stack. Each project picks an **architecture profile**; the profile decides which rules and agent instructions apply. The same kit can build a 3-screen tool and a 60-screen offline field app with different architectures.

A profile answers three questions:
1. **Platform:** native iOS (SwiftUI), native Android (Compose), Flutter, or a KMP shared core.
2. **State and layer model:** one entry from the catalog.
3. **Data model:** server only, local cache, or offline-first + sync engine.

The answers go into `docs/architecture-profile.md`; `/architecture` writes the ADR, and `/ui`, `/core`, `/qa` and `/audit` fail when code leaves the profile.

---

## 1. State per platform (2026)

### 1.1 Native iOS (SwiftUI, Swift 6.2, Xcode 26, iOS 26)
- **Default: MVVM + `@Observable`.** Observation (iOS 17+) removed most of the need for Combine; 2026 articles treat it as the default for small and medium projects. With coordinators and DI, "MVVM-C" is the most common recommendation.
- **TCA (The Composable Architecture):** strict unidirectional state, deep testing, large teams. Cost: tight coupling to the library, slow first build, a lot of DI. **TCA 2.0 is in beta** ("ground-up reimagining") with no release date. The kit offers TCA as a profile but pins 1.x until 2.0 is stable and records that in the ADR.
- **Modularity:** SPM feature packages are an axis independent of the state model. Medium and large projects use `Features/*`, `Core/*`, `Platform/*` packages.
- **Swift 6.2 "Approachable Concurrency":** Xcode 26 creates new projects with `Default Actor Isolation = MainActor` and Approachable Concurrency on. That is the right start for UI-heavy targets; heavy work is moved off the main actor explicitly with `@concurrent` or `nonisolated`. **Caveat:** new SPM packages do not inherit the setting; it must be set in `swiftSettings`. Massicotte warns that MainActor-by-default is a long-term mode that can make real concurrency problems harder to understand. Kit rule: the UI target is MainActor by default; `Core`, networking and persistence packages are **explicitly** actors or nonisolated.
- **Persistence:** SwiftData (iOS 17+, simple to medium model, private CloudKit) · GRDB (performance, raw SQL, aggregates) · Core Data (mature migrations, shared CloudKit). SwiftData has no aggregate queries (sum/avg); iOS 26 fixed the `@ModelActor` view-update bug back to iOS 17. Sources treat performance as inversely proportional to abstraction; there are no measured iOS 26 numbers. Kit rule: offline-first or > 10k rows → GRDB; otherwise SwiftData.
- **Minimum target:** iOS 26 ran on ~79 % of iPhones using the App Store in June 2026; an **iOS 17 floor** is reasonable.

### 1.2 Native Android (Kotlin, Jetpack Compose, Navigation 3)
- **Official recommendation (developer.android.com):** Compose + layered architecture (UI / optional domain / data) + **unidirectional data flow in every layer** + ViewModels exposing UI state + **Navigation 3** (Compose-first, the app owns the back stack, replacing `NavController` graphs). Part of the navigation page still says Navigation Compose; the kit follows Navigation 3 and states it in the ADR.
- **Modularity:** `:feature:x:api` (navigation keys, shared models) + `:feature:x:impl` (UI, ViewModel), plus `:core:*` modules.
- **Performance:** test release builds with R8; Compose ships a default baseline profile, but an **app-specific Baseline Profile** must be generated and regenerated whenever the start-up path changes; Macrobenchmark guards regressions in CI. Compose 1.9+ matches Views for scroll jank (hero benchmarks). Reported cold-start gains of 20–40 % (not verified).

### 1.3 Flutter (Dart 3, Impeller)
- **Official architecture guide (docs.flutter.dev/app-architecture):** two layers. UI = View + ViewModel; Data = Repository + Service. The repository is the single source of truth and owns caching, errors and retries; one service per data source; **repositories never depend on each other.** Reference app: Compass.
- **State management:** Riverpod 3.x is the default for new projects (little boilerplate, `AsyncValue`, explicit dependencies, experimental offline persistence in 3.x). Bloc 9.x for large teams, strict reviews and an auditable event → state history; the cost is ceremony (three files). Both scale to large apps.
- **Folder structure:** in large projects **feature-first** (each feature owns its domain/data/presentation), layers inside the feature. Very large: one Dart package per feature in a Melos workspace. Very Good Ventures (Aug 2026) recommends this as an "AI-ready monorepo" so coding agents find a feature's files together.
- **2026 roadmap (flutter.dev):** Impeller migration on Android completes and Skia is removed on Android 10+; day-zero support for Android 17 and new iOS releases; Wasm as the web default; at least four stable releases a year.

### 1.4 Kotlin Multiplatform / Compose Multiplatform (additional profile)
- Compose Multiplatform for iOS is **stable since 1.8.0 (May 2025, JetBrains)**; ~9 MB extra size; the Respawn app reports 96 % shared code. Gaps: iOS animations behind SwiftUI, UI testing harder because Compose renders as one `UIViewController` on iOS, Swift Export still maturing.
- Position in the kit: "KMP shared core (network, models, business rules) + native UI per platform" is safe; "shared UI with Compose Multiplatform" is labeled **experimental**.

---

## 2. Data model axis (platform-independent)

| Need | Choice |
|---|---|
| Server only | repository + memory cache, HTTP cache |
| Local cache | repository + local DB (SwiftData / Room / Drift-Isar), stale-while-revalidate |
| Offline-first | the local DB is the source of truth + a sync engine. **PowerSync** (SQLite, offline first-class, works with Supabase/Postgres, Apache-2.0 SDKs). ElectricSQL is a sync layer without client persistence. **Realm / Atlas Device Sync is not used** (deprecated by MongoDB in 2025; verify). Hand-written queues only for one-way, few-table cases. |

Backend selection in detail: `backend-selection.md`.

---

## 3. Performance budgets (apply to every profile, measured by `/perf`)

Platform-independent:
- Cold start to first interaction **< 400 ms** (iOS community target 300–400 ms; Android measured with Macrobenchmark `startup`). Apple publishes no official number; the budget is recorded in the project's ADR.
- Scroll jank: dropped-frame rate under the threshold at 60/120 Hz (Instruments SwiftUI template / Compose JankStats / Flutter DevTools raster and UI threads).
- Synchronous network or disk I/O at start-up is **forbidden**.
- Images: sized loading, caching, no decoding on the main thread.

iOS: Instruments **Time Profiler + Allocations + SwiftUI** (body call counts and duration), App Launch template (dyld, initializers, first frame); remove unused frameworks; keep state scope narrow to avoid needless re-evaluation.
Android: release + R8; app-specific Baseline Profile; Macrobenchmark in CI; `profileinstaller` and benchmark library versions must match.
Flutter: measure in profile mode; `const` widgets, `RepaintBoundary`, no work in `build`; Impeller on; shader warm-up; `flutter analyze` with zero warnings.

---

## Sources
- [Android architecture recommendations](https://developer.android.com/topic/architecture/recommendations) · [Guide to app architecture](https://developer.android.com/topic/architecture) · [Compose performance](https://developer.android.com/jetpack/compose/performance)
- [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide) · [Flutter & Dart 2026 roadmap](https://flutter.dev/blog/flutter-darts-2026-roadmap) · [Feature-first clean architecture (VGV)](https://verygood.ventures/blog/feature-first-clean-architecture.md)
- [Compose Multiplatform 1.8.0 stable (JetBrains)](https://blog.jetbrains.com/kotlin/2025/05/compose-multiplatform-1-8-0-released-compose-multiplatform-for-ios-is-stable-and-production-ready/)
- [TCA 2.0 beta (Point-Free)](https://www.pointfree.co/beta-previews)
- [MainActor by default (Massicotte)](https://www.massicotte.org/blog/mainactor-by-default) · [Should you opt in to Swift 6.2's MainActor isolation? (Donny Wals)](https://www.donnywals.com/should-you-opt-in-to-swift-6-2s-main-actor-isolation/)
- [SwiftData in appleOS 27 (Michael Tsai)](https://mjtsai.com/blog/2026/06/23/swiftdata-in-appleos-27/) · [Key considerations before using SwiftData (Fatbobman)](https://fatbobman.com/en/posts/key-considerations-before-using-swiftdata/)
- [iOS architecture in 2026](https://medium.com/@chandra.welim/ios-architecture-in-2026-which-one-should-you-actually-use-793917181411)
- [Riverpod 3 vs Bloc 9](https://sharpskill.dev/en/blog/flutter/flutter-state-management-riverpod-vs-bloc)
- [Navigation 3 multi-module](https://medium.com/@sivavishnu0705/mastering-multi-module-navigation-with-jetpack-navigation-3-8a7c44d8b667)
- [PowerSync docs](https://docs.powersync.com/_sites/docs.powersync.com/installation/database-setup)
- [iOS performance tuning with Instruments](https://sheldonwangrjt.github.io/posts/2025/05/blog-post-may-1)
