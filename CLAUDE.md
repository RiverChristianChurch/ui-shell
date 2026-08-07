# CLAUDE.md — RCC UI Shell

Design system for RCC web properties: tokens + component CSS + live HTML mockups. Beta, consumed by `RiverChristianChurch/web` via git-tag install.

## Context

- **Direction:** Option 1 "Dark Cinematic" + teal revision (office feedback 2026-04-10: more teal lower in the page). The five `options/` files are an archive — never edit them.
- **Source of truth:** `src/css/rcc-tokens.css` (tokens) and `src/css/rcc-components.css` (components). The `beta/` mockups must stay in sync with these — they link the CSS directly.
- **Published:** GitHub Pages serves the repo root (mockups); consuming apps install via `npm install github:RiverChristianChurch/ui-shell#v<tag>`.
- **Planning docs:** BRAIN vault `50-RCC/5010-Projects/Website-Rebuild-UI-Shell.md`.

## Rules

- All component classes are prefixed `rcc-`. Tokens are `--rcc-*`.
- No new colors/fonts/radii outside tokens. Inter is the only font family.
- Vue components do NOT live here yet — they live in `web` until a second consumer needs them (promotion policy in README).
- Version bumps: package.json + git tag `v<version>` + GitHub release. Consuming apps pin the tag.
- Task tracking: **GitHub Issues on this repo** (RCC convention — no Linear).
- Mockup-only styling (like the beta switcher) goes in `beta/beta-nav.css`, never in `src/css/`.
- `brand/index.html` is the **living brand guide** (supersedes the 2020 v1.1 PDF in Dropbox/graphics/_BRAND). Two open decisions live there: accent color (`--rcc-accent` is PROPOSED-Ember, candidates in tokens comment) and typography (Montserrat display + Inter body proposed). When either locks: update tokens, the guide page, and cut a new tag.
