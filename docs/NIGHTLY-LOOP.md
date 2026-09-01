# Nightly Iteration Loop — RCC Website

Build the new riverchristian.church section-by-section as **real Nuxt pages in the
`web` repo** (`~/dev/rcc/web`), consuming this design system's tokens/components.
One top-level section per night; Jason reviews each morning. Cairn-style: iterate
autonomously, ship, report, stop.

> **Build target = `web` (decided 2026-08-08).** Earlier nights produced static
> mockups in `ui-shell/beta/` — that's retired. New sections ship as `web/pages/*.vue`
> (+ `web/components/*` as needed). `ui-shell` stays the design source of truth: only
> touch it to add/adjust shared tokens/components, and when you do, **bump the tag and
> re-point `web`** (see Build step). The `ui-shell/beta/` mockups remain as design
> reference only. Section 1 (Visit) is live at `web/pages/visit.vue`.

## Inputs (read every night)

- This file — the queue below is the state
- `web` repo conventions: `layouts/default.vue` (nav/footer/supra), `pages/`, `nuxt.config.ts`, `tailwind.config.ts`, `CLAUDE.md`
- Sitemap (target IA + statuses): https://claude.ai/code/artifact/8f944e6e-eb71-4f83-9e4a-61e3445562c0
- BRAIN: `50-RCC/5010-Projects/Website-Feature-Inventory.md` (feature calls) + `Website-Rebuild.md` (decisions)
- **Real serve-team + ministry write-ups** (verbatim RCC copy): the volunteer repo's
  `~/dev/rcc/volunteer/src/data/serveTeams.ts` (5 categories, ~20 teams with
  descriptions/leaders). Use it to source ministry blurbs instead of inventing.
- **Forms pattern (confirmed 2026-08-12):** the current site uses **PCO Church Center
  hosted forms** (e.g. serve = `churchcenter.com/people/forms/937439`) and **Subsplash**
  for giving. So a form here = embed/link the Church Center form OR build a branded
  Nuxt form → Nitro server route → PCO People API. **Decided: custom branded forms →
  PCO (ADR-004).** First build = Connect Card + prayer request; needs the PCO workflow
  IDs from Jason. Kids grade: RCC Kids = Birth–4th; FIVE 6 = 5th–6th "tween" (separate).
- **LifeGroups finder is ported** (`/groups`) from the volunteer app — PCO Groups via
  `web/server/api/groups.get.ts` + a Leaflet finder. Goes live once `NUXT_PCO_APP_ID/SECRET`
  are set. Same PCO-Groups pattern the live site embeds. All settled 2026-08-12.
- Brand guide: `brand/index.html` (live at /ui-shell/brand/) — tokens, type, logo tiers, accent (pending lock: use `--rcc-accent`)
- Model-site raw audits: `~/dev/rcc/web/docs/research/church-site-audits-2026-08.json`
- Current-site content source: https://riverchristian.church

## 🌙 TONIGHT — overnight batch (queued 2026-08-12 by Jason; multiple sessions OK)

Jason authorized **multiple autonomous sessions tonight** to tackle this batch. Work top-down;
ship + report each piece; `/clear` between them. Order:

> ⚠️ **2026-08-25 — READ THIS BEFORE TRUSTING THIS LIST.** The nightly prompt says
> *"Take the FIRST unchecked **section** from the queue"* and *"Build `web/pages/<section>.vue`"*.
> It drives off the **checkbox Section queue further down this file**, NOT off this prose
> "Order:" list. Consequence: for seven nights item 1 below (download the Subsplash media)
> was never picked up, because it has no checkbox and is not a page. The archive metadata
> shipped; the media migration never started, and every video/audio URL on the live site
> still pointed at `cdn.subsplash.com`. **Anything that must actually happen belongs in the
> checkbox queue as a GitHub issue, not in this prose list.**

