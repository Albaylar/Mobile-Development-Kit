---
name: ui
description: "Work through the [UI] tasks of a feature: screens, navigation, components, loading/error/empty/offline states, accessibility and localization, with screen and snapshot/golden tests, inside the project's architecture profile, in an isolated sub-agent. After /core, before /platform."
argument-hint: "PROJ-X"
context: fork
agent: ui-dev
background: false
---

# UI Developer

Build the screens for feature $ARGUMENTS. Follow `.claude/skills/BUILDER.md`; this file adds what is specific to [UI].

## Specific rules
- Views render state from the state holder `/core` built and send events back. No network, storage or business logic in a view. No new state holder without a task.
- Navigation as the profile names it (value-driven `NavigationStack` via coordinator, Navigation 3, go_router). Deep-link entry points from `architecture.md` A.
- Resizable by construction: size classes and `GeometryReader`/`onGeometryChange`, never `UIScreen.main`, idiom or orientation checks; standard containers before custom chrome; custom chrome respects reserved regions (iPhone Duo fold and camera). Rules in `ios.md` "iPhone Duo".
- Design: the approved frames in `features/PROJ-X-name/design.md` when `/design` ran; tokens and components from the Foundation MCP (`search`, `get_component`, `get_tokens`; `docs/foundation-mcp.md`) or `docs/design/design-system.md`, else platform defaults (HIG via `swiftui-pro`, Material 3). Before writing any control call `search`; a component not in the catalog is not written, it is reported (it must go through `/design`). Run `check_usage` on every new screen before reporting. The PRD says Foundation but its tools are missing → stop and report "run `/foundation status`"; do not fall back to inventing components.
- Every screen has loading, error (with retry), empty and, where the profile is cached/offline, offline state. Error text comes from the failure type, never from an exception.
- Accessibility is part of the task: labels, Dynamic Type / font scale to XXXL without clipping, contrast 4.5:1, reduce motion, 44 pt / 48 dp targets (`ios-accessibility`).
- Localization: every string through the project's system, all languages; dates, numbers and plurals through the platform formatters.
- Performance habits: stable identity in lists, no work in `body`/`build`/composition, lazy lists, images sized to the slot (`swiftui-performance-audit`, `flutter-performance`, `compose-performance`).

## Tests
Per screen: a screen/widget/Compose test for each AC the screen fulfils, asserting the visible result; snapshot/golden tests from profile B: one light, one dark, one smallest-device-at-XXXL image per screen, nothing that renders differently between runs. L1 runs the screen's suite only (`verify.sh only <Target>/<ScreenTests>`); XCUITest / integration tests are written here when a task asks for them but run once in L4 by `/qa`, never per step. `swiftui-pro` review checklist before reporting.

## Report
List for the main conversation what to check on simulator/emulator: smallest device, XXXL font, dark mode, rotation, VoiceOver/TalkBack pass. Next: "`/platform PROJ-X`" if [PLAT] tasks exist, else "`/qa PROJ-X`".
