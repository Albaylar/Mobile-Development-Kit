---
paths:
  - "**/*.swift"
  - "**/*.kt"
  - "**/*.dart"
  - "**/*.plist"
  - "**/AndroidManifest.xml"
  - "**/*.entitlements"
  - "supabase/**"
  - "server/**"
---

# Security Rules (mobile)

## The bundle is public
- Anything in the app can be read: no API keys, secrets, signing material or third-party credentials in source, plist, `strings.xml`, Dart constants, assets or `.env` copied into the build. The app holds publishable keys only; the server holds the rest.
- Server-side access rules (RLS, security rules, API auth) are the only real protection. Every table or endpoint has them for read, create, update, delete, tested with a second user.

## Transport and storage
- TLS only: ATS on, Android cleartext off. Certificate pinning when the profile requires it (financial, health).
- Tokens in Keychain / Keystore; refresh tokens never logged; sessions expire server-side.
- Input validated on the server; the client validates for UX only.

## Platform
- Deep links and intents validated (scheme, host, parameters) before they route; no arbitrary URL opening from untrusted content.
- WebViews: JavaScript off unless needed, no file access, no bridging of native APIs to untrusted pages.
- Jailbreak/root detection only if the profile and the client ask for it.

## Review triggers (explicit user approval)
- Any change to server access rules or auth flow.
- Any new third-party SDK.
- Any new entitlement, capability or permission.
