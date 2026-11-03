---
name: release
description: "Take an accepted feature to the stores: pre-flight checks, store-review audit, build number, TestFlight / Play internal track, submission, post-release verification, tag and rollback plan. Signing and store accounts stay with a human. Only the user runs this."
argument-hint: "PROJ-X"
disable-model-invocation: true
---

# Release

**Role:** you are the release manager. You protect users from a broken build: every check before submission, a staged rollout, and a plan for when it goes wrong.

A release changes what real users get and cannot be unshipped from their phones. Be explicit.

## Before starting
1. Read `features/INDEX.md`, `features/PROJ-X-name/spec.md`, `qa-report.md`, `docs/architecture-profile.md`, `.claude/rules/store.md`.
2. **Gate:** status Accepted. Approved is not enough: "The client has not accepted the build yet: `/signoff PROJ-X acceptance` first." Stop.
3. Feature PR merged into `dev` (`git log origin/dev --oneline | grep PROJ-X`); every PROJ-ID in `git log origin/main..origin/dev` is Accepted or Released. Otherwise stop.

## Pre-flight
- [ ] Full test suites green on `dev`; no Critical/High in QA; `perf-report.md` green if budgets were touched
- [ ] Store-review audit: `appstore-review` skill (iOS) and the Play checklist in `store.md`: privacy manifest, required-reason APIs, ATT, account deletion, Sign in with Apple, Data Safety form, target SDK, permissions with usage strings, no test or debug flags
- [ ] Backend migrations applied to production **before** the app (or the server accepts both versions); feature flags for anything that must switch at a fixed time
- [ ] No secrets in the bundle (`strings` on the binary / `unzip -l` on the AAB show none); crash reporting receives symbols (dSYM / mapping)
- [ ] Purchases: production products approved in both stores, webhook points at the production handler, sandbox events cannot grant production access, paywall shows price, period, trial, renewal terms, restore and manage-subscription link
- [ ] iOS: built with the iOS 27.1 SDK; iPhone Duo pose matrix in `qa-report.md`; Duo screenshots uploaded (badge) unless the spec marks the inner display out of scope; App Store Connect checked for the current Duo screenshot/SDK requirement
- [ ] Store listing and release notes in `docs/store/` (create it on the first release), in every store language, from the spec, no marketing claims the client did not approve
- [ ] Build numbers: `CFBundleVersion` / `versionCode` / `version+build` bumped once, here, and committed

## Build and distribute
Release PR `dev` → `main` titled `release: vX.Y.Z PROJ-X …`; a human merges. From `main`:
- iOS: archive, upload, TestFlight external group → App Store submission via `asc-release-flow` / `asc-testflight`, or fastlane if the profile says so. Signing certificates and the Apple account are `[HUMAN]`: say exactly what to click.
- Android: signed AAB (upload key held by the human), Play internal → closed → production with staged rollout (recommend 10 % → 50 % → 100 % over 3 days).
- Flutter: both of the above from one tag.
Submit; record the submission id. Store review is outside our control: set INDEX.md status to **Released (in review)**; a rejection reopens the fix loop (status In Progress, fix, `/qa`, acceptance of the fix, `/release` again).

## After approval
- [ ] Production build installs over the previous version (upgrade path, local data migrated)
- [ ] Main flow works with production backend; crash dashboard shows no new crash in the first 24 h; staged rollout advanced only then
- [ ] Spec section "Release": date, versions, build numbers, store links. INDEX.md → Released. Tag `vX.Y.Z` pushed.

## Rollback
Mobile cannot roll back installed apps. Options: halt the staged rollout (Play) / remove from sale or expedite a fix build (App Store, request expedited review), server-side feature flag off, backend kept backward compatible. Then fix loop.

## Handoff
"PROJ-X is in the stores. Next feature: `/write-spec`, or `/audit` before the next cycle."
