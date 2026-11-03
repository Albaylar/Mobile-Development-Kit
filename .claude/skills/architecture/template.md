# PROJ-X: Technical Design

| | |
|---|---|
| **Feature** | [name](spec.md) |
| **Created** | YYYY-MM-DD |
| **Based on** | spec.md at the commit named in its sign-off line, `docs/architecture-profile.md` |
| **Reviewed by** | _name (four eyes), or "owner (self-reviewed)"_ |

## A. Screens and navigation
<!-- Screens, entry points, back stack, deep links. Reused screens/components by name. -->
```
Tab "Orders"
  OrderListScreen (exists) → OrderDetailScreen (new) → sheet EditNoteScreen (new)
```

## B. Modules and state
| Screen | Module / package | State holder | State it owns | Events in → out |
|---|---|---|---|---|

## C. Data
<!-- Entities in plain words: fields, limits, relations, where stored (per profile), cache/offline behavior, retention. -->

## C2. Offline queue and sync (only if the profile is cached or offline-first)
<!-- Which writes are queued, entry removed only after server confirmation, server-side ids, idempotent retry, conflict rule, storage-full behavior, what the user sees while pending. -->
- n/a

## D. Access and security
| Data or action | Who | Enforced where (server / app) | Secret storage |
|---|---|---|---|

## E. Platform work
<!-- Permissions + usage strings, push, background, deep links, widgets, Info.plist / Manifest / entitlements. Store-review impact. "None" if none. -->
- None

## E2. Tests
| ID | Test kind | Where | Doubles needed |
|---|---|---|---|
| AC-1 | unit + screen | `…Tests/OrderDetailTests` | FakeOrderRepository |

## F. External services and current documentation
<!-- Per service: purpose, version checked (Context7 / official docs, date), APIs, cost, personal data or device id sent. -->
- None

## F2. Only a human can do this
<!-- Developer account, certificates, store listing, dashboard settings, secrets. Becomes [HUMAN] tasks. -->
- Nothing

## G. Files
| File | New / changed | Purpose |
|---|---|---|

## H. Deliberately simple
- …

## I. Decisions
- [ ] Question → recommendation: …

## J. Effort
<!-- Does the estimate in INDEX.md hold? If not: new estimate and reason. -->
