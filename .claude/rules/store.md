# Store Rules (App Store, Google Play)

Store review is a gate we do not control; these rules keep a submission from being rejected for known reasons. Verified by `/platform` while building and by `/release` before submission (`appstore-review` skill for iOS).

## Both stores
- Account deletion inside the app whenever the app has accounts (Apple 5.1.1(v), Play user-data policy); the backend has the deletion path.
- Every permission has a usage string that says what the data is for, in every store language; the app works when denied.
- Login with a third-party identity provider → also offer Sign in with Apple (Apple 4.8) or an equivalent privacy-preserving option.
- Privacy policy URL in the listing and reachable in the app; it matches what the app actually collects (`docs/privacy.md` is the source).
- No hidden or debug features, no test credentials, no "coming soon" screens in a submitted build. Demo account for review if login is required.
- Subscriptions and purchases only through the store's billing via the subscription platform (`rules/monetization.md`); prices, period, trial and cancellation shown before purchase; restore button; manage-subscription link; account deletion warns that the store subscription continues.
- Minimum supported OS and target SDK as the profile says; Play raises the required target SDK yearly, check before every release.

## iOS
- `PrivacyInfo.xcprivacy`: required-reason APIs declared, tracking domains listed, collected data types match the App Privacy answers in App Store Connect.
- App Tracking Transparency prompt before any tracking or IDFA use; none → do not add the ATT framework.
- Export compliance answered (standard encryption only → `ITSAppUsesNonExemptEncryption = NO`).
- Background modes, push, HealthKit, location "always" only with a matching feature and explanation in the review notes.
- Build number (`CFBundleVersion`) increases with every upload; marketing version (`CFBundleShortVersionString`) per release.
- iPhone Duo: built with the iOS 27.1 SDK, pose matrix passed (`docs/iphone-duo.md`), Duo screenshots uploaded for the "Made for iPhone Duo" badge; the reported April 2027 screenshot and SDK requirement is checked in App Store Connect before each release.

## Android
- Data Safety form answers derived from the code and third-party SDKs; updated whenever `/platform` adds a data flow.
- `versionCode` increases with every upload; upload key held by a human, app signing by Play.
- Permissions declared in the manifest match what the app uses; `QUERY_ALL_PACKAGES`, SMS, call-log and accessibility-service permissions need a declaration form and are avoided unless the product is about them.
- Foreground services declare a type and the matching permission.
- Release build: R8 on, debuggable off, Baseline Profile included.

## Files `/release` reads
`Info.plist`, `*.entitlements`, `PrivacyInfo.xcprivacy`, `AndroidManifest.xml`, `build.gradle(.kts)`, `pubspec.yaml`, `docs/privacy.md`, the store listing text in `docs/store/`.
