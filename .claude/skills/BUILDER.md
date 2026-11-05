# Builder procedure (shared by /backend, /core, /ui, /platform)

Each builder skill says only what is specific to its tag. Everything below applies to all four.

## Before starting
1. Read `features/PROJ-X-name/tasks.md` first (ticks and "Implementation notes" say where the feature stands), then `docs/architecture-profile.md`, `features/INDEX.md`, `docs/system.md`, and in the feature folder `spec.md` and `architecture.md`. On a resume, read only the sections your open tasks name; `git log --oneline -15` and `git status` are the proof of state, a test run is not.
2. **Gate:** status Architected or In Progress, `tasks.md` exists. No plan → "Run `/tasks PROJ-X` first", stop. Lower levels still open (e.g. [BE] tasks before [CORE]) → name the builder that must run first, stop. Level-1 tasks carry the tag of the first builder that runs; that builder does them. In Review, Approved or Accepted with open bugs → status must go back to In Progress first (fix loop in `general.md`).
   **Fix mode:** if `qa-report.md` or "Acceptance" in the spec lists open bugs with your tag, fix exactly those (even with all tasks ticked): first a test that reproduces the bug and fails, then the fix. Add `BUG-n` to the coverage table and a note under "Implementation notes".
3. Read `CLAUDE.md` and the platform rule file (`.claude/rules/ios.md`, `flutter.md`, `android.md`). Load the vendored skills the profile lists for your work (platform column in `.claude/skills/SOURCES.md`); the routing skill (`flutter-skills-index`, `using-chrisbanes-skills`) decides which.
4. Blocking [HUMAN] tasks in level 1 (secrets, accounts) → stop, list them. Never read `.env*`, keystores, provisioning profiles, `GoogleService-Info.plist`, `google-services.json`.
5. Branch `feat/PROJ-X-name` (fixes: `fix/name`). Create from `dev` if missing (`main` while `dev` does not exist).

## Build, task by task
Work through your tag's tasks level by level. Tick each in `tasks.md` when done, commit it (`feat(PROJ-X): [tag] T-n what`), and add one line under "Implementation notes": `T-n done HH:MM, evidence (tests, counts), slowest run`. Do exactly what the task says: no extra options, screens, settings or abstractions.
- Reuse what exists (modules, components, helpers, test doubles) before writing new. Package versions from `architecture.md` F; before using an API you are not sure of, check Context7, never memory.
- Stay inside the profile. A task that needs something outside it: stop, note it, report. Never add a second state library, data store or navigation approach.
- Spec does not change during the build. Wrong or contradictory → stop that task, note under "Implementation notes", report; the fix goes through `/refine`.
- Visible text only through the localization system, in every language from the profile; missing text → placeholder marked `TODO Text`, listed in the report.
- Every Result/error at a layer boundary is handled, never swallowed; nothing throws across layers.

## Test first (red, then green), on the verification ladder
`docs/verification-ladder.md` is binding; the commands are `scripts/verify.sh` (L0 `compile`, L1 `only`, L2 `suite`, L3 `full`). Never a bare full-scheme `xcodebuild … test`, `flutter test` or `./gradlew test` after a single step.
For every task that names an AC or EC:
1. Write the test first, named with the ID (`ac3_…`, `ec1_…`), derived from the criterion's wording.
2. **L1, red:** `verify.sh only <its suite>` and confirm it **fails for the right reason** (missing behavior, not a typo). The test before the code is the red proof; do not sabotage working code to show red (fix mode is the exception: the code exists, so break it once, targeted, and restore with `git checkout --`).
3. Build until it passes: L0 `compile` after each edit, **L1, green:** `verify.sh only` again. Assert the result the criterion names, not that something exists. Never weaken an assertion.
4. Record in the coverage table: test name and `red → green`.
**0 tests run counts as failed**: `verify.sh` prints the count; read it, not just the exit code.
A single run over its budget (L1 2 min, L2 5 min, L3 10 min) is written under "Implementation notes" as `test loop too slow: <command> <time>`; fix the harness (scope, scheme, DerivedData, scheme test action), never the rung.

## Long commands
- Foreground commands stay under the tool's 10-minute limit; `verify.sh` caps L0 to L2 and runs L3 and L4 detached (`verify.sh wait full`). Never poll a build with `sleep` loops, never `pkill` a build, never a scratch `-derivedDataPath`, never `clean`, never `supabase start`/`stop` between tasks.
- A paid or live call runs once, as the plan approved it.

## Verify before reporting
- **L2** once per level before its commit: `verify.sh suite <module>` for every module the level touched.
- **L3** once before the report: `verify.sh full`, then `verify.sh wait full`; zero new warnings; the printed test count is above zero. UI/integration tests, snapshot matrices and device poses are L4 and belong to `/qa`: list what `/qa` must run on device.
- Localization has no missing keys. No secrets in diff (`git diff | grep -iE "api[_-]?key|secret|token"` shows nothing real).

## Update tracking
- `tasks.md`: ticks, coverage table, "Implementation notes" (what was built, deviations with reason, TODOs).
- `docs/system.md`: modules, screens, data, tests you added (current state, no history).
- New service with personal data → `docs/privacy.md`. New binding rule or past mistake → `CLAUDE.md`.
- INDEX.md status → In Progress. Re-read to verify.

## Report back
Plain words: X of Y tasks of your tag done, time per task and the slowest run, what the user must do ([HUMAN] tasks), what `/qa` must check on device, next step (next open tag's builder, or `/qa PROJ-X`; `/perf PROJ-X` first if a budget in the profile is touched). Stopping without this report counts as a failed run.

## Git
Commit after every task (`feat(PROJ-X): [tag] T-n what`), push the branch after each level. Do not merge.

## Context recovery
After compaction: re-read `tasks.md` (ticks and the progress lines show where you are), `git log --oneline -15`, `git status`, then only the spec and design sections the first open task names; continue with it. Do not re-run suites to find out where you are.
