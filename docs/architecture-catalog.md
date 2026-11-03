# Architecture catalog (what `/architecture` chooses from)

> Decision rules derived from `architecture-research.md` (the evidence, with sources), plus the tie-break rules the dry runs asked for. Research dated 2026-11-03.

## 1. Profile size
Take the **lowest** profile that fits screens *and* team. Lifetime does not raise the profile; it sets the revisit trigger in ADR-001 ("revisit when screens > 30 or team > 5").

| | A | B | C |
|---|---|---|---|
| Screens | ≤ 8 | 8–30 | > 30 |
| Team | 1–2 | 2–5 | > 5 or several teams |
| Tests | unit + screen | + snapshot/golden, integration | + contract, benchmark in CI |

## 2. State model per platform (one per platform; the profile names it)
| Platform | A | B | C |
|---|---|---|---|
| iOS | MVVM-C + `@Observable`, single target | MVVM-C + local SPM packages `Features/* Core/* Platform/*` | TCA 1.x (2.0 when stable) **or** MVVM-C with strict module boundaries; snapshot tests |
| Android | Compose + ViewModel + UDF, single module, Navigation 3 | + `:feature/:core` modules, Hilt | + `api/impl` split, Baseline Profile + Macrobenchmark in CI, convention plugins |
| Flutter | official layering (View → ViewModel/Notifier → Repository → Service), Riverpod 3, single package, feature-first folders | + feature packages, go_router | feature-first monorepo (Melos), Bloc 9 **or** Riverpod 3 (team decision), golden tests |
| Shared core | not recommended | KMP shared (models, network, rules) + native UI | same; Compose Multiplatform UI only as "experimental" |

Domain / use-case layer: only in C, or when the ADR names complex rules shared by several screens.

## 3. Data model (chosen independently of the size)
| Need | Choice | Local store |
|---|---|---|
| Server only | repository + memory cache, HTTP cache | none |
| Cached reads, online writes | repository + local DB, stale-while-revalidate; writes retried from a small queue | SwiftData / Room / Drift |
| Offline-first (writes must survive) | local DB is the source of truth + sync engine (PowerSync for Postgres/Supabase; Firestore's built-in offline for Firebase) | GRDB / Room / SQLite via PowerSync SDK |
Hand-written queues only for one-way, few-table cases; rules in `architecture.md` C2. Realm / Atlas Device Sync is not used (deprecated by MongoDB, 2025; verify before relying on it).

Backend choice: `docs/backend-selection.md`.

## 4. Fixed defaults (stated once)
Minimum OS iOS 17 / Android API 26 (PRD may lower it with a reason). Budgets: cold start ≤ 400 ms, dropped frames ≤ 1 % at 60 Hz, memory and size per PRD. iOS app target MainActor-by-default + Approachable Concurrency, set again in every SPM package. Errors are values at layer boundaries. No GCD / raw threads / GetX / dartz in new code.
