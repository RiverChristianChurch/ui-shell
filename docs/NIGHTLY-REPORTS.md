# Nightly Iteration Reports — RCC Website Beta

One entry per night. Newest first. See `NIGHTLY-LOOP.md` for the queue and rules.

---

## 2026-08-12 · Review pass — Jason's 7 fixes (text width · icons · /give · /groups · ministries · waves · sermon art)

**Status:** shipped to `web` main. Ran on Jason's review of the morning's work — 7 items.

1. **Readable text measure** — Next Steps funnel step text stretched the full 1280px
   container (160-char lines). Scoped `:deep(.rcc-step) p { max-width: 68ch }` — now
   matches the tighter Give block. His example was STEP THREE.
2. **Emojis → icons + central times.** Prayer section 🙏/📝 replaced with `<RccIcon>`
   (new component: inline-SVG, open-license Lucide paths — FA Pro swaps in later via the
   npm token). Recurring times now come from **`utils/siteConfig.ts`** (one source of
   truth). His question — "where did 11:00–11:45 come from?": it's **verbatim** from the
   live `/ministries/prayer/` ("Join us each week … 11:00AM–11:45AM in the Worship
   Center"). The live page names **no weekday**, so `SITE.prayer.day` is left blank and
   flagged — confirm if it's the Wednesday time.
3. **Removed the redundant CTA band** ("Take the Next Step" → scrolled to the same page).
4. **Nav de-duplicated** — dropped the "Visit" nav link; kept "Plan a Visit" as the one
   visit entry point.
5. **Sermon series graphic.** The scraper now captures `artworkUrl` (the series graphic)
   → `public/sermon-art/` → record `thumb`. `thumbFor`/`thumbOf` no longer fabricate a
   YouTube thumb from a PLACEHOLDER id (that WAS the gray 3-dot box); `/watch` shows a
   branded gradient with the series name until real art lands. Samples de-placeholdered.
6. **Give = step 05** on Next Steps. **LifeGroups** leader/study material split to a new
   **`/groups`** page (verbatim blurb + the 16-study library). New **`/give`** page embeds
   the church's **real Subsplash giving form** (`secure.subsplash.com/ui/access/8MDG8H`,
   centralized as `SITE.givingUrl`) + ways-to-give. Both routes flipped to ready.
7. **Ministries "way better."** Emojis gone → clean **text-only cards** (brand accent bar,
   corner "Soon" badge for unbuilt sub-pages, "Coming soon" CTA). Fixed the **wave hard
   cut** — the divider's black background against the grey section above; div bg now
   matches the section above (same fix applied on outreach + next-steps waves).

**Also:** `<RccLink>` gained `hide-tag` so full-card links don't sprout a floating "soon"
sup. Build + SSR verified on every route (incl. new /groups, /give); browser-screenshot
confirmed each fix; link-validation sweep shows no live href to an unbuilt route.

### Needs Jason
- **Prayer weekday** — is 11:00–11:45 AM the Wednesday prayer time? Set `SITE.prayer.day`.
- **FA Pro** — want real FontAwesome? Drop the FA npm token in `.npmrc` and I'll swap
  RccIcon's rendering (call sites don't change).
