# Mobile Development Kit

**A ready-made way of working for building native iOS (SwiftUI), native Android (Jetpack Compose) and Flutter apps with Claude Code.** Every step from idea to store is a command (a skill): product definition, feature spec, client sign-off, design, architecture, task plan, test-first building, independent QA, performance measurement, monetization and store release.

The core idea: **the architecture is not fixed.** Each project picks its own architecture profile (platforms, state model, data model, performance budgets) and every agent follows it. A small tool and a large offline field app are built with the same kit but a different architecture.

| | |
|---|---|
| Status | 2026-11-03. Dry-run on two sample projects from `/init` to `/tasks`, 45 findings fixed. Builders, QA and release have not run on a real project yet |
| Repository | [Albaylar/Mobile-Development-Kit](https://github.com/Albaylar/Mobile-Development-Kit) |
| Local path | `~/Developer/Mobile-Development-Kit` |
| Design-system server | [Albaylar/foundation-mcp](https://github.com/Albaylar/foundation-mcp) (separate Go repository, connected by `/foundation setup`) |
| **Start here** | [`docs/USAGE.md`](docs/USAGE.md): the complete usage map, from an empty folder to the App Store, with a worked example |

---

## Contents
1. [Quick start](#1-quick-start)
2. [Machine setup](#2-machine-setup)
3. [Workflow at a glance](#3-workflow-at-a-glance)
4. [Statuses and gates](#4-statuses-and-gates)
5. [Architecture profile](#5-architecture-profile)
6. [Design first](#6-design-first)
7. [Foundation MCP: components once](#7-foundation-mcp-components-once)
8. [Backend choice](#8-backend-choice)
9. [Monetization: purchases and subscriptions](#9-monetization-purchases-and-subscriptions)
10. [Quality: test first, independent QA, performance](#10-quality-test-first-independent-qa-performance)
11. [Rules](#11-rules)
12. [Vendored expert skills](#12-vendored-expert-skills)
13. [Folder layout](#13-folder-layout)
14. [Keeping the kit current](#14-keeping-the-kit-current)
15. [How the kit came about](#15-how-the-kit-came-about)
16. [Known limits and roadmap](#16-known-limits-and-roadmap)
17. [FAQ and troubleshooting](#17-faq-and-troubleshooting)
18. [License and credits](#18-license-and-credits)

---

## 1. Quick start

Every app is a copy of the kit:

```bash
cp -R ~/Developer/Mobile-Development-Kit ~/Developer/my-app
```
```bash
cd ~/Developer/my-app && rm -rf .git && git init
```

Open Claude Code in that folder and describe the app in a few sentences:

```
/init Bakery staff log deliveries by scanning barcodes; the owner sees stock per shop.
```

The kit asks **one question at a time**, each with a **recommendation** you confirm or correct. At the end `docs/PRD.md` and `features/INDEX.md` exist. Whenever you do not know what comes next:

```
/help
```

The full walk-through is in [`docs/USAGE.md`](docs/USAGE.md).

## 2. Machine setup

Done once per machine.

| What | Why | How |
|---|---|---|
| Claude Code | the kit runs in it | desktop app or CLI |
| Xcode 26 + simulator | iOS build, tests, `/qa` | App Store; `xcrun simctl list` must work |
| Flutter SDK + official Flutter plugin | Flutter projects; Dart/Flutter MCP and task skills | two commands below |
| Android Studio, JDK 17, an emulator | Android and Flutter-on-Android | Android Studio setup |
| Go 1.25+ | building the Foundation MCP | `brew install go` |
| App Store Connect CLI (`asc`) | TestFlight and submission in `/release` | optional |
| Figma desktop + Dev Mode | reading designs through the Figma MCP | when the design is in Figma |
| RevenueCat AI Toolkit | hosted RevenueCat MCP + skills | optional, when the app sells subscriptions through RevenueCat |

Official Flutter plugin:
```bash
claude plugin marketplace add flutter/agent-plugins
```
```bash
claude plugin install dart-flutter@dart-flutter
```

RevenueCat AI Toolkit (optional):
```bash
claude plugins marketplace add RevenueCat/ai-toolkit
```
```bash
claude plugins install revenuecat
```

Globally installed generic skills (`swift-expert`, `flutter-expert` and similar) overlap with the kit's skills; disabling them is recommended.

## 3. Workflow at a glance

```
/init → (/foundation setup) → (/monetization) → /write-spec PROJ-X → /signoff PROJ-X spec → (/design PROJ-X)
      → /architecture PROJ-X → /tasks PROJ-X → /backend → /core → /ui → /platform → (/perf) → /qa
      → /signoff PROJ-X acceptance → /release
Any time: /help · /refine · /audit · /foundation setup|sync|status
```

| Command | What it does | Output | Runs in |
|---|---|---|---|
| `/init` | Defines the product by interview; asks the **ten architecture inputs**: platforms and min OS, size, backend, offline needs, design source (and Foundation MCP), store accounts, languages, analytics, lowest device and budgets, monetization | `docs/PRD.md`, `features/INDEX.md` | main session |
| `/foundation setup` | Clones foundation-mcp from GitHub, builds and tests it, turns the project's design into tokens and loads them, writes `.mcp.json` | `docs/design/tokens.json`, `.mcp.json` | main session |
| `/monetization` | RevenueCat or Adapty, products and entitlements, backend entitlement sync incl. cancellations, grace and refunds; adds the paywall and sync features | ADR, `docs/monetization-setup.md` | main session |
| `/write-spec PROJ-X` | One feature's spec: user stories, **AC-n** acceptance criteria (Given / when / then), **EC-n** edge cases (no network, permission denied, app killed, XXXL font, …), out of scope, personal data | `features/PROJ-X-…/spec.md` | main session |
| `/signoff PROJ-X spec` | Gate 1: client approval (who, when, channel, commit) | sign-off line in the spec | user only |
| `/design PROJ-X` | Screens before code: a frame per screen and state, component inventory, token check, client approval | `design.md`, `docs/design/PROJ-X/` | main session |
| `/architecture PROJ-X` | On the first feature **chooses the architecture profile** (`docs/architecture-profile.md` + `ADR-001`); technical design for every feature | `architecture.md` | main session |
| `/tasks PROJ-X` | Task plan: levels, `[BE] [CORE] [UI] [PLAT] [HUMAN]` tags, coverage table (every AC/EC in at least one task) | `tasks.md` | main session |
| `/backend` | Tables, access rules, server functions, API contract, webhook handlers, server tests | code + tests | sub-agent |
| `/core` | Models, repositories, services, local store, sync, ViewModels/notifiers, entitlement service, unit tests | code + tests | sub-agent |
| `/ui` | Screens, navigation, components (from the Foundation MCP), all states, accessibility, screen and snapshot tests | code + tests | sub-agent |
| `/platform` | Permissions, push, deep links, background work, widgets, manifests/entitlements, privacy manifest | code + tests | sub-agent |
| `/perf PROJ-X` | Measures the profile's budgets on release builds (Instruments / Macrobenchmark / DevTools) | `perf-report.md` | main session + auditor agent |
| `/qa PROJ-X` | Tests every AC/EC in the simulator incl. the smallest device; sabotage-checks the tests; security, privacy, profile compliance, purchase matrix | `qa-report.md` | main session + independent QA agent |
| `/signoff PROJ-X acceptance` | Gate 2: the client accepted a TestFlight / internal-track build | acceptance line in the spec | user only |
| `/release PROJ-X` | Store audit, build number, TestFlight / Play, staged rollout, rollback plan | version tag | user only |
| `/refine PROJ-X` | Changes a spec; first separates "inside scope" from a paid change request | spec update | main session |
| `/audit` | Health of the setup: traceability gaps, profile drift, stale documents, skill freshness | report + cleanup list | main session |
| `/help` | Says where you stand and the single next step | | main session |

**Why sub-agents?** `/backend`, `/core`, `/ui` and `/platform` run in their own context (`context: fork`), so the main session does not fill up. Sub-agents **never ask questions**: when something is unclear they stop and report. Their shared procedure is `.claude/skills/BUILDER.md`.

**Why QA in the main session?** Only the main session can drive the simulator and emulator. An independent `qa-engineer` agent that did not write the code audits it in parallel. QA fixes nothing; every bug it finds gets a failing test.

## 4. Statuses and gates

```
Roadmap → Planned → Signed Off → (Designed) → Architected → In Progress → In Review → Approved → Accepted → Released (in review) → Released
```

- **Gate 1 (Signed Off):** the client approved the spec. No architecture without it.
- **Designed:** in projects with a design source the screens are approved. Unapproved screens are not built.
- **Gate 2 (Accepted):** the client accepted a real build (TestFlight / internal track).
- **Released (in review):** submitted to the stores; a rejection reopens the fix loop.
- Status lives only in `features/INDEX.md`. Specs carry no status, effort or technical detail.

IDs (`AC-n`, `EC-n`, `T-n`, `BUG-n`) are never renumbered; the same ID is traced from spec to task plan to test to QA report.

## 5. Architecture profile

On the first feature `/architecture` picks from the matrix in `docs/architecture-catalog.md` and writes `docs/architecture-profile.md` + `docs/adr/ADR-001`. Rule: **size from screens and team** (lowest profile that fits), **data model from its own table**, lifetime only sets the revisit trigger.

| Platform | A (≤ 8 screens, 1–2 people) | B (8–30 screens, 2–5 people) | C (> 30 screens, > 5 people) |
|---|---|---|---|
| iOS | MVVM-C + `@Observable`, single target | MVVM-C + local SPM packages | TCA 1.x **or** MVVM-C with strict modules, snapshot tests |
| Android | Compose + ViewModel + UDF, Navigation 3 | + `:feature` / `:core` modules, Hilt | + `api/impl`, Baseline Profile + Macrobenchmark in CI |
| Flutter | official layering (View → ViewModel → Repository → Service), Riverpod 3, feature-first | + feature packages, go_router | Melos monorepo, Bloc 9 or Riverpod 3, golden tests |

Constant in every profile: UI never touches network or storage; business logic imports no UI; errors are **values** at layer boundaries (Swift `Result`, Dart `Result<T>` + sealed `AppFailure`, Kotlin sealed); concurrency is explicit and off the main thread (Swift Concurrency, isolates, coroutines); no GCD, raw threads, GetX or dartz in new code. Leaving the profile needs `/refine` and a new ADR, never a silent choice; `/audit` and `/qa` catch drift.

Research behind it (2026 state of mobile architectures, with sources): `docs/architecture-research.md`.

## 6. Design first

Screens invented while coding come out different every time, the client sees them too late and tokens are wasted. So in projects with a design source (Figma, Claude Design, or a design system only) the `/design` step sits between spec sign-off and architecture.

`/design PROJ-X` produces:
1. a frame for every screen and state of the spec (default, loading, empty, error, offline, permission denied), plus smallest-device, XXXL-font and dark variants,
2. a **component inventory**: every component is either existing (Foundation MCP / design system) or new; new ones enter the design system and the Foundation catalog first, then the screen,
3. a token check (every color, type style and spacing resolves to a token),
4. `design.md` and client approval.

Figma is read through the official Figma MCP (`get_design_context`, `get_variable_defs`, `get_screenshot`, `search_design_system`, Code Connect tools). Details: `docs/design-first.md`.

## 7. Foundation MCP: components once

A button is designed once; its tokens and its SwiftUI / Flutter code live in the [foundation-mcp](https://github.com/Albaylar/foundation-mcp) server. When the kit uses it:

- `/ui` calls `search` / `get_component` before writing any control and **pastes** the code; a component missing from the catalog is reported, not written,
- `check_usage` runs on every new screen (hard-coded colors, literal spacing, components outside the catalog),
- `/qa` runs the same check on the diff; a finding is a "not from the design system" bug.

**Components are shared, values belong to the project.** The project's brand lives in `docs/design/tokens.json`; the server merges it over the base tokens with `--tokens`.

### Setup: `/foundation setup`
1. Checks Go is installed (asks you to install it if not).
2. **Clones** `github.com/Albaylar/foundation-mcp` into `~/Developer/foundation-mcp` (or `pull --ff-only` if it exists and is clean).
3. Builds, runs `go test ./...` and `--check`; a broken server is not connected.
4. **Loads the design:** takes values from Figma (`get_variable_defs`), the Claude Design System artifact or `design-system.md`, maps them to the base token names, writes `docs/design/tokens.json` and `tokens-mapping.md`, validates with `--check`.
5. Writes `.mcp.json` (absolute paths, `--tokens` included) and asks you to restart Claude Code.
6. If the app project exists, generates `FoundationTokens.swift` / `foundation_tokens.dart`.
7. Records version and catalog commit in `docs/system.md`.

`/foundation sync` updates the server and lists new components; `/foundation status` names the missing step. A new component is written during `/design` with `register_component` into a branch of the **server repository**, merged by pull request, and picked up by every app with `sync`.

Contract and reasoning: `docs/foundation-mcp.md`. The server's own documentation: the foundation-mcp README.

## 8. Backend choice

`docs/backend-selection.md` decides with three questions:

1. **Is the data relational?** Entities, relations, row-level permissions → SQL (Postgres). Documents read and written whole → a document store is enough.
2. **Must writes survive offline?** Yes → Firestore (built-in offline) **or** Postgres + a sync engine (PowerSync). Supabase alone has no offline mode.
3. **Exit path and cost.** Postgres is portable; Firestore has no open-source equivalent and bills per document operation.

| Situation | Recommendation |
|---|---|
| Business app, relational data, EU client | Supabase (+ PowerSync if offline writes are required) |
| Consumer app, offline-heavy, realtime | Firebase (Firestore; SQL Connect for those who want SQL) |
| Large project or existing backend | own API + Postgres |
| iOS only, personal data | no backend + CloudKit |

Realm / Atlas Device Sync is not used (deprecated by MongoDB in 2025).

## 9. Monetization: purchases and subscriptions

If the app sells anything, `/init` records it (input 10) and `/monetization` plans it. Details: `docs/monetization.md`; binding rules: `.claude/rules/monetization.md`.

- **A subscription platform, never hand-written receipt handling.** RevenueCat by default (broadest ecosystem, official Firebase extension, Claude Code AI Toolkit); Adapty when paywall and onboarding A/B testing drive the business.
- **App user id = backend user id**; `logIn` after sign-in, `logOut` on sign-out.
- **The client gates UI, the server gates data.** Premium server features check the backend entitlement, never a client flag.
- **The backend always knows the state.** A webhook handler verifies the secret, stores every event idempotently, re-reads the customer from the platform and writes one state model: `active, in_trial, cancelled_active, in_grace, billing_retry/on_hold, paused, expired, refunded`.
- **Cancellation is not expiration.** Turning off auto-renew keeps access until `expires_at`; access ends on expiration, refund/revocation, or when the grace period ends (Google account hold).
- **Per backend:** Firebase → RevenueCat Firebase extension (Firestore + Auth custom claims) or a Cloud Function for Adapty; Supabase → Edge Function + `entitlements` and `subscription_events` tables with RLS; own API → the same two tables.
- **Tested:** purchase, trial, renewal, cancel, billing issue and grace, refund, restore, upgrade/downgrade, account switch, duplicate and out-of-order webhooks, sandbox never granting production access.
- **Analytics:** revenue and churn from the platform dashboard; product analytics through the platform's integration with the same user id.

## 10. Quality: test first, independent QA, performance

- **Test first.** For every AC and EC a failing test is written first and shown red, then the code. **0 tests run counts as failed.** An assertion is never weakened to go green.
- **Sabotage.** QA deliberately breaks the behavior behind the two most important AC tests; a test that stays green is a high-severity "test without claim" bug.
- **Severity.** Critical (security, data loss, crash on the main flow, certain store rejection), High (AC fails, budget unproven, purchase case missing), Medium (workaround exists), Low (cosmetic).
- **Performance budgets** (in the profile): cold start ≤ 400 ms, dropped frames while scrolling ≤ 1 %, memory and size from the PRD. Measured only on release/profile builds on the lowest device.
- **Accessibility is part of done:** Dynamic Type XXXL, VoiceOver/TalkBack, contrast 4.5:1, reduce motion.

## 11. Rules

Under `.claude/rules/`; `general.md` loads in every session, the others load when matching files are opened (`paths:`).

| File | Essence |
|---|---|
| `general.md` | read before you change; not done while type/analysis errors or **new warnings** exist; layer separation; the profile is binding; errors are values; explicit concurrency; no secrets in the bundle; permissions at the moment of use; offline is normal; i18n from the first screen; statuses and gates; git rules |
| `ios.md` | MVVM-C or TCA (never mixed); ViewModels do not import SwiftUI; protocols injected through the initializer; Swift Concurrency only; MainActor by default, set again in every SPM package; iOS 17 `@Observable`; SwiftData / GRDB / Core Data choice; Swift Testing |
| `flutter.md` | official layering; feature-first folders; domain layer only in profile C; Riverpod 3 or Bloc 9 (never both, no GetX); immutable state; `Result<T>` + sealed `AppFailure` (no dartz); `const`; heavy work in isolates |
| `android.md` | Compose + UDF; Navigation 3; `api/impl` modules; Hilt; coroutines/Flow; R8 + Baseline Profile |
| `security.md` | the bundle is public; server access rules are the only protection; TLS; Keychain/Keystore; validated deep links |
| `store.md` | account deletion; usage strings; Sign in with Apple; privacy manifest; ATT; Data Safety; build numbers; paywall requirements |
| `privacy.md` | data region; every SDK in `docs/privacy.md`; location only when needed; no personal data in logs; synthetic test data |
| `monetization.md` | subscription platform; user id; client gates UI, server gates data; webhook rules; revoke only when access ends; purchase test matrix |

`.claude/settings.json`: force push denied; `.env`, `.p12`, `.p8`, `.mobileprovision`, `.jks`, `.keystore`, `key.properties`, `GoogleService-Info.plist`, `google-services.json` cannot be read; build and test commands are allowed.

## 12. Vendored expert skills

The kit ships 33 current third-party skills with known sources. Claude Code only discovers skills at `.claude/skills/<name>/SKILL.md`, so they are **flat folders**; platform, source repository, commit and license are in `.claude/skills/SOURCES.md`.

| Platform | Skills | Main sources |
|---|---|---|
| iOS (14) | swiftui-pro, swiftdata-pro, swift-concurrency-pro, swift-testing-pro, swift-architecture, swiftui-performance-audit, swiftui-view-refactor, swift-security, ios-accessibility, ios-simulator, appstore-review, asc-cli-usage, asc-release-flow, asc-testflight | Paul Hudson, Thomas Ricouard, efremidze, rudrankriyam |
| Flutter (8) | flutter-skills-index, flutter-architecture, flutter-dart-style, flutter-state-management, flutter-testing, flutter-performance, flutter-result-errors, flutter-riverpod3 | abugeek (verified against Flutter 3.47 / Dart 3.13), Ethiel97 |
| Android (11) | using-chrisbanes-skills, compose-state-and-effects, compose-performance, compose-component-design, compose-ui-testing-patterns, kotlin-concurrency-and-flow, kotlin-control-flow, kotlin-api-design, gradle-run, android-benchmark-comparison, android-development | Chris Banes, dpconde |

What was chosen, what was left out and why: `docs/skills-catalog.md`. The official Flutter plugin and the RevenueCat AI Toolkit are installed per machine, not copied (see §2).

## 13. Folder layout

```
CLAUDE.md                     short context loaded in every session: principle, workflow, layout
README.md                     this file
.mcp.json.example             foundation + figma MCP example (/foundation setup writes the real one)
.claude/
  settings.json               permissions and denials
  rules/                      general, ios, flutter, android, security, store, privacy, monetization
  agents/                     backend-dev, core-dev, ui-dev, platform-dev, qa-engineer, perf-auditor
  skills/
    BUILDER.md                shared procedure of the four builders
    SOURCES.md                vendored skill sources
    init/ foundation/ monetization/ write-spec/ refine/ signoff/ design/ architecture/ tasks/
    backend/ core/ ui/ platform/ perf/ qa/ release/ help/ audit/       (the kit's own skills, with templates)
    swiftui-pro/ … flutter-architecture/ … compose-performance/ …     (33 vendored skills)
docs/
  USAGE.md                    the complete usage map (start here)
  PRD.md                      product definition (filled by /init)
  architecture-profile.md     the project's profile (written by /architecture)
  adr/                        architecture decisions
  system.md                   current state of the app
  privacy.md                  register of services and SDKs
  design/                     design-system.md, tokens.json, frame exports
  monetization-setup.md       products, entitlements, webhook (written by /monetization)
  architecture-catalog.md     profile matrix and rules
  architecture-research.md    2026 mobile architecture research (with sources)
  backend-selection.md        SQL / NoSQL / sync decision
  monetization.md             subscriptions: platform choice, state model, backend sync, tests
  design-first.md             reasons and rules of the design step
  foundation-mcp.md           Foundation MCP contract
  skills-catalog.md           skill research
features/
  INDEX.md                    every feature and its status
  PROJ-X-name/                spec.md · design.md · architecture.md · tasks.md · perf-report.md · qa-report.md
scripts/
  vendor-skills.sh            re-fetches the vendored skills
```

File names (`architecture.md`, `tasks.md`, `qa-report.md`, `perf-report.md`) are fixed whatever the document language; the content is written in the project's document language.

## 14. Keeping the kit current

```bash
cd ~/Developer/Mobile-Development-Kit && scripts/vendor-skills.sh
```
Re-fetches every vendored skill, aligns names with folders and rewrites `SOURCES.md`. Run it before a new project, read `git diff`, and read the changed `SKILL.md` files before committing.

Changes to the kit itself go to `github.com/Albaylar/Mobile-Development-Kit` through pull requests.

To bring a newer kit into an existing project: copy the kit's `.claude/` and `docs/*.md` (not the project documents) and read the diff.

## 15. How the kit came about

1. **Architecture research:** the 2026 state of SwiftUI + Observation, Swift 6.2 approachable concurrency, TCA 2.0 beta, SwiftData/GRDB; Compose + Navigation 3 + Baseline Profiles; Flutter's official architecture + Riverpod 3 / Bloc 9 + Impeller; KMP/CMP; PowerSync, Firestore, Supabase. Result: the profile catalog.
2. **Skill research:** 21 repositories read, 33 skills chosen (recency, the author's platform track record, reference structure, no overlap, MIT/Apache).
3. **Rules:** the user's own rule file (MVVM-C/TCA, `@Observable`, Swift Concurrency, feature-first clean Flutter, Riverpod/Bloc, `Either`, `const`) was merged in with two corrections: a domain layer only in profile C, and `Result` + sealed failure instead of `Either`.
4. **Dry runs:** two agents ran `/init` → `/tasks` for real on a Flutter + Supabase offline bakery app and a native iOS tide app without backend; 9 blockers, 19 contradictions and ~17 gaps were found and fixed.
5. **Design first, backend selection, Foundation MCP** were added; foundation-mcp was written in Go (v0.2.0, tests green).
6. **Skill discovery:** the vendored skills first sat in `ios/ flutter/ android/` group folders; Claude Code does not find those, so they were flattened.
7. **Monetization:** RevenueCat / Adapty, entitlement sync per backend, cancellation and grace handling, purchase test matrix.

## 16. Known limits and roadmap

- Builders, `/perf`, `/qa` and `/release` have not run on a real project; expect wording adjustments in the first full cycle.
- No vendored skill for the KMP shared-core profile.
- No skill for offline sync engines; the rules are in `architecture.md` section C2.
- No skill for Play Data Safety and Android store rules (`store.md` has them as rules).
- Foundation MCP has no Compose sources, no Figma import command and no platform compile checks in CI yet.
- No official Adapty MCP or agent skill found; RevenueCat's AI Toolkit is the only vendor tooling.

## 17. FAQ and troubleshooting

**I do not see the kit's skills in the `/` menu.** Open Claude Code in the root of the kit (or your copy). Skills must be at `.claude/skills/<name>/SKILL.md`; a skill inside a group folder is not found.

**The Foundation tools do not show up.** Run `/foundation status`. Usually Claude Code was not restarted after `.mcp.json` was written, or the server was not approved.

**A sub-agent says it stopped.** Sub-agents cannot ask; answer the open question in its report and run the same command again.

**Who is the "second pair of eyes" on a one-person project?** Documents say "owner (self-reviewed)"; the independent QA agent takes the reviewer role.

**I had to change the spec during the build.** The build stops; change it with `/refine`. A signed-off spec that changes in substance needs a new sign-off.

**The client asked for something new.** If the spec lists it as out of scope it is a change request: `/refine` says so and `/write-spec` makes it a new feature.

**A user cancelled but still has premium.** Correct until `expires_at`: cancelling turns off auto-renew. Access ends on the `EXPIRATION` event (`docs/monetization.md` §3).

## 18. License and credits

The kit is released under the [MIT License](LICENSE), © 2026 Furkan Deniz Albaylar.

The 33 vendored skills are the work of their authors and keep their own licenses (MIT or Apache-2.0); each folder contains its upstream `LICENSE` unchanged, and `.claude/skills/SOURCES.md` lists the repository, commit and license of every one. Thanks to Paul Hudson, Thomas Ricouard, Chris Banes, Lasha Efremidze, Rudrank Riyam, Ivan Magda, Daniel Devesa, Conor Luddy, 3 Paws AI, abugeek, Ethiel97 and dpconde for publishing them.

The design-system server lives in its own repository, [Albaylar/foundation-mcp](https://github.com/Albaylar/foundation-mcp), also MIT.
