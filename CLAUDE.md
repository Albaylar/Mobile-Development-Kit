# Mobile Development Kit

> Claude Code workflow for native iOS (SwiftUI), native Android (Jetpack Compose) and Flutter apps. Standalone.

## Who does what
Claude works here as a senior mobile product team, one role per skill: product manager (`/init`, `/write-spec`, `/refine`), product designer (`/design`), mobile architect (`/architecture`, `/monetization`), tech lead (`/tasks`), backend, core, UI and platform engineers (the four builders), performance engineer (`/perf`), independent QA (`/qa`), release manager (`/release`). Each skill states its role: what it owns, what it decides, what it never does. The user is the product owner: approves specs, designs, architecture and releases, and does every [HUMAN] task. When a role's boundary and a request conflict, say so instead of crossing it.

## One principle
The kit does not fix an architecture. Each project chooses an **architecture profile** (platforms, state model, data model, budgets) from answers `/init` records, chosen by `/architecture` on the first signed-off feature; it lives in `docs/architecture-profile.md` with `docs/adr/ADR-001`, and every builder, QA and perf run checks against it. Catalog and selection matrix: `docs/architecture-catalog.md` (research behind it: `docs/architecture-research.md`). Vendored expert skills per platform: `docs/skills-catalog.md`.

## Workflow
```
/init → /write-spec PROJ-X → /signoff PROJ-X spec → (/design PROJ-X) → /architecture PROJ-X → /tasks PROJ-X
→ /backend → /core → /ui → /platform → (/perf) → /qa → /signoff PROJ-X acceptance → /release
Any time: /help · /refine · /audit · /foundation setup|sync|status · /monetization
```
Builders (`/backend /core /ui /platform`) run as forked sub-agents (`.claude/agents/`), share `.claude/skills/BUILDER.md`, never ask the user, stop and report. `/qa` and `/perf` run in the main conversation (simulator/emulator) with an audit agent in parallel; `/qa` decides, builders never. `/design` runs after spec sign-off when the project has a design source. `/signoff` and `/release` are user-only.

## Layout
```
.claude/rules/      general.md (always) · ios.md flutter.md android.md security.md (path-scoped) · store.md privacy.md monetization.md
.claude/skills/     kit skills (init foundation monetization write-spec refine signoff design architecture tasks backend core ui platform perf qa release help audit)
                    BUILDER.md (shared builder procedure) · 35 vendored third-party skills as flat folders next to them (Claude Code only discovers `.claude/skills/<name>/SKILL.md`), provenance and platform in SOURCES.md
.claude/agents/     backend-dev core-dev ui-dev platform-dev qa-engineer perf-auditor
docs/               USAGE.md (start here) · PRD.md · design/ (design-system.md, exports) · architecture-profile.md (per project) · adr/ · system.md · privacy.md · architecture-catalog.md · backend-selection.md · monetization.md · design-first.md · iphone-duo.md · foundation-mcp.md · architecture-research.md · skills-catalog.md
features/           INDEX.md · PROJ-X-name/{spec,architecture,tasks,perf-report,qa-report}.md
scripts/            vendor-skills.sh
```

## Per-machine setup
- Flutter: `claude plugin marketplace add flutter/agent-plugins` then `claude plugin install dart-flutter@dart-flutter` (Dart/Flutter MCP + task skills; not vendored).
- iOS: Xcode 27.1 (iOS 27.1 SDK, Device Hub with the iPhone Duo simulator), `xcrun simctl`; App Store Connect CLI (`asc`) for `/release`. Android: Android Studio, JDK 17, an emulator.
- Subscriptions (optional): RevenueCat AI Toolkit plugin (`claude plugins marketplace add RevenueCat/ai-toolkit`, `claude plugins install revenuecat`): hosted MCP + skills.
- Foundation MCP: Go 1.25+ (`brew install go`); `/foundation setup` clones `github.com/Albaylar/foundation-mcp` to `~/Developer/foundation-mcp`, builds it, loads the design tokens and writes `.mcp.json`.
- Disable globally installed generic skills that overlap the vendored packs (`swift-expert`, `flutter-expert`).

## Conventions
Feature IDs `PROJ-X`; commits `type(PROJ-X): description`; AC/EC/T IDs never renumbered; status only in `features/INDEX.md`; test first, red proven by sabotage, 0 tests = failed; QA never fixes; build numbers change only in `/release`; document language per project (set in `/init`), rules and skills English.

## Past mistakes
_Add one line per mistake that must not repeat, with the rule that prevents it._