- Still open from before: real URLs for baptism form / packet PDFs / volunteer sign-up (#14).

---

## 2026-08-12 · Rework — Outreach & Missions (Here·Near·Far) + sitewide stub-link system

**Status:** shipped to `web` main · ui-shell `v0.1.0-beta.6` · closes **#13**. Ran on
Jason's #13 feedback (not autonomous): keep & build out Here/Near/Far; stub links to
planned pages (disabled until ready) + validate links every nightly run.

### The reconciliation (#13)
Jason corrected a de-invention from the prior run: the **"Here/Near/Far"** I'd removed
from Next Steps **is real RCC content** — it's `/ministries/outreach-missions/`, framed
on **Acts 1:8** (Jerusalem → Judea & Samaria → Ends of the Earth). So instead of keeping
it cut, I **built the missions page out** from the church's own words.

### What shipped
1. **New page `web/pages/ministries/outreach-missions.vue`** (route
   `/ministries/outreach-missions`). VERBATIM from the live page: hero
   ("Outreach & Missions" / "RCC Outreach Gameplan"), the **Acts 1:8 (NIV)** quote, the
   "We Need You!" blurb, and **all 16 partner ministries** across the three tiers
   (8 local / 3 regional / 5 global) with their exact one-line descriptions. The **only
   DRAFT chip** is the added **"Here·Near·Far / Local·Regional·Global"** overlay on the
   biblical tier labels — that plain-language taxonomy is the model-site pattern, not RCC
   copy, so it's chipped with a source note. Wired **Next Steps' Serve step** to link here
   ("See where we serve — here, near & far →").
2. **Sitewide stub-link system** (Jason's ask). `web/utils/routeRegistry.ts` is the
   single source of truth (route → ready?); `<RccLink>` renders a real `<NuxtLink>` when
   the target is built and a disabled **"soon"** stub (muted, non-clickable, hover note)
   when it isn't; ui-shell `.rcc-link-soon` / `.rcc-soon-tag` style it (v0.1.0-beta.6).
   **Swept every page** — all static internal links to unbuilt routes (`/connect`,
   `/give`, `/serve`, `/about`, `/groups`, `/preschool`, `/this-week`, ministry
   sub-pages) now render disabled instead of 404-ing; live routes stay clickable.
   Disabled stubs render as hrefless `<a>` so they inherit nav/footer `a` styling.
3. **Nightly loop step 5b (link validation)** added to `NIGHTLY-LOOP.md`: every night,
   point new links at planned routes via `<RccLink>`, flip a route to `true` when its
   page ships (auto-enables every link to it), and sweep for drift (no live href to a
   `false` route; no `<RccLink>` to a route missing from the registry).

### ≥2 model borrowings
1. **Traders Point (TPCC) / East 91st (E91)** — the concentric **"Here · Near · Far"**
   missions taxonomy layered over local/regional/global partners. Used as the scannable
   overlay on RCC's Acts 1:8 tiers (chipped as DRAFT — it's the added framing).
2. **The Chapel / Eleven22-style missions directory** — a text-first **partner-card grid**
   (name + one-line description per organization) rather than logo walls. Every RCC
   partner is a card under its tier.

### Validation
`npm run build` passes; SSR `200` on the new route with all verbatim strings + the three
Here/Near/Far tags + the DRAFT chip; stub links render `.rcc-link-soon`; **no live `href`
points at any unbuilt route** across `/ /next-steps /ministries /visit /watch /events` and
the new page.

### Needs Jason
- Real destinations still open (now safely stubbed, not silently wrong): the Church Center
  **baptism form**, the two **PDF packets**, and the **volunteer sign-up** form. Give a URL
  and I flip each stub to the real link.
- OK on the single DRAFT overlay (Here·Near·Far tags) on the missions page? If you'd rather
  use RCC's biblical labels only, I'll drop the tags.

---

## 2026-08-12 · Rework — Next Steps content-fidelity audit + condense

**Status:** shipped to `web` main (`5a4cde5`) · rework-queue box checked. Autonomous run.
Took the first unchecked **rework** item (priority over new sections per the loop).

### What shipped — `web/pages/next-steps.vue` (route `/next-steps`)
A fidelity + condense pass on an existing page (it shipped section-heavy with
paraphrased copy before the verbatim rule). Diffed every line against the live site
(`curl` raw HTML → strip tags) and restored RCC's exact words.
- **Restored verbatim** from `/next-steps/growth-track/`, `/baptism/`, `/lifegroups/`,
  `/ministries/prayer/`: the Growth Track intro + Acts 2:42; Welcome to RCC ("room 204
  during 2nd service… great FIRST STEP"); the baptism statement + Kid Baptism (age 7+)
  + both packets (Kids Baptism, Adventure of a Lifetime); LifeGroups ("makes a big
  church seem small… crazy uncle Tim") + Study Material blurb + the 16-study library;
  the Serve blurb; the Give paragraph; and Prayer (Galatians 6:2, "11:00AM – 11:45AM
  in the Worship Center", the two request methods).
- **De-invented** (RCC's own pages carry no such copy — omission, not reword, so no
  chip per the rule; flagged here): the E91-style **Serve Here/Near/Far** tiers, the
  **LifeGroups group-finder** concept, and the paraphrased **"Holy Spirit-led prayer"**
  team paragraph. This reverts prior invented borrows in favor of fidelity.
- **Condensed 8 content bands → 4**: Hero → one Growth Track funnel section (all four
  steps + Give) → Prayer → CTA.
- **One DRAFT chip** remains: the native prayer-request form (Name / "would you like a
  pastor to follow up?" / request) isn't built — routes to the Connect Card for now.
- Build passes; SSR verified (`200`; 8 verbatim strings render; all 4 inventions gone;
  `/connect /events /give /portal` links resolve; no hardcoded colors).

### ≥2 model borrowings (structure that survived the fidelity pass)
1. **Motivation Church** — its `/next-steps` is "a clean linear discipleship funnel:
   Salvation → Baptism → Small Group → Dream Team." RCC's Growth Track is the same
   numbered, take-them-in-order funnel (Welcome → Baptism → LifeGroups → Serve → Give).
2. **Venture Christian** — surfaces its **Connection Point newcomer class with dates +
   room** as step one, and pairs Next Steps with a Prayer block. Mirrored by leading
   with "Welcome to RCC" (room 204, 2nd service, monthly) and keeping Prayer in the funnel.

### Decisions needed (Jason) — see needs-jason issue
- Confirm the three de-inventions are correct to drop (vs. keep any as a planned DRAFT).
- Real destinations for the placeholder `/connect` CTAs: baptism scheduling + the two
  packet PDFs, and Sign-Up-to-Serve (real Church Center forms exist on the live site).
- Native prayer-request form vs. routing to Connect Card.



**Status:** shipped to `web` main · Section 4 box checked. Interactive session.

### What shipped — Events (`web/pages/events/index.vue` + `[slug].vue`)
RCC's current `/events/` is a JS-only Subsplash embed (invisible); registration
hands off to Planning Center Church Center (`riverchristianchurch.churchcenter.com/
registrations/events/<id>`). So header copy is real; the list is net-new + DRAFT.
- **Header** — REAL/verbatim: "Church Calendar" + "Listed below are all the upcoming
  church-wide events at RCC."
- **List** — E91 text-first rows (date · title · time/blurb · arrow) + functional
  category filter over sample data. Real event names (Mercy Comedy, Women's Bible
  Study, MOMs Fall); dates/blurbs placeholder. DRAFT chip w/ source note.
- **CTA** — ministry quick-links (Kids/Students/Men/Women, real) + Connect Card.
- **`/events/[slug]`** — Fusion detail: description + Register (real Church Center
  handoff for Women's Bible Study, reg 3757530) + Add-to-Calendar (Google) + Share.
- 3 bands + detail page. Build passes; SSR verified for `/events` + a detail slug.

### ≥2 model borrowings
1. **E91** — text-first filterable event list (linked title + date + blurb + more),
   category filter with Apply/Reset → the list + category pills.
2. **Fusion** — event detail page with register + add-to-calendar + share → `[slug]`.

### Also this session — ADR-003 (sermon media hosting)
Wrote `docs/architecture/decisions/ADR-003-sermon-media-hosting.md` (Proposed).
Recommends migrating **off Subsplash**: **video on YouTube** (or Cloudflare Stream
if RCC wants to own the player) + **sermon metadata as a git content collection**,
synced via the **YouTube Data API** — SEO-visible on our domain, automatable by
Claude + the nightly loop, cheap, no lock-in. Blocked on confirming the channel (web#10).

### DRAFT / owed
- Events list + detail wire to PCO Church Center at cutover (category taxonomy = PCO teams).
- Still owed (rework queue): **Next Steps** content-fidelity audit vs the live site.

---

## 2026-08-11 (3) · Section 3 — Watch (+ header/home fixes, interactive)

**Status:** shipped to `web` main · Section 3 box checked. Interactive session.

### What shipped — Watch (`web/pages/watch/index.vue` + `[slug].vue`)
RCC does **not** self-host sermons (livestream = Church Online Platform
`riverchristian.online.church`; on-demand = a JS-only Subsplash embed, invisible to
search). So real copy is thin and the archive/detail are net-new + DRAFT-flagged.
- **Live band** — REAL: verbatim "Join us online on Sunday mornings at 10:00 or
  11:30 AM" + Church Online CTA + "Live · Sundays 10:00 & 11:30 AM" pill.
- **Latest message** — `rcc-message-*` card; placeholder sermon (Nathan Freeman =
  real lead pastor; series/title sample). DRAFT chip w/ source note.
- **Message archive** — on-site filterable grid, functional **series** filter over
  sample data (speaker/date next). Net-new — RCC has no filterable archive. DRAFT.
- **Also On** — Church Online + Facebook (`facebook.com/rivercc`) real; **YouTube
  @RiverCC flagged UNVERIFIED**.
- **`/watch/[slug]`** — per-sermon detail concept: video + Message Notes (PDF) +
  response CTAs (Get Baptized / Connect Card / Give). DRAFT.
- 4 bands + detail page. Build passes; SSR verified for `/watch` and a detail slug.

### ≥2 model borrowings
1. **Real Life Sac** — on-site archive with a Series/Speaker/Date filter (browse on
   our domain, video hosted elsewhere) → the archive grid + series filter.
2. **E91** — per-sermon detail URL + downloadable message guide → the detail page.
3. **Motivation** — detail page = video + notes + response CTAs → the next-step block.

### Also this session (Jason review fixes)
- **Header pinned to always-glass** (ui-shell **beta.5**): removed the
  transparent-at-top state + scroll listener; same deep-teal glass at rest and on scroll.
- **Home hero video**: pulled the current site's home mp4 (`rcc-web-2025`) as an
  autoplay/muted/loop background; moved the photo Jason likes to the **Visit hero**
  (also the home video's poster). Added `.rcc-hero-video` to ui-shell.

### DRAFT / decisions needed from Jason
- **YouTube channel** — is it `@RiverCC`? Unverified; several decoys. Confirm before linking.
- **Archive data source** — where do real sermons come from (keep Subsplash, move to
  YouTube, or Planning Center)? The archive + detail are placeholders until this is decided.
- **Live player** — keep Church Online Platform embed, or host the live player on YouTube?
- Still owed (rework queue): **Next Steps** content-fidelity audit vs the live site.

---

## 2026-08-11 (2) · Visit — content-fidelity + header fix (interactive)

**Status:** shipped to `web` main. Triggered by Jason review, not the scheduler.

### What shipped
- **Content fidelity (fixed a HARD-RULE violation).** The condensed Visit page had
  paraphrased the church's real copy (e.g. the parking blurb) and invented a
  "Questions First-Timers Ask" FAQ that isn't on the live site. Re-fetched
  `/about-us/what-to-expect/`, `/about-us/new/`, and the home page (raw HTML) and
  rebuilt `web/pages/visit.vue` with **verbatim** RCC copy:
  - What to Expect = the site's own sections verbatim (Services, Worship Music,
    What to Wear, Where to Park, Communion, Kids).
  - Close = `/about-us/new/` verbatim ("…you can belong before you believe", Connect Card).
  - Removed the invented FAQ + the reworded parking copy entirely.
  - Only deviation: **kids age** — site says "birth through grade five" (kept
    verbatim); a DRAFT chip's hover note flags the open 6th-grade question (source + why).
  - Verified: `Our parking team is top-notch…` present verbatim; paraphrase gone; FAQ gone.
- **Header (the "grey bar" fix).** Shipped **ui-shell v0.1.0-beta.4**: nav + supra
  are now **transparent over the hero** and gain the glass/teal only on scroll
  (`.is-scrolled`). The hero fills to the very top (padding-top clears the header);
  removed the `margin-top` that had left a solid bar above it. Layout adds a scroll
  listener toggling `.is-scrolled`.
- **DRAFT chip is now source-aware** (ui-shell beta.4): `[data-note]` hover tooltip
  shows source + what changed + why — so every deviation from live copy is traceable.

### New standing rule (all future nights)
Added a hard rule: **verbatim RCC copy; any reword/reformat/invention gets a
source-noted DRAFT chip.** Verify by fetching the live page and diffing each line.

### Owed next (rework queue)
- **Next Steps** now needs a content-fidelity audit vs the live site (its copy was
  paraphrased before this rule), then a condense pass. Queued.

### Decisions needed from Jason
- **Kids age:** live site says "birth through grade five" — confirm whether to keep
  that or change to "through 6th grade" (you'd asked for 6th earlier). See the DRAFT
  chip on the Visit page's Kids block.

---

## 2026-08-11 · Rework — Visit (condense)

**Status:** shipped to `web` main · rework-queue box checked · sitemap Visit dots stay ● (refined, not new)

Rework-queue item took priority over a new section (per the loop's condense-first rule).

### What shipped
Streamlined **`web/pages/visit.vue`** — same route `/visit`, same look/feel, less length.
- **7 content bands → 5:** hero → What to Expect (4 beats) → Times & Directions (grid +
  map) → Visitor FAQ → one merged Connect-Card CTA (teal).
- **Cut** the standalone **Kids-preview band** (3 cards) — it duplicated the "Your Kids Are
  Covered" step and the kids FAQ answer; Kids gets its own page in Section 5.
- **Merged** the two competing closing CTAs (teal "Your Next Step" + brand CTA band) into a
  single Connect-Card next-step — one primary action, no dead-end second band.
- **Trimmed FAQ** from 8 → 6 (dropped the two DRAFT answers: "do I have to give" and "when
  should I arrive"). Tightened copy across the hero sub + What-to-Expect beats.
- Build passes; SSR curl confirms real content + `#times`/`#next` anchors resolve.

### ≥2 model borrowings (condense-justifying)
1. **Fusion "New Here"** — a single tight page = short what-to-expect + a visitor FAQ that
   answers the real anxieties verbatim (dress, giving, kids, coffee) + one Plan-a-Visit CTA.
   Justifies folding kids into the FAQ and cutting the separate kids band.
2. **Venture Christian** — service times live in the hero (and sitewide footer) with a single
   repeated primary CTA and "no dead-end pages." Justifies collapsing the dual closing CTAs
   into one Connect-Card next-step rather than a second, competing band.

### DRAFT-flagged (unchanged from before)
- Kids FAQ answer: "Stop by the Kids Ministry check-in when you arrive…" still carries a
  DRAFT chip pending confirmation of the actual check-in flow.

### Decisions needed from Jason
- Is 5 bands the right density, or go further (e.g. fold Times & Directions' address block
  into the footer and drop to 4)? Next rework item (Next Steps, 7 bands) waits on this cue.

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
