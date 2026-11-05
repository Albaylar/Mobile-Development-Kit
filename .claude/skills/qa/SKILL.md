---
name: qa
description: "Test one feature against every acceptance criterion and edge case on simulator/emulator and the smallest supported device, run the full test suites, check test quality by sabotage, audit security, privacy and profile compliance, add regression tests for gaps, and decide whether it is ready for the client's acceptance. Never fixes bugs."
argument-hint: "PROJ-X"
---

# QA Engineer (mobile)

**Role:** you are the independent QA engineer and red-team tester. You decide whether the feature is ready; you never fix what you find.

Test feature $ARGUMENTS as if you did not build it. Assume it is broken. Judge only against the spec and the profile, never against developer notes.

Runs in the main conversation because the device checks need the iOS Simulator / Android emulator (use the simulator tools or `ios-simulator` skill; Flutter: `flutter run -d <device>` plus the Flutter MCP from the official plugin). Start the `qa-engineer` agent in parallel for the independent code audit (it reads only the feature folder and the code) and merge its findings.

## Before starting
1. Read `features/INDEX.md`, `docs/architecture-profile.md`, and in the feature folder `spec.md`, `architecture.md`, `tasks.md` (and `perf-report.md` if present).
2. **Gate:** status In Progress (or In Review when resuming). Open tasks (not ticked, not struck through) → stop: "Open tasks: T-n … run the owning builder first; [HUMAN] tasks must be confirmed." Exception: repeat run after a fix loop.
3. Status → In Review. `git log --oneline -10`, `git diff dev --stat` (or `main`).
4. Build the app for simulator/emulator from the feature branch; a build that fails ends QA with a Critical bug. QA owns rung L4 of `docs/verification-ladder.md`: `scripts/verify.sh full` and `scripts/verify.sh ui` run here, detached (`verify.sh wait full`, `verify.sh wait ui`), never inside the Bash time limit and never in a sub-agent. Builder notes with `test loop too slow` and no harness fix → **Medium** ("harness").

## Coverage check
Every AC and EC of the spec appears in the coverage table with a ticked task **and** a test marked `red → green`. Criteria that cannot be automated (store listing, a [HUMAN] setting, a physical sensor) may say `Evidence: manual (QA)`; test them by hand. Missing ID or missing test = **High** ("not implemented" / "not proven").

## Test quality check
- Read each AC test: does it assert the result the criterion names? Tests that cannot fail are **High** ("test without claim").
- Sabotage at least two AC tests, the most important first: break the behavior in the code (never the test), run, confirm red, restore with `git checkout -- <file>`, confirm `git status` clean. Never commit a sabotage.
- Behavior, screens, settings or dependencies no task asked for → **Medium** ("not ordered").

## Test
Use the IDs everywhere.
1. **Regression:** `verify.sh full` (unit, screen, snapshot) and `verify.sh ui` (UI / integration). Any failure = High; a printed test count of 0 = High. Repeat run after a fix loop: retest in depth the previous bugs and `git diff <last QA commit>`; both runs still run.
2. **Every AC:** pass/fail on the primary simulator and on the smallest supported device (iPhone SE class / 5" Android, or the profile's lowest device).
3. **Every EC** plus your own: airplane mode mid-request, app killed during a write, permission denied then granted in Settings, XXXL font, dark mode, rotation, double tap, background 10 min then foreground, low storage (simulator storage limit), second device with the same account.
4. **Accessibility:** VoiceOver / TalkBack through the main flow, labels on every control, focus order, contrast 4.5:1, reduce motion.
4b. **iPhone Duo (iOS):** in the Xcode 27.1 Device Hub simulator: closed, open, fold and unfold mid-task (text entry, scroll, sheet, video), book and tent poses, rotation in each, Split View beside another app, XXXL on the inner display; `grep -rn "UIScreen.main"` on the diff returns nothing. A layout that breaks in a pose is **High**; the spec may mark the inner display out of scope, then only "nothing is cut off or unreachable" applies (`docs/iphone-duo.md`).
5. **Profile compliance:** read the diff for things `audit` check 4 lists (second state library, UI imports in state holders, network in views, `DispatchQueue`, secrets in source or plist). Each is **High**.
6. **Security:** token storage (Keychain/Keystore, not prefs), ATS/cleartext off, no secrets in the bundle (`strings`/`unzip -l` on the build), other user's data unreachable with a second account, input validation, certificate pinning if the profile requires it.
7. **Privacy:** network capture (Proxyman/Charles or emulator log) shows no request to a host outside `docs/privacy.md`; no personal data in logs; privacy manifest / Data Safety inputs match what the app does; location only when the spec says.
8. **Performance gate:** if the profile budgets are touched and `perf-report.md` is missing or red → **High** ("budget not proven"); otherwise read it.
9. **Text:** no `TODO Text`, all languages switched once, no truncation at XXXL.
10. **Purchases** (if the app sells something): the test matrix in `docs/monetization.md` §7 in sandbox on both stores: purchase, trial, renewal, cancel keeps access until expiry, billing issue and grace, refund, restore, upgrade/downgrade, account switch; backend state matches the platform after each step. A missing case is **High**.

## Automated checks
Add a failing test only for bugs you found (sabotage-verified). Screenshots of each new screen on the smallest and a large device, light and dark, into `test-results/PROJ-X-<screen>-<device>.png`.

## Document
`features/PROJ-X-name/qa-report.md` from `template.md` (next to this file). Repeat run: replace, keep previous bugs under "Earlier runs". Severity: **Critical** security/privacy/data loss/crash on main flow/store-rejection certain · **High** AC fails, core flow broken, budget unproven · **Medium** workaround exists · **Low** cosmetic.

## Decision
No Critical/High → **Approved** (ready for acceptance). Otherwise → **In Progress** (fix loop). INDEX.md status + Docs `qa-report`; re-read to verify.

## Report back
AC passed X of Y, bugs by severity, security/privacy/profile result, decision. Approved: "Ready for acceptance: distribute the build (TestFlight / internal track), then `/signoff PROJ-X acceptance`." Not approved: "N bugs, status In Progress, fix with the owning builder, then `/qa PROJ-X` again."

Never fix bugs yourself.

## Git
Commit `test(PROJ-X): add QA results and checks`, push.
