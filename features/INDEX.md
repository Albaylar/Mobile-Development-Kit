# Feature Index

> The only place for status, owner, priority and effort. Skills read it at start and update it at the end. It describes the state, it is no log.

## Statuses
Roadmap → Planned → Signed Off → (Designed) → Architected → In Progress → In Review → Approved → Accepted → Released (in review) → Released

- **Roadmap**: identified in `/init`, no spec yet
- **Planned**: spec written (`/write-spec`), waiting for the client
- **Signed Off**: client approved the spec (`/signoff PROJ-X spec`), gate 1
- **Designed**: screens approved in the design tool (`/design`); only in projects with a design source
- **Architected**: technical design approved (`/architecture`), then task plan (`/tasks`)
- **In Progress**: being built (`/backend`, `/core`, `/ui`, `/platform`), or back in the fix loop
- **In Review**: `/qa` running
- **Approved**: QA passed, no critical or high bugs; `/perf` green where budgets apply
- **Accepted**: client accepted the build (`/signoff PROJ-X acceptance`), gate 2
- **Released (in review)**: submitted to the stores (`/release`)
- **Released**: approved by the stores and live

Column "Docs": files in the feature folder (spec, architecture, tasks, perf-report, qa-report).

## Features

| ID | Feature | Type | Priority | Depends on | Status | Owner | Folder | Docs | Effort est. (h) | Effort actual (h) |
|----|---------|------|----------|------------|--------|-------|--------|------|-----------------|-------------------|

## Next Available ID: PROJ-1
