# Nightly Iteration Reports — RCC Website Beta

One entry per night. Newest first. See `NIGHTLY-LOOP.md` for the queue and rules.

---

## 2026-08-23 · web#23 file storage — SCOPED to ADR-008 (Proposed), not built

**Not a page section — a scoping/proposal night.** With the Section queue (1–11) + Rework
queue complete, the first unchecked post-section item is **web#23 (file storage for ministry
resources)**. Its queue note says *"needs a storage-backend decision first… scope before
building."* The next item, **web#7 (native sermon archive + YouTube ingest), is blocked** — the
/watch page's own DRAFT note flags the YouTube channel as UNVERIFIED and web#10 (needs-jason)
exists to confirm it; building ingest against an unconfirmed channel would push wrong sermons to
the congregation (hard-rule violation). So tonight I **scoped #23** rather than build anything
blind. No model-church research / verbatim rules apply (no page shipped).

**Why it can't be built blind:** a role-gated resource library fits none of the app's three data
planes — PCO (system of record, not a file store), Redis (cache-only, can't own data), or git
content (every change is a deploy — the one thing #23 forbids). It forces **the app's first
app-owned database** for file metadata, a decision shared with #18 (tickets) and #20 (graphics
queue).

**Shipped (web `1c56fc9` → `main`, pushed):**
- **ADR-008** — `docs/architecture/decisions/ADR-008-file-storage-and-app-data.md`, Status
  **Proposed**. Two-part recommendation: (1) **DO Spaces** for the blobs — private objects +
  short-TTL pre-signed URLs, admin-gated Nitro upload route (**ready to build, no blocker**);
  (2) a **small managed Postgres** for the metadata — the app's first app-owned DB.
- **Proposal Artifact** (RCC teal, phone-first, theme-aware):
  `https://claude.ai/code/artifact/f5383b65-4ef8-4191-97a5-7ffd3e517085`
- **web#23** commented with the recommendation + Artifact, labeled **needs-jason**.

**Model borrowings (structural, from ADR-003's proven shape — no new page cohort to mine):**
1. **ADR-003's "cheap blob store + owned metadata" split** — reused verbatim as Spaces (blobs) +
   Postgres (catalog); ADR-003 already anticipated "Notes/PDFs live in… a cheap object store."
2. **The portal's `usePortalSession()` preview-gate seam (Section 10)** — reused so the
   upload/download pipeline can be built and demoed now behind the same guest/preview gate and
   flip live when ADR-006's real session lands, no redesign.

**DRAFT-flagged copy:** none (no page copy produced).

**Decisions needed from Jason (why it's needs-jason):**
1. **App-data store: DO Managed Postgres (rec., ~$15/mo, one bill per ADR-005) vs. reuse an
   existing Supabase instance (~$0, already operated).** Sets the precedent for #18/#20.
2. **Budget:** ~$20/mo all-DO, or ~$5/mo reusing Supabase.
3. **Role floors** for download: anything member-visible, or leader-and-up to start?
4. **Blocked-not-stalled:** download *enforcement* reads roles from **ADR-006** (contested, POC-
   blocked). Storage/schema/route design don't wait on it.

**Sitemap dot:** unchanged — #23 is infra, not an IA section.

---

## 2026-08-21 · Code-quality hardening — ESLint + Prettier + typecheck + commit gate (batch #3/#4)

**Not a page section.** The Section queue (1–11) and Rework queue are complete; the first
unchecked **autonomous** batch items were #3 (code audit + tooling) and #4 (commit-time gate).
Everything else remaining (#5 serve form, #6 auth/ADR-006, #7 tickets, #8 graphics) is gated on
ADR-006 (PCO OAuth), which needs Jason's creds + a test account — already tracked in web#19/#17/#29.
So tonight took the two fully-autonomous items instead. No model-church research / verbatim-copy
rules apply (no page shipped).

**What shipped (web `1c70745`, two commits — pushed to `main`, DO deploys on push):**

- **ESLint** — `@nuxt/eslint` flat config (`web/eslint.config.mjs`) extending the project-aware
  base Nuxt generates (Vue+TS+Nuxt aware). Stylistic off (Prettier owns formatting).
  `no-explicit-any` → **warning** (allowed at the loose PCO/JSON boundary). Disabled
  `vue/no-multiple-template-root` — a **Vue-2-only rule** that false-positived on all our Vue 3
  fragment-root section pages (120 phantom errors; confirmed the templates are valid Vue 3).
- **Prettier** — `.prettierrc.json` (no-semi, single-quote, 100 col) + `.prettierignore`
  (build output, `content/`, `docs/research/` data, `.do/` deploy specs). Applied repo-wide as a
  formatting baseline (2nd commit is formatting-only; **RCC copy content byte-identical** — only
  surrounding quote chars changed, so no verbatim-copy impact).
- **Typecheck** — `nuxt typecheck` (vue-tsc) + `@types/node`. **Clean.**
- **Commit gate** — Husky + lint-staged (`.husky/pre-commit`): `eslint --fix` + `prettier --write`
  on staged files, then full `npm run typecheck`. Build excluded (too slow per commit; DO
  build-on-push is the backstop). **Verified live** — both of tonight's commits passed the gate.
- **Scripts** — `lint`, `lint:fix`, `format`, `format:check`, `typecheck`, `prepare`.
- **Docs** — new "Code Quality & Commit Gate" section in `web/CLAUDE.md`; nightly step 5 now
  requires `lint && typecheck` before build (also enforced by the hook). Fixed a stale
  `localhost:1720` → `1721` in the Commands block (1720 is the browser-blocked port).

**Real fixes surfaced by the new gate (not just config):**
- `web/server/api/groups.get.ts` — typed the PCO JSON:API envelope (`PcoResource`/`PcoResponse`/
  `GroupsResult`) to break an implicit-any inference cascade (TS7022/7023/7024) under
  `noImplicitAny`. **Behavior unchanged** — booted the build and confirmed `/api/groups` still
  returns the friendly unconfigured `{"configured":false,…}` 200. Cut file `any` warnings 13→3.
- `web/plugins/fontawesome.ts` — targeted `import/first` waiver for the deliberate
  `autoAddCss=false`-before-stylesheet ordering (prevents SSR style flash).
- Added `@types/node` (server route used `Buffer` with no node types); `npm audit fix` cleared a
  transitive nanoid high-sev advisory (0 vulns).

**Audit / organize finding.** Structure is already industry-standard — 20 pages, 4 components,
5 utils, 2 server routes, 2 composables, clean route-group nesting. No reorg needed; the value was
in the linting/typing gate + the PCO envelope types, not moving files.

**Validation.** `npm run lint` → 0 errors (3–4 boundary `any` warnings, intentional). `npm run
typecheck` → clean. `npm run build` → passes. Booted `.output/server` and curled `/`, `/about`,
`/groups`, `/api/groups` → SSR renders real content; the refactored PCO route behaves identically.

**Borrowings (n/a).** Tooling night — no model-church section built, so the ≥2-borrowings rule
doesn't apply.

**DRAFT-flagged.** None (no copy touched beyond quote-char normalization).

**Decisions needed → Jason.** Nothing new tonight. The standing blocker is unchanged: **ADR-006
(PCO OAuth)** gates the four remaining batch builds (#5 serve form, #7 tickets, #8 graphics, and
portal go-live #29). Running that POC needs Jason's PCO OAuth client creds + a Church-Center-only
test account — tracked in web#19. Until that lands, autonomous nights should shift to polish/QA
(real-device mobile sweep) and any newly-queued items.

---

## 2026-08-17 · Section 9 — Give (verbatim rebuild) + sitewide footer social

**Shipped:** `web/pages/give.vue` (route **`/give`**, already live in the registry;
pushed to `web` `main` → DigitalOcean deploys) + sitewide footer social in
`web/layouts/default.vue`. ui-shell bumped **v0.1.0-beta.7 → v0.1.0-beta.8** for one
new footer sub-component class.

**What changed (content-fidelity pass, the real work):** the existing `/give` page had
a **verbatim-rule violation** — the hero paraphrased RCC's "why we give" as *"Giving is
the primary way we acknowledge that God is first…"* with **no DRAFT chip**, and the
"Ways to Give" cards were paraphrased and DRAFT-chipped. I fetched the live
`riverchristian.church/give/` raw HTML and rebuilt every block to **verbatim** copy:
- **Hero** → RCC's exact "WHY WE GIVE" paragraph (…"a joy and an honor to sow some of
  our resources back into the Kingdom of God… (2 Corinthians 9:6–8)…").
- **Give Now** → verbatim "ONLINE" copy beside the unchanged Subsplash widget embed
  (`wallet.subsplash.com/ui/embed/8MDG8H`).
- **Ways to Give** → verbatim **In-Person / Mobile Apps / Mail** cards (dropped the
  invented "Bank Bill Pay" card — that content lives in the FAQ on the live site).
- **NEW: Giving FAQs** accordion → the live page's own **6 questions verbatim** (fund
  usage, contribution statements, giving history, card fees, online fees, bank bill pay).
- **Result: ZERO draft chips** on `/give` — the whole page is now source-traceable.

**Sitewide footer/supra pattern:** footer social row (Facebook/Instagram/YouTube) was
**dead plain text** — now real external links from **`SITE.social`** (hrefs verbatim off
the live footer: `facebook.com/rivercc`, `instagram.com/clayrivercc`, `youtube.com/rivercc`),
rendered via new ui-shell **`.rcc-footer-social`** (inline-flex; base `.rcc-footer a` is
`display:block`/stacked) with a ≤560px stack. Supra (Preschool + This Week) already in the
layout; both remain disabled `<RccLink>` stubs until those pages ship.

**≥2 model borrowings (named):**
1. **Venture Christian Church** (Restoration peer) — `/giving` = **"Give + FAQs"**: pairs
   the giving form with a giving-FAQ block → RCC's own six FAQs elevated into an accordion
   band beside the form.
2. **Fusion Christian Church** (runs on Planning Center/Church Center like RCC) — splits a
   dedicated **`/alternate-ways-of-giving/`** page → shapes the scannable "More Ways to
   Give" card band (In-Person / Mobile / Mail).
3. **East 91st Street (E91)** (Restoration peer) — *"No header Give button — Give lives in
   footer only"* → confirms RCC's **Give-never-highlighted** rule (plain nav item; the
   highlighted CTA stays "Plan a Visit") and a Give link carried in the footer Connect column.

**DRAFT-flagged (invented copy):** **none.** All prose is verbatim RCC. Editorial-only:
dropped the transitional "we changed providers from Breeze to Subsplash / instructions here"
note and de-linked two live "here" hyperlinks whose exact URLs we don't hold (Breeze history,
the contribution-statement request form) — kept the FAQ text, rendered "here" as plain words
(pure omission of a link, not a reword → no chip).

**Validation:** `npm run build` passes; booted `.output/server` and curled `/give` → SSR
renders all verbatim blocks (hero, ways cards, all 6 FAQs, embed); confirmed **no
`rcc-draft-chip` element** (only the CSS class def is inlined) and the old paraphrase is
gone. Footer social links resolve on `/`. Link sweep: no live `href` points at a `false`
route (preschool/this-week/connect/prayer/mental-health/five6 all render as disabled stubs);
only non-RccLink static internal link is `about.vue`'s `NuxtLink to="/visit"` → a live route.
Zero hardcoded colors in changed files. Responsive: give-grid → 1 col ≤860px, footer-bottom
stacks ≤560px. Browser eyeball deferred (no Chrome connected).

**Decisions needed → `needs-jason` issue (web):**
- Real destinations for two Give links currently de-linked to plain text: the
  **contribution-statement request form** ("complete our contact form, topic = Giving") and,
  if desired, a **historical-Breeze-donations** link. Both map to the future Connect Card /
  contact route (`/connect`, not built) — wire when that ships.
- Confirm the **"why we give" hero photo** (currently an Unsplash placeholder) → swap to a
  Glen Reed shoot asset when available.

---

## 2026-08-16 · Section 8 — About (story · beliefs · team · contact)

**Route shipped:** `/about` (`web/pages/about.vue`) → riverchristian.church deploy via
DigitalOcean App Platform on push to `web` `main` (commit `a87a189`). Registry `/about` flipped
to `true`, so the nav "About", footer "Our Team", and footer "Beliefs" `<RccLink>`s all went
live sitewide in the same change.

**What it is:** the live site's whole **About-Us** section is five separate WordPress pages —
`/who-we-are/`, `/our-story/`, `/what-we-believe/`, `/our-team/`, `/contact/`. This collapses
them into ONE tight, anchor-navigable page (5 bands):
1. **Hero — Who We Are.** Verbatim Restoration-Movement opener + WIN·TRAIN·UNLEASH mission
   pills + anchor buttons (#story / #beliefs).
2. **Our Story (#story).** The six-location **timeline** — Eagle Harbor Pool (Mar 2015, ~30) →
   Russell Haven of Rest **Cemetery** → **Funeral Home** → Wehner's Dance Studio (Easter 2018) →
   Saint John's Classical Academy (sprinkler burst) → 5900 US-17 (~1200+). Each milestone
   verbatim with its avg-attendance. Closes on the verbatim "Where We Are Headed" mission block.
3. **What We Believe (#beliefs).** 8-doctrine **accordion** (God · Jesus · Holy Spirit · Man ·
   The Bible · Baptism · Salvation · Eternity), each statement verbatim with its Scripture
   references rendered inline beneath.
4. **Our Team (#team).** 17 staff as compact accent-bar cards **grouped by department**
   (Pastoral / Kids & Preschool / Students / Office & Admin), bios verbatim, + the **Our Elders**
   board (Tim Collins · Nathan Freeman · Dennis Morrison · Tim Queen · Tony Rodriguez · Rick Wood).
5. **Contact (#contact).** Office address/phone/hours + **mailing PO Box 10075** + weekend
   service times, all read from `SITE` (siteConfig). "Send Us a Message" → Connect Card (soon).

**≥2 model borrowings (named):**
- **Fusion Christian Church** (audits — "`/about/` … mission #values, #beliefs, #staff on one
  page"): a single About page carrying mission/beliefs/staff as in-page anchors, not five pages.
  → RCC's five About-Us sub-pages collapse into one anchor-navigable `/about`, matching the
  condensed-pages rule.
- **Church of Eleven22** (coe22.com, our Jacksonville-area peer — audits notable: "Statement of
  Faith written inline on `/about` with per-claim scripture documentation"): each doctrine shows
  its supporting Scripture inline. → What We Believe accordion renders every belief's verbatim
  reference list beneath the statement.
- **Venture Christian Church** (audits — "`/staff-working` (Staff & Leaders + Elders…)"): staff
  and the elder board surfaced together. → Our Team pairs the staff directory with RCC's
  verbatim "Our Elders" governance list.

**DRAFT-flagged (invented copy):** none. Every prose block is verbatim RCC (grammar/flow only).
Section labels/titles and the department groupings under Our Team are editorial framing
(consistent with prior pages), not content copy — no chips. Consolidating five live pages into
one is the documented reason the page runs to 5 bands rather than ~4. Staff **emails** are
Cloudflare-obfuscated on the live site, so — as on Care — they are NOT reproduced or fabricated;
contact routes through the office phone + Connect Card.

**Validation:** `npm run build` passes; booted `.output/server` and curled `/about` → HTTP 200
with correct SSR (verified Restoration Movement, The Cemetery, Wehner's, 1200+, baptizo, full
staff, PO Box, mission pills, per-doctrine Scripture all render server-side). Accordion = 8
`<details>`, first `open`. Link sweep: only `<RccLink>` + in-page anchors + the always-live
`/visit` NuxtLink (matches the layout's Plan-a-Visit convention); no live `href` at a `false`
route; zero hardcoded colors (tokens only). **Browser-eyeballed** in Chrome at 645px — hero,
timeline spine, beliefs accordion, grouped team cards, and teal contact band all render clean.

**Decisions needed → `needs-jason` issue (web):**
- Real **Church Center / contact-form URL** to replace the `/connect` "soon" placeholder on the
  "Send Us a Message" CTA (live `/contact/` uses a WPForms form with a Topic dropdown:
  General / Outreach·Missions / LifeGroups / Care / Kids / Students / Giving / Technical). Ties
  into ADR-004 custom-forms build (batch #17) — until then it's a disabled stub.
- **This Week** (email-archive concept, part of the Section 8 line) is NOT built — it's a
  distinct concept and stays the `/this-week` supra stub. Confirm what it should be (Subsplash/
  Mailchimp archive embed vs. native list) before a future night builds it.

---

## 2026-08-15 · Section 7 — Care & Support (Special Needs deferred)

**Status:** shipped to `web` main (`e1c4762`). DigitalOcean auto-deploys from `main`.

**Shipped:** `/ministries/care` (`web/pages/ministries/care.vue`) — the Care Ministries
hub, ALL prose **verbatim** from the live `/ministries/care/`:
- **Care Services** (pastoral): *Hospital Visit* + *Counseling Referrals* — two cards.
- **Support Groups**: *Celebrate Recovery* (Fri 7 PM), *DivorceCare* (Mon 6:30, Portable 2),
  *GriefShare* (Tue 6:30, Portable 2) — scannable meeting cards leading with day/time/
  location/leaders, then the verbatim description. DivorceCare carries its own three-part
  "What to Expect" (Video with Experts / Discussion with Purpose / Personal Reflection).
- **Mental Health Resources** — a named live Care ministry; its page isn't built here yet,
  so it's a **stubbed `<RccLink>`** to `/ministries/care/mental-health` (renders "soon"),
  not the old WordPress page and not a 404.
- Registry: `/ministries/care` flipped **true** → the Ministries-hub Care card auto-enabled
  (its "Soon" badge dropped, no per-link edit). Close CTA routes to Connect Card + Prayer.

**Special Needs — NOT built (deliberate).** Section 7 paired Care with a Special Needs page,
but RCC has **no special-needs / buddy / accessibility content to source**: `/special-needs/`
and `/ministries/special-needs/` both 404, nothing in `serveTeams.ts`, no mention on Kids.
A page would be 100% invented → hard-rule violation. Filed **needs-jason issue
`RiverChristianChurch/web#25`** (models: Highlands "Highlands Haven", audits[8]) asking
whether RCC wants one and for real copy. Care & Support stands as the Section 7 deliverable.

**Model borrowings (≥2, named):**
- (1) **Motivation Church "Support & Recovery"** (`audits[2]`): one Care hub that pairs
  *pastoral* care (hospital visitation, referrals) with the *recovery/support* groups, each
  group carrying scannable logistics → RCC Care = two tiers ("Care Services" + "Support
  Groups"), every group card leading with day · time · location · leaders.
- (2) **Real Life Church Sacramento** Care page (`audits[4]`): "honestly outsources — named
  counseling partners + a plainly stated referral policy," not implied in-house clinical
  counseling → RCC's *Counseling Referrals* policy surfaced up front as an honest "we point
  you toward options, you choose" card, verbatim.

**DRAFT-flagged (invented copy):** none. All body copy is verbatim RCC (grammar/flow only —
e.g. "6 pm" → "6:00 PM", the meeting-logistics reformat). Section labels/titles ("From Crisis
to Community", "We're Here When Life Is Hard") are editorial framing, consistent with prior
ministry pages — not content copy, no chip. Leader **emails are obfuscated on the live site**,
so none reproduced (would be fabrication); contact routes via office phone + Connect Card.

**Validation:** `npm run build` passes; booted `.output/server` and curled
`/ministries/care/` → HTTP 200 with correct SSR (verbatim strings "from crisis to community",
"hurts and hangups", "15,000+ churches", "point you towards specific options" all present).
Link sweep across ALL pages: only `<RccLink>` + in-page anchors on the new page; **no live
`href` points at a `false` route** (`/connect`, `/ministries/prayer`, `/ministries/care/
mental-health` all render disabled "coming soon"). Zero hardcoded colors — all `var(--rcc-*)`
tokens (fixed two invalid `--rcc-muted`/`--rcc-border` → `--rcc-text-muted-dark`/
`--rcc-dark-border`). Responsive: care-services + What-to-Expect grids collapse to 1 col ≤768.
Browser eyeball deferred (no Chrome connected).

**Decisions needed → `needs-jason`:**
- **#25 — Special Needs**: does RCC have (or want) a special-needs/accessibility ministry, and
  the real copy? Off the site until answered.
- **Mental Health Resources** page: build it next (source = live `/mental-health/`), or link
  out? Currently a "soon" stub.

### Next up
Section 8 — **About** (story, beliefs, staff, contact, This Week email-archive concept).

---

## 2026-08-12 · PCO forms map + Serve page port + tonight's batch queued

**Status:** shipped to `web` main. Volunteer-app sunset continues; forms design locked.

- **PCO forms ↔ workflows mapping** (Jason asked, "you have access to PCO"): queried the live RCC
  Planning Center read-only (PAT from the volunteer app's env) and wrote
  `web/docs/reference/pco-forms-workflows.md` — every workflow (Baptism, Follow-Up Serve/LifeGroup/
  First-Time-Guest/Pastoral-Care/Membership, Attends Welcome…) + the website-form → workflow routing.
  **Key finding:** the PCO **Forms API can't accept submissions** and doesn't expose a form's
  workflow automation — so branded forms create **Person + Workflow card** directly (ADR-004 updated).
  A few routings are name-inferred → Jason confirms in the PCO Automations UI.
- **Serve page ported** (`/serve`) — sunsetting the volunteer app, its two public embeds move here:
  LifeGroups (done last session) + **Serve teams browse** now. `utils/serveTeams.ts` (verbatim RCC
  team content) + a category/card directory; "Join" → the real Church Center form (937439 → Serve @
  RCC workflow). `/serve` flipped ready — serve links across the site auto-enabled.
- **Auth placement decided** (ADR-002 updated): public **browse** (LifeGroups finder, Serve teams)
  stays public; the **onboarding/matrix/leader/admin/`/connect`** machinery folds into the **auth'd
  portal**. Cutover 301s once those reach parity.
- **Tonight queued** (Jason authorized multiple sessions): (1) scrape more sermon series + artwork,
  (2) build Sections 6–8, (3) full code audit + lint/typecheck to industry standard, (4) stand up a
  **pre-commit validation gate** (lint + typecheck + build) — see the 🌙 TONIGHT block in NIGHTLY-LOOP.
- **FA Free** wired earlier this day; **LifeGroups finder** ported earlier this day.

### Needs Jason
- Confirm the _(inferred)_ form→workflow routings + the **List IDs** for Men's/Women's signups
  (see the mapping doc). Set `NUXT_PCO_APP_ID/SECRET` in web env/Vercel to light up the live group
  finder + forms.

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

---

## 2026-08-13 — Section 6: Ministries — Students (REACH), Men, Women + MOMs

**Shipped (web `main`, commit `92e1cb3`; DigitalOcean deploys on push):**
- `/ministries/students` — RCC Students (REACH). Hero surfaces grade + both meeting
  times; PROGRAMS band = REACH (Sun 5:00–7:00) + GROW (Wed 6:30–8:00) verbatim;
  SERVE band (students-serve paragraph verbatim); close = Get Student Updates.
- `/ministries/men` — mission statement verbatim; UNCOMMON GROUPS band with the real
  four-block Sample Meeting Agenda; STUDIES band (Four-Week Daniel Study, Authentic
  Manhood resources); close = Get Email/Text Updates.
- `/ministries/women` — mission verbatim + John 15:5(a) pull-quote; **MOMs** folded in
  as the substantive band: Mentoring of Moms (Titus 2:4) verbatim, STARVED study by
  Amy Seiffert + its 4 practices, and a registration card ($32 · 2026 semester dates ·
  limited childcare · opens 8/1/26).
- routeRegistry: `students`/`men`/`women` flipped `true` (hub cards + every sitewide
  `<RccLink>` auto-enable). Hub Men/Women blurbs re-sourced from real mission copy
  (two DRAFT chips dropped).

**Model borrowings (≥2 per page, named):**
- *Students* — (1) **Venture Christian** `/students`: two clearly-labeled programs split
  by meeting (ELEVATE MS / MOMENTUM HS) → RCC REACH (Sun) + GROW (Wed) as two program
  cards each carrying day/time/grade meta. (2) **E91 Students**: lead with grade range +
  meeting time in the hero so "who + when" reads before scrolling.
- *Men* — (1) **Seacoast Church**: keeps a *dedicated* Men page under Ministries (not a
  generic `/adults` hub) → standalone `/men` leading with its own mission statement.
  (2) **Motivation (Motivation Men)**: mission-statement hero + a single "join a group"
  CTA repeated top & bottom, updates via Church Center → "Find an Uncommon Group" +
  "Get Email/Text Updates."
- *Women/MOMs* — (1) **Seacoast**: separate Women page under Ministries → dedicated page
  w/ mission + scripture. (2) **Fusion / Motivation**: study registration surfaced with
  concrete dates + cost and a register CTA → RCC's real MOMs $32 / 2026-dates / childcare
  block instead of a vague "sign up."

**DRAFT-flagged (invented copy):** none. All body copy is verbatim RCC (grammar/flow only).
Section labels/titles are editorial framing (consistent with prior ministry pages), not
content copy. MOMs was *folded* from its own live nav page into a band on Women — pure
editorial condensing (no chip, per the omission rule).

**Validation:** `npm run build` passes; booted `.output/server` and curled all four routes
(students/men/women/hub) → HTTP 200 with correct SSR content per page. Link sweep: new pages
use only `<RccLink>` + in-page anchors (no bare NuxtLink/href); no live `href` points at a
`false` route across all built pages. Zero hardcoded colors — swapped my rgba/px literals for
`var(--rcc-dark-border)` / `var(--rcc-radius)` tokens. Responsive rule added (MOMs grid
collapses to 1 col ≤768). Browser eyeball deferred (no Chrome connected).

**Decisions needed → `needs-jason` issue (web):**
- Real **Church Center URLs** to replace the `/connect` "soon" placeholders on all join CTAs:
  Men "Find an Uncommon Group" (live page = email-the-leader), **MOMs "Register"** (live
  "Register HERe" → Church Center form; registration opens 8/1/26), and the three
  "Get Updates" email-signup CTAs. Until wired they render as disabled "soon" stubs.
- Confirm **MOMs stays folded into Women** (live site lists it as its own top-nav item) vs.
  breaking out a standalone `/ministries/moms` page.

### Next up
Section 7 — **Special Needs** (full page; model Highlands/Seacoast) + **Care & Support**.

## 2026-08-18 · Priority item — PWA (installable web app, ADR-007)

**Shipped:** `web` `main` @ `4c928a7` (DigitalOcean auto-deploys). Not a content
section — this is the mobile strategy: the site is now an **installable PWA** (no
native app, no store wrapper — ADR-007).

- **Module:** `@vite-pwa/nuxt@1.1.1` added to `nuxt.config.ts` (`modules` + a `pwa {}`
  block). `registerType: 'autoUpdate'`.
- **Manifest** (`/manifest.webmanifest`, served 200): name "River Christian Church" /
  short_name **"River"**, `display: standalone`, `theme_color #063d54` (`--rcc-brand-dark`,
  matches the deep-teal header), `background_color #095879` (`--rcc-brand`, seamless with
  the icon field on the splash), scope `/`, start_url `/`, + 4 home-screen **shortcuts**
  (Plan a Visit / Watch / Events / Give).
- **Service worker** (`/sw.js`, served 200): Workbox precache of the built app shell —
  `globPatterns: **/*.{js,css,html,svg,png,ico,woff2}`, `navigateFallback: '/'`,
  `cleanupOutdatedCaches`. This is the offline / weak-worship-center-signal cache.
- **Icons:** new regenerable `web/scripts/generate-pwa-icons.mjs` (devDep `sharp`) renders
  the ui-shell **waves mark** (white) centered on the brand-teal field → `web/public/icons/`:
  `pwa-192x192`, `pwa-512x512` (`any`), `maskable-512x512` (extra safe-zone padding),
  `apple-touch-icon` (180, opaque teal), `favicon-{16,32}`. No hardcoded colors in CSS —
  the two hex values live only in the JSON manifest / `theme-color` meta (manifests can't
  reference CSS vars), sourced from the ui-shell tokens and documented in comments.
- **Head:** `<link rel="manifest">` is **server-rendered** via `<VitePwaManifest>` placed in
  `app.vue` (the module only registers it globally — it must be mounted to hit SSR);
  `theme-color`, `apple-mobile-web-app-*`, `apple-touch-icon` + PNG favicons in `app.head`.
- **ADR-007** flipped `Implementation: Not yet started → Done (2026-08-18)` with the full
  what-shipped record (same commit).

**Model borrowings (≥2, named — from live-cohort manifests/meta):**
- **Venture Christian Church** — ships a declared `theme-color` + a home-screen icon that is
  the **icon-tier logo *mark*** (`VCC-Logo_icon-duotone-dark.png` — the glyph, not the
  wordmark). RCC mirrors this exactly: the **waves mark** on a solid brand-teal field as the
  app icon, plus a brand-dark `theme_color`, rather than cramming the full logo into a tile.
- **Fusion, Motivation, Brooklake** — each ships a dedicated **180×180 "webclip" /
  `apple-touch-icon`** so iOS *Add to Home Screen* yields a branded rounded tile (not a page
  screenshot). RCC ships `apple-touch-icon.png` (180, opaque teal) for the same reason.

**DRAFT-flagged (invented copy):** none — no page copy touched (infra-only change).

**Validation:** `npm run build` passes. Booted `.output/server/index.mjs` →
`manifest.webmanifest` + `sw.js` both `200`; SSR HTML carries the manifest link +
`theme-color #063d54` + apple-touch/apple-mobile-web-app tags; client bundle registers
`navigator.serviceWorker`; all icons render correctly (verified visually). Link sweep clean
(no live href → `false` route). **Real-device install NOT verified** — the nightly run's
connected Chrome is not co-located with dd-mini's dev server (localhost unreachable from it),
so the on-device "Add to Home Screen" + standalone-launch screenshot is deferred.

**Decisions needed → `needs-jason` issue (web):**
- **Install + screenshot on a real phone** (iOS Share → Add to Home Screen; Android install
  prompt): confirm the home-screen icon renders as the teal waves tile and the app launches
  fullscreen/standalone with the deep-teal status bar. This is the last acceptance step the
  ADR requires and the only thing the autonomous run can't do.

## 2026-08-19 · Section 10 — Portal deepening (role dashboard shell)

**Shipped:** `web` `main` @ `d68c4ef` (DigitalOcean auto-deploys). Route: **`/portal`**
(noindex). Not a public content page — this is the signed-in **Member Portal** shell:
one page, two audiences (CLAUDE.md principle #2).

- **Guest state (the real front door):** sign-in gate — "Sign in with Planning Center"
  CTA (disabled + `soon` until ADR-006 auth is wired) beside a `.rcc-portal-features`
  list of what signing in unlocks (Next Steps / Groups / Serving / Giving / This
  Weekend). Links to the migrating volunteer portal (ADR-002).
- **Authed state (role-differentiated dashboard):** `.rcc-dash-grid` cards that change
  per role — **member / volunteer / leader / staff**:
  - **Your Next Steps** — members see a Growth Track prompt; servers (volunteer+) see the
    ported onboarding checklist w/ progress bar + `n/5` pill.
  - **Your Groups** — "find a group" (not in one) vs. group name + meeting time (in one).
  - **Serving** — "explore teams" vs. team list; leaders also get a Team-roster action.
  - **Giving** — Give now + **My giving** (both → Subsplash; Eleven22 "My Giving" pattern).
  - **This Weekend** — service times from `SITE.services` + Watch/Visit links.
  - **Leader Tools / Staff Tools** — role-gated admin cards (roster, website tickets,
    graphics requests) as disabled phase-2 stubs.
- **The auth seam:** all state flows through a new `usePortalSession()` composable. Today
  it returns **guest** by default and **representative role fixtures via `?preview=<role>`**
  (visible amber Preview notice + role switcher). When ADR-006 ships, swap that composable's
  body for a `GET /api/auth/session` fetch — the page template and every card stay identical.
  Onboarding checklist labels are VERBATIM from the production volunteer app (ADR-002).
- ui-shell already shipped the full dashboard vocabulary (`.rcc-dash-*`, `.rcc-checklist`,
  `.rcc-progress`, pills, `.rcc-portal-*`, `.rcc-avatar`) — **reused as-is, no ui-shell
  change / no tag bump.** Added FA icons only (web `plugins/fontawesome.ts`).

**Model borrowings (≥2, named):** The single-site cohort (E91, Venture, Fusion, Brooklake,
Motivation, Real Life) deliberately has **no member portal / sign-in** — they push the
signed-in experience entirely into Church Center / Subsplash apps (an audit finding in its
own right). The portal pattern is therefore sourced from the **multi-site cohort**:
- **Church of Eleven22** — utility-nav Login + a **profile dropdown (My Account / My Giving
  (Pushpay) / Logout)**. RCC mirrors this: a signed-in profile chip (avatar + name + role
  pill) with Sign out, and **"My giving"** surfaced as a first-class card action → the
  member's real Subsplash giving portal (no shadow store — matches ADR-001/006).
- **Seacoast Church** — a **named, branded member portal ("My Seacoast")** as the signed-in
  home, distinct from public nav. RCC's `/portal` is that branded signed-in home rather than
  a bare login redirect (the prior stub).
- **Cohort-wide pattern — Church Center as one back office** ("one back office, zero custom
  forms … so data lands in one platform"): every dashboard card links into the member's real
  Church Center / Subsplash surface (give, groups, serve, watch) instead of a mirrored DB.

**DRAFT-flagged (invented copy):** the portal is a NEW app surface with **no live-site copy**
to draw from, so all wording is UI microcopy authored here. It is disclosed two ways rather
than chipping every line: (1) an inline `.rcc-draft-chip` on the one substantive claim
("no separate account/password") citing ADR-006; (2) a page-level amber `.rcc-draft`
**Preview** notice on the authed state. Preview person names + sample groups/teams are
representative scaffolding (not real member data, not church content).

**Validation:** `npm run build` passes. Booted `.output/server` and curled **all four states**
(`/portal` guest + `?preview=member|volunteer|leader|staff`) → HTTP 200 with the correct
per-role SSR content (Growth Track vs. checklist, group present/absent, serve teams, staff
tools, verbatim onboarding steps). Link sweep: phase-2 admin routes render as `.rcc-link-soon`
disabled stubs; **no live `href` points at a `false` route** on any portal state or any other
built page. Responsive: `.rcc-dash-grid` → 2 cols @1024 → 1 col @768 (ui-shell media queries).
**Zero hardcoded colors** (scoped styles use only `var(--rcc-*)` tokens). Browser eyeball
deferred (nightly Chrome not co-located with dd-mini's dev server).

**Decisions needed → `needs-jason` issue (web):**
- **ADR-006 (auth) is the blocker for going live.** To turn the gate on and swap fixtures for
  real data, need: the PCO OAuth app registered (`NUXT_PCO_OAUTH_CLIENT_ID/SECRET` + redirect
  URIs) and a **Church-Center-only test account** for the pre-build verification. Until then
  the portal ships as the reviewable shell.
- Confirm the **role → PCO mapping** draft (People-app permission → staff; leads a group/team →
  leader; on any serve team → volunteer; else member) before wiring role resolution.
- Confirm "My giving" should point at the Subsplash access portal (`SITE.givingUrl`) vs. a
  future Church Center giving link.

### Next up
Section 11 — **Home polish + cross-linking + mobile QA sweep** (the last queued section).

## 2026-08-20 · Section 11 — Home polish + cross-linking + mobile QA sweep

**Route shipped:** `/` (`web/pages/index.vue`) — DigitalOcean App Platform auto-deploys
from `main` (ADR-005). Commit `f839ca2`.

**What shipped.** The home page was **hero-only**. Section 11 builds it into the site's
front door + the primary cross-linking hub that routes into every section shipped across
the run. Kept the approved hero (mission tagline + weekend times over the church's own
home video) and added three tight bands below it:

1. **Start Here** — 4 quick-action tiles → `/visit`, `/watch`, `/next-steps`, `/give`.
2. **Ministries — "There's a Place for You"** — a 7-card showcase → the six built ministry
   pages (Kids, Students, Men, Women, Care & Support, Outreach & Missions) + LifeGroups
   (`/groups`), plus a "See All Ministries" → `/ministries`. Card blurbs **reuse the
   RCC-sourced one-liners already on the `/ministries` hub** — no new copy invented here.
3. **Join Us This Sunday** — closing visit CTA. The online line is **VERBATIM** from the
   live home-page Church Online callout ("Join us online on Sunday mornings at 10:00 or
   11:30 AM"); the service-times card reads from `SITE` (utils/siteConfig.ts — one source
   of truth), so a time change happens in one place.

**≥2 model borrowings.**
- **E91** — "quick action tiles (I'm New / Connect / Mission & Vision)" under the hero →
  the **Start Here** band.
- **Fusion** — "connect cards ×5 (Kids, Youth, Groups, Serve, Next Steps)" anchoring the
  home page into each ministry → the **Ministries grid** pattern.
- **Motivation / Real Life Sac / Seacoast** — the "Join Our Community" / "Get Connected"
  ministry-card showcase + a **"Join Us This Sunday"** visit CTA with service times →
  the Ministries grid + the closing band.
- **Venture** — "Plan Your Visit w/ service times (9:30 & 11:00a)" block → the closing
  **service-times card**.

**Cross-linking / link sweep (step 5b).** Converted the last bare static internal links
to `<RccLink>`: `about.vue` Plan-a-Visit, and the layout **Sign In / Plan a Visit** nav
buttons (grep for `NuxtLink to="/"|href="/"` in pages+layouts is now clean except the
logo link + the `/portal` self sign-out). Booted the build and verified across **all 18
built pages**: **no live `href` points at any `false`-registry route** (exact
href∩false-set intersection = empty). New home links all target built routes; unbuilt
targets (Connect Card, Preschool, This Week, etc.) are only ever reached via `<RccLink>`,
which renders them disabled.

**DRAFT-flagged.** One chip added: the hero's carried-over welcome sentence ("Join us this
weekend in Fleming Island … through the love of Jesus") is **invented** — the live home
hero shows only the mission tagline + service times, so there's no verbatim source. Chip
`data-note` says to replace with RCC's approved hero line or cut it. This corrects a
pre-existing unflagged violation from an earlier build. No other invented copy on the page.

**Validation.** `npm run build` passes. Booted `.output/server` and curled `/` → SSR renders
all real content (Start Here, "There's a Place for You", "Join Us This Sunday", the verbatim
online line, all ministry cards). Responsive: `.rcc-home-tiles` has explicit breakpoints
(4→2 @1024 →1 @560); the closing `.rcc-portal-grid` collapses to 1-col @1024 and
`.rcc-hero-meta` hides @768 (ui-shell). **Zero hardcoded colors** (scoped CSS uses only
`var(--rcc-*)`); no emoji. **No ui-shell change needed** — reused existing classes; only
scoped page CSS added.

**Constraint noted (not a silent cap).** The nightly Chrome window would not resize below
~1200px in this environment, so a true phone-width visual capture wasn't possible. Verified
the responsive CSS is present and correct instead (same shared ui-shell breakpoints already
eyeballed at 768/1024 on prior nights + the page's own scoped queries). Desktop was captured
and looks right. A real-device eyeball is a good candidate for Jason's morning pass.

**Decisions needed → Jason.** None new blocking this section. The **Section queue is now
COMPLETE (1–11)** — the open cross-site blocker remains **ADR-006 (PCO OAuth)**, which gates
the portal, custom forms, and the Connect Card (already tracked). The hero welcome line needs
Jason's approved copy or a cut (DRAFT chip on `/`). Filed a `needs-jason` issue for the home
hero line.

### Next up
**Section queue complete (1–11).** No unchecked Section or Rework item remains. Next nightly
runs should either (a) take a newly-queued item Jason adds, or (b) shift from "build sections"
to **polish/QA passes** — real-device mobile sweep, the ADR-006 auth build (unblocks portal +
forms + Connect Card), and the phase-2 portal tools (web#18/#20/#21). Await Jason's direction.

## 2026-08-22 · FIVE 6 — preteen ministry as its own page (web#24)

**Route shipped:** `/ministries/five6` (`web/pages/ministries/five6.vue`, new) — DigitalOcean
App Platform auto-deploys from `main` (ADR-005). Commit `3e82987`.

**Context.** The Section queue (1–11) and the Rework queue are complete; every remaining
`needs-jason` / auth-gated item (portal go-live, custom forms, ticket + graphics queues) is
blocked on **ADR-006 (PCO OAuth)**. The first *non-blocked, content-forward* item is the
`enhancement` issue **web#24 — split FIVE 6 out of the Kids page into its own ministry page**
(verbatim copy already exists; the hub already had a FIVE 6 directory card wired to
`/ministries/five6` rendering as a "soon" stub). Took that.

**What shipped.** A tight, 5-band FIVE 6 page for RCC's preteen (5th & 6th grade) ministry:
1. **Hero** — grade range + service times surfaced; hero sub is the verbatim opening line.
2. **About** — the **full verbatim 3-paragraph FIVE 6 description** from `/ministries/kids/#five6`
   ("A preteen ministry can be a very powerful place…" through "…builds a bridge to the next step
   of their lives and faith journeys."), on a ~68ch readable measure.
3. **Check-in** — DRAFT (E91 + Venture borrow), the same reviewed pattern the Kids page carries.
4. **The Pathway — "A Bridge to the Next Step"** — Kids (Birth–4th) → FIVE 6 (5th–6th) → REACH
   (7th–12th), cross-linking `/ministries/kids` and `/ministries/students`.
5. **Close** — parent connect (email/Facebook/resources) + `RccMinistryEvents`.

**Verbatim fidelity + a latent violation fixed.** All ministry prose on the new page is verbatim;
only the check-in band is invented and it's DRAFT-chipped. Card blurbs in the pathway band are pure
category labels ("Children's ministry", "Student ministry") + a nav cue, not reworded site prose.
**Fixed a pre-existing violation on the Kids page:** its FIVE 6 blurb had a *paraphrased* second
paragraph with **no DRAFT chip**. Replaced it with the verbatim opening sentence + an "Explore
FIVE 6 →" pointer to the new page (removes the reword; adds the cross-link).

**≥2 model borrowings.**
- **E91 + Venture** — kids **check-in** ("kiosk opens ~10 min early, online pre-registration,
  name-tag/security-tag match, text-paging"). web#24 explicitly asks to "borrow Kids check-in";
  preteens check in through the same RCC Kids system → the FIVE 6 check-in band (DRAFT).
- **E91 / Venture** — lead the hero with **"who + when"** (grade range + service times) so a parent
  knows fit + timing before scrolling → FIVE 6 hero meta.
- **Cohort ministry-pathway pattern** (Kids → preteen → students shown as a progression) → the
  **"Bridge to the Next Step"** band. RCC's own verbatim copy frames FIVE 6 as a "two-year
  transitional period" that "builds a bridge to the next step," so the framing is the site's.

**DRAFT-flagged.** One band: the FIVE 6 **check-in** flow (chip + `data-note` citing E91/Venture and
asking Jason to confirm RCC's real kiosk timing / tag-match / paging). No other invented copy.

**Link validation (step 5b).** `/ministries/five6` flipped to `true` in `utils/routeRegistry.ts`
→ the hub FIVE 6 card and the Kids pointer both auto-enabled (verified live NuxtLinks, not stubs).
Swept all **18** built pages against the served HTML: **no live `href` points at any `false`-registry
route** (`/connect`, `/preschool`, `/this-week`, `/ministries/prayer`, `/ministries/care/mental-health`,
`/portal/{team,tickets,graphics}` all only reachable via disabled `<RccLink>`).

**Validation.** `npm run lint` = 0 errors (4 pre-existing boundary `any` warnings). `npm run typecheck`
clean. `npm run build` passes. Booted `.output/server` and curled `/ministries/five6` → SSR renders
all real content (About verbatim paras, pathway, check-in). Zero hardcoded colors (scoped CSS uses
only `var(--rcc-*)`); no emoji; steps collapse to 1-col ≤768px.

**Decisions needed → Jason.** (1) Confirm the FIVE 6 **check-in** process (or that FIVE 6 uses the
same RCC Kids check-in) so the DRAFT chip can drop — same open question as the Kids page. (2) Nothing
else new. The site-wide blocker remains **ADR-006 (PCO OAuth)**.

### Next up
No unchecked Section or Rework item remains. Non-blocked `enhancement` candidates still open:
**web#23** (file storage for ministry resources — needs a storage backend decision) and **web#7**
(native sermon archive + YouTube ingest). Everything else waiting on Jason is the **ADR-006 auth
POC** (gates portal go-live, custom forms, ticket/graphics queues). Await Jason's direction on
which non-blocked build to take, or the auth POC session.

## 2026-08-25 · web#7 (archive half) — the real sermon archive: 291 messages, filterable, SSR'd

**Shipped.** `web` `c29fe0b` → `main`, pushed; DigitalOcean App Platform auto-deploys (ADR-005).
Routes: `/watch` (rebuilt archive band), **`/watch/series`** (new series index),
`/watch/series/[slug]`, `/watch/[slug]` (rebuilt detail).

**Context / queue state.** The loop file was two nights stale: **web#23 shipped 2026-08-23**
(`3f660bd` + ADR-008 Accepted `a92fdb7` — Supabase-backed ministry resource library) but its box
was never checked and no report was written. Verified against the commits and checked it off.
That made **web#7** the first unchecked, non-blocked item. Its YouTube-ingest half is gated on
`YT_API_KEY`/`YT_CHANNEL_ID` (web#10, needs-jason) — but the **archive half needs neither**, and
it was the piece actually holding `/watch` back: the page was rendering **three fake sample
records**. Took that.

**What shipped.**
1. **The real catalog — 291 messages, 65 series, 2021-01-03 → 2026-08-09.** New
   `scripts/manifest-catalog.mjs` turns the captured 352-entry Subsplash manifest into
   `content/sermons/*.json`: title, series, speaker, date, Scripture refs and the published
   **note outline**, all verbatim RCC. It also downloads each **unique** series graphic once and
   downsamples it to an 800px JPEG — Subsplash serves `_source` PNGs, so this is **109 MB → 5.2 MB**
   for the same 65 graphics. Deterministic, no AI: series is the manifest field, else a
   `"Series - Title"` split accepted **only** when the prefix exactly matches a series the manifest
   already names; speaker strips a leading `"Pastor "` so the filter doesn't list one person twice.
2. **A compact index so 300 records don't ship as 350 KB of prose.** `build-sermon-index.mjs`
   projects the records into `content/sermons-index.json` (~97 KB raw, ~25 KB gzipped) which the
   listing pages import; the full record lazy-loads on the detail page only. Wired into
   `npm run dev` / `build` / `generate`, so the index **cannot drift** from the records.
3. **`/watch` archive band** — `RccSermonArchive.vue`: keyword search + Series / Speaker / Year
   selects + result count + Reset, over text-first rows (date cell · title · series·speaker·Scripture),
   24 at a time behind **Load More**. The flat 65-card series wall moved to a recent-8 strip with
   "All 65 series →".
4. **`/watch/series`** — new series index with its own find-a-series box, real artwork, year span
   and message counts.
5. **`/watch/[slug]`** — renders the **Message Notes** outline (RCC's own published outline, verbatim),
   prev/next within the series, and interim playback from the church's own Subsplash media when a
   record has no `youtubeId` yet. Also fixed a latent ui-shell trap: `.rcc-message-video::after`
   paints a 30% scrim + pointer cursor for a *poster tile* — over a real player it dims the video and
   **swallows every click**. A `.rcc-player` container now drops both.
6. **Series pages read oldest→newest** (a series is taught in order; the index is newest-first).

**≥2 model borrowings** (all from `docs/research/church-site-audits-2026-08.json`):
- **Real Life Church Sacramento** — *"On-site sermon archive with three-way filtering (Series /
  Speaker / Date) instead of dumping visitors to YouTube"* → the archive filter bar.
- **E91** — *"/watch searchable archive filtered by series, speaker, topic; per-sermon detail pages"*
  → the keyword search across the archive + the find-a-series box on `/watch/series`.
- **Motivation Church** — *"flat chronological tile grid w/ Load More; detail page has YouTube embed
  + PDF notes + response CTAs"* → Load More pagination (291 rows is not a scroll wall) and the
  detail page's notes-plus-next-steps layout.
- **Brooklake** — *"list archive w/ title, speaker, date, scripture… browsable by series"* + dedicated
  `/series/<slug>/` pages → Scripture on every row and the series index behind them.
- And the audit's finding about **RCC's own site** — *"Core content (events calendar, sermons/messages)
  exists only as Subsplash JS embeds — zero SEO/no-JS visibility"* — is what this closes for sermons.

**DRAFT-flagged: none — and three chips REMOVED.** Every word on these pages is RCC's own: the titles,
series names, speakers, Scripture references and note outlines came out of the church's own media
library. The old sample-record DRAFT chips on `/watch` and `/watch/series/[slug]` are gone because the
samples are gone. Two mechanical, non-editorial normalizations are worth naming: descriptions were
whitespace-collapsed (the embed's ragged indentation; **not one word changed**), and the card/meta
blurb is the message's **first published note line verbatim** — never a rewrite or a truncation.

**Not built / excluded.** 61 of the 352 captures are thin (filename-ish titles, no date/speaker/art)
and are excluded rather than shown as junk — see web#31. Their data is preserved in the committed
`content/subsplash-unmatched.json` because the manifest itself is gitignored.

**Link validation (step 5b).** `/watch/series` flipped to `true` in `utils/routeRegistry.ts`. Swept the
20 built pages against served HTML: **no live `href` points at any `false` route** (`/connect`,
`/preschool`, `/this-week`, `/ministries/prayer`, `/ministries/care/mental-health`,
`/portal/{team,tickets,graphics}`). Every `RccLink` target resolves in the registry. Dynamic
`/watch/<slug>` and `/watch/series/<slug>` links stay `NuxtLink` per the rule; an unknown slug 404s.

**Validation.** `npm run lint` 0 errors (4 pre-existing boundary `any` warnings) · `npm run typecheck`
clean · `npm run build` passes · booted `.output/server` and curled every route: SSR renders the real
archive (26 rows + "Load More (267 left)" in the HTML), the series index, a series page in teaching
order, and a detail page with its full note outline. Artwork serves 200 `image/jpeg`. Zero hardcoded
colors. Browser QA at 768px: filters wrap 2-up, rows read cleanly, real series art renders.

**Decisions needed → Jason.**
1. **web#10 / YouTube ingest (the other half of web#7)** — still the blocker for durable media.
   `sync-youtube.mjs` + `upload-youtube.mjs` are written and waiting on `YT_API_KEY` +
   a **confirmed** `YT_CHANNEL_ID` (several similarly-named channels exist). Until then the site
   plays Subsplash CDN files that die at contract end.
2. **web#32** — press play on a message in a normal browser and confirm it starts. The file is a
   fast-start MP4 and the CDN answers range requests in ~114 ms, but playback would not start inside
   the nightly automation browser (`readyState` stuck at 0), and I can't tell from here whether that's
   the sandbox or the file. If it doesn't play for real people, I'll default the page to the audio tab.
3. **web#31** — worth a second capture pass for the 61 undated messages, or let them go?

### Next up
`web#7`'s YouTube-ingest half (blocked on web#10). Non-blocked alternatives: nothing left in the
Section/Rework queues; remaining enhancements (web#17/#18/#19/#20) are all gated on **ADR-006 (PCO
OAuth)**, which is still the single biggest unblock for this project.

## 2026-08-27 · Prayer (`/ministries/prayer`) — rhythms first, then how to ask

**Shipped:** `web/pages/ministries/prayer.vue` + `web/public/img/prayer-hero.jpg`
(web `7fd3e52`, pushed to `main` → DigitalOcean App Platform deploys on push).
Route: **`/ministries/prayer`**.

This was the last Care & Support route that existed only as a disabled stub. Four
bands, per the condensed rule:

1. **Hero** — RCC's own *Night of Worship* photo (literally the live prayer page's
   own hero image, pulled from `wp-content/uploads/2021/08/`, downsampled to 1800px
   / 300 KB), Galatians 6:2 verbatim as the sub, `Request Prayer` + `Care & Support`.
2. **How We Pray** — the Prayer Team paragraph verbatim, then the church's three
   actual rhythms: *every service* · *every week, over every submitted request* ·
   *together in the Worship Center* (day/time/place from `SITE.prayer`, so a change
   is one edit sitewide).
3. **Request Prayer** (`#request`) — the live page's three pathways, verbatim, at
   equal weight, closing with "All requests are handled with compassion and
   discretion" + the office phone.
4. **Join the Prayer Team** — the serve-team record verbatim (leader John Pratt ·
   Weekend Services · Flexible), CTAs to `/serve` and `/next-steps`.

**Model borrowings (4, cohort singles):**

1. **Brooklake Church `/prayer`** (audits[5]: *"describes prayer culture and rhythms;
   requests go through the app's Prayer Thread"*) → RCC's page leads with **How We
   Pray** and names the rhythms *before* it asks for anything. The page is about the
   church's prayer life, not a submission funnel.
2. **E91 `/prayer`** (audits[2]: *"'How Can We Pray for You?' custom web form on
   /prayer"*) → the ask stays **on RCC's own site** rather than bouncing to Church
   Center, and the pastoral **follow-up option** is stated up front instead of being
   a surprise field. (The form itself is the one DRAFT — see below.)
3. **Fusion Christian Church** (audits[3], recorded as a **weakness**: *"/prayer/ page
   is orphaned — a working prayer form not reachable from any menu"*) → shipping this
   route flipped `/ministries/prayer` → `true` in the registry, which auto-enabled the
   ministries-hub Prayer card and the Care page's "Request Prayer" CTA; I also added a
   **Next Steps → prayer** cross-link. Three entrances, zero orphan.
4. **Real Life Church Sacramento** (audits[1]: *"prayer text line promoted in the
   footer sitewide — very low-friction care entry point"*) → the three pathways are
   parallel cards of equal weight with the **office phone** right underneath, so the
   page is never form-or-nothing.

**DRAFT-flagged (1):**

- **"Send it from here"** pathway. The live page's third bullet is *"Complete the form
  below."* — an inline Gravity Form (Name; *"Would you like a pastor to follow up with
  you?"* → No Thank You / Phone / Email; Prayer Request). That native form isn't built
  (ADR-004: custom branded forms → PCO, workflow IDs pending), so the pathway carries a
  `.rcc-draft-chip` and routes to the Connect Card — the same treatment `/next-steps`
  already uses. **→ web#37 (needs-jason).**

**Deviations from live copy, both deliberate:**

- Weekly prayer time renders **"on Wednesdays"** (`SITE.prayer.day`, confirmed by Jason
  2026-08-12) where the live page says "each week" and names no day. Same as the
  `/next-steps` prayer band; not chipped, on the same reasoning.
- **Omissions (editorial, no chip):** the live page's Growth Track band (already the
  spine of `/next-steps`) and its "Want More Information?" obfuscated mailto — no email
  is reproduced anywhere in this repo, same rule as `/ministries/care`.

**Validation:** `npm run lint` (0 errors, the 4 known boundary `any` warnings) ·
`npm run typecheck` clean · `npm run build` passes · booted `.output/server/index.mjs`
and confirmed SSR renders the real content at `/ministries/prayer` (200) and the hero
photo serves (200). **Link sweep (5b):** curled all 21 built routes — every one 200,
and no live `href` points at any `false` route (`/connect`, `/preschool`, `/this-week`,
`/ministries/care/mental-health`, `/portal/{team,tickets,graphics}`). The three
remaining bare `<NuxtLink>`s (layout logo → `/`, portal sign-out → `/portal`, ministry
events → `/events`) all target live routes. No hardcoded colors; no new ui-shell
tokens needed, so **no tag bump** this night. Browser-verified at 1350px (hero H1 was
initially all-accent over the photo and read low-contrast — changed to plain white,
matching the live page's own `PRAYER` H1).

**Decisions needed (Jason):**

- **web#37 (new, needs-jason)** — where a prayer request should land in PCO (workflow
  vs. form vs. Prayer-Team list), the ID, who gets notified, whether the follow-up
  opt-in becomes a PCO field, and whether requests should be visibility-restricted to
  the Prayer Team. This is the **first** ADR-004 custom form, so it sets the pattern.
- **web#38 (new)** — queued as the next build: `/ministries/care/mental-health`, the
  last Care & Support stub. Flagged there: the live page's intro carries a **broken
  crisis number** (`899-273-8255`; the correct `800-273-8255` appears further down the
  same page) and a wrong Scripture cite ("Mathew 28:11" for Matthew 11:28). Both get
  fixed + chipped rather than shipped verbatim.
