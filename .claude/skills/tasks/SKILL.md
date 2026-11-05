---
name: tasks
description: "Turn a feature's spec and technical design into an ordered task plan (tasks.md): levels, [P] for parallel tasks, each task tagged [BE] [CORE] [UI] [PLAT] or [HUMAN] and tied to the AC/EC it fulfils, plus a coverage table that proves nothing is missing. After /architecture, before any builder."
argument-hint: "PROJ-X"
---

# Task Planner (mobile)

**Role:** you are the tech lead planning the build. You turn spec, design and architecture into small, checkable tasks, prove that every criterion is covered, and add nothing nobody asked for.

A good plan is why the build stays small and complete: nothing forgotten, nothing extra.

## Before starting
1. Read `features/INDEX.md`, `docs/system.md`, `docs/architecture-profile.md`, and in the feature folder `spec.md` and `architecture.md` (and the approved design frames if `/design` ran).
2. **Gate:** status Architected. Otherwise stop and name the missing step. **Dependencies** in INDEX must be Accepted or later (the app shell: at least Approved), otherwise stop: a plan cannot reuse screens that do not exist.
3. `tasks.md` exists with ticked tasks → re-plan: keep ticked tasks, mark obsolete ones `~~T-n~~ dropped (reason)`, add new ones with the next free number. Never renumber.
4. Check what exists in the code: the modules, screens, repositories and tests `architecture.md` names.

## Build the plan
Copy `template.md` to `features/PROJ-X-name/tasks.md`.

**Levels** in this order, leave empty ones out:
1. **Groundwork and connection tests:** [HUMAN] steps this feature needs that `docs/preflight.md` does not cover (link the pre-flight items, do not repeat them), minimal live test of every new external service, new packages added to the manifest with the version from `architecture.md` F. Non-[HUMAN] tasks here carry the tag of the **first builder that runs** for this feature ([BE] if there are [BE] tasks, else [CORE]). **The first feature with app code** adds the harness task: `scripts/verify.sh` configured (`.verify.env`: scheme, destination, UI targets), the app scheme's test action without UI targets, one `.build/DerivedData`, `verify.sh only` proven under two minutes and `verify.sh full` under ten.
2. **Backend** [BE]: tables, policies, functions, API contracts, server tests.
3. **Core** [CORE]: models, repositories, services, local store, sync, state holders, **protocols for platform services and their fakes**, unit tests.
4. **UI** [UI]: screens, navigation, components, screen tests, snapshot/golden tests, exactly the approved design frames.
5. **Platform** [PLAT]: **implementations** of the platform protocols, permissions, push, deep links, background, extension targets with their build settings, manifests, store-review items.
6. **Hardening:** loading, error, empty and offline states; smallest screen and XXXL font; dark mode; accessibility; localization complete; `docs/system.md`; [HUMAN] store listing or test-group steps.

**Each task:** one checkable result, 15 to 60 minutes, tagged, [P] if independent within its level, names the AC/EC it fulfils (groundwork: `fulfils: basis for T-n`) and the test suite its L1 run targets (`verify: AccountTests/AccountManagerTests`). A screen and its screen test are one task; a module's snapshot images are one task. Only what spec, design and profile require; anything else goes to "Notes" as a possible change request. **Caps:** an Infrastructure feature has at most 12 tasks and 4 [HUMAN] tasks; a plan over 25 tasks means the spec is two features.

**Paid services:** the level-1 connection test uses the cheapest call, states the expected cost, needs the user's OK.

**Coverage table:** every AC and EC with at least one task. "Test" and "Evidence" stay empty for the builders. Fill it last, check it twice; an empty row means the plan is incomplete.

## Review
Summary: tasks per level, [HUMAN] tasks, external costs, coverage. Ask whether the plan fits; apply feedback.

## Update tracking
Status stays Architected. INDEX.md Docs: add `tasks`. Re-read to verify.

## Handoff
[HUMAN] tasks in level 1 first ("Please do these first: …"); tick them in the main conversation after the human confirms, never in a sub-agent. Then: "Plan is ready. Next: `/backend PROJ-X`" if [BE] tasks exist, else "`/core PROJ-X`". Solo mode (PRD reviewer "owner (self-reviewed)"): the review and the handoff are one message.

## Git
Commit `docs(PROJ-X): add task plan`.
