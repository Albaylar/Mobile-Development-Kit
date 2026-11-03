# Backend selection for mobile apps (2026)

> Used by `/init` (decision 3) and `/architecture` (data model). Sources: vendor docs and 2026 comparisons; prices are blog figures, verify before quoting. Research 2026-11-03.

## The three questions that decide it
1. **Is the data relational?** Entities with relations, joins, reports, permissions per row → SQL (Postgres). Documents that are read and written whole, per user, little cross-entity querying → a document store is fine.
2. **Must writes survive offline?** Yes → either Firestore (offline cache and write queue built in, on by default on iOS/Android) or Postgres + a sync engine (PowerSync). Supabase alone has no offline mode.
3. **Exit path and cost model.** Postgres is open: dump and move. Firestore has no open-source equivalent; leaving means rewriting the data layer. Firestore bills per document read/write (chatty apps get expensive); Supabase bills a flat tier plus overage.

## Options
| Option | Model | Offline | Auth, push, crash | Region / privacy | Pick when |
|---|---|---|---|---|---|
| **Supabase** (Postgres, RLS, Storage, Edge Functions, Realtime) | SQL | none built in → add **PowerSync** (SQLite on device, Apache-2.0 SDKs, self-hostable Open Edition free, cloud from ~$49/mo) | Auth yes; push and crash via third parties | EU region selectable; one DPA | Relational data, row-level permissions, B2B, EU clients, you want a Postgres exit path |
| **Firebase** (Firestore + Auth + FCM + Crashlytics; **SQL Connect** = Cloud SQL Postgres with GraphQL, GA 2025, renamed 2026) | NoSQL (Firestore) or SQL (SQL Connect) | Firestore: built in. SQL Connect: client-side offline caching reported GA in 2026, verify | All first-party (push, crash, analytics, remote config) | Multi-region, Google DPA; EU-only storage needs explicit location choice | Consumer app, offline-heavy, realtime feeds, you want push/crash/analytics from one vendor |
| **Own API** (Go/… + Postgres) | SQL | you build the sync | you build or buy | wherever you host | Existing backend, special compliance, heavy business logic server-side |
| **No backend** | device only | n/a | n/a | n/a | Tools whose data never leaves the phone; iCloud/CloudKit sync for personal data on iOS |

## Recommendations by profile
- **Profile A, consumer, both platforms, offline:** Firebase (Firestore) unless the data is relational or EU-only storage is a hard requirement.
- **Profile A/B, business app, relational, EU client:** Supabase; add PowerSync only when offline writes are required (the dry-run bakery app: yes).
- **Profile C or an existing backend:** own API with Postgres; sync engine chosen per feature.
- **iOS-only personal tools:** no backend + CloudKit.

## What the profile records
Backend, auth, region, offline mechanism, who creates the project, the DPA, and the cost model. `/backend` then writes migrations and access rules for exactly that backend; `/core` builds against the written API contract.

## Not chosen and why
- MongoDB Realm / Atlas Device Sync: deprecated by MongoDB (2025).
- ElectricSQL: sync layer without client persistence; more to build than PowerSync for the same result.
- Hand-written sync for multi-table, two-way data: historically the source of data loss; only for one-way, few-table queues (rules in `architecture.md` C2).
