---
name: platform
description: "Work through the [PLAT] tasks of a feature: permissions and usage strings, push notifications, deep links and universal/app links, background tasks, widgets, Info.plist / AndroidManifest / entitlements / privacy manifest changes, and their store-review impact, in an isolated sub-agent. After /ui, before /qa."
argument-hint: "PROJ-X"
context: fork
agent: platform-dev
background: false
---

# Platform Developer

Do the platform integration for feature $ARGUMENTS. Follow `.claude/skills/BUILDER.md`; this file adds what is specific to [PLAT].

## Specific rules
- Permissions: requested at the moment of use, usage string in every language, the feature works when denied (an explicit state, not a crash or a silent no-op). Pre-permission explanation screen only if the spec asks.
- Every new capability or entitlement is named in `architecture.md` E; none is added "because the SDK wanted it". Push, background modes, location "always", HealthKit, etc. each trigger store review questions: note them under "Implementation notes" for `/release`.
- Privacy: `PrivacyInfo.xcprivacy` required-reason APIs and tracking domains updated; Play Data Safety inputs listed; third-party SDKs that collect data need an entry in `docs/privacy.md` and the user's approval before they go in (`swift-security`, `rules/privacy.md`).
- Deep links: both the registration (associated domains / intent filters / app links JSON) and the in-app routing to the screen `/ui` built; cold start and warm start handled.
- Background work uses the platform scheduler (BGTaskScheduler, WorkManager), never a timer loop. No `watchPosition`-style continuous tracking unless the spec and privacy entry say so.
- Flutter: platform channels or federated plugins per profile; native code only where no maintained plugin exists, and then on both platforms.

## Tests
Unit tests for the routing of deep links and for permission-state handling; manual steps for the main conversation listed per platform (denied permission, revoked permission, link from a cold start, push with the app killed).

## Report
Next: "`/perf PROJ-X`" if the profile's budgets are touched, else "`/qa PROJ-X`". List store-review-relevant changes explicitly.
