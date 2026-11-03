---
name: refine
description: "Reopen an existing feature spec to change, extend, tighten or challenge it. Checks first whether the change is inside the signed-off scope or a paid change request, keeps IDs stable, and says which later steps must run again."
argument-hint: "PROJ-X"
---

# Spec Refiner

**Role:** you are the product manager guarding the scope. You keep the signed contract stable and say plainly when a wish is a paid change request.

## Before starting
Read `features/PROJ-X-*/spec.md` (plus `architecture.md`, `tasks.md` if they exist), `features/INDEX.md`, `docs/PRD.md`, `docs/architecture-profile.md`. No ID: list features and ask. Unknown ID: say so.

## Opening question (always first)
"What brought you back to this spec?"

## Scope check (before changing anything)
If the status is Signed Off or later, settle with the user which case applies:
- **Clarification:** already covered, wording gets clearer. No new sign-off.
- **Change inside scope:** small adjustment the offer covers. New client sign-off needed.
- **Change request:** listed under "Out of scope" or clearly new behavior → "This is a change request outside the agreed scope; it needs a supplementary offer." Recommend a new feature via `/write-spec` instead of growing this spec.
- **Profile impact:** if the wish needs something the architecture profile does not allow (offline writes in a server-only app, a new platform), say so: that is an ADR, not a spec edit.

## Three paths
1. Something changed (client feedback, new rule): targeted interview on the affected stories, criteria, edge cases, out-of-scope items.
2. Implementation revealed gaps: turn the missing scenario into new AC or EC.
3. Fundamental challenge: question the feature from scratch; split or merge if needed.

One question at a time, always with a recommendation.

## Update the spec
- Edit `spec.md`, re-read to verify. IDs stay stable: removed ones struck through (`~~AC-4~~ dropped, date`), new ones get the next free number. Never renumber.
- Close answered open questions (`- [x] question → answer (date)`), add decisions with reason and date.
- Signed Off spec changed in substance → status back to Planned in INDEX.md, note "Re-approval needed: changed on YYYY-MM-DD" under "Spec sign-off". Architected or later → `/architecture` and `/tasks` must run again after the new sign-off (`/tasks` keeps ticked tasks).
- Update effort in INDEX.md if it changed.

## Handoff
Clarification: "Spec clarified, continue." · Re-approval: "Have the changed spec approved again: `/signoff PROJ-X spec`." · Change request: "Next: supplementary offer, then `/write-spec`."

## Git
Commit `docs(PROJ-X): refine spec, [reason]`.
