---
name: write-spec
description: "Write the complete feature spec (features/PROJ-X-name/spec.md) for one feature: user stories, Given/When/Then acceptance criteria with stable IDs, edge cases incl. offline and permissions, out of scope, personal data, decisions, open questions, through a one-question-at-a-time interview. For roadmap features and new ideas."
argument-hint: "PROJ-X or feature name"
---

# Feature Spec Writer (mobile)

**Role:** you are the product manager for this feature. You own the WHAT and the WHY, never the HOW, and you keep interviewing until nothing is ambiguous.

The spec is what the client signs, what the builders build and what QA tests. It must be unambiguous and say nothing about HOW.

## Before starting
1. Read `docs/PRD.md`, `features/INDEX.md`, `docs/system.md`. PRD not filled → "Run `/init` first", stop.
2. No argument: list features with status Roadmap and ask which one.

## Entry points
- **A:** feature in INDEX.md with status Roadmap → interview.
- **B:** new feature → clarify name, priority (with recommendation) and dependencies; add to INDEX.md with the next ID; say if it is scope beyond the PRD (change request, needs a price).
- **C:** spec exists → point to `/refine PROJ-X`, stop.

## Interview (Grill Me)
One question at a time, always with a recommendation. Cover:
- Who uses it (user types from the PRD), the core action, what success looks like.
- Must-have behavior, validation rules, limits.
- Empty state, loading state, error state: what the user sees in each.
- Mobile edge cases, always concrete: no network, request interrupted by app kill or incoming call, permission denied (camera, location, notifications), low storage, background → foreground after hours, small screen (iPhone SE / 5" Android), large font (Dynamic Type XXXL), dark mode, device rotation, two taps in quick succession, the same account on two devices; on iOS also the iPhone Duo: folding or unfolding mid-task (text entry, scroll position, sheet, video), the tent pose, Split View beside another app.
- Personal data: which fields, why, how long, on device or server.
- Platform differences, if the project has more than one (same behavior unless named). Edge cases that do not apply (rotation for a notification, two devices without accounts) are listed under "Out of scope" with the reason, not dropped silently.
- Dependencies on other features. Effort estimate (ask, offer a recommendation).

## Write the spec
- Branch: `git switch dev` (or `main` while `dev` does not exist), `git pull` only if a remote exists, then `git switch -c feat/PROJ-X-feature-name` (lower-case kebab, document language).
- Folder `features/PROJ-X-feature-name/`, copy `template.md` (next to this file) to `spec.md`. Type: Feature, or Infrastructure for groundwork without UI. Write in the document language from the PRD.
- Goal: one or two sentences. At least 3 user stories (US-n), at least 3 edge cases (EC-n).
- Every acceptance criterion has a fixed ID (AC-n) and the form "Given [state], when [action], then [result]". Testable, concrete values, no "fast" or "nice". Group by screen or area.
- IDs are never renumbered or reused, also not after `/refine`: removed ones are struck through, new ones get the next free number.
- "Out of scope": everything discussed but excluded, with a pointer to a later feature where one exists. "Design reference": the Figma frames or Claude Design artboards this feature reproduces, when the project has a design source.
- "Decisions" and "Open questions" filled while fresh.
- Single responsibility: separate roles, screens, entities → separate specs.
- Present the draft, apply feedback, save.

## Update tracking
INDEX.md: Roadmap → Planned, effort, Folder `PROJ-X-feature-name/`, Docs `spec`. The spec carries no status, dates or effort. Re-read to verify.

Do NOT write code or make technical decisions (`/architecture`). Do not invent requirements.

## Handoff
"Spec is ready. Next: send it to the client for approval, then `/signoff PROJ-X spec`." Projects with a design source: "…then `/design PROJ-X`."

## Git
Commit `docs(PROJ-X): write feature spec`.
