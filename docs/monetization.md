# Monetization: in-app purchases and subscriptions

> Used by `/init` (decision 10), `/monetization`, `/architecture`, `/backend`, `/core`, `/qa` and `/release`. Research 2026-11-03; vendor docs are the source for event names, check them again before building.

The hard part of subscriptions is not the purchase button. It is keeping **one truth about who has access** across the store, the app and your backend, through renewals, failed payments, grace periods, cancellations, refunds, upgrades and account switches. Get it wrong and paying users lose access or cancelled users keep it.

## 1. Do not talk to the stores directly
Use a subscription platform. It validates receipts with Apple and Google, normalizes both stores into one model, sends webhooks, and gives revenue analytics. Writing your own StoreKit 2 + Play Billing + server-notification pipeline is weeks of work and a permanent source of edge-case bugs.

| | **RevenueCat** (default) | **Adapty** |
|---|---|---|
| Pick when | you want the broadest ecosystem, integrations (Firebase extension, analytics, attribution), mature SDKs, and an official Claude Code toolkit | paywall and onboarding A/B testing is central to the business, or you want a larger free tier before paying |
| SDKs | iOS, Android, Flutter (`purchases_flutter`), KMP, React Native | iOS, Android, Flutter (`adapty_flutter`), React Native |
| Paywalls | RevenueCat Paywalls + Experiments | paywall builder, onboarding builder, deep A/B testing |
| Backend sync | webhooks; official **Firebase extension** (Firestore + Auth custom claims); REST API to re-read a customer | webhooks (shared secret in `Authorization`, answer 200 within 10 s); REST API |
| AI tooling | **RevenueCat AI Toolkit**: Claude Code plugin with a hosted MCP server (`mcp.revenuecat.ai`) and skills, plus `revenuecat-play-billing` | docs include webhook guidance for AI agents; no official MCP found |
| Pricing (verify) | free up to a monthly tracked revenue threshold, then a share of revenue | larger free tier reported, then a plan or a share of revenue |

Recommendation: **RevenueCat unless the client's growth plan is built on paywall experiments**, then Adapty. Both are a data processor: add them to `docs/privacy.md` with the DPA. Pricing figures in comparison blogs conflict; check the vendors' pricing pages and write the result into the ADR.

RevenueCat AI Toolkit for Claude Code (per machine, optional, needs a RevenueCat account):
```bash
claude plugins marketplace add RevenueCat/ai-toolkit
```
```bash
claude plugins install revenuecat
```

## 2. The architecture
```
 App Store / Google Play
        │  receipts, server notifications
        ▼
 RevenueCat / Adapty ── dashboards, analytics, experiments
        │  webhook (signed)              ▲ REST: re-read customer
        ▼                                │
 Backend webhook handler ──────────────── │
        │  idempotent upsert
        ▼
 entitlements (one row/doc per user)  +  subscription_events (append-only log)
        │                                      
        ├─ server features check it (never trust the client)
        └─ app reads it for server-side data; SDK CustomerInfo for UI gating
```

