# Usage map: from an empty folder to the App Store

> This is the guide to read before your first project. It walks the whole kit in the order you will use it, with a worked example, the decisions you make at each step, what the human does and what Claude does, and what to do when something goes wrong. The README explains *what* the kit is; this file explains *how to use it*.

---

## Contents
- [Part 0: The mental model (5 minutes)](#part-0-the-mental-model)
- [Part 1: One-time machine setup](#part-1-one-time-machine-setup)
- [Part 2: Start a project](#part-2-start-a-project)
- [Part 3: Project foundations (once per project)](#part-3-project-foundations)
- [Part 4: The feature loop (repeat per feature)](#part-4-the-feature-loop)
- [Part 5: Release](#part-5-release)
- [Part 6: After release](#part-6-after-release)
- [Part 7: When things go wrong](#part-7-when-things-go-wrong)
- [Part 8: Decision guides](#part-8-decision-guides)
- [Part 9: Cheat sheet](#part-9-cheat-sheet)
- [Part 10: Checklists per phase](#part-10-checklists-per-phase)
- [Part 11: Glossary](#part-11-glossary)

The worked example used throughout: **"Habitly"**, a habit tracker sold by subscription. Flutter for iOS and Android, Supabase backend, offline check-ins, design in Figma, components from the Foundation MCP, subscriptions through RevenueCat. It touches almost every part of the kit.

---

## Part 0: The mental model

**1. Files are the memory, not the chat.** Everything that matters is written into the repository: the product (`docs/PRD.md`), the architecture (`docs/architecture-profile.md`, `docs/adr/`), every feature (`features/PROJ-X-name/`), the state of the app (`docs/system.md`). You can close Claude Code at any time; the next session reads the files and continues. Never rely on "Claude remembers".

**2. Every feature goes through the same pipeline.**
```
spec ─▶ sign-off ─▶ design ─▶ architecture ─▶ task plan ─▶ build (test first) ─▶ QA ─▶ acceptance ─▶ release
WHAT      client      screens   HOW            checklist     4 builder agents       independent  client     stores
```
Each arrow is a command. Each step refuses to run if the previous one is missing. That is deliberate: it stops the agent from building something nobody agreed on.

**3. You decide, Claude asks.** Interviews ask **one question at a time with a recommendation**. You answer "yes", or correct it. You never have to write a spec from scratch; you never get a wall of 20 questions.

**4. The architecture is chosen once per project and then binding.** The first feature that reaches `/architecture` picks the profile (platform, state model, data model, budgets). After that every agent follows it; leaving it needs a recorded decision (ADR).

**5. Four kinds of work, four builders.** `[BE]` backend, `[CORE]` models/repositories/state, `[UI]` screens, `[PLAT]` permissions/push/manifests. Plus `[HUMAN]` for what only a person can do (accounts, certificates, dashboards, approvals).

**6. Nothing is "done" without a test that failed first.** And QA, which did not write the code, decides whether it is done; builders never do.

**7. Two gates belong to the client.** Spec sign-off (gate 1) and acceptance of a real build (gate 2). Only you run `/signoff`.

---

## Part 1: One-time machine setup

Do this once per computer. It takes about an hour, mostly downloads.

| Step | Command or action | Check |
|---|---|---|
| Claude Code | install the desktop app or CLI | `claude --version` |
| Xcode 27.1 or newer | App Store, then open once to install components; includes Device Hub with the iPhone Duo simulator | `xcrun simctl list devices` lists iPhones |
| Android Studio + JDK 17 | install, create one emulator (Pixel, API 35+) | the emulator boots |
| Flutter SDK | flutter.dev install guide | `flutter doctor` has no red items |
| Go 1.25+ | `brew install go` | `go version` |
| Kit | `git clone https://github.com/Albaylar/Mobile-Development-Kit.git ~/Developer/Mobile-Development-Kit` | folder exists |

Official Flutter plugin (Dart/Flutter MCP + task skills):
```bash
claude plugin marketplace add flutter/agent-plugins
```
```bash
claude plugin install dart-flutter@dart-flutter
```

Optional, when you will sell subscriptions through RevenueCat:
```bash
claude plugins marketplace add RevenueCat/ai-toolkit
```
```bash
claude plugins install revenuecat
```

Optional, when designs are in Figma: Figma desktop app, open the file, switch to Dev Mode, enable the MCP server in the Dev Mode panel (it serves at `127.0.0.1:3845`).

Recommended: disable globally installed generic skills that overlap with the kit (`swift-expert`, `flutter-expert`) so Claude does not pick the older advice.

**Accounts you will need per project** (the kit asks in `/init`, you create them): Apple Developer Program, Google Play Console, the backend (Supabase / Firebase), RevenueCat or Adapty if you sell something, Figma if the design lives there.

---

## Part 2: Start a project

### 2.1 Copy the kit
```bash
cp -R ~/Developer/Mobile-Development-Kit ~/Developer/habitly
```
```bash
cd ~/Developer/habitly && rm -rf .git && git init && git add -A && git commit -m "chore: start from Mobile Development Kit"
```
Optionally create the project's own GitHub repository now and push; the kit works without a remote too.

### 2.2 Open Claude Code in the folder
Always open Claude Code in the project root. Type `/` and check that you see `init`, `write-spec`, `foundation`, `monetization` and the vendored skills such as `flutter-architecture`. If they are missing, you are in the wrong folder.

### 2.3 Run `/init`
```
/init A habit tracker. People pick up to 5 daily habits, check them off, see streaks, get a reminder at a chosen time. Free for 1 habit, subscription for more habits and statistics. iOS and Android.
```

What happens:
- Claude reads any files you put in `docs/design/` first (briefing, screenshots, a Figma link in a text file).
- Then it interviews you **one question at a time**, each with "My suggestion: …". Typical questions for Habitly and good answers:

| Question (shortened) | Suggested | Your answer for Habitly |
|---|---|---|
| Client or internal? Who reviews documents? | | Internal; "owner (self-reviewed)" |
| Document language? | client's language | English |
| Native or Flutter? Minimum OS? Tablet? | Flutter for one small team shipping both | Flutter, iOS 17 / API 26, phone only |
| Size: screens, team, lifetime | | ~10 screens, 1 developer, 3+ years |
| Backend and login, who creates it | Supabase for relational data | Supabase EU, Sign in with Apple + Google; I create the project |
| Offline: must writes survive without network? | it is the expensive answer | Yes, check-ins must work offline |
| Design source? Foundation MCP? | yes, Foundation for every client app | Figma; yes |
| Store accounts and signing | | Both exist; I sign |
| UI languages | | English, Spanish |
| Analytics / crash reporting | | none in v1, Crashlytics later |
| Lowest device, budgets | 400 ms, 1 %, 150 MB, 30 MB | iPhone SE 2, defaults |
| Monetization | RevenueCat unless experiments drive the business | Subscriptions, RevenueCat |
| Master data? | | none |
| Launch date? | checked against the P0 list | TestFlight in 6 weeks |

Outputs:
- `docs/PRD.md` with the ten **Architecture inputs** filled.
- `features/INDEX.md` with the feature map. For Habitly something like:

| ID | Feature | Type | Depends on |
|---|---|---|---|
| PROJ-1 | Backend and auth setup | Infrastructure | |
| PROJ-2 | App shell and navigation (creates the Flutter project) | Feature | PROJ-1 |
| PROJ-3 | Sign in (Apple, Google) | Feature | PROJ-2 |
| PROJ-4 | Habits: create, edit, delete | Feature | PROJ-3 |
| PROJ-5 | Daily check-in (offline) | Feature | PROJ-4 |
| PROJ-6 | Streaks and statistics | Feature | PROJ-5 |
| PROJ-7 | Reminders (local notifications) | Feature | PROJ-4 |
| PROJ-8 | Paywall and purchase | Feature | PROJ-3 |
| PROJ-9 | Entitlement sync | Infrastructure | PROJ-1, PROJ-8 |
| PROJ-10 | Account deletion | Feature | PROJ-3 |

Merge or commit as the handoff says. **Read the PRD once yourself**: everything later builds on it.

---

## Part 3: Project foundations

Done once per project, before the first feature is built. Order: Foundation, monetization, then PROJ-1 and PROJ-2 through the normal feature loop.

### 3.1 `/foundation setup` (if the PRD says Foundation MCP)
```
/foundation setup
```
1. Checks Go.
2. Clones `Albaylar/foundation-mcp` to `~/Developer/foundation-mcp` (or updates it).
3. Builds and tests it.
4. Asks where the design is (Figma for Habitly). With the Figma MCP connected it calls `get_variable_defs`, maps `Brand/Primary` → `color.brand` and so on, asks you about unclear mappings one at a time, and writes `docs/design/tokens.json` (only Habitly's values) and `docs/design/tokens-mapping.md`.
5. Validates with `--check`.
6. Writes `.mcp.json`.

**You then restart Claude Code in the folder** and approve the `foundation` (and `figma`) MCP server. `/foundation status` confirms all green.

### 3.2 `/monetization` (if the app sells something)
```
/monetization
```
Interview: what is sold (Habitly: one entitlement `pro`, monthly + yearly, 7-day trial), platform (RevenueCat), who sets up the dashboards (you), grace period (on), which server features are premium (statistics come from the server → yes, entitlement sync needed), analytics forwarding (none in v1).

Outputs: `docs/adr/ADR-002-monetization.md`, `docs/monetization-setup.md` (product ids per store, entitlement, offering, webhook URL, the Supabase tables `entitlements` and `subscription_events`, RLS, Edge Function), INDEX entries for PROJ-8 and PROJ-9, a `docs/privacy.md` row for RevenueCat.

**Your [HUMAN] tasks now:** create the subscription group and products in App Store Connect, the subscription and base plans in Play Console, the RevenueCat project with both apps and the `pro` entitlement, enable Billing Grace Period (Apple) and a grace period (Google). Keep the API keys and the webhook secret out of the repository.

### 3.3 Build PROJ-1 and PROJ-2 first
They go through the feature loop like any feature (Part 4). Two things are special:
- **PROJ-1 (backend setup)** is type Infrastructure: no UI, no `/design`, mostly `[HUMAN]` (create the Supabase project in the EU region, turn off public sign-ups, set the auth providers) and `[BE]` (schema, RLS, tests).
- **PROJ-2 (app shell)** is where the Flutter project is **created**: bundle id, signing team, flavors, localization wiring, theme from `FoundationTokens`, root navigation with empty screens. Every later feature depends on it; `/tasks` refuses to plan features whose dependencies are not built.
- **The first feature that reaches `/architecture` chooses the architecture profile** and writes `docs/architecture-profile.md` + `ADR-001`. Read it carefully; it binds the whole project.

For Habitly the profile comes out as: **profile A** (10 screens, 1 developer; lifetime only sets the revisit trigger), Flutter official layering + Riverpod 3, feature-first folders, Supabase + **PowerSync** (offline-first check-ins), RevenueCat with a Supabase Edge Function webhook, budgets from the PRD.

---

## Part 4: The feature loop

Repeat for every feature. Here: **PROJ-5 Daily check-in (offline)**.

### Step 1: `/write-spec PROJ-5`
Claude creates the branch `feat/PROJ-5-daily-check-in` and interviews you about this one feature: who uses it, the core action, empty/loading/error states, and mobile edge cases one by one (no network, app killed mid-write, two devices, midnight and time zones, double tap, XXXL font, dark mode). Not-applicable edge cases are listed under "Out of scope" with the reason.

Output: `features/PROJ-5-daily-check-in/spec.md` with user stories, **AC-1…AC-n** ("Given a habit not yet checked today, when the user taps it offline, then it shows as done immediately and syncs within 10 s of reconnecting") and **EC-1…EC-n**. INDEX: Planned.

**You:** read it. This is the contract. If a criterion is vague, say so now.

### Step 2: client approval, then `/signoff PROJ-5 spec`
Send the spec to the client (for Habitly: approve it yourself). Then:
```
/signoff PROJ-5 spec
```
Claude asks who approved, when, how; writes the line with the spec's commit hash. INDEX: Signed Off.

### Step 3: `/design PROJ-5` (projects with a design source)
Claude lists every screen and state the spec needs (habit list default, checked, offline-pending indicator, sync error, empty state, XXXL, dark). The designer builds the frames in Figma (or Claude builds them in Claude Design). Claude reads each frame through the Figma MCP, checks every component against the Foundation catalog (`search`, `list_components`), and every value against tokens (`get_variable_defs`). A new component (say a "check circle") is added to the design system and registered in Foundation (`register_component` → a branch in the foundation-mcp repository) **before** the frame is approved.

Output: `design.md`, exported frames in `docs/design/PROJ-5/`, approval line in the spec. INDEX: Designed.

### Step 4: `/architecture PROJ-5`
Claude writes `architecture.md` inside the profile: screens and navigation (from the frames), module and state per screen, data (check-in entity), **C2 offline queue and sync** (PowerSync sync rules, conflict rule: last write wins per habit per day, what the user sees while pending), access rules (RLS: a user reads and writes only own check-ins), platform work (none), tests per AC/EC, external services with current docs (PowerSync SDK version, looked up with Context7), files, what is deliberately simple, open decisions with recommendations.

**You:** answer the open decisions; approve. INDEX: Architected.

### Step 5: `/tasks PROJ-5`
Claude turns spec + design + architecture into `tasks.md`: tasks in levels (groundwork → backend → core → UI → platform → hardening), each tagged and tied to AC/EC, and a **coverage table** proving every AC and EC has a task. It lists [HUMAN] tasks first (e.g. "add the check-ins table to the PowerSync sync rules in its dashboard").

**You:** do the [HUMAN] tasks, tell Claude, it ticks them.

### Step 6: build: `/backend`, `/core`, `/ui`, `/platform`
Run them in that order; each runs as a sub-agent and works only on its tag.
```
/backend PROJ-5
```
```
/core PROJ-5
```
```
/ui PROJ-5
```
Each builder, per task: writes the test first, runs it, shows it **red for the right reason**, writes the code until green, ticks the task, fills the coverage table with `red → green`, commits per level. `/ui` pulls every control from the Foundation MCP and runs `check_usage` on each new screen. Builders never ask you questions: if something is unclear they stop and report; answer and run the same command again.

After the builders: **you** run the app in the simulator once and look. Builders cannot see the screen.

### Step 7: `/perf PROJ-5` (when the feature touches a budget)
The habit list scrolls and the app starts with it, so yes. Claude builds a profile/release build, measures cold start, scroll jank and memory on the lowest device three times, and writes `perf-report.md`. A failed budget goes back to the owning builder.

### Step 8: `/qa PROJ-5`
Runs in the main session with the simulator, plus an independent QA agent in parallel. It checks coverage (every AC/EC has a red→green test), **sabotages** two important tests to prove they can fail, runs all suites, tests every AC on the main and the smallest device, every edge case (airplane mode mid-write, app killed, XXXL, dark, two devices), accessibility, profile compliance, security and privacy, and for paid features the purchase matrix. It writes `qa-report.md` and decides:
- no Critical or High bugs → **Approved**,
- otherwise → back to **In Progress**: the builder fixes each bug with a failing test first, then `/qa` again.

### Step 9: client acceptance, then `/signoff PROJ-5 acceptance`
Distribute a TestFlight / internal-track build, the client tries it, then:
```
/signoff PROJ-5 acceptance
```
INDEX: Accepted. Merge the feature pull request into `dev` (or `main` while there is no `dev`). Claude never merges; you do.

### The loop in one picture
```
/write-spec ─▶ /signoff spec ─▶ /design ─▶ /architecture ─▶ /tasks ─▶ [HUMAN] ─▶ /backend ─▶ /core ─▶ /ui ─▶ /platform ─▶ /perf ─▶ /qa ─┬─▶ /signoff acceptance ─▶ merge
                                                                                                                             └─ bugs ─▶ builder (failing test first) ─▶ /qa
```

### Special feature types
- **Infrastructure** (PROJ-1, PROJ-9): no `/design`, no `/ui`; the owner signs off internally.
- **Paywall and purchase** (PROJ-8): `/core` wraps RevenueCat in one `EntitlementService` (`logIn` with the Supabase user id), `/ui` builds the paywall from the design with restore button and manage-subscription link, `/qa` runs the full purchase matrix in sandbox on both stores.
- **Entitlement sync** (PROJ-9): `/backend` builds the Edge Function webhook (verify secret, store event by id, re-read the customer, upsert one state), the `entitlements` and `subscription_events` tables with RLS, and tests for every transition: purchase, renewal, **cancel keeps access until expiry**, billing issue and grace, expiration, refund, duplicate and out-of-order events, wrong secret, sandbox never granting production access.

---

## Part 5: Release

```
/release PROJ-5
```
Runs only for **Accepted** features whose pull request is merged. Pre-flight: suites green, no Critical/High, budgets green, **store audit** (`appstore-review` for iOS, `store.md` checklist for Play: privacy manifest, data safety, account deletion, Sign in with Apple, usage strings, paywall texts), backend migrations applied before the app, no secrets in the bundle, release notes, build numbers bumped once. Then a release pull request `dev → main` (you merge), archive and upload (signing is yours), TestFlight → App Store, Play internal → closed → production with **staged rollout** (10 % → 50 % → 100 % over three days).

Status becomes **Released (in review)**. When the stores approve: verify the upgrade path, watch crashes for 24 hours, advance the rollout, tag the version, status **Released**.

**A store rejection** reopens the fix loop: status In Progress, fix with a failing test first, `/qa`, acceptance of the fix, `/release` again.

**Rollback** does not exist for installed apps: halt the staged rollout (Play), request an expedited fix review (App Store), switch a server-side flag off, keep the backend compatible with the previous app version.

---

## Part 6: After release

- **Next feature:** `/write-spec` for the next Roadmap row, or `/help`.
- **A client wish:** `/refine PROJ-X` tells you whether it is a clarification, a change inside scope (needs new sign-off) or a **change request** (new feature, new price).
- **Every third released feature and before the first submission:** `/audit`. It finds traceability gaps, profile drift (a second state library, network calls in views, legacy threading, secrets), stale `docs/system.md`, old vendored skills.
- **Before each new project:** `scripts/vendor-skills.sh` in the kit to refresh the vendored skills; `/foundation sync` in the project to get new components.
- **Keep `docs/system.md` honest:** builders update it; if it drifts, `/audit` says so.

---

## Part 7: When things go wrong

| Symptom | Cause | What to do |
|---|---|---|
| `/write-spec` says "run /init first" | PRD still has the `_Not filled in yet_` line, or the init PR is not merged | merge or commit the init branch |
| `/architecture` refuses | spec not signed off, or design not approved in a project with a design source, or a dependency not Architected | run the step it names |
| `/tasks` refuses | a dependency feature is not built (usually the app shell) | build that feature first |
| A builder says it stopped | it hit a question it may not decide | answer in the chat, run the same command again |
| A builder reports "outside the profile" | the task needs something the profile forbids | `/refine` the spec or write an ADR; do not tell it to "just do it" |
| QA: "test without claim" | a test passes even when the behavior is broken | the builder rewrites it to assert the AC's result |
| QA: "not ordered" | something was built no task asked for | decide: keep it (then `/refine`) or remove it |
| Foundation tools missing | Claude Code not restarted after `.mcp.json`, server not approved, absolute paths wrong | `/foundation status` |
| Figma MCP returns nothing | Dev Mode off, nothing selected, desktop MCP disabled | open the file in Dev Mode, select the frame |
| Premium vanished after cancel | handler revoked on CANCELLATION | fix: revoke only on expiration/refund (`docs/monetization.md` §3) |
| User cancelled, still premium | correct until `expires_at` | nothing to fix |
| Sandbox purchase unlocked production | environment not stored/checked | `/backend` fix with a failing test first |
| Skills not in the `/` menu | wrong folder, or a skill inside a group folder | open Claude Code in the project root; skills must be `.claude/skills/<name>/SKILL.md` |
| Context feels full mid-feature | long session | start a new session; skills re-read the files and continue from the ticked tasks |

---

## Part 8: Decision guides

### Native or Flutter?
- **Flutter** when one small team ships iOS and Android, the UI is your brand rather than the platform's, and you do not depend on deep platform features.
- **Native iOS (SwiftUI)** when widgets, Live Activities, App Intents, Apple Watch, CarPlay or native feel are the product, or the app is iOS only.
- **Native Android (Compose)** for Android-only products or deep Android integration.
- **KMP shared core + native UI** when two native teams want one business-logic layer (experimental for shared UI).

### Which profile size?
Count screens and people; take the **lowest** profile that fits both. Lifetime only sets when to revisit.

### Which backend? (`docs/backend-selection.md`)
```
Relational data or EU-only storage? ── yes ─▶ Supabase (+ PowerSync if offline writes)
            │ no
Offline-heavy consumer app, realtime? ── yes ─▶ Firebase (Firestore)
            │ no
Existing backend or heavy server logic? ── yes ─▶ own API + Postgres
            │ no
Personal iOS-only data ─▶ no backend + CloudKit
```

### Which subscription platform? (`docs/monetization.md`)
RevenueCat by default; Adapty when paywall and onboarding A/B tests are the growth plan.

### Design source?
Figma for client work with a designer; Claude Design for fast internal mock-ups; design system only when screens are standard; none → platform defaults, themed later.

---

## Part 9: Cheat sheet

```
/help                         where am I, what next
/init <description>           once: PRD + feature map
/foundation setup|sync|status design-system server
/monetization                 purchases and subscriptions plan
/write-spec PROJ-X            feature contract (AC, EC)
/signoff PROJ-X spec          gate 1 (you)
/design PROJ-X                screens before code
/architecture PROJ-X          technical design (first one: profile + ADR-001)
/tasks PROJ-X                 task plan + coverage
/backend /core /ui /platform  builders (sub-agents, test first)
/perf PROJ-X                  measure budgets
/qa PROJ-X                    independent verdict
/signoff PROJ-X acceptance    gate 2 (you)
/release PROJ-X               stores (you)
/refine PROJ-X                change a spec
/audit                        health check
```

Statuses: `Roadmap → Planned → Signed Off → (Designed) → Architected → In Progress → In Review → Approved → Accepted → Released (in review) → Released`

Where things are: product `docs/PRD.md` · profile `docs/architecture-profile.md` · decisions `docs/adr/` · app state `docs/system.md` · features `features/INDEX.md` + `features/PROJ-X-name/` · tokens `docs/design/tokens.json` · purchases `docs/monetization-setup.md` · third parties `docs/privacy.md`.

---

## Part 10: Checklists per phase

**Before `/init`**
- [ ] machine setup done (Part 1)
- [ ] kit copied, new git repository, Claude Code opened in the project root
- [ ] briefing, screenshots or Figma link in `docs/design/` if you have them

**Before the first feature is built**
- [ ] PRD read and correct, ten architecture inputs filled
- [ ] `/foundation setup` done and Claude Code restarted (if Foundation)
- [ ] `/monetization` done and dashboard [HUMAN] tasks finished (if selling)
- [ ] PROJ-1 (backend) and PROJ-2 (app shell) are the first features
- [ ] architecture profile and ADR-001 read and approved

**Per feature, before `/qa`**
- [ ] all tasks ticked, [HUMAN] tasks confirmed
- [ ] coverage table: every AC/EC has a test marked `red → green`
- [ ] you ran the app once on the simulator
- [ ] `/perf` green if a budget is touched

**Before `/release`**
- [ ] feature Accepted, PR merged
- [ ] store audit green, privacy manifest and Data Safety match the app
- [ ] purchases: production products approved, webhook on production, restore and manage links present
- [ ] backend migrations applied before the app
- [ ] release notes in every store language

---

## Part 11: Glossary

| Term | Meaning |
|---|---|
| **AC-n** | acceptance criterion with a fixed id: "Given …, when …, then …" |
| **EC-n** | edge case with a fixed id and its expected behavior |
| **T-n** | task in `tasks.md` |
| **Profile** | the project's architecture contract: platforms, state model, data model, budgets |
| **ADR** | architecture decision record in `docs/adr/` |
| **Gate** | a client approval the pipeline cannot pass without (spec sign-off, acceptance) |
| **Builder** | `/backend`, `/core`, `/ui`, `/platform`; sub-agents that build one tag of tasks |
| **[HUMAN]** | a task only a person can do (accounts, certificates, dashboards, approvals) |
| **Coverage table** | table in `tasks.md` linking every AC/EC to tasks and tests |
| **Red → green** | a test shown failing before the code, passing after |
| **Sabotage** | breaking the behavior on purpose to prove a test can fail |
| **Foundation MCP** | the shared design-system server: components once, project tokens per app |
| **Entitlement** | what a paying user may access (`pro`); its state is kept in the backend by the webhook |
| **Design source** | Figma, Claude Design, a design system file, or none |
| **Vendored skill** | a third-party expert skill copied into `.claude/skills/` (sources in `SOURCES.md`) |
