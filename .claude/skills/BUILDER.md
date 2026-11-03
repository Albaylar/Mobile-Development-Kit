# Builder procedure (shared by /backend, /core, /ui, /platform)

Each builder skill says only what is specific to its tag. Everything below applies to all four.

## Before starting
1. Read `features/INDEX.md`, `docs/system.md`, `docs/architecture-profile.md`, and in `features/PROJ-X-name/`: `spec.md`, `architecture.md`, `tasks.md`.
2. **Gate:** status Architected or In Progress, `tasks.md` exists. No plan → "Run `/tasks PROJ-X` first", stop. Lower levels still open (e.g. [BE] tasks before [CORE]) → name the builder that must run first, stop. Level-1 tasks carry the tag of the first builder that runs; that builder does them. In Review, Approved or Accepted with open bugs → status must go back to In Progress first (fix loop in `general.md`).
   **Fix mode:** if `qa-report.md` or "Acceptance" in the spec lists open bugs with your tag, fix exactly those (even with all tasks ticked): first a test that reproduces the bug and fails, then the fix. Add `BUG-n` to the coverage table and a note under "Implementation notes".
3. Read `CLAUDE.md` and the platform rule file (`.claude/rules/ios.md`, `flutter.md`, `android.md`). Load the vendored skills the profile lists for your work (platform column in `.claude/skills/SOURCES.md`); the routing skill (`flutter-skills-index`, `using-chrisbanes-skills`) decides which.
4. Blocking [HUMAN] tasks in level 1 (secrets, accounts) → stop, list them. Never read `.env*`, keystores, provisioning profiles, `GoogleService-Info.plist`, `google-services.json`.
5. Branch `feat/PROJ-X-name` (fixes: `fix/name`). Create from `dev` if missing (`main` while `dev` does not exist).

## Build, task by task
Work through your tag's tasks level by level. Tick each in `tasks.md` when done. Do exactly what the task says: no extra options, screens, settings or abstractions.
- Reuse what exists (modules, components, helpers, test doubles) before writing new. Package versions from `architecture.md` F; before using an API you are not sure of, check Context7, never memory.
- Stay inside the profile. A task that needs something outside it: stop, note it, report. Never add a second state library, data store or navigation approach.
- Spec does not change during the build. Wrong or contradictory → stop that task, note under "Implementation notes", report; the fix goes through `/refine`.
- Visible text only through the localization system, in every language from the profile; missing text → placeholder marked `TODO Text`, listed in the report.
- Every Result/error at a layer boundary is handled, never swallowed; nothing throws across layers.

## Test first (red, then green)
For every task that names an AC or EC:
1. Write the test first, named with the ID (`ak3_…`, `sf1_…`), derived from the criterion's wording.
2. Run it and confirm it **fails for the right reason** (missing behavior, not a typo).
3. Build until it passes. Assert the result the criterion names, not that something exists. Never weaken an assertion.
4. Record in the coverage table: test name and `red → green`.
**0 tests run counts as failed**: read the test count in the output, not just the exit code.

## Verify before reporting
- Full build and test command of the profile passes, zero new warnings (`ios.md` / `flutter.md` / `android.md` name the command).
- Localization has no missing keys. No secrets in diff (`git diff | grep -iE "api[_-]?key|secret|token"` shows nothing real).
- You cannot run a device or simulator interactively unless your skill says so: list what the main conversation must verify on device.

## Update tracking
- `tasks.md`: ticks, coverage table, "Implementation notes" (what was built, deviations with reason, TODOs).
- `docs/system.md`: modules, screens, data, tests you added (current state, no history).
- New service with personal data → `docs/privacy.md`. New binding rule or past mistake → `CLAUDE.md`.
- INDEX.md status → In Progress. Re-read to verify.

## Report back
Plain words: X of Y tasks of your tag done, what the user must do ([HUMAN] tasks), what to check on device, next step (next open tag's builder, or `/qa PROJ-X`; `/perf PROJ-X` first if a budget in the profile is touched).

## Git
Commit `feat(PROJ-X): [tag] [what]` after each level, push the branch. Do not merge.

## Context recovery
After compaction: re-read `tasks.md` (ticks show where you are), the spec, `git diff`, `git status`; continue with the first open task.
