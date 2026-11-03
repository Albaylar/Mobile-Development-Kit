---
name: foundation
description: "Connect this project to the Foundation MCP (the shared design-system server in Go): clone or update github.com/Albaylar/foundation-mcp, build it, load the project's design (Figma variables, Claude Design system, or design-system.md) into a project tokens file, validate it, write .mcp.json, and export the token source for the app. Also 'sync' (update server and re-export) and 'status'. Use when the PRD says the project uses the Foundation MCP, or before /design and /ui need it."
argument-hint: "setup | sync | status"
---

# Foundation MCP connector

**Role:** you are the design-system engineer. You connect this project to the shared component catalog and load the project's brand into it; you never edit shared components here.

The Foundation MCP holds the shared components (Button, TextField, Card, …) and their SwiftUI / Flutter / Compose sources. **The components are shared, the values are the project's**: every app keeps its own `docs/design/tokens.json` (brand colors, type, spacing) that the server merges over the base tokens. Background: `docs/foundation-mcp.md`. Server documentation: the README of the server repository.

Defaults (override only if the user names others):
- Server repository: `https://github.com/Albaylar/foundation-mcp.git` (public)
- Local path: `$FOUNDATION_HOME`, else `~/Developer/foundation-mcp`
- Project tokens: `docs/design/tokens.json`; mapping notes: `docs/design/tokens-mapping.md`

Argument missing → `status`, then suggest `setup` if anything is missing.

## `setup`

### 1. Toolchain
`go version` must print 1.25 or newer. Missing → [HUMAN]: "Install Go (`brew install go`), then run `/foundation setup` again." Stop.

### 2. Get the server
- Local path missing → `git clone https://github.com/Albaylar/foundation-mcp.git <path>`. Clone fails → report the error (network, proxy, or a changed repository URL); never guess credentials.
- Local path exists → `git -C <path> status --porcelain` must be empty (someone may be working on a component there); clean → `git -C <path> pull --ff-only`. Not clean → do not pull; say so and continue with the local state.

### 3. Build and self-test
In `<path>`: `go build -o foundation ./cmd/foundation`, `go test ./...` (must report `ok` with tests run), `./foundation --version`, `./foundation --catalog ./catalog --check`. Any failure → stop and report the output; do not connect a broken server.

### 4. Load the project's design into `docs/design/tokens.json`
Read the base names first: `<path>/catalog/tokens.json`. **Keep the base token paths** (`color.brand`, `color.surface`, `type.body`, `space.4`, `radius.field`, …): components reference them. The project changes values; it adds a path only when its design has something the base lacks.
Pick the source from PRD input 5:
- **Figma:** with the Figma MCP connected, call `get_variable_defs` on the library page or a frame that uses all styles (desktop server needs Dev Mode in the file). Map each Figma variable to a base path (e.g. `Brand/Primary` → `color.brand`). Unclear mappings: one question at a time with a recommendation.
- **Claude Design:** read the project's Design System artifact (Artifact `read`) and take its color, type, spacing and radius values.
- **`docs/design/design-system.md`:** take hex colors, type scale, spacing and radii from it.
- **None:** copy the base file unchanged and ask only for the brand color (recommendation: keep the base until a design exists).
Write `docs/design/tokens.json` in W3C Design Tokens format (`{"color":{"brand":{"$type":"color","$value":"#…"}}}`), containing only the tokens that differ from the base or are new. Write `docs/design/tokens-mapping.md`: source name → token path → value, plus open questions.
Validate: `<path>/foundation --catalog <path>/catalog --tokens docs/design/tokens.json --check` must print `ok`. A component that references a token the merge lost is a stop.

### 5. Connect Claude Code
Create or update `.mcp.json` in the project root from `.mcp.json.example`, with absolute paths (expand `~`):
```json
{ "mcpServers": { "foundation": { "command": "<abs path>/foundation", "args": ["--catalog", "<abs path>/catalog", "--tokens", "<abs project path>/docs/design/tokens.json"] } } }
```
Keep any other servers already in `.mcp.json` (e.g. `figma`). Tell the user: "MCP servers load when a session starts: restart Claude Code in this folder (or reconnect in /mcp) and approve the `foundation` server once."

### 6. Token source for the app
If the app project exists (the app shell feature is In Progress or later): generate the token file per platform from the merged tokens and write it where the profile's module layout says (default iOS `Core/Design/FoundationTokens.swift`, Flutter `lib/core/design/foundation_tokens.dart`). Before the restart the `get_tokens` tool is not available yet: build the file with `<path>/foundation` after the restart, or note it as the first [UI] task of the app shell. Never hand-edit a generated token file.

### 7. Record
- `docs/system.md` section "Design system": server version (`--version`), catalog commit (`git -C <path> log -1 --format=%h`), tokens file, date.
- `docs/privacy.md`: nothing (the server is local and sends nothing).
- Commit in the app project: `chore: connect Foundation MCP (v<version>, catalog <hash>)`.

## `sync`
Clean working tree in `<path>` → `pull --ff-only`, rebuild, `go test ./...`, `--check` with the project tokens. Compare the catalog commit with the one in `docs/system.md`: list new or changed components (`git -C <path> log --oneline <old>..HEAD -- catalog/components`). Re-export the token files if `tokens.json` or the base changed. Update `docs/system.md`. Commit `chore: sync Foundation MCP to catalog <hash>`.

## `status`
Report, one line each: Go present · server path and version · catalog commit vs `docs/system.md` · behind `origin/main`? (`git -C <path> fetch -q && git -C <path> rev-list --count HEAD..origin/main`) · `docs/design/tokens.json` present and `--check` result · `.mcp.json` has `foundation` · the `foundation` tools visible in this session (if not: restart needed).

## New components (not done here)
A component the design needs and the catalog lacks is added by `/design` with `register_component`. That writes into the **server repository** working tree: commit it there on a branch `feat/component-<name>`, open a pull request in `Albaylar/foundation-mcp`. It becomes available to every app after the merge and a `/foundation sync`.

## Handoff
setup → "Foundation is connected. Restart Claude Code here, then `/design PROJ-X` (or `/ui` if designs are approved)." · sync → list of changed components · status → the one missing step.
