# Nightly Iteration Reports — RCC Website Beta

One entry per night. Newest first. See `NIGHTLY-LOOP.md` for the queue and rules.

---

## 2026-08-10 · Section 2 — Next Steps

**Status:** shipped to `web` main · queue box checked · sitemap Next-Steps dots → ◐ in-beta

### What shipped
New real Nuxt route **`web/pages/next-steps.vue`** (SSR + `useHead` SEO) — the discipleship
funnel, built from real RCC copy.
- Route: `/next-steps` (added to sitewide nav in `layouts/default.vue`). Vercel deploys from `main`.
- Sections: hero (real framing line "…that's the starting point, not the goal") → **Growth
  Track** 4-step ladder (Welcome to RCC → Baptism → LifeGroups → Serve, + Give as step 5) →
  **Welcome to RCC** (real: monthly, Room 204, 2nd service; next date DRAFT) → **Baptism**
  (real definition/immersion copy, Schedule + Age-7 Kids Packet + *Adventure of a Lifetime*)
  → **LifeGroups** (real one-liner + 16-topic study library; finder = DRAFT) → **Serve**
  (DRAFT, Here/Near/Far tiers — real teams migrate from the volunteer app, ADR-002) →
  **Prayer** (real: Galatians 6:2, prayer-team copy, weekly 11:00–11:45 Worship Center, 3
  in-person pathways, Request Prayer CTA) → CTA band.
- Built entirely on existing ui-shell primitives (`rcc-steps`, `rcc-card-grid`, `rcc-pill`,
  `rcc-portal-feat`, `rcc-faq`, waves, section bands) — no new components needed for the page.

### ≥2 model borrowings
1. **Motivation Church** — linear "one card, one action, in order" next-steps funnel → the
   Growth Track 4-step ladder (each rung a single CTA to its section).
2. **E91 (East 91st St)** — (a) group **finder** ("help me find a group") → the DRAFT
   LifeGroups finder concept (filter by day/location/audience/study); (b) **Serve Here /
   Near / Far** tiered IA → the three Serve cards; (c) surfacing the newcomer-event **date +
   RSVP** on the tile → Welcome-to-RCC "Save My Spot".

### DRAFT-flagged (needs review)
- Welcome-to-RCC **next session date** (wires to PCO events feed).
- **LifeGroups group finder** (placeholder layout; groups come live from PCO).
- **Serve** teams/descriptions (source of truth = migrating volunteer app / PCO team list).

### Also this session (not part of the nightly section)
- **Header redesign** — retired the flat grey supra/nav for a **branded deep-teal header**
  (deep-teal brand rail supra + deep-teal glass nav w/ brand-soft hairline + shadow). New
  header-surface tokens (`--rcc-supra-bg`, `--rcc-nav-bg`, `--rcc-nav-border`,
  `--rcc-nav-shadow`). Shipped as **ui-shell v0.1.0-beta.3**, consumed by `web`.
- **Dev-port fix** — 1720 is a browser-blocked port (`ERR_UNSAFE_PORT`); dev server moved
  to **1721** in `web` and documented in DEV_PORTS.md.

### Decisions needed from Jason
- LifeGroups finder + Serve teams need the PCO data wiring plan (which comes first — this
  page's finder, or the volunteer-app migration that owns the serve teams?).
- Baptism/Welcome/Serve CTAs currently point to `/connect`; confirm whether each should be a
  dedicated PCO Church Center form instead.

---

## 2026-08-08 · Section 1 — Visit

**Status:** shipped to beta · queue box checked · sitemap dots (Visit ×4) → ◐ in-beta

### What shipped
New page **`beta/visit.html`** — the visitor funnel, built from real RCC content.
- Live (GitHub Pages): https://riverchristianchurch.github.io/ui-shell/beta/visit.html
- Sections: hero ("You Are Welcome Here") → **What to Expect** (4 beats) → **Service Times & Directions** (Sat/Sun/Online grid + address, office hours, Get Directions) → **Visitor FAQ** (8-question accordion) → **Kids preview** (River Kids teaser) → **Before You Come** next-step (Connect Card + Welcome Desk) → CTA → footer.
- Wired into every beta switcher; home nav/hero/CTA/footer "Visit / Plan Your Visit / What to Expect / Service Times" now point to the page.

New **reusable shell components** (`src/css`, token-driven, `rcc-` prefixed):
- `.rcc-draft` / `.rcc-draft-chip` — amber DRAFT badge for un-reviewed invented copy
- `.rcc-supra` + `--rcc-supra-h` + `.rcc-has-supra` — supra utility bar (Preschool · This Week)
- `.rcc-times` — service-times grid · `.rcc-faq` — native `<details>` accordion (no JS)

Logo tiers per brand guide: **tier-2 short lockup** in nav, **tier-1 full logo** in footer.

### Model-church borrowings (single-site cohort)
1. **Fusion & Brooklake** — visitor-FAQ accordion that answers real first-timer anxieties *verbatim* (dress, length, music, communion, kids, parking). This is now the spine of the page.
2. **E91 (New Here) & Real Life Sac (/visit)** — first-time-guest framing and a dedicated `/visit` funnel page rather than burying it under About.
3. **Fusion "Plan Your Visit" form** — *considered and deliberately dropped*: the decided sitemap IA **cuts the custom plan-a-visit form** ("What-to-Expect + FAQ is the funnel"). Kept the intent (know-you're-coming) but routed it to RCC's real **Connect Card (→ PCO)** + Welcome Desk instead of a bespoke form.

### Content provenance
Nearly all copy is **real RCC**, pulled from `riverchristian.church/about-us/what-to-expect/` and `/about-us/new/` (welcome statement, dress, parking + flashers, ~1 hour / worship-communion-teaching, 3–6 week series, contemporary-with-traditional music, weekly pre-packaged communion, birth–5th-grade kids, times, address, office hours). Edited only for grammar/flow.

### DRAFT-flagged (invented — needs review) — 5 items
1. **FAQ "Do I have to give money?"** — invented reassurance answer.
2. **FAQ "When should I arrive?"** — invented "~15 min early, grab a coffee" guidance (coffee/arrival not confirmed on live site).
3. **FAQ "What about my kids?"** — the *check-in location* sentence (real page states nursery + grade groups only).
4. **Kids preview "Safe & Secure"** card — secure check-in/check-out specifics (belongs to Section 5 Kids; placeholder here).
5. **Directions** — "just south of the Buckman Bridge" landmark line.

### Validation
Static: HTML tag-balanced; **zero hardcoded colors** (all `var(--rcc-*)`); internal links/anchors (`#times`, `#next`) and logo assets all resolve; responsive rules present at 768/1024 incl. new components; no external JS (accordion is native `<details>`, so no console errors possible). **Browser render deferred** — no Chrome connected at run time; recommend an eyeball on mobile in the morning.

### Decisions needed → GitHub issues (label `needs-jason`)
- Confirm Visit's next-step = Connect Card + Welcome Desk (custom plan-a-visit form stays cut). *(issue)*
- Review the 5 DRAFT copy items above — esp. giving reassurance, arrival guidance, kids check-in/safety wording. *(issue)*
- Supra-menu introduced on Visit only (Preschool · This Week); confirm sitewide rollout is Section 9's job. *(noted, not blocking)*

### Next up
Section 2 — **Next Steps** (Growth Track, Baptism, LifeGroups finder, Serve, Prayer).
