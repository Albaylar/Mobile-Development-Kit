# Foundation MCP: the design system as a tool, in Go

> Goal: a button is designed once. Its tokens, variants and the SwiftUI / Flutter / Compose implementation are stored, and every later screen reuses them through an MCP server instead of Claude re-deriving them from a Figma dump. Fewer tokens per screen, identical components across apps, and `/ui` cannot invent a second button.

## Is it feasible here? Yes, and it should be a **separate repository** used by every project
- The MCP server is a Go program (`github.com/modelcontextprotocol/go-sdk/mcp`, v1.7.0, protocol 2026-07-28, stdio and streamable-HTTP transports). One binary, no runtime.
- The kit does not contain the server; it contains the **contract** (tool names, the component manifest format) and a `.mcp.json` entry that every project copies. The server lives in its own repo (`foundation-mcp`) with the design-system data, versioned and released like a library. Reason: the design system outlives any single app, and two apps must not carry two diverging copies.
- Integration with the design source: the server ingests tokens and component metadata from Figma (variables via the Figma REST API or a one-time `get_variable_defs` export) or from the Claude Design System artifact export, and stores the code implementations next to them. Figma Code Connect can point back at the same implementations, so `get_design_context` in Figma returns our component names.

## What the server exposes (contract, v1)
Tools (typed input structs; the names are what the kit's skills call):
| Tool | Input | Returns |
|---|---|---|
| `list_components` | `platform?` (swiftui / flutter / compose), `tag?` | names, one-line purpose, variants, status (stable / draft) |
| `get_component` | `name`, `platform` | tokens used, variants and their props, the implementation source (file content), usage example, accessibility notes, Figma node id, version |
| `get_tokens` | `set?` (color / type / spacing / radius / motion), `platform?` | token values, and the platform export (`Color` extension, `ThemeData` fragment, `MaterialTheme` fragment) |
| `search` | `query` | components and tokens matching by name, tag or purpose (so a request "a destructive confirmation" finds `Button.destructive` + `ConfirmSheet`) |
| `register_component` | `name`, `platform`, `source`, `tokens`, `variants`, `figma_node?` | validates (tokens exist, name unique, source compiles in CI later), writes the manifest entry; only `/design` calls it |
| `check_usage` | `source` (a screen's code) | reports hard-coded colors/spacing and components not in the catalog: `/ui` and `/qa` run it on every new screen |

Resources: `foundation://tokens.json` (W3C Design Tokens format), `foundation://components/<platform>/<name>` (source), `foundation://changelog`.

Prompt: `use_foundation` (loaded by `/ui`: "before designing any control, call `search`; use `get_component`; never write a new component without `register_component` through `/design`").

## Data layout in the server repo
```
foundation-mcp/
  cmd/foundation/main.go          stdio by default; --http :8765 for a shared server
  internal/catalog/               manifest loading, validation, search index
  internal/tools/                 one file per tool
  catalog/
    tokens.json                   W3C Design Tokens (exported from Figma variables or the Claude Design System artifact)
    components/
      button/
        manifest.yaml             name, purpose, tags, variants, tokens, figma_node, version, status
        swiftui/Button.swift      implementation + preview
        flutter/button.dart
        compose/Button.kt
        README.md                 usage, do/don't, accessibility
  .github/workflows/ci.yml        compile checks per platform (swift build, flutter analyze, gradle compile), token references validated
```

## Token economics (why it saves)
Without the server, `/ui` reads the design system file (hundreds of lines) and the Figma context for every screen and re-derives components. With it, a screen costs: `list_components` (one short table) + `get_component` for the 3–6 components used + `get_tokens` for the set needed. The implementations arrive as source to paste, not to invent. Claude Code loads tool schemas lazily, so the six tools cost almost nothing until called.

## How the kit uses it
- **`/foundation setup`** does the connection: clones or updates `github.com/Albaylar/foundation-mcp` into `~/Developer/foundation-mcp`, builds and tests it, loads the project design into `docs/design/tokens.json` (merged over the base tokens with `--tokens`), validates with `--check`, writes `.mcp.json`. `/foundation sync` updates, `/foundation status` reports. **Status 2026-11-03: server v0.2.1, tested, and its catalog is really compiled in CI (SwiftUI against the iOS SDK, Flutter with `flutter analyze`)** in `~/Developer/foundation-mcp`: 24 tokens, Button/TextField/Card for SwiftUI and Flutter, all six tools, the tokens resource, the `use_foundation` prompt, in-memory MCP tests. Next: Compose sources, Figma import, platform compile checks in CI.
- `/design`: `list_components` + `search` before new components; `register_component` for approved new ones.
- `/ui` (ui-dev agent): must call `search`/`get_component` before writing any control; `check_usage` on every new screen before reporting. `rules/general.md` "tokens are the only source of color" is enforced by `check_usage`.
- `/qa`: `check_usage` on the diff; a hard-coded value or a catalog-less component is a Medium bug ("not from the design system").
- `/audit`: catalog version in `docs/system.md` vs server version.

## Build order
1. Repo + `catalog/tokens.json` from the current design source; `get_tokens` and `list_components` with 3 components (Button, TextField, Card) for one platform. Stdio transport, CI compile check.
2. `register_component`, `check_usage`, `search`.
3. Figma import (REST API: variables and component metadata) and Code Connect export.
4. HTTP transport for a shared team instance; access token; changelog resource.

## Open decisions
- Where the catalog lives: inside the server repo (simple) or a separate `design-system` repo the server reads (cleaner when designers commit). Recommendation: inside, until a designer commits regularly.
- Whether Compose is in v1 (only if an Android-native project exists).
- Whether `check_usage` parses code (per-platform parsers) or pattern-matches (regex on hex colors, literal paddings, unknown component names). Recommendation: regex in v1.
