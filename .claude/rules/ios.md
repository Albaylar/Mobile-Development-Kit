---
paths:
  - "**/*.swift"
  - "**/*.xcodeproj/**"
  - "**/*.xcworkspace/**"
  - "**/Package.swift"
  - "**/*.plist"
  - "**/*.entitlements"
  - "**/*.xcprivacy"
---

# iOS Rules (SwiftUI, Swift 6.2+, Xcode 26)

The vendored iOS skills (platform "ios" in `.claude/skills/SOURCES.md`) own the detail. This file says which one applies and what is non-negotiable.

## Architecture (from the profile)
- Allowed state models: **MVVM-C with `@Observable`** (default, profile A/B) or **TCA** (profile C, pinned to 1.x until 2.0 is stable). The profile names one; `swift-architecture` skill applies it. Mixing both in one app is forbidden.
- ViewModels import `Foundation` only, never SwiftUI. One ViewModel per screen. Domain code imports no framework.
- Dependencies are protocols injected through the initializer; SwiftUI `Environment` only for view-scoped values. No singletons reached from inside a ViewModel.
- Modules: profile B/C use local SPM packages (`Features/*`, `Core/*`, `Platform/*`); feature packages never depend on each other.
- Navigation is value-driven `NavigationStack` / `NavigationSplitView` state owned by a coordinator or the feature's store, not pushed from inside views.

## Concurrency
- Swift Concurrency only: `async`/`await`, actors, `@MainActor`, task groups. No GCD/`DispatchQueue`, `OperationQueue` or `Timer` in new code (`swift-concurrency-pro`).
- App target: Approachable Concurrency on, Default Actor Isolation = MainActor. Every SPM package sets the same in `swiftSettings`; it is **not** inherited.
- Networking, parsing, image decoding, persistence run off the main actor explicitly (`@concurrent` / `nonisolated` / a dedicated actor). "It compiled under MainActor-by-default" is not proof that the work is off-main; `/perf` checks with Instruments.

## State and data
- iOS 17+ floor: `@Observable`, never `ObservableObject`/Combine for new view state.
- Persistence per profile: SwiftData (simple/medium model, private CloudKit) with `swiftdata-pro`; **GRDB** for offline-first, > 10k rows or aggregate queries; Core Data only when migrating an existing store. Secrets in Keychain (`swift-security`).

## Verification
- `swift-testing-pro`: new tests use Swift Testing; XCTest stays for UI and performance tests. Snapshot tests for every screen in profile C.
- Build check: `xcodebuild -scheme <App> -destination 'platform=iOS Simulator,name=<newest iPhone of the installed Xcode>' -quiet build test` with `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` on the app target.
- `swiftui-pro` review before `/qa`: deprecated API, data flow, navigation, Dynamic Type, Reduce Motion, localization. `swiftui-performance-audit` when a screen has a list, animation or `body` that recomputes.
- `ios-accessibility`: VoiceOver labels, Dynamic Type to XXXL, contrast. `ios-simulator` drives the simulator in `/qa` and `/perf`.

## Store
- `appstore-review` runs in `/release` before every submission: PrivacyInfo.xcprivacy, required-reason APIs, ATT, account deletion, Sign in with Apple, paywall wording. `asc-*` skills handle TestFlight and submission through the App Store Connect CLI; signing is `[HUMAN]`.
