# Nightly Iteration Loop — RCC Website Beta

Build the new riverchristian.church section-by-section as beta mockups in this
repo. One top-level section per night; Jason reviews each morning. Cairn-style:
iterate autonomously, ship, report, stop.

## Inputs (read every night)

- This file — the queue below is the state
- Sitemap (target IA + statuses): https://claude.ai/code/artifact/8f944e6e-eb71-4f83-9e4a-61e3445562c0
- BRAIN: `50-RCC/5010-Projects/Website-Feature-Inventory.md` (feature calls) + `Website-Rebuild.md` (decisions)
- Brand guide: `brand/index.html` (live at /ui-shell/brand/) — tokens, type, logo tiers, accent (pending lock: use `--rcc-accent`)
- Model-site raw audits: `~/dev/rcc/web/docs/research/church-site-audits-2026-08.json`
- Current-site content source: https://riverchristian.church

## Section queue (check off when done)

- [x] 1. Visit — what to expect, service times/directions, visitor FAQ, kids preview
- [ ] 2. Next Steps — Growth Track, Baptism, LifeGroups (finder concept), Serve, Prayer
- [ ] 3. Watch — live, messages archive (series/speaker/date mock), sermon detail page
- [ ] 4. Events — text-first filterable list + event detail page (E91/Eleven22 pattern)
- [ ] 5. Ministries hub + Kids (incl. check-in/safety/pre-reg content)
- [ ] 6. Ministries: Students/REACH, Men, Women + MOMs
- [ ] 7. Special Needs (full page — model on Highlands/Seacoast examples) + Care & Support
- [ ] 8. About — story, beliefs, staff, contact, This Week (email archive concept)
- [ ] 9. Give + supra-menu (Preschool, This Week) + footer (sitewide pattern)
- [ ] 10. Portal deepening — dashboard states per role, group/serve/give cards
- [ ] 11. Home polish + cross-linking + mobile QA sweep

## Nightly steps

1. `cd ~/dev/rcc/ui-shell && git pull`. Take the FIRST unchecked section.
2. **Research**: for THIS section only, revisit the model sites (6 single-site
   cohort first — E91, Venture, Real Life Sac, Motivation, Fusion, Brooklake —
   then multis) via the raw audits + live fetches. Note 2–3 concrete
   borrowings in the report.
3. **Content**: pull real RCC copy from riverchristian.church.
   **RCC content takes precedence — edit only for grammar and flow.**
   Where copy must be invented, wrap it in a visible draft marker
   (`.rcc-draft` — amber outline + "DRAFT — needs review" chip; add the class
   to `src/css/rcc-components.css` on first use) until Jason approves.
4. **Build**: `beta/<section>.html` pages using existing tokens/components.
   New styles only if reusable, `rcc-`-prefixed, token-driven — no hardcoded
   colors/fonts. Follow the brand guide. Text-first events; no text baked
   into imagery; logo tiers per the guide; Give never visually highlighted;
   supra-menu carries Preschool + This Week.
5. **Validate**: every page linked from the beta switcher + `beta/index.html`;
   responsive at 768/1024 breakpoints; both logo tiers correct; no console
   errors; links between beta pages resolve on Pages paths.
6. **Ship**: small commits to `main`, push (Pages auto-publishes).
7. **Update state**: check the section box above (commit this file); update
   the section's status dot in the sitemap artifact (pass its URL to the
   Artifact tool) from ○ to ◐/●.
8. **Report**: append to `docs/NIGHTLY-REPORTS.md` — date, section, what
   shipped (URLs), borrowings, DRAFT-flagged content list, decisions needed.
   Anything needing Jason = GitHub issue on this repo labeled `needs-jason`.
   End with a short summary message. Then STOP — one section per night.

## Hard rules

- RCC content precedence; generated copy is DRAFT-flagged inline until reviewed.
- Never touch `options/` (archive) or brand-guide decisions (accent, type,
  logo tiers, seasonal policy) — propose changes via issue instead.
- Taxonomy (web #1) is undecided — use current ministry names verbatim.
- Google Fonts / open-license only. Tokens only. No paid assets.
- Commit + push every night — git is the only cross-machine channel.
- Work on dd-mini's canonical checkout.
