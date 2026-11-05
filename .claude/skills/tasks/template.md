# PROJ-X: Task plan

| | |
|---|---|
| **Feature** | [name](spec.md) |
| **Based on** | spec.md `<hash from sign-off line>`, architecture.md `<hash of design commit>`, profile `docs/architecture-profile.md` |
| **Created** | YYYY-MM-DD |

Legend: **[P]** independent of the other tasks of its level, may run in parallel. **[BE]** server (`/backend`) · **[CORE]** models, repositories, services, state (`/core`) · **[UI]** screens and navigation (`/ui`) · **[PLAT]** permissions, push, deep links, manifests (`/platform`) · **[HUMAN]** a person does it.
Every task names the AC and EC it fulfils.

## Level 1: Groundwork and connection tests
- [ ] **T-1** [HUMAN] … · fulfils: basis for T-2

## Level 2: Backend
- [ ] **T-2** [BE] [P] … · fulfils: AC-1, EC-1

## Level 3: Core
- [ ] **T-3** [CORE] … repository + unit tests with FakeService · fulfils: AC-2

## Level 4: UI
- [ ] **T-4** [UI] [P] … screen + screen test · fulfils: AC-3

## Level 5: Platform
- [ ] **T-5** [PLAT] … permission + usage strings in every language · fulfils: EC-2

## Level 6: Hardening
- [ ] **T-6** [UI] loading, error, empty, offline states; smallest screen; XXXL font; dark mode · fulfils: EC-1, EC-3
- [ ] **T-7** [HUMAN] TestFlight group / internal track testers · fulfils: basis for acceptance

## Coverage
Every AC and EC from spec.md appears here with at least one task. An empty row is a planning error.
"Test" and "Evidence" are filled by the builders: each test is red first (run before the code exists), then green; both runs through `scripts/verify.sh only`.

| ID | Short description | Tasks | Test | Evidence |
|---|---|---|---|---|
| AC-1 | … | T-2, T-3 | `OrderRepositoryTests.ak1_…` | red → green |
| EC-1 | … | T-2, T-6 | | |

## Implementation notes
<!-- Builders add: what was built, deviations from the design with reason, open TODOs. -->
