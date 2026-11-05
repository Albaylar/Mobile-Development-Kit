---
name: signoff
description: "Record a client sign-off. \"spec\" = gate 1 (spec approved, status Signed Off). \"acceptance\" = gate 2 (client accepted the build on TestFlight / internal track, status Accepted). Only the user runs this."
argument-hint: "PROJ-X spec|acceptance"
disable-model-invocation: true
---

# Client Sign-off

**Role:** you are the project's record keeper. You write down exactly what was approved, by whom and on which version; you never approve anything yourself.

What was approved is written down with date, person, channel and the exact build or commit.

## Before starting
Read `features/PROJ-X-*/spec.md` (gate 2 also `qa-report.md`), `features/INDEX.md` and the reviewer line in `docs/PRD.md`. Gate type missing → ask "Spec approval or acceptance of the result?".
**Solo mode:** the PRD names the reviewer as "owner (self-reviewed)" → no interview. The person is the owner, the channel "internal (self)", the date today (gate 2: the build from `qa-report.md`); open questions are listed once and count as accepted as open unless the owner objects. Write the line, update INDEX.md, commit, hand off. One command, one commit.

## Gate 1: `spec`
- Required status: Planned. Otherwise explain and stop.
- Open questions must be resolved or explicitly accepted as open by the client.
- Ask one at a time: who approved (a name, also for internal projects), when (the day of approval, even if later than the commit), how (recommend e-mail: traceable; internal projects: "internal (self)").
- `git status -- features/PROJ-X-*/spec.md` must be clean; if not, commit first (`docs(PROJ-X): spec as sent to client`).
- Write under "Spec sign-off": `Approved by [name] on [date] via [channel]. Valid for commit [git log -1 --format=%h -- spec.md].`
- INDEX.md: Signed Off.

## Gate 2: `acceptance`
- Required status: Approved (QA passed, no critical or high bugs). Otherwise explain and stop.
- Ask: which build (TestFlight build number / Play internal track version code), on which devices, who accepted, when, how, and whether small issues were noted.
- Small issues: list under "Acceptance" as open items; ask whether they block release. Blocking → status In Progress (fix loop: builder → `/qa` → acceptance again). Not blocking → record acceptance, items become follow-ups.
- New wishes not in the spec are change requests → `/refine` or `/write-spec`.
- Write under "Acceptance": `Accepted by [name] on [date] via [channel] on build [number] ([platforms]).`
- INDEX.md: Accepted.

## Handoff
Gate 1: "Sign-off recorded. Next: `/architecture PROJ-X`" (projects with a design source: "`/design PROJ-X`"). · Gate 2: "Acceptance recorded. Merge the feature pull request into `dev`, then `/release PROJ-X`."

## Git
Commit `docs(PROJ-X): record client sign-off (spec|acceptance)`.
