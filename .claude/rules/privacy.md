# Privacy Rules (GDPR and store privacy requirements)

Mobile apps collect more by default than web apps: device identifiers, location, contacts, photos, sensors. Every one of them needs a reason in a spec.

## Data location and services
- Personal data stays in the region the profile names (EU for European clients). Every service that receives personal data or the device identifier is listed in `docs/privacy.md`: purpose, data, region, data-processing agreement, SDK version.
- A new service or SDK is added only with the user's approval, and `/platform` updates the privacy manifest / Data Safety inputs in the same task.

## On the device
- Collect only what the feature needs; every personal field in a spec has a reason and a retention.
- Secrets and tokens in Keychain / Keystore / `flutter_secure_storage`, never in UserDefaults, SharedPreferences, files or logs.
- Local databases with personal data use the platform's file protection (iOS Data Protection class, Android encrypted storage where the profile requires it); no personal data in app-group containers or backups unless the spec says so.
- Photos and documents: picked through the system picker with limited access where available; no full library access by default.

## Location, sensors, identifiers
- Location only when the feature runs, "always" only with a spec, a privacy entry and a visible indicator. No continuous tracking of employees without a legal basis the client supplies (many jurisdictions forbid it outright).
- No IDFA / advertising ID unless the product is about ads; then ATT (iOS) and the Play ads declaration.
- Analytics and crash reporting: no personal data in event properties or breadcrumbs; user id only as an opaque hash.

## Logs and test data
- Never log personal data or tokens (`print`, `os_log`, `Logger`, `debugPrint`, `Log.d` included). Release builds strip verbose logging.
- Synthetic test data only. Never copy real customer data into tests, screenshots, store listings, prompts or this repository.

## User rights
- Account and data deletion reachable in the app (store requirement) and executed on the server.
- The privacy notice (Art. 13) comes from the client; the app shows it before the first data collection and links it in settings.