1. **Scrape more sermon series.** Run the Subsplash back-catalog pass on dd-mini (Chrome MCP).
   Per Jason: downloads ARE on the public embed — **Download → Download Video + Download Audio**,
   plus capture the **series artwork** (`artworkUrl`). Extend `content/subsplash-manifest.json`
   with more series, run `scripts/subsplash-fetch.mjs`, commit the new `content/sermons/*.json`
   (+ art in `public/sermon-art/`). /watch then shows real series graphics (see #12).
2. **Build the next set of pages** (Section queue below): Section 6 (Students/REACH, Men,
   Women + MOMs), Section 7 (Special Needs + Care & Support), Section 8 (About). Same discipline:
   verbatim RCC copy (use `~/dev/rcc/volunteer/src/data/serveTeams.ts` + the ministries hub for
   real write-ups), ≥2 model borrowings, DRAFT-chip invented copy, tight bands, no emojis
   (`<RccIcon>`), stub links via `<RccLink>` + registry, waves per the source/dest rule.
3. **[x] Full code audit + organize to industry standard — DONE 2026-08-21.** Stood up
   **ESLint (@nuxt/eslint flat) + Prettier + `nuxt typecheck` (vue-tsc)** with `lint`/`lint:fix`/
   `format`/`typecheck` scripts. Baseline: **0 lint errors** (4 boundary `any` warnings), **typecheck
   clean**, build passes. Real fixes: typed the PCO JSON:API envelope in `server/api/groups.get.ts`
   (broke an implicit-any cascade under noImplicitAny; behavior unchanged), `import/first` waiver in
   `fontawesome.ts`, added `@types/node`. Prettier baseline applied repo-wide (formatting-only, RCC
   copy byte-identical). Structure was already industry-standard (20 pages / 4 components / 5 utils /
   2 server routes) — verified, no reorg needed. web `1c70745`.
4. **[x] Commit-time validation/testing process — DONE 2026-08-21.** Husky + lint-staged pre-commit
   gate (`.husky/pre-commit`): `eslint --fix` + `prettier --write` on staged files, then full
   `npm run typecheck`. Build excluded (too slow per commit; DO build-on-push is the backstop).
   Documented in `web/CLAUDE.md` (new "Code Quality & Commit Gate" section). Verified live — both of
   tonight's commits passed the gate. **From now on every session runs lint + typecheck before
   committing** (the hook enforces it automatically).
5. **Serve "join" custom form (#17).** Replace the `/serve` → Church Center redirect with our own
   session-aware form: signed-in → prefill + submit the join on their behalf (→ Serve @ RCC workflow
   633475); not signed-in → PCO sign-in if they can auth, else name + phone-last-4 confirm (port the
   volunteer app's River Crossers `search`/`verify`, ~`volunteer/api/index.js` 5936–6128). Per ADR-004;
   depends on PCO OAuth (#3). This is a build, not just a page — scope it to a full session.
6. **Auth strategy — research + ADR-006 (#19).** FOUNDATIONAL, do EARLY (it gates #17/#18 and forms).
   Determine the **minimum PCO permission** for a member to authenticate via PCO OAuth (can a
   Church-Center-only person with no People-app permission authorize our app + return a usable
   identity?). Test it against real PCO + read the OAuth docs. Decide: PCO-OAuth-primary vs. our own
   accounts + PCO link vs. hybrid (PCO when available, else own account + name/phone-last-4 match).
   Write **ADR-006 (auth strategy)**. Relates to #3.
7. **Website ticket system (#18).** Admin-gated (account admins only, for now) portal tool: submit a
   website ticket + a listing showing status (new → in progress → resolved) + outcome. Our own store
   (Redis/table — app data, not PCO). Behind portal auth (#3); keep separate from PCO's support form.
8. **Graphic / ad request form + queue (#20).** For admins + team/ministry leaders. Implements the
   RCC Graphics & Communications Plan §3 intake (`BRAIN/50-RCC/5010-Projects/Graphics/`): Ministry ×
   Category routing, character caps at entry, the 3-wk/10-day/<10-day lead-time rule, channel
   checkboxes, reach→promo-tier, "I don't know what this should look like." Listing with status.
   Shares the request/listing infra with #18; role gating from #19.

Report each in `NIGHTLY-REPORTS.md`; anything needing Jason → a `needs-jason` issue.

## Queued next — PWA (Jason, 2026-08-12 — **NOT tonight**; eligible from the next nightly run)

Priority queued item — run this on an upcoming night **before** finishing the
remaining lower-priority ministry sections (6–11). **Do NOT run it tonight** — tonight's
authorized batch above stands.

- [x] **PWA — installable web app.** DONE 2026-08-18. `@vite-pwa/nuxt@1.1.1` in
      `web/nuxt.config.ts` (`pwa` block): manifest (name "River", `standalone`,
      brand-teal theme/bg, shortcuts Visit/Watch/Events/Give) + Workbox SW precaching
      the app shell (offline / weak signal). Icons: `web/scripts/generate-pwa-icons.mjs`
      → `web/public/icons/*` (waves mark on teal; 192/512 any + 512 maskable + 180
      apple-touch + favicons). Manifest link server-rendered via `<VitePwaManifest>` in
      `app.vue`. ADR-007 flipped to Done. Verified headless (build + manifest/sw 200 +
      SSR head + SW registration). Real-phone install screenshot deferred to Jason
      (needs-jason issue) — nightly Chrome isn't co-located with dd-mini's server.
      Original task spec below (kept for reference):
- [ ] ~~**PWA — installable web app.** Add **`@vite-pwa/nuxt`**~~: web manifest (name, RCC
      icons, theme color, `display: standalone`) + a service worker (install + offline-cache
      the shell so it loads on weak worship-center signal). Result: the site installs to the
      home screen (iOS Share → Add to Home Screen / Android install prompt) and launches
      fullscreen with the RCC icon — **no app store, no native wrapper.** This is the whole
      mobile strategy: PWA is "the app." Source icons/splash from the brand guide
      (`brand/index.html` logo tiers); tokens only. Validate by building and **installing it on
      a real phone** (screenshot the home-screen icon + standalone launch); confirm the manifest
      + service worker register (Chrome DevTools → Application). Update `.env.example` if any new
      config is introduced. Ship to `web` `main`; report + refresh the tracker.
      **When you take this up, UPDATE the ADR in the same change:**
      `web/docs/architecture/decisions/ADR-007-mobile-strategy-pwa.md` — flip its
      **Implementation** line from `Not yet started` to `Done (<date>)` and record what shipped
      (the `@vite-pwa/nuxt` config location, manifest + icon paths, offline-cache scope, and that
      it was verified installed on a real phone). The ADR is the durable record — don't leave it stale.
      Related: the **Groups leader roster/attendance module** is a *separate* post-launch build —
      GitHub issue `RiverChristianChurch/web#21` (phase-2), not part of this task.

## Rework queue (PRIORITY — clear before taking a new section)

Streamline/condense passes take precedence over new sections. In step 1, take the
FIRST unchecked **rework item** here; only if this list is empty do you take the
first unchecked Section below. One item per night, same ship/report discipline.

- [x] **Visit** (`web/pages/visit.vue`) — DONE 2026-08-11. Condensed 7 bands → 5
      (hero + What to Expect + Times & Directions + FAQ + one merged Connect-Card
      CTA). Cut standalone Kids-preview band, merged dual closing CTAs, trimmed FAQ
      to 6 real Qs, tightened copy. Look/feel unchanged.
- [x] **Next Steps** (`web/pages/next-steps.vue`) — DONE 2026-08-12. (a) Content
      fidelity audit: every prose block restored VERBATIM (diffed line-by-line vs
      /next-steps/growth-track/, /baptism/, /lifegroups/, /ministries/prayer/).
      De-invented the Serve Here/Near/Far tiers, the LifeGroups finder concept, and
      the paraphrased Prayer-team paragraph (omission, not reword — no chip). One
      DRAFT remains: native prayer-request form (routes to Connect Card). (b) Condensed
      8 bands → 4 (single Growth Track funnel section). Build + SSR verified.
- [x] **Outreach & Missions + Here/Near/Far reversal + stub-link system** — DONE
      2026-08-12 (Jason's #13 feedback). Jason: the "Here/Near/Far" I'd de-invented
      IS real — it's `/ministries/outreach-missions/` framed on **Acts 1:8**
      (Jerusalem/Judea&Samaria/Ends of the Earth). So I (a) BUILT
      `web/pages/ministries/outreach-missions.vue` — verbatim hero + Acts 1:8 + all 16
      partners; the only DRAFT chip is the added "Here·Near·Far / Local·Regional·Global"
      overlay (TPCC/E91 pattern). (b) Wired Next Steps' Serve step to it. (c) Shipped
      the **stub-link system** (`utils/routeRegistry.ts` + `<RccLink>` + ui-shell
      `.rcc-link-soon`, ui-shell v0.1.0-beta.6) and swept EVERY page: all static
      internal links now render disabled "soon" stubs when their target isn't built.
      New nightly step **5b (link validation)** added above. Build + SSR verified;
      no live href leaks to an unbuilt route.

## Section queue (check off when done)

- [x] 1. Visit — what to expect, service times/directions, visitor FAQ, kids preview
- [x] 2. Next Steps — Growth Track, Baptism, LifeGroups (finder concept), Serve, Prayer
- [x] 3. Watch — live, messages archive (series/speaker/date mock), sermon detail page
- [x] 4. Events — text-first filterable list + event detail page (E91/Eleven22 pattern)
- [x] 5. Ministries hub + Kids — DONE 2026-08-11 (built ahead of the nightly run).
      `/ministries` (hub: hero → directory grid → CTA) + `/ministries/kids`
      (RCC Kids: programs → first-time/check-in → safety → close). Verbatim RCC
      copy; check-in/safety/pre-reg drafted (E91 + Venture model) with DRAFT chips.
      OPEN: grade-range conflict (see below) + directory-card descriptions need real copy.
- [x] 6. Ministries: Students/REACH, Men, Women + MOMs — DONE 2026-08-13.
      `/ministries/students` (REACH + GROW + serve), `/ministries/men` (mission +
      Uncommon Groups + agenda + studies), `/ministries/women` (mission + John 15:5
      + MOMs band w/ STARVED study + $32/2026-dates register block). Verbatim RCC
      copy; routes flipped true; hub Men/Women blurbs now sourced. MOMs register +
      all join CTAs point at /connect (soon) — real Church Center URLs needed (#issue).
- [x] 7. Care & Support — DONE 2026-08-15. `/ministries/care` (Care Services:
      Hospital Visit + Counseling Referrals; Support Groups: Celebrate Recovery /
      DivorceCare / GriefShare as scannable meeting cards). ALL copy verbatim from
      /ministries/care/ — no invented prose. Mental Health Resources stubbed
      (`/ministries/care/mental-health` = soon). Registry flipped; hub Care card
      auto-enabled. **Special Needs: NOT built — RCC has no special-needs / buddy /
      accessibility content on the live site (404) and none in serveTeams; building
      a page would be 100% invented (hard-rule violation). Filed needs-jason issue
      w/ Highlands Haven model → does RCC want one + supply copy.**
- [x] 8. About — DONE 2026-08-16. `/about` consolidates the live site's five
      About-Us sub-pages (who-we-are, our-story, what-we-believe, our-team,
      contact) into one anchor-navigable page: Our Story location timeline (6
      milestones, verbatim + avg attendance), What We Believe 8-doctrine
      accordion w/ inline Scripture refs, Our Team (17 staff grouped by dept +
      Our Elders board), Contact (office/mailing/service-times from SITE).
      ALL prose verbatim — no invented copy, no chips. Message CTA → Connect
      Card (soon). Registry flipped `/about` → true (nav/footer links auto-live).
      **This Week (email-archive concept) NOT built — stays `/this-week` stub in
      supra; it's a distinct concept, filed for a later section.**
- [x] 9. Give + supra-menu (Preschool, This Week) + footer (sitewide pattern) —
      DONE 2026-08-17. `/give` rebuilt to VERBATIM live-site copy: fixed a
      verbatim-rule violation (hero previously paraphrased "why we give" with no
      chip), replaced paraphrased/DRAFT-chipped Ways-to-Give cards (In-Person /
      Mobile Apps / Mail) with the live wording, and added a Giving FAQs accordion
      (6 Qs, verbatim from the live /give/ FAQ — Venture "Give + FAQs" pattern).
      ZERO draft chips remain. Sitewide footer social row now real external links
      from `SITE.social` (ui-shell `.rcc-footer-social`, v0.1.0-beta.8); supra
      (Preschool + This Week) already present, both stay disabled stubs until built.
      Borrowings: Venture (Give+FAQs), Fusion (alternate-ways breakout), E91 (Give
      in footer, not a highlighted header button). Build + SSR verified; no chips,
      no hardcoded colors, no link drift.
- [x] 10. Portal deepening — DONE 2026-08-19. `/portal` rebuilt as one shell, two
      audiences: (a) **guest sign-in gate** (PCO OAuth CTA, disabled until ADR-006 +
      a what-you-get feature list) and (b) **role-differentiated dashboard** —
      member / volunteer / leader / staff — with Your Next Steps (Growth Track for
      members; ported volunteer onboarding checklist + progress for servers), Your
      Groups, Serving, Giving (Give + My Giving, Eleven22 pattern), This Weekend,
      plus leader/staff admin cards. State flows ONLY through the new
      `usePortalSession()` composable (the auth seam): guest by default, representative
      role fixtures via `?preview=<role>` with a visible amber Preview notice, until
      ADR-006 wires the real server session (template unchanged then). Onboarding
      steps VERBATIM from the volunteer app (ADR-002). Phase-2 admin tools render as
      disabled `<RccLink>` stubs (`/portal/{team,tickets,graphics}`). ui-shell
      dashboard vocab reused as-is (no tag bump); zero hardcoded colors. **Live data /
      sign-in still gated on ADR-006 (Jason: OAuth creds + test account).**
- [x] 11. Home polish + cross-linking + mobile QA sweep — DONE 2026-08-20.
      `/` rebuilt from hero-only into the site's front door + primary
      cross-linking hub: **Start Here** 4 quick tiles (Visit/Watch/Next
      Steps/Give), **Ministries** "There's a Place for You" grid → the 6
      built ministry pages + LifeGroups (blurbs reuse the RCC-sourced hub
      one-liners — no new copy), **Join Us This Sunday** closing visit CTA
      (online line VERBATIM from live Church Online callout; times from
      SITE). Every internal link is `<RccLink>`. Flagged the carried-over
      invented hero welcome line with a DRAFT chip. **Link sweep (5b):**
      converted the last bare static internal links to `<RccLink>`
      (about Plan-a-Visit; layout Sign In / Plan a Visit); verified across
      all 18 built pages — no live href points at any `false` route. Build
      + SSR verified; responsive breakpoints confirmed (tiles 4→2→1,
      portal-grid 1-col ≤1024). Visual phone capture constrained by the
      nightly Chrome window's ~1200px min-width — relied on the verified
      responsive CSS (ui-shell breakpoints + per-page scoped queries, same
      as prior-QA'd pages). **Section queue COMPLETE.**

## Post-section enhancement builds (Section queue done — take these next; check off)

Section queue (1–11) + Rework queue are complete. When no Section/Rework item is
open, take the first unchecked, **non-blocked** GitHub enhancement here (skip any
gated on ADR-006 / PCO OAuth or `needs-jason`). One per night, same discipline.

- [x] **web#24 — FIVE 6 as its own ministry page.** DONE 2026-08-22. Built
      `web/pages/ministries/five6.vue` (hero → verbatim About → DRAFT check-in →
      Kids→FIVE 6→Students pathway → parent connect). Full verbatim FIVE 6 copy
      from `/ministries/kids/#five6`; fixed a latent Kids-page paraphrase-without-chip
      by swapping it for a verbatim-line pointer. Registry flipped `/ministries/five6`
      → true (hub card + Kids pointer auto-live). web `3e82987`.
- [x] **web#23 — file storage for ministry resources** — BUILT 2026-08-23 (web `3f660bd`,
      ADR-008 Accepted `a92fdb7`): private Supabase Storage bucket + Postgres metadata
      catalog, staff upload, role-gated download via short-TTL signed URLs,
      `/portal/resources` behind the portal preview gate. Live verification still
      needs Supabase env vars + real sessions (ADR-006). Original scoping note:
- [ ] ~~**web#23 — file storage for ministry resources**~~ (admin upload / leader
      download). **SCOPED 2026-08-23 → ADR-008 (Proposed), now `needs-jason`.**
      web `1c56fc9`. Recommendation: DO Spaces for the blobs (private + short-TTL
      pre-signed URLs, admin-gated upload — **ready to build**) + the app's **first
      app-owned Postgres** for file metadata (shared with #18/#20). The one open call
      is the data store: **DO Managed Postgres vs. reuse Supabase** (+ budget ~$20 or
      ~$5/mo). Download enforcement gated on ADR-006. Proposal Artifact:
      `https://claude.ai/code/artifact/f5383b65-4ef8-4191-97a5-7ffd3e517085`. Box
      stays unchecked — the BUILD is unstarted, waiting on Jason's backend pick.
- [~] **web#7 — native sermon archive + YouTube ingest.** ARCHIVE HALF DONE
      2026-08-25 (web `c29fe0b`). The catalog is real: **291 messages across 65
      series**, built from the captured Subsplash library by the new
      `scripts/manifest-catalog.mjs` — every title, speaker, Scripture ref and note
      outline verbatim RCC, plus 65 series graphics downsampled to 5.2 MB. `/watch`
      now carries a Series/Speaker/Year + keyword filter with Load More;
      `/watch/series` is a new series index; `/watch/[slug]` renders the note outline,
      prev/next in series and interim playback from the church's own Subsplash media.
      Listing pages read a generated compact index (`build-sermon-index.mjs`, runs
      before dev/build); full records lazy-load on the detail page.
      **STILL OPEN — the YouTube ingest half:** `sync-youtube.mjs` + `upload-youtube.mjs`
      exist but need `YT_API_KEY` / `YT_CHANNEL_ID` and channel confirmation (web#10,
      needs-jason). Until then media plays from Subsplash CDN URLs that die at contract
      end. Also open: web#31 (61 undated thin captures), web#32 (verify playback in a
      real browser).

- [x] **Prayer (`/ministries/prayer`)** — DONE 2026-08-27 (web `7fd3e52`). The last
      Care & Support route that existed only as a disabled stub. Four bands: hero
      (RCC's own Night of Worship photo — the live page's own hero image) → **How We
      Pray** (the church's rhythms: every service · weekly over every submitted
      request · the weekly gathering, day/time/place from `SITE.prayer`) → **Request
      Prayer** (all three live-site pathways at equal weight) → **Join the Prayer
      Team** (verbatim serve-team record: John Pratt · Weekend Services · Flexible).
      All prose verbatim from `/ministries/prayer/` + `volunteer/src/data/serveTeams.ts`.
      Registry flipped `/ministries/prayer` → true, which lit up the ministries-hub
      card and the Care page CTA; added a Next Steps → prayer cross-link. ONE draft
      chip: the live page's inline prayer form (ADR-004, needs PCO workflow IDs →
      **web#37**), routing to the Connect Card meanwhile.
- [x] **web#38 — `/ministries/care/mental-health`.** DONE 2026-08-29 (web `4c57416`).
      The last Care & Support stub is now a real page. Five bands: short hero (verbatim
      intro) → **Get Help Now** (988 + the corrected national line as tap-to-call, the
      four national resources + findhelp.org as number-forward cards, then the church's
      own "we are here for you" paragraph) → **If Someone Is at Risk** (the suicide
      what-to-do / warning-signs / things-to-know content, always open, never in the
      accordion) → **Christian Counselors Near You** (6 practices + 5 regional
      counselors as a grouped directory, every card's action its phone number) →
      **Resources by Topic** (~30 books/articles/videos in a `<details>` accordion).
      ALL copy verbatim. **Three corrections, each source-note chipped:** the crisis
      number `899-273-8255` → **800**-273-8255; "Mathew 28:11" → **Matthew 11:28**; and
      Foundations Christian Counseling's 404ing deep link → the practice's live root.
      Registry flipped → the Care hub row auto-enabled to "View resources →".
      `pages/ministries/care.vue` moved to `care/index.vue` so the sub-route can nest.
      **ui-shell v0.1.0-beta.9** adds `.rcc-hero--short` (sub-page hero sized to its
      content, so the crisis band clears the fold). Filed **web#45** (needs-jason:
      confirm the three corrections — and fix the 899 typo on the LIVE WordPress site,
      which is the higher-severity half) and **web#44** (pre-existing: FontAwesome
      icons never render server-side on ANY page).

- [x] **web#4 — `/events` fed by the real PCO Calendar.** DONE 2026-08-30 (web `c8a92e5`).
      The events list was six hand-written placeholder events under a DRAFT chip; it now
      reads the church's own Planning Center calendar via a new `server/api/events.get.ts`
      (server-side PAT, same pattern as `/api/groups`). The raw feed is NOT a public list —
      ~450 Church-Center-visible instances fall in the next 120 days, almost all weekly
      repeats (25 LifeGroups x weekly, 3 services x weekly). The route filters on the
      church's OWN publish flag (`visible_in_church_center`), drops back-of-house tags,
      leaves services to `/visit` and LifeGroups to `/groups`, and collapses each event to
      one row using PCO's own recurrence wording → **22 real events** (Welcome to RCC, FPU,
      Marriage Class, MOMs, Women's Refresh Conference, Worship Night, Catalyst, GriefShare…).
      Category facets come from the church's real PCO tags. `/events/[slug]` is a real detail
      page (description, register → Church Center, add-to-calendar, share) and 404s on an
      unknown slug; `<RccMinistryEvents>` reads the same live feed. **Zero DRAFT chips remain
      on /events.** Two correctness fixes found while validating: times now use
      `published_starts_at` (PCO's `starts_at` is the room block INCLUDING setup — REACH read
      3:00 PM vs a published 5:00 PM; GriefShare/DivorceCare/GROW/Celebrate Recovery were each
      1h+ early), and all dates format in the new `SITE.timezone`. Perf: tag pass 9s → filtered
      at source (1641→404 events) + parallel paging + stale-while-revalidate. Filed **web#48**
      (needs-jason: ministry events tagged only "Community Wide", so Women/Kids strips are
      empty — a PCO data fix, not code) and **web#49** (needs-jason: set the PCO PAT in
      DigitalOcean or prod shows the empty state).

- [x] **web#16 — `/groups` fed by the real PCO Groups directory.** DONE 2026-08-31
      (web `bf4f2be`, ui-shell `5f2d275` = **v0.1.0-beta.10**). The finder was ported
      from the volunteer app months ago and had never been run against live Planning
      Center data; doing that surfaced two bugs, both publishing things the church
      does not publish. **(1) The publish flag was ignored** — PCO Groups v2 silently
      drops an unsupported `?filter=listed`, so the route returned all 92 groups in the
      account and the page tried to compensate with a name regex that caught 4 of them.
      Live, `/groups` would have listed **53 groups RCC never listed**: 14 REACH student
      groups (7th–12th grade minors, staff email attached), 28 "River Crossers" shadow
      groups duplicating every real LifeGroup, a group named TEST, a volunteer team and
      the Discipleship classes. Now filtered on the `listed` attribute (exactly the set
      with a Church Center URL, 1:1) and scoped to the LifeGroups type → **27 real
      groups**. **(2) Host families' home addresses were published** — 21 of 27 meet in
      homes, which PCO marks `display_preference: approximate`; the API was shipping
      `full_formatted_address` + rooftop coordinates to the browser and the map pinned
      the house. Street address + exact coordinates now go out only for `exact` venues;
      homes get the church's own "Meeting Area" wording and a ~1km-rounded coordinate
      drawn as an **area circle**, not a pin. Location NAME withheld too (several are
      family names); leader `contact_email` no longer sent at all. Also: every
      LifeGroup's PCO description is the same two boilerplate paragraphs, so the cards
      were 27 identical blocks — the route now parses the lines that actually differ
      (audience + meeting area) and the card shows those, verbatim. Facets are
      **day / area / who it's for / childcare**, URL-backed
      (`?day=Tuesday&area=Middleburg&for=Women`) so a filtered view is linkable.
      Borrowings: **Seacoast** (group-finder category deep links → URL-backed filter
      state), **Highlands** (directory searchable by interest + availability → the
      "who it's for" facet from RCC's own audience lines), **E91** ("help me find a
      group" path kept beside the self-serve directory), **Eleven22/Highlands
      counter-example** (their directories are login- or season-gated; ours stays
      public). ui-shell **beta.10** promotes `.rcc-filterbar` + `.rcc-chip` out of the
      two pages that hand-rolled them and adds `.rcc-map-pin`/`.rcc-map-area` so pin
      color comes from tokens (the finder had been passing 7 raw hex day colors from JS
      into the marker SVG — a hardcoded-color violation); `/events` converted to the
      shared bar in the same change. Copy: **two pre-existing verbatim-rule violations
      now carry source-noted DRAFT chips** (Study Material "below"→"in the portal";
      the invented closing CTA) plus one new chipped line explaining the area circles.
      Filed **web#50** (needs-jason: 26 PCO group tags defined, zero assigned — the
      facets parse prose because the structured data is empty) and **web#51**
      (needs-jason: approve or replace the three DRAFT lines).

- [x] **River Preschool (`/preschool`)** — DONE 2026-09-01 (web `8ff89de`). The last
      route that was linked SITEWIDE but never built: the supra utility bar's first
      item has rendered as a disabled "soon" stub since the shell shipped, and the
      live site promotes the preschool first in its own utility bar too. Five bands,
      every word VERBATIM from `/river-preschool/` (`/preschool/` 301s there): short
      hero → the church's four welcome paragraphs beside RCC's own playground photo
      → **Tuition & Fees / 2026-27 School Year** (2's, 3's, VPK monthly rates) with
      the **$250 registration fee** and its three opening dates → **Document
      Download** (the three real registration/summer-camp PDFs) → **Pay Tuition &
      Fees** + **More Information** as tap-to-call / tap-to-email. Nothing reworded;
      no invented prose. Borrowings: **E91 Early Learning** (leads with "Programs,
      Fees & Registration" + a call-us action → tuition sits second here, not last,
      and the phone number is the closing CTA) and **Venture Preschool** (each age
      its own block carrying schedule + cost → nine flat rate lines become one
      column per age). **Two DRAFT chips, both OURS not the church's:** the payment
      form is still a WordPress WP Simple Pay embed and we link out to it (taking
      payment here needs the preschool's own Stripe account — RPK is post-launch),
      and the three packets are 34 MB of PDFs still served by WordPress, so they die
      at domain cutover. Registry flipped `/preschool` → true, lighting the supra
      link sitewide. Filed **web#57** (needs-jason: the live site's registration
      window — Jan. 6 / 20 / 26 with no year — has already closed for 26-27, and the
      2026 Summer Camp packet is past; the LIVE WordPress page has the same problem)
      and **web#58** (needs-jason: is the preschool a separate Stripe account, and
      #23/ADR-008 must land so the packets can move off WordPress).

**Care & Support is now complete** — care hub, prayer, and mental health all shipped;
no stubs remain in the section.

Blocked (do NOT take autonomously — need Jason): web#17/#18/#19/#20 (auth/forms/
queues, all gated on **ADR-006 PCO OAuth**), plus the open `needs-jason` issues.

## Nightly steps

1. `cd ~/dev/rcc/ui-shell && git pull` (loop state + design system), then
   `cd ~/dev/rcc/web && git checkout main && git pull` (build target). Take the
   FIRST unchecked **Rework-queue** item if any exist; otherwise the FIRST unchecked
   Section. Both trees must be clean.
2. **Research**: for THIS section only, revisit the model sites (6 single-site
   cohort first — E91, Venture, Real Life Sac, Motivation, Fusion, Brooklake —
   then multis) via the raw audits + live fetches. **Each section earns ≥2
   concrete model borrowings — name them in the report.** Don't invent sections
   the cohort doesn't justify (keep the page tight to what's sourced).
3. **Content**: pull real RCC copy from riverchristian.church.
   **RCC content takes precedence — edit only for grammar and flow.**
   Where copy must be invented, wrap it in a visible draft marker
   (`.rcc-draft` block / `.rcc-draft-chip` inline — amber "DRAFT — needs review")
   until Jason approves. Cross-check the sitemap artifact for decided IA before
   building (it can *cut* things — e.g. the custom plan-a-visit form).
4. **Build**: `web/pages/<section>.vue` (+ `web/components/*` as needed), using
   ui-shell classes via `<script setup>` + `useHead` for title/description.
   Nav/footer/supra live in `web/layouts/default.vue` — pages supply content only.
   No hardcoded colors/fonts. If the section needs a **new shared token/component**,
   add it to `ui-shell/src/css` FIRST, bump `ui-shell` version + tag
   (`vX` → `git tag`/push), then `npm i @riverchristianchurch/ui-shell@github:...#vX`
   in `web` and use it. Brand guide governs logo tiers; Give never highlighted;
   supra-menu carries Preschool + This Week; taxonomy undecided → current names.
5. **Validate**: `cd ~/dev/rcc/web && npm run lint && npm run typecheck` must both pass
   (standing gate since 2026-08-21 — the pre-commit hook enforces it too), then
   `npm run build` must pass; boot
   `node .output/server/index.mjs` and `curl` the route to confirm SSR renders the
   real content; internal links/anchors resolve; responsive at 768/1024; no
   hardcoded colors. Browser screenshot if a Chrome is connected.
5b. **Link validation (EVERY night, across ALL built pages — not just tonight's).**
   The stub-link system is `web/utils/routeRegistry.ts` (route → ready?) + the
   `<RccLink>` component (renders a real link when ready, a disabled "soon" stub when
   not). Each night:
   - **New links → point them at the planned route via `<RccLink>`.** When a page you
     build should link somewhere on the sitemap that isn't built yet, add the link
     anyway with `<RccLink to="/that-route">` and add `/that-route: false` to the
     registry — it renders disabled until that page ships. Never leave a bare
     `<NuxtLink>`/`<a href>` pointing at an unbuilt page (it 404s).
   - **Shipped a page tonight? → flip its route to `true`** in the registry. Every
     `<RccLink>` sitewide that points at it auto-enables — no per-link edits.
   - **Sweep + verify all existing pages.** `grep -rn 'NuxtLink to=\|href="/' web/pages
     web/layouts`: every STATIC internal link should be an `<RccLink>` (dynamic
     `:to="\`/x/${slug}\`"` detail links stay `<NuxtLink>` — their parent pages exist).
     Then boot the build and confirm **no live `href` points at a `false` route**
     (`curl` each page; grep for `href="/<unbuilt>"` → must be empty) and **no
     `<RccLink>` references a route missing from the registry** (missing = treated as
     not-ready). Fix drift before shipping.
6. **Ship**: small commits to `web` `main`, push (DigitalOcean App Platform deploys, ADR-005). If ui-shell
   changed, commit + push it + the new tag first.
7. **Update state**: check the section box above (commit this file to ui-shell);
   update the section's status dot in the sitemap artifact (pass its URL to the
   Artifact tool) from ○ to ◐/●.
8. **Report**: append to `docs/NIGHTLY-REPORTS.md` (in ui-shell) — date, section,
   what shipped (route + DO/preview URL), the ≥2 borrowings, DRAFT-flagged
   list, decisions needed. Anything needing Jason = GitHub issue labeled
   `needs-jason` (repo: whichever the work touched; default `web`).
9. **Update the morning handoff Artifact.** Edit `ui-shell/docs/handoff.html` to
   reflect what shipped (move the built section from "tonight" into "pages shipped",
   set the next queue item as tonight's plan, refresh the to-dos), commit it to
   ui-shell, then redeploy the SAME Artifact URL so Jason wakes to a current handoff:
   `https://claude.ai/code/artifact/0d660315-7ffc-4718-9d78-7e8256658eec`
   (Artifact tool, `url:` = that link, favicon 📋). Proposals still get their own
   Artifact per the hard rule; this is the standing project handoff.
   End with a short summary message. Then STOP — one section per night.

## Hard rules

- **Verbatim RCC copy + source-traceable changes (Jason, 2026-08-11).** OUR CONTENT
  FIRST: pull the church's exact words from the live site and use them **verbatim**.
  If you change the wording of ANYTHING that exists on the current site — reword,
  condense, reformat (e.g. prose → FAQ), or invent net-new copy — it gets a
  `.rcc-draft-chip` (or `.rcc-draft` block) whose `data-note` states **the source
  URL, what changed, and why**. No paraphrasing real copy without a chip; no
  inventing sections/answers the site doesn't have (the invented "Questions
  First-Timers Ask" FAQ + reworded parking blurb was the violation that set this
  rule). Verifying = fetch the live page (`curl` raw HTML → strip tags), diff each
  line. Pure omission (dropping a whole section for scope) is editorial, not a
  reword — note it in the report, no chip needed.
- **Condensed over comprehensive (Jason, 2026-08-10).** Jason prefers tight, dense
  pages — no fluff. Prefer fewer, higher-value sections; tighten copy; when in doubt
  cut a band rather than add one. A new page should not exceed ~4–5 content bands
  without a reason. The look/feel is already where he wants it — spend the effort on
  brevity, not more sections.
- RCC content precedence; generated copy is DRAFT-flagged inline until reviewed.
- **Proposals/recommendations for Jason → Artifact (Jason, 2026-08-11).** Any
  recommendation or decision write-up gets published as a claude.ai Artifact
  (load `artifact-design`, ground it in the RCC teal system) so he can review it
  from any device — keep the repo ADR/record too, but link the Artifact from the
  report + needs-jason issue. A committed doc alone isn't the deliverable for a proposal.
- Build in `web` (real Nuxt). `ui-shell` only for shared tokens/components, and
  only via a tag bump — never point `web` at an un-tagged ui-shell ref.
- Never touch `ui-shell/options/` (archive) or brand-guide decisions (accent,
  type, logo tiers, seasonal policy) — propose changes via issue instead.
- Taxonomy (web #1) is undecided — use current ministry names verbatim.
- **No emojis as UI (Jason, 2026-08-12).** Never use emoji for icons/bullets/accents.
  Use `<RccIcon name="…">` or text/typographic treatment. RccIcon is now backed by
  **FontAwesome Free** (`web/plugins/fontawesome.ts`; free-solid set, no token, OFL/MIT).
  To add an icon: import it in the plugin, add to `library.add(...)`, map a friendly key
  in `RccIcon.vue`. (Jason has no FA Pro — Free only.)
- **Recurring times/locations live in `web/utils/siteConfig.ts` (`SITE`) — ONE source
  of truth (Jason, 2026-08-12).** Service times, office hours, the weekly prayer time,
  address, and the Subsplash giving URL are there; pages read from it so a time/day
  change happens in exactly one place. Prayer is **Wednesday** (`SITE.prayer.day`,
  confirmed by Jason 2026-08-12).
- **Sermon scraper must capture the SERIES GRAPHIC (Jason, 2026-08-12).** The browser
  metadata pass records `artworkUrl` per message; `subsplash-fetch.mjs` downloads it to
  `public/sermon-art/<slug>` and sets the record `thumb`. `/watch` shows the real series
  art — never YouTube's gray 3-dot placeholder (a branded gradient shows until art lands).
- **Readable measure.** Body/funnel text gets a ~68ch max-width so lines don't stretch
  the full 1280px container (Jason, 2026-08-12 — Next Steps steps were the example).
- **Stubbed links, disabled until ready** — see step 5b. New links to unbuilt pages use
  `<RccLink>` + a `false` registry entry; flip to `true` when the page ships.
- Google Fonts / open-license only. Tokens only. No paid assets.
- Commit + push every night — git is the only cross-machine channel.
- Work on dd-mini's canonical checkout.
