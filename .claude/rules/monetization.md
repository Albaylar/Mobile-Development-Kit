# Monetization Rules (in-app purchases and subscriptions)

Applies whenever the PRD (input 10) says the app sells something. Background and event tables: `docs/monetization.md`.

- **Use a subscription platform** (RevenueCat by default, Adapty when paywall experiments drive the business). No hand-written receipt validation, no direct StoreKit / Play Billing purchase flow next to the platform's SDK.
- **App user id = backend user id.** `logIn` after sign-in, `logOut` on sign-out. Never use a device id or e-mail as the app user id.
- **Client gates UI, server gates data.** Premium server features check the backend entitlement (`has_entitlement`, custom claim, or the entitlement document), never a flag the client sends.
- **Entitlements are written only by the webhook handler** (or the RevenueCat Firebase extension). No client, no admin screen writes them directly; promotional grants go through the platform.
- **Webhook handler:** verify the signature or shared secret, store the raw event idempotently by event id, answer 200 quickly, then re-read the customer from the platform API (or apply by timestamp) and upsert the full state. Duplicates and out-of-order events are normal.
- **Revoke only when access ends:** expiration, refund/revocation, grace period over (Google account hold). A cancellation that only turns off auto-renew keeps access until `expires_at`.
- **One state model** (`active, in_trial, cancelled_active, in_grace, billing_retry/on_hold, paused, expired, refunded`) in every backend; access is derived from it.
- **Sandbox never grants production access**; store the environment with every event.
- **Restore purchases** button and **manage subscription** link exist; price, period, trial and renewal terms are visible before purchase.
- **Account deletion** warns that the store subscription continues and links to its management; entitlement rows are deleted or anonymized with the account.
- **Tests:** every state transition, duplicate event, wrong secret, client write refused, sandbox vs production, restore, upgrade/downgrade (`docs/monetization.md` §7). A subscription feature without these tests is not Approved.
- The platform is a data processor: entry in `docs/privacy.md`; analytics and attribution only as the PRD names them.
