---
name: audit
description: "Health check of the project's AI setup and documents: instruction length, INDEX vs feature folders, traceability (AC/EC without task or test), profile drift (code that violates docs/architecture-profile.md), stale docs/system.md, leftover TODOs, test suites, vendored skill freshness. Reports first, cleans up only after approval."
argument-hint: "optional: quick"
---

# Setup Audit

**Role:** you are an independent reviewer of the setup. You find decay before it costs quality and change nothing until the user approves the list.

Setups decay quietly. Find it before it costs quality. Read everything first, change nothing until the cleanup list is approved. `quick` runs checks 1 to 4.

## Checks
1. **Instruction length.** Lines loaded into every session: `CLAUDE.md`, rules without `paths:`, `docs/PRD.md`, `features/INDEX.md` (if included by `@`). Propose what should move to `docs/system.md`, a skill, or a path-scoped rule.
2. **INDEX vs folders.** Every row Planned or later has a folder; every folder has a row; Docs column matches; Next Available ID above every used ID.
3. **Traceability.** From Architected: every AC/EC in the coverage table. From In Progress: each with a test marked `red → green`. From In Review: each in `qa-report.md`. Struck-through IDs ignored.
4. **Profile drift.** `docs/architecture-profile.md` vs code: a second state library in `Package.swift` / `pubspec.yaml` / `build.gradle.kts`; ViewModels importing UI frameworks; network or storage calls in views; `DispatchQueue`/raw `Thread` in new code; `setState` for cross-screen state; a data store the profile does not name; secrets in source, plist, `strings.xml`. Each finding is a Gap.
5. **Status plausibility.** Approved needs `qa-report.md` with "Ready for acceptance: YES"; Accepted needs the sign-off lines; In Progress with all tasks ticked for days waits for `/qa`.
6. **Spec hygiene.** No status, dates or technical detail in specs; one feature, one spec.
7. **System picture.** `docs/system.md` vs reality: modules, screens, data stores, tests. Over ~150 lines: propose condensing.
8. **Leftovers.** `TODO`, `FIXME`, `TODO Text`; open questions older than the last sign-off; [HUMAN] tasks still open in features In Review or later; usage strings missing for a requested permission.
9. **Tooling.** Build and test commands from the profile pass with more than 0 tests; localization has no missing keys; the official Flutter plugin installed where Flutter is in scope.
10. **Skills freshness.** `.claude/skills/SOURCES.md` dates older than 6 months → propose `scripts/vendor-skills.sh`; vendored skills the profile never uses → propose removal.

## Report
- **Result:** one sentence.
- **Findings** sorted: Gap (breaks trace, workflow or profile), Decay, Cosmetic. Each with file, problem, proposed fix.
- **Cleanup list:** numbered, concrete.
Ask which items to clean up; do only those. Gaps that need code or tests are not cleanup: name the skill (`/tasks`, builder, `/qa`).

## Git
Branch `chore/audit-YYYY-MM-DD`, commit `chore: audit cleanup`, PR into `dev` (or `main`).
