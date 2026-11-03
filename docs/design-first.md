# Design first: screens are approved before code

> Why: a builder that invents layout while coding produces a different screen every time, costs tokens on redesign, and the client sees the result too late. The kit therefore puts a `/design` step between spec sign-off and `/architecture` whenever the project has a design source (PRD input 5). Status: Signed Off → **Designed** → Architected.

## Sources the kit supports
| Source | How Claude reads it | How the design system is kept |
|---|---|---|
| **Figma** (recommended for client work) | Official Figma MCP server: desktop (`127.0.0.1:3845/mcp`, needs Dev Mode in the file) or remote (`mcp.figma.com/mcp`). Tools used: `get_design_context` (layout + code representation of a selection; default React/Tailwind, `clientFrameworks` label e.g. `SwiftUI` steers Code Connect mappings), `get_variable_defs` (tokens used in a selection), `get_screenshot`, `get_metadata` (XML outline), `search_design_system`, `get_code_connect_map`. Write-back: `add_code_connect_map` / `send_code_connect_mappings` link a Figma component to the code component. | Figma variables = tokens; components library; Code Connect maps each component to the SwiftUI/Flutter/Compose implementation so `get_design_context` returns *our* component names instead of raw layout |
| **Claude Design** (artifacts, internal or fast client mock-ups) | The Design artifact type on claude.ai: artboards on a canvas, built from a Design System artifact. Read back with the Artifact tool (`read`); export frames as images into `docs/design/`. | The Design System artifact holds tokens and components; the same tokens are exported to `docs/design/design-system.md` |
| **Design system only** (no screens) | `docs/design/design-system.md` + the Foundation MCP (`foundation-mcp.md`) | tokens + component catalog |
| **None** | platform defaults (HIG / Material 3); `/design` is skipped | theme file generated in the app shell |

Flutter and Compose are not Code Connect labels today (only an example `SwiftUI` label is documented); for them `get_design_context` returns layout, and the Foundation MCP maps component names to our widgets.

## What `/design PROJ-X` produces
1. **Frames per screen of the spec**, named `PROJ-X / <screen> / <state>` with the states the spec requires: default, loading, empty, error, offline where applicable; the smallest device and XXXL font variant for at least the main screen; dark mode variant.
2. **Component inventory**: every component on the frames is either an existing design-system component (by name) or a new one, which goes into the design system *first* and is registered in the Foundation MCP before any screen uses it. No one-off components.
3. **Token check**: every color, type style and spacing on the frames resolves to a token; hard-coded values are a finding.
4. **Design notes** in `features/PROJ-X-name/design.md`: frame links or exported images in `docs/design/PROJ-X/`, component inventory, interactions (what tapping does), platform differences, accessibility notes (labels for icons, Dynamic Type behavior).
5. **Client approval** recorded in the spec section "Design reference" (`Designed by … approved by … on … via …`). Status → Designed.

## How later steps use it
- `/architecture` A: screens come from the frames, not invented; B: state per screen derived from the states on the frames.
- `/tasks` level 4: one task per frame; the coverage table references frames.
- `/ui`: builds exactly the frames; reads tokens and components from the Foundation MCP (or `design-system.md`); any deviation is noted with a reason; snapshot/golden tests are compared against the frames.
- `/qa`: visual check frame vs screen on the smallest device and XXXL.

## Rules
- A spec without approved frames is not built in projects with a design source; `/architecture` refuses.
- New components enter the design system, then the Foundation MCP, then code; never the other way round.
- Tokens are the only source of color, type and spacing in code (`rules/general.md`); the token file is generated from the design source, never edited by hand.