Rules:
1. **App user id = your backend user id** (Firebase UID, Supabase `auth.uid()`, your API's user id). Set it with the SDK's `logIn` right after sign-in; call `logOut` on sign-out. Anonymous purchases before login are aliased by the platform; test that path.
2. **The client gates UI, the server gates data.** The SDK's customer info decides whether to show the paywall. Anything the server delivers only to subscribers (premium content, API quota, sync) checks the backend entitlement, because a client flag can be spoofed.
3. **The webhook is a trigger, the platform is the truth.** Events can arrive late, twice or out of order. On every event, either apply it idempotently by event id with its timestamp, or re-read the customer from the platform's REST API and write the full state. Re-reading is simpler and safe; it costs one API call per event.
4. **Revoke only at the end of access.** A cancellation usually means "auto-renew turned off", not "access ended". Access ends on expiration, on refund/revocation, or when a grace period ends without payment.
5. **Log every event** (append-only, with the raw payload) for support and audits. Never log card data (you never receive it) or more personal data than the user id.
6. **Respond fast.** Verify the signature or shared secret, store the raw event, return 200, process asynchronously. Platforms retry on failure; duplicates are expected.

## 3. One state model for every backend
| State | Has access | Typical cause |
|---|---|---|
| `active` | yes | purchase or renewal succeeded |
| `in_trial` | yes | free trial running |
| `cancelled_active` | yes, until `expires_at` | user turned off auto-renew |
| `in_grace` | yes | renewal failed, store grace period running |
| `billing_retry` / `on_hold` | **no** | grace over, store still retrying (Google "account hold") |
| `paused` | no | Google Play pause |
| `expired` | no | period ended without renewal |
| `refunded` / `revoked` | no | refund, chargeback, family-sharing revoke |

Columns or fields: `user_id`, `entitlement` (e.g. `pro`), `state`, `product_id`, `store` (app_store / play_store / stripe / promotional), `period_type` (trial / intro / normal), `will_renew`, `expires_at`, `grace_expires_at`, `original_transaction_id`, `environment` (sandbox / production), `updated_at`, `last_event_id`. Access is derived: `state in (active, in_trial, cancelled_active, in_grace) and (expires_at is null or expires_at > now())`.

### RevenueCat events → state
| Event | State change |
|---|---|
| `INITIAL_PURCHASE` | `active` or `in_trial` (period type) |
| `RENEWAL` | `active`, new `expires_at` |
| `CANCELLATION` (`cancel_reason` UNSUBSCRIBE) | `cancelled_active`, `will_renew = false`; **keep access** |
| `CANCELLATION` (refund / customer support) | `refunded` |
| `UNCANCELLATION` | back to `active`, `will_renew = true` |
| `BILLING_ISSUE` | `in_grace` while the grace period runs; it is **not** an expiration |
| `PRODUCT_CHANGE` | update `product_id` at the effective date (upgrade immediately, downgrade at renewal); check the docs for the store's behavior |
| `EXPIRATION` | `expired` (or `paused` for `SUBSCRIPTION_PAUSED`); **revoke access** |
| `SUBSCRIPTION_PAUSED` | record the scheduled pause; access ends at `EXPIRATION` |
| `TRANSFER` | move the entitlement between app user ids (account switch) |
| `TEST` | log only |

### Adapty events → state
| Event | State change |
|---|---|
| `subscription_started`, `trial_started` | `active` / `in_trial` |
| `subscription_renewed`, `trial_converted` | `active`, new `expires_at` |
| `subscription_renewal_cancelled`, `trial_renewal_cancelled` | `cancelled_active`; keep access |
| `subscription_renewal_reactivated` | `active` |
| `entered_grace_period` / `billing_issue_detected` | `in_grace` |
| `subscription_expired`, `trial_expired` | `expired`; revoke (fires when access fully ends, not at cancellation) |
| `subscription_refunded` | `refunded` |
| `access_level_updated` | re-read the profile and write the full state |

Event names change: confirm them against the vendor's "event types and fields" page when `/backend` builds the handler, and record the version in `architecture.md` F.

### What the stores do underneath (for testing and support)
- **Apple:** renewal failure → billing retry; with Billing Grace Period enabled in App Store Connect, access continues during grace (`DID_FAIL_TO_RENEW` / `GRACE_PERIOD`), then `GRACE_PERIOD_EXPIRED` / `EXPIRED`. Refunds arrive as `REFUND`. Turn on grace period for subscriptions; it recovers revenue.
- **Google:** grace period (configurable) → **account hold**; since December 2025 the hold lasts 60 days minus the grace period by default. During account hold **block access**. Revocation/refund → `SUBSCRIPTION_REVOKED`. Pause is a separate state.

## 4. Per backend
### Firebase
- **RevenueCat:** install the official **RevenueCat Firebase extension** (needs the Blaze plan, costs cents per month). It writes customer and entitlement data to Firestore and sets **Auth custom claims** with active entitlements. Use the Firebase UID as the RevenueCat app user id. Security rules: a user reads only their own customer document; nobody writes it except the extension. Cloud Functions and rules check the custom claim (`request.auth.token.revenueCatEntitlements` or the configured name: verify in the extension docs). After a purchase, force-refresh the ID token so the new claim is visible.
- **Adapty:** an HTTPS Cloud Function receives the webhook, verifies the `Authorization` secret, writes `subscription_events/{eventId}` (idempotent by id), then upserts `entitlements/{uid}` in the state model above. Optionally set custom claims from the function.
- Firestore rules: `entitlements/{uid}` readable by `request.auth.uid == uid`, writable by no client.

### Supabase / Postgres
- Tables `entitlements` (primary key `user_id, entitlement`) and `subscription_events` (`event_id` unique, raw `jsonb`, `received_at`).
- An **Edge Function** is the webhook endpoint: verify the secret (RevenueCat: the `Authorization` header value you set in the dashboard; Adapty: shared secret), insert the event with `on conflict (event_id) do nothing`, re-read the customer from the platform API, upsert `entitlements`.
- RLS: users `select` their own rows; `insert/update/delete` only with the service role (the Edge Function). A SQL function `has_entitlement(uid, 'pro')` is what other policies and functions call.
- With PowerSync (offline-first profile): sync `entitlements` read-only to the device; never let the client write it.

### Own API
Same two tables, same handler, same rule: the client never writes entitlements.

## 5. Account and lifecycle cases that must work
- Purchase before login, then login (alias/transfer) · login on a second device (restore) · sign-out and a different user on the same device · reinstall · **"Restore purchases" button** (store requirement).
- Upgrade, downgrade, crossgrade between plans; monthly ↔ yearly.
- Family Sharing (iOS) and its revocation.
- **Account deletion does not cancel the store subscription.** Tell the user before deletion and link to the store's subscription management; delete or anonymize the entitlement rows with the account.
- Promotional/granted entitlements from the dashboard.
- Sandbox vs production: store `environment`; never let sandbox events grant production access.

## 6. Analytics
- Revenue, MRR, churn, trial conversion, refunds: the platform's dashboard is the source; do not rebuild it.
- Product analytics (which screen led to the paywall, paywall views → purchase): send events to the analytics tool the PRD names (input 8) and use the platform's integration to forward purchase events, so both sides share the same user id.
- Attribution (ads): only if the PRD names it; on iOS it needs ATT.
- Every tool is in `docs/privacy.md`; no personal data beyond the user id in event properties.

## 7. Testing (what `/qa` runs)
| Case | iOS | Android |
|---|---|---|
| purchase, trial start | StoreKit configuration file in Xcode; sandbox account | license tester, test card |
| renewal | accelerated sandbox renewals | test-track accelerated renewals |
| cancel (auto-renew off) keeps access until expiry | sandbox manage subscriptions | Play subscriptions screen |
| billing issue → grace → recovery / expiry | StoreKit testing "fail transactions" | test card "declined" |
| refund / revoke | StoreKit transaction manager refund | Play Console refund |
| restore on second device / reinstall | ✓ | ✓ |
| upgrade, downgrade | ✓ | ✓ |
| webhook replay and duplicate | resend from the platform dashboard; state unchanged | same |
| out-of-order events | send `EXPIRATION` before `RENEWAL` in a backend test; re-read fixes state | same |

Backend tests (`/backend`): one test per state transition, duplicate event, wrong secret rejected, client cannot write `entitlements`, sandbox event does not grant production access.

## 8. Store rules (see `rules/store.md`)
Price, period, trial length and renewal terms shown before purchase; restore button; link to manage subscriptions; terms and privacy links on the paywall; no links to outside payment except where the store allows it in that region; subscription group set up so upgrades and downgrades work.
