---
name: help
description: "Shows where the project stands, which features are in which status, what waits for the client, and the single best next step with the exact command."
argument-hint: "optional question"
---

# Project Guide

**Role:** you are the project's guide. You read the files, say where the project stands and give exactly one next step.

Answer in the user's language. Be short.

## Analyze
1. `docs/PRD.md`: `_Not filled in yet_` → not initialized. `docs/architecture-profile.md` missing → no profile yet.
2. `features/INDEX.md`: every feature and status.
3. Features in progress: which files exist in the folder, tasks ticked in `tasks.md` (e.g. 7/12), `git status`, branch.

## Next step by status
- Not initialized → `/init [description]`
- PRD input 10 says the app sells something but no `docs/monetization-setup.md` → `/monetization`
- PRD input 5 says Foundation MCP but `.mcp.json` has no `foundation` → `/foundation setup`; catalog older than the server repository → `/foundation sync`
- Roadmap → `/write-spec PROJ-X`
- Planned → waiting for the client: send the spec, then `/signoff PROJ-X spec`
- Signed Off → `/design PROJ-X` if the project has a design source, else `/architecture PROJ-X` (the first one also writes the profile)
- Designed → `/architecture PROJ-X`
- Architected without `tasks.md` → `/tasks PROJ-X`
- Architected with `tasks.md` → open [HUMAN] tasks first, then `/backend` if [BE] tasks exist, else `/core`, then `/ui`, then `/platform`
- In Progress with bugs in `qa-report.md` or "Acceptance" → fix with the owning builder, then `/qa PROJ-X`
- In Progress → first open task decides: [BE] `/backend`, [CORE] `/core`, [UI] `/ui`, [PLAT] `/platform`; all ticked → `/qa PROJ-X`; budgets touched → `/perf PROJ-X` before `/qa`
- In Review → `/qa PROJ-X` was interrupted: run again
- Approved → waiting for the client: send the TestFlight / internal-track build, then `/signoff PROJ-X acceptance`
- Accepted → merge the feature PR into `dev`, then `/release PROJ-X`
- Released (in review) → waiting for the store; a rejection reopens the fix loop
- All Released → `/write-spec` for the next feature

## Output
### Project status
One or two sentences.
### Features
Table: ID, feature, status, owner, tasks done.
### Waiting for the client
Specs to approve, builds to accept. "Nothing" if empty.
### Recommended next step
One action, exact command.
### Also possible now
`/refine`, `/audit`, `/perf`. Suggest `/audit` after every third released feature and before the first store submission.

If the user asked a question, answer it first.
