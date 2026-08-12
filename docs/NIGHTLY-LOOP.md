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
3. **Full code audit + organize to industry standard.** The imported volunteer code (`utils/
   serveTeams.ts`, `utils/groups.ts`, `server/api/groups.get.ts`, `components/LifeGroupsMap.vue`,
   `plugins/fontawesome.ts`) + everything built this week: verify structure, naming, and that it
   passes lint/typecheck. Add/enable **ESLint + Prettier + `vue-tsc` typecheck** if not present
   (`@nuxt/eslint`), fix findings, add `npm run lint` / `npm run typecheck` scripts.
4. **Commit-time validation/testing process.** Stand up a pre-commit gate (Husky + lint-staged, or
   a `.git/hooks/pre-commit`) that runs lint + typecheck (+ `npm run build` or fast tests) before a
   commit lands. Document it in CLAUDE.md. This is the durable "validate before commit" workflow —
   after tonight, **every session runs lint + typecheck before committing** (add to step 5 below).

Report each in `NIGHTLY-REPORTS.md`; anything needing Jason → a `needs-jason` issue.

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
- [ ] 6. Ministries: Students/REACH, Men, Women + MOMs
- [ ] 7. Special Needs (full page — model on Highlands/Seacoast examples) + Care & Support
- [ ] 8. About — story, beliefs, staff, contact, This Week (email archive concept)
- [ ] 9. Give + supra-menu (Preschool, This Week) + footer (sitewide pattern)
- [ ] 10. Portal deepening — dashboard states per role, group/serve/give cards
- [ ] 11. Home polish + cross-linking + mobile QA sweep

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
5. **Validate**: `cd ~/dev/rcc/web && npm run build` must pass; boot
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
