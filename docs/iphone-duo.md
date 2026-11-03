# iPhone Duo: building and shipping for Apple's foldable

> Apple's foldable iPhone (announced 2026-09-09, on sale 2026-10-23, iOS 27). Facts below come from Apple's "Prepare your app for iPhone Duo" page, the newsroom announcement and the Tech Talks "Prepare your app for iPhone Duo" and "Strike a pose with adaptive layouts on iPhone Duo"; items marked *(verify)* come from secondary sources only. Research 2026-11-03. Binding rules are in `.claude/rules/ios.md` (section "iPhone Duo"); this file is the reasoning and the detail.

## What changes
- Two displays with the same aspect ratio. The **outer display** behaves like other iPhones (compact width). The **inner display** is about 50 % larger than an iPhone 18 Pro Max and has **regular horizontal and vertical size classes**: the first iPhone where `horizontalSizeClass == .regular` is not an iPad.
- The app's window **resizes while running**: when the device opens, closes, folds "like a book", is set down "like a tent", rotates, or enters **Split View** (two apps side by side on an iPhone for the first time).
- Apps built with the **iOS 26 SDK or earlier** run but do not adapt: open, they sit centered with empty space around the window; closed, they sit left of the status bar and camera. Apps built with the **iOS 27.1 SDK** extend to the edges and must handle toolbars and tab bars that can appear **vertically below the status bar**.
- The device reports **reserved regions**: the fold is a *division* region (active only while the device is folded), the camera an *occlusion* region. Standard bars, sheets, alerts and context menus avoid them automatically; custom chrome must ask.

## Rules (what the builders follow)
1. **Build with the iOS 27.1 SDK or later** (Xcode 27.1). This alone fixes the empty-space problem.
2. **Freely resizable layout.** No fixed widths, no layouts chosen per device or orientation. Size from the view or the window, never from the screen: `GeometryReader`, `onGeometryChange`, `view.bounds`, `window.bounds`. Remove every `UIScreen.main`; `UIWindow(frame: UIScreen.main.bounds)` becomes `UIWindow(windowScene:)`. Never store a `UIScreen`.
3. **Size classes decide, not idiom or orientation.** `@Environment(\.horizontalSizeClass)` / `verticalSizeClass` (UIKit: `traitCollection`). Remove `userInterfaceIdiom == .phone/.pad`, `UIDevice.current.orientation`, `statusBarOrientation`, and checks like `bounds.height == 844`. Compare width and height of the bounds when you need "landscape".
4. **React to every size change**, not once at launch: SwiftUI handles it; UIKit uses `layoutSubviews` / `viewDidLayoutSubviews` and `viewWillTransition(to:with:)`. Safe-area insets can differ on opposite sides; never assume symmetry.
5. **Standard containers first:** `NavigationStack`, `NavigationSplitView`, `TabView` (`.defaultTabBarPlacement(.sidebar)` on the inner display), `ArrangementView` (iOS 27.1, `.split` / `.overlay` styles) for two-pane layouts that must respect the fold. Do not nest `NavigationSplitView` inside an `ArrangementView`, and keep `ArrangementView` out of scrollable containers.
6. **Custom chrome asks for reserved regions:** SwiftUI `proxy.reservedRegions(kind: .division / .occlusion)` (iOS 27.1, `options: .includeInactive` to plan for the fold while it is flat); UIKit `view.reservedRegions(kind:)`. Nothing interactive sits on the fold or under the camera.
7. **Images:** `.fill` / `.scaleAspectFill` can crop the subject when the window changes shape; choose fill or fit per size class, or set a focal point.
8. **`UIRequiresFullScreen`** is still honored but opts the app out of resizing; do not add it.
9. **Landscape and tent pose are opportunities** (video, reading, calls); support them unless the spec says otherwise. The inner display may not honor `supportedInterfaceOrientations`; test instead of assuming.

## Design (what `/design` produces)
Frames for the main screens in **both size-class pairs**: compact/regular (outer display) and regular/regular (inner display, iPad-like layout), plus one half-folded state for any screen with two panes or media. Controls stay clear of the fold line; the inner-display layout extends the outer one, it is not a different app.

## Testing (what `/qa` runs)
Xcode 27.1 **Device Hub**: the iPhone Duo simulator can open, close, fold and rotate; the resizable simulator and iPhone Mirroring on macOS 27 cover extreme window sizes. Matrix per feature: closed · open · fold and unfold **mid-task** (text entry, scroll position, modal sheet, playing video) · half-folded "book" and "tent" · rotation in each state · Split View next to another app · Dynamic Type XXXL on the inner display · `UIScreen.main` grep returns nothing.

## Store
- Submitting **iPhone Duo screenshots** in App Store Connect earns the **"Made for iPhone Duo" badge** on the product page; featuring nominations can state "optimized for iPhone Duo, including support for all device poses".
- *(verify)* Secondary sources report that from **April 2027** new submissions and updates must include iPhone Duo screenshots and be built with the iOS 27 SDK or later; check App Store Connect's current notice before the first release.
- Marketing text must not claim Duo optimization unless the matrix above passed.

## Flutter and Android
- Flutter's `MediaQuery.displayFeatures` is **populated only on Android**; on the iPhone Duo Flutter apps resize like any window but do not see the fold. Treat the Duo as a resizable window (`LayoutBuilder`, breakpoints by width, no device checks). Fold-aware layouts on iOS need a plugin (`foldable`, `duo_flex`, `fold_kit`; none verified on hardware as of this research) and an ADR naming it.
- Android foldables: same resizable-window rule; `WindowInfoTracker` / Jetpack WindowManager for the hinge, `DisplayFeature` in Flutter.

## Sources
- [Prepare your app for iPhone Duo (Apple Developer)](https://developer.apple.com/iphone-duo/prepare/)
- [Developers bring new app experiences to iPhone Duo (Apple Newsroom)](https://www.apple.com/newsroom/2026/10/developers-bring-incredible-new-app-experiences-to-iphone-duo/)
- [Tech Talk: Prepare your app for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111461/) · [Tech Talk: Strike a pose with adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/) · [Tech Talk: Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466/)
- [HIG: Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)
- Secondary (deadline, verify): [MacObserver](https://www.macobserver.com/news/iphone-duo-app-store-sdk-rule-april-2027/), [ASO World](https://marketingtrending.asoworld.com/en/discover/apple-opens-app-store-submissions-for-iphone-duo-badge-screenshot-specs-and-the-april-2027-deadline/)
- Flutter: [`foldable` on pub.dev](https://pub.dev/packages/foldable), [`duo_flex`](https://pub.dev/packages/duo_flex/license)
