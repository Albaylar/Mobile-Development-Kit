# QA report template

Write to `features/PROJ-X-name/qa-report.md` in the project's document language.

```markdown
# PROJ-X: Test report

**Tested:** YYYY-MM-DD · **Build:** branch/commit, build number · **Devices:** iPhone 16 Sim, iPhone SE Sim / Pixel 8 Emu, 5" Emu · **Tester:** QA (AI) + qa-engineer agent

### Coverage
- **Spec:** Y acceptance criteria, Z edge cases
- **In the task plan:** Y of Y, Z of Z
- **Proven by test (red → green):** Y of Y, Z of Z
- **Test quality sample (sabotage):** AC-1, AC-4 turn red when the behavior is missing
- **Built but not ordered:** none

### Acceptance criteria
- [x] AC-1: … (primary + smallest device)
- [ ] AC-2: … → BUG-1

### Edge cases
- [x] EC-1: airplane mode mid-request → queued, retried
- [x] own: app killed during write → …

### Regression and suites
- [x] unit / screen / snapshot / integration: N of N green (command: …)
- [x] localization complete, all languages switched

### Accessibility
- [x] VoiceOver / TalkBack main flow · [x] XXXL font · [x] contrast · [x] reduce motion

### Profile compliance, security, privacy
- [x] no construct outside `docs/architecture-profile.md`
- [x] tokens in Keychain / Keystore, no secrets in bundle
- [x] other user's data unreachable
- [x] no request outside docs/privacy.md, no personal data in logs
- [x] privacy manifest / Data Safety match behavior

### Performance
- [x] perf-report.md: cold start … ms (budget …), jank … % (budget …) · or "not touched"

### Bugs
**BUG-1: title**
- **Severity:** Critical / High / Medium / Low
- **Device:** …
- **Steps:** 1. … 2. …
- **Expected:** … · **Actual:** …
- **Regression test added:** `…` (red on bug, green after fix)

### Result
- **AC:** X of Y passed · **Bugs:** N (C/H/M/L) · **Ready for acceptance:** YES / NO

### Earlier runs
_None._
```
