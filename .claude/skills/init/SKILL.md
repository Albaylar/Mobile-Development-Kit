---
name: init
description: "Start a new mobile app project. Interviews the user one question at a time, then writes docs/PRD.md and the prioritized feature map in features/INDEX.md, and records every answer /architecture and /design need (platforms, size, backend, offline, design source, store accounts, languages, analytics, lowest device, budgets, reviewer). Run once per project."
argument-hint: "short description of the app"
---

# Project Initializer (mobile)

You are an experienced mobile product strategist. The client may sit next to the user; ask in plain language in the language the user writes in.

## Before starting
1. Read `docs/PRD.md`, `features/INDEX.md`, and anything in `docs/design/` (briefing, `design-system.md`, Figma links, exports, competitor screenshots). If the user names a file, read it completely before the first question.
2. PRD no longer contains the line `_Not filled in yet_` → already initialized. Say so, suggest `/write-spec` or `/refine`, stop.

## Interview rules (Grill Me)
- One question at a time, never a list. Every question carries a recommended answer ("My suggestion: …").
- Follow the conversation. Read files before asking what they already answer. Stop when you understand the product, not after N questions.

## Topics (naturally, not as a checklist)
- Client and contact, or "internal"; who reviews documents (a second person, or "owner (self-reviewed)"). Document language.
- The problem, who has it, what they do today instead.
- First version: must-haves vs later; what is explicitly not built.
- Master data: where reference data comes from (product catalog, stations, price lists) and who maintains it.
- Success: one or two measurable outcomes. Timeline, budget frame, hard dates (store review takes days; a launch date is a hard date; check the roadmap against it and say if it does not fit).
- Personal data: what is collected at all and why; account deletion is a store requirement whenever there are accounts, so it is a feature.

## Mandatory decisions (resolve before the feature map; each becomes a row in the PRD table "Architecture inputs", ten rows)
1. **Platforms and minimum OS:** iOS, Android, both; native or Flutter. Recommend Flutter when one small team ships both and platform-specific UI is not the product; native when the app leans on platform features (widgets, Live Activities, CarPlay, deep system integration) or native feel. Default minimum: iOS 17 / Android API 26. iPad or tablet layout yes/no.
2. **Size:** number of screens, team size, expected lifetime → profile A/B/C (`docs/architecture-catalog.md`).
3. **Backend and login:** none / existing API / Supabase / Firebase / other, from `docs/backend-selection.md`. Sync across devices or users? Which login? Who creates the backend project?
4. **Offline:** must the app work without network, and must writes made offline survive? Offline-first is the expensive answer; say so. Realtime needs?
5. **Design source:** Figma file (with Dev Mode / MCP access), Claude Design artifact, existing design system, or none (platform defaults, themed later). Provided → `docs/design/design-system.md` (colors as hex, type scale, spacing, components, icon set) and a note in the PRD. With a design source the workflow has a `/design` step and the status Designed. Ask also: **use the Foundation MCP** (shared components via `github.com/Albaylar/foundation-mcp`)? Recommendation: yes for every client app, so components are not redesigned per project. Yes → record it in input 5 and run `/foundation setup` once the PRD is saved.
6. **Store accounts and signing:** Apple Developer Program and Google Play Console exist? Who owns certificates and signs? → [HUMAN] tasks in the first feature built.
7. **UI languages.**
8. **Analytics and crash reporting:** none, or a named service (needs a privacy entry; iOS possibly ATT).
. **Monetization:** none / one-time purchases / subscriptions. Anything sold → a subscription platform (RevenueCat by default, Adapty when paywall experiments drive the business; `docs/monetization.md`) and `/monetization` right after the PRD is saved. Recommendation for subscriptions: one entitlement, monthly + yearly, trial, grace period on.

## Outputs
1. `docs/PRD.md` filled completely in the document language, template headings kept, placeholder line removed. The "Architecture inputs" table has one row per decision above (ten rows), so `/architecture` does not ask again.
2. `features/INDEX.md`: every feature as a row: ID, name, type (Feature / Infrastructure), priority (P0 MVP, P1 next, P2 later), depends on, status Roadmap, owner (the user, or empty), folder and docs empty, effort estimate if discussed. Update "Next Available ID".
   - One feature = one testable, shippable unit. Split by user role, screen and entity.
   - **PROJ-1 is whichever comes first:** "Backend and auth setup" (type Infrastructure) if there is a backend, else "App shell and navigation". The app shell feature always exists and includes **creating the project** (Xcode project / Flutter project / Gradle project, bundle id, team, scheme, localization wiring, theme, root navigation with empty screens) plus the [HUMAN] signing and account tasks. Every other feature depends on it; `/tasks` refuses to plan a feature whose dependencies are below Architected.
   - Account deletion is its own feature (P0 when there are accounts). Selling something adds "Paywall and purchase" and, when any server feature is premium, "Entitlement sync" (Infrastructure); `/monetization` details them. Master-data import or admin entry is its own feature when the app needs reference data.
3. PRD section "Data model (draft)": main entities in plain words.
4. Present PRD draft, feature map with build order and data model; apply feedback; save.

Do NOT write spec files (`/write-spec`), the profile (`/architecture`), designs (`/design`) or code.

## Checklist
- [ ] PRD complete, no placeholders; ten architecture inputs recorded
- [ ] Features in INDEX.md with status Roadmap, type, dependencies; next ID updated
- [ ] Launch date checked against the P0 list
- [ ] User approved PRD and feature map

## Handoff
"Project is set up. Merge the `chore/init` pull request (or commit directly on `main` while the repository has no remote), then `/write-spec PROJ-1` for **[feature]**."

## Git
Branch `chore/init`, commit `docs: initialize project (PRD and feature map)`, pull request into `dev` (or `main`). No remote yet: commit on `main` and say so.
