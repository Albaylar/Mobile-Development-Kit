---
name: backend
description: "Work through the [BE] tasks of a feature: tables, access policies, server functions and API contracts for the backend named in the architecture profile (Supabase, Firebase or an own API), with server-side tests, in an isolated sub-agent. After /tasks, before /core."
argument-hint: "PROJ-X"
context: fork
agent: backend-dev
background: false
---

# Backend Developer

Build the server side for feature $ARGUMENTS. Follow `.claude/skills/BUILDER.md`; this file adds what is specific to [BE]. No [BE] tasks → report "Nothing to do for the backend, next `/core PROJ-X`" and stop.

## Specific rules
- The backend is the one named in `docs/architecture-profile.md`. The mobile app ships only a publishable key, so server-side access rules (RLS, security rules, API auth) are the only protection: every table or collection has them for read, create, update, delete, exactly as `architecture.md` D says.
- Schema changes are migrations (idempotent, versioned) so every environment (dev, staging, production) applies the same file. Record the order relative to the app release (schema first or app first) under "Implementation notes"; a mobile app cannot be force-updated, so the server must accept the previous app version.
- API contracts are written down (fields, types, error codes) before `/core` builds against them; the mobile client never parses undocumented fields.
- Only the personal data fields the spec lists. Retention and deletion paths (account deletion is a store requirement) exist for every personal field.
- Paid external APIs: only the connection test the plan approved, cheapest call, report the real cost, never auto-retry.
- Ladder for the server: L1 is one test file (`supabase test db supabase/tests/<file>.sql`, `firebase emulators:exec` with one spec, one `go test -run`), L2 the test directory, L3 the directory plus the migration applied to the development project once. `supabase start` once per run, `supabase db reset` only after a migration changed, never `stop`/`start` between tasks.
- Subscriptions: the webhook handler and entitlement storage follow `docs/monetization.md` §2–4 and `rules/monetization.md` (verify secret, idempotent by event id, re-read the customer, one state model, revoke only when access ends, clients never write entitlements). Tests: every state transition, duplicate, wrong secret, client write refused, sandbox vs production.

## Tests
Server tests for every policy: own data, another user's data, unauthenticated, wrong role; contract tests for every endpoint the app will call. Test command and framework per backend (Supabase: pgTAP or PGlite scenarios; Firebase: emulator rules tests).

## Report
What is stored where, who can access it, what the user must apply in which environment and in which order, any access-rule change (needs explicit approval). Next: "`/core PROJ-X`".
