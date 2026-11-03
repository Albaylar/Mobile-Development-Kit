---
name: monetization
description: "Set up in-app purchases and subscriptions for the project: choose RevenueCat or Adapty, record the decision in an ADR, plan products, entitlements and offerings, define the backend entitlement sync for the chosen backend (Firebase, Supabase/Postgres or own API) including cancellations, grace periods and refunds, and add the paywall and entitlement-sync features to the roadmap. Use when the PRD says the app sells something, or when a subscription feature is about to be specified."
argument-hint: "optional: revenuecat | adapty"
---

# Monetization setup

**Role:** you are the monetization architect. You design how purchases flow from the stores through the subscription platform to the backend so that access is right in every state; you write no code here.

Read `docs/monetization.md` first; `.claude/rules/monetization.md` is binding.

## Before starting
1. Read `docs/PRD.md` (inputs 3 backend, 8 analytics, 10 monetization), `features/INDEX.md`, `docs/architecture-profile.md` if it exists.
2. PRD input 10 is "none" → "The PRD says the app sells nothing. Change it with `/refine` or the PRD first." Stop.

## Interview (one question at a time, with a recommendation)
1. **What is sold:** subscriptions (which tiers, monthly/yearly, trial length), one-time unlocks, consumables. Recommendation: one entitlement (`pro`) with monthly and yearly products and a 7-day trial, unless the business needs tiers.
2. **Platform:** RevenueCat (default) or Adapty (`docs/monetization.md` §1). Ask whether paywall/onboarding A/B testing is central; yes → recommend Adapty.
3. **Who sets up the dashboards:** App Store Connect subscription group and products, Play Console subscriptions and base plans, platform project, API keys, webhook secret. These are [HUMAN] tasks.
4. **Grace period:** enable on both stores (recommendation: yes, 7 days on Google, Apple Billing Grace Period on).
5. **Server-gated features:** which features does the backend deliver only to subscribers? (Decides whether the entitlement sync is required in v1; recommendation: yes as soon as any server data is premium.)
6. **Analytics forwarding** to the tool in PRD input 8; attribution only if named.

## Outputs
1. `docs/adr/ADR-00n-monetization.md` (from `.claude/skills/architecture/adr-template.md`): platform, products and entitlements, backend sync design (Firebase extension / Cloud Function / Supabase Edge Function / own API), state model, revisit triggers (e.g. "pricing changes", "experiments needed").
2. `docs/monetization-setup.md` for this project:
   - product table: store product id per store, entitlement, period, trial, price tier, subscription group / base plan
   - entitlement table and offerings / paywalls
   - webhook: URL of the handler, secret storage (never in the repo), events enabled
   - backend schema for the chosen backend exactly as `docs/monetization.md` §4 describes
   - test accounts (sandbox, license testers) and who owns them
3. `docs/architecture-profile.md` section "Monetization" filled (if the profile exists; otherwise `/architecture` copies it from the ADR).
4. `features/INDEX.md`: add, if missing, with dependencies:
   - "Paywall and purchase" (UI, restore, manage subscription link, store-required texts)
   - "Entitlement sync" (type Infrastructure: webhook handler, entitlements and events tables, access rules, backend tests) when any server feature is premium
   - "Account deletion" must mention the subscription warning (update its spec through `/refine` if it exists)
5. `docs/privacy.md`: the platform (and analytics forwarding) with purpose, data (user id, purchase history), region, DPA.
6. `.mcp.json` / per-machine note: RevenueCat AI Toolkit plugin (optional) as in `docs/monetization.md` §1.

## Handoff
"Monetization is planned. Do the [HUMAN] dashboard tasks in `docs/monetization-setup.md`, then `/write-spec` for **Entitlement sync** and **Paywall and purchase**."

## Git
Commit `docs: plan monetization (<platform>)`.
