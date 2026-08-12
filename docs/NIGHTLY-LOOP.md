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
- Brand guide: `brand/index.html` (live at /ui-shell/brand/) — tokens, type, logo tiers, accent (pending lock: use `--rcc-accent`)
- Model-site raw audits: `~/dev/rcc/web/docs/research/church-site-audits-2026-08.json`
- Current-site content source: https://riverchristian.church

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
6. **Ship**: small commits to `web` `main`, push (Vercel deploys). If ui-shell
   changed, commit + push it + the new tag first.
7. **Update state**: check the section box above (commit this file to ui-shell);
   update the section's status dot in the sitemap artifact (pass its URL to the
   Artifact tool) from ○ to ◐/●.
8. **Report**: append to `docs/NIGHTLY-REPORTS.md` (in ui-shell) — date, section,
   what shipped (route + Vercel/preview URL), the ≥2 borrowings, DRAFT-flagged
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
- Google Fonts / open-license only. Tokens only. No paid assets.
- Commit + push every night — git is the only cross-machine channel.
- Work on dd-mini's canonical checkout.
