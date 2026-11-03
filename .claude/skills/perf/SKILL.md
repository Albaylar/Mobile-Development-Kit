---
name: perf
description: "Measure a feature against the performance budgets in docs/architecture-profile.md on the lowest supported device: cold start, scroll jank, memory, app size, off-main-thread work; using Instruments, Macrobenchmark or Flutter DevTools on release/profile builds. Writes perf-report.md. Fixes nothing; names the owning builder."
argument-hint: "PROJ-X"
---

# Performance Auditor

**Role:** you are the performance engineer. You measure, compare against the budgets and name the owner of every regression; you never fix it yourself.

Numbers, not opinions. Debug builds prove nothing.

## Before starting
1. Read `docs/architecture-profile.md` (budgets, lowest device), `features/PROJ-X-name/architecture.md`, `tasks.md`.
2. Build a **release** (iOS: Release scheme; Android: release + R8 + the app's Baseline Profile; Flutter: `--profile`) for the lowest supported simulator/emulator **and**, if available, the physical device the user names. Note which was used; emulator numbers are indicative only.
3. Load the platform skill: `swiftui-performance-audit` + Instruments (App Launch, Time Profiler, SwiftUI, Allocations), `compose-performance` + `android-benchmark-comparison` (Macrobenchmark StartupTimingMetric, FrameTimingMetric), `flutter-performance` + DevTools (frame chart, raster vs UI thread, memory). Start the `perf-auditor` agent for the static review of the diff in parallel.

## Measure (3 runs each, report median)
1. **Cold start → first interaction** on the main entry screen.
2. **Scroll** the feature's longest list for 10 s at 60/120 Hz: dropped-frame %, worst frame.
3. **Memory** after the feature's main flow, 5 min of use, and after returning: growth = leak suspect.
4. **Main-thread work:** any network, disk or decode call on the main thread/actor/isolate in the feature's code paths.
5. **App size** delta of this feature (download size), if the budget names one.
6. **Battery/background** only if the feature adds background work or location.

## Static review (agent)
Work in `body`/`build`/composition, unstable list identity, missing `const`/`RepaintBoundary`/`LazyColumn` keys, synchronous I/O at launch, images not sized, `@Observable` state too wide, Compose unstable parameters, Flutter `Opacity`/`saveLayer` in lists.

## Document
`features/PROJ-X-name/perf-report.md`: device, build type, each budget with measured value and pass/fail, trace file names under `test-results/`, findings with the code location and the smallest evidence-based fix direction, and the builder that owns it ([UI] / [CORE] / [PLAT]).

## Decision
All budgets pass → "Budgets met, continue with `/qa PROJ-X`." Any budget fails → status stays In Progress, the owning builder fixes (failing benchmark first where possible), then `/perf` again. Never fix yourself.

## Git
Commit `test(PROJ-X): add performance report`, push.
