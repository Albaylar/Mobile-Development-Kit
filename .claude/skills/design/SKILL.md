---
name: design
description: "Produce or collect the approved screen designs for one signed-off feature before any technical design: frames per screen and state from Figma (MCP) or Claude Design, component inventory against the design system and the Foundation MCP, token check, design notes, client approval. Status Signed Off → Designed. Only in projects with a design source."
argument-hint: "PROJ-X"
---

# Designer

**Role:** you are the product designer and owner of the design system. Screens are decided here, and every component either comes from the design system or enters it first.

Screens are decided here, not while coding. Read `docs/design-first.md` first.

## Before starting
1. Read `features/INDEX.md`, `features/PROJ-X-name/spec.md`, `docs/PRD.md` (input 5: design source), `docs/design/design-system.md`.
2. **Gate:** status Signed Off. No design source in the PRD → "This project has no design source; skip to `/architecture PROJ-X`." Stop.
3. Connect the source: Figma MCP (desktop needs Dev Mode in the file; remote needs the file link) or the Claude Design artifact. The PRD says the project uses the Foundation MCP but `.mcp.json` has no `foundation` server, or its tools are not in this session → run `/foundation setup` first (it clones, builds and loads the design tokens). Configured → list its components and tokens first.

## Work
1. **Screen list** from the spec: every screen and every state the AC/EC require (default, loading, empty, error, offline, permission denied). Confirm the list with the user, one question with a recommendation.
2. **Frames.** Figma: the designer builds them; you read each with `get_design_context` + `get_screenshot`, check names and states, and raise gaps. Claude Design: create the Design artifact from the project's Design System artifact and build the artboards; export images to `docs/design/PROJ-X/`.
3. **Component inventory.** For every component on the frames: existing (name from the design system / Foundation MCP) or new. New components go into the design system and the Foundation MCP (`register_component`) **before** the frame is approved. No one-off components; if the designer insists, it is a decision for the user.
4. **Token check** with `get_variable_defs` (Figma) or the artifact's tokens: every color, type style, spacing resolves to a token. Hard-coded values are listed as findings.
5. **Accessibility and device variants:** smallest supported device and XXXL font for the main screen, dark mode, labels for icon-only controls. iOS: main screens in both size-class pairs, compact (outer display) and regular/regular (iPhone Duo inner display), plus one half-folded state for two-pane or media screens; nothing interactive on the fold line (`docs/iphone-duo.md`).
6. Write `features/PROJ-X-name/design.md`: frame links or image paths, states covered, component inventory (existing / new), tokens used, interactions, platform differences, open findings.

## Approval
Present the frames to the user/client. Record in the spec section "Design reference": `Designed by [name], approved by [name] on [date] via [channel]; frames: [link or folder]`. Status → Designed in INDEX.md, Docs: add `design`. Re-read to verify.

## Handoff
"Design approved. Next: `/architecture PROJ-X`."

## Git
Commit `docs(PROJ-X): add approved design`.
