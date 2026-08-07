# RCC UI Shell

> **Status: BETA** — `@riverchristianchurch/ui-shell@0.1.0-beta.1`, installed from git tag. Design tokens + component CSS + live mockups for the riverchristian.church rebuild.

Design system for all RCC web properties. Single source of truth for visual direction, design tokens, and shell layout. Modeled on `NATCA-ITC/natca-ui-shell`, but deliberately simpler: **one theme, one shell, shared by the public site and the signed-in member portal.** No Vuetify wrapping, no WordPress build — the new site is fully custom.

**Live mockups:** https://riverchristianchurch.github.io/ui-shell/

## The direction

**Option 1 — Dark Cinematic** (CCV-inspired: full-screen worship hero, dark base, `#095879` teal accent, wave dividers), selected by office consensus 2026-04-10, **plus the requested teal revision**: teal carried into the lower page via teal wave fills (`.rcc-wave-fill-teal`), a deep-teal events band (`.rcc-s-teal`), and a teal-glow portal section (`.rcc-s-card--glow`).

| Preview | What it shows |
|---|---|
| [`brand/index.html`](brand/index.html) | **Brand Guide v2.0 draft** — logo, voice, unified palette (digital + print CMYK + SW paint), typography, graphics rules, live accent-color picker |
| [`beta/index.html`](beta/index.html) | Public homepage with the teal revision |
| [`beta/portal.html`](beta/portal.html) | Signed-in member dashboard — same shell, auth'd components |
| [`beta/components.html`](beta/components.html) | Token + component reference sheet |
| `options/` | Archive: the original five concepts (Apr 2026). Option 1 was selected. |

## What's in the package

| Layer | Import | Contents |
|---|---|---|
| **Tokens** | `@riverchristianchurch/ui-shell/tokens` | CSS custom properties — brand teal ramp, neutrals, status colors, type, radius, layout |
| **Components** | `@riverchristianchurch/ui-shell/components` | `rcc-`-prefixed component CSS: nav shell, hero, wave dividers, sections, cards, event rows, pathway steps, portal features, dashboard cards, pills, progress, checklists, forms, CTA band, footer |

Classes are prefixed `rcc-` so they coexist with Tailwind utilities in consuming apps.

## Install (consuming apps)

Distributed via **git tag**, not a registry — no auth token needed locally or on Vercel:

```bash
npm install github:RiverChristianChurch/ui-shell#v0.1.0-beta.1
```

```ts
// e.g. nuxt.config.ts
css: [
  '@riverchristianchurch/ui-shell/tokens',
  '@riverchristianchurch/ui-shell/components',
]
```

Fonts: the shell uses **Inter only**. Consuming apps load it themselves (Google Fonts or self-hosted).

> Differs from the NATCA shell on purpose: NATCA publishes to GitHub Packages because ~8 apps consume it. RCC has one consumer (`web`), so git-tag install avoids `NODE_AUTH_TOKEN` friction everywhere. Revisit if consumers multiply (e.g. RPK as a separate app).

## Release process

1. Make changes in `src/css/` (and update `beta/` mockups to match)
2. Bump `version` in `package.json`
3. Commit, tag `v<version>`, push with tags
4. `gh release create v<version> --prerelease` (drop `--prerelease` at 1.0)
5. Bump the tag ref in consuming apps' `package.json`

## Component promotion policy

Vue components live **in the `web` app** until a second consumer needs them — then they get promoted here. Don't build a component library ahead of need; CSS layers here, Vue layers in the app. (Lesson from NATCA: the package/version dance is only worth it once multiple apps consume.)

## Design rules for consuming apps

- **No hardcoded colors, fonts, or radii** — use tokens. If a value isn't a token, add it here first.
- One shell for everything: public pages and portal views share nav, sections, and components. Auth'd views add dashboard components; they don't fork the theme.
- Waves: fill class = the color of the *next* section; inline `background` = the color of the *previous* section.
- Keep templates resize-safe and mobile-first — church traffic spikes Sunday morning on phones.

## Research (still valid)

Peer research behind the shared patterns (6–7 nav items max, "Plan a Visit" primary CTA, Give always visible, Sign In in header, latest message prominent, PCO-fed events, 4-step growth pathway, mobile-first) drew on Elevation, Life.Church, VOUS, Hillsong, Church of the Highlands, Passion City, Bethel, Transformation Church, CCV, Southeast, and Traders Point. **Single-site model cohort** (Aug 2026, primary for IA/feature decisions — verified one-campus, comparable scale): E91 Indianapolis, Venture Christian (Carmel IN), Real Life Sacramento, Motivation (Richmond VA), Fusion Christian (Temecula CA), Brooklake (Federal Way WA) — full feature matrix in BRAIN `Website-Feature-Inventory` and raw audits in the `web` repo `docs/research/`. Full reference list + PCO portal feature research: `BRAIN/50-RCC/` (Reference-Churches, Website-Rebuild) and the [`web`](https://github.com/RiverChristianChurch/web) repo docs.
