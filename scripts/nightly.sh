#!/usr/bin/env bash
# RCC website nightly iteration — invoked by LaunchAgent com.jason.rcc-web.nightly.
#
# Mirrors the Cairn nightly pattern (dd/cairn/scripts/nightly.sh). Instead of a headless
# `claude -p` (Remote Control INACTIVE, so no PushNotification AND no claude.ai/Artifact
# access — which would make the sitemap status dots lag), this INJECTS the nightly prompt
# into the persistent JARVIS-rcc-web tmux session, which has Remote Control active. That
# session builds ONE section per docs/NIGHTLY-LOOP.md, ships to main, updates the sitemap
# artifact's status dot, writes the report, and can push-notify / answer Jason in-thread.
#
# The loop state lives in ui-shell/docs/NIGHTLY-LOOP.md (the queue self-selects the next
# section every night). Sections BUILD as real Nuxt pages in ~/dev/rcc/web (pages/*.vue);
# ~/dev/rcc/ui-shell holds the loop docs + the shared tokens/components (bump its tag when
# a section needs new ones). Research audits are read from ~/dev/rcc/web/docs/research/.
set -uo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
SESSION="rcc-web"
REPO="$HOME/dev/rcc/ui-shell"   # loop state (NIGHTLY-LOOP.md) + design system
WEB="$HOME/dev/rcc/web"         # build target — real Nuxt pages ship here
LOG="$HOME/Library/Logs/rcc-web-nightly.log"

exec >>"$LOG" 2>&1
echo ""
echo "========== rcc-web nightly inject $(date '+%Y-%m-%d %H:%M:%S') =========="

# 1. The persistent session must be up (the claude-sessions watchdog keeps it alive).
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "SKIP: tmux session '$SESSION' not running; watchdog should restart it. Nothing injected."
  exit 0
fi

# 2. It must be idle. Do NOT scrape the pane for keywords: this session doubles as Jason's
#    interactive REPL and its scrollback discusses these very keywords, poisoning any content
#    regex. Detect MOTION instead: an actively generating turn updates its elapsed-second timer
#    every second, so two captures ~1.3s apart differ. An idle session is static.
snap1=$(tmux capture-pane -t "$SESSION" -p -S -12 2>/dev/null)
sleep 1.3
snap2=$(tmux capture-pane -t "$SESSION" -p -S -12 2>/dev/null)
if [ "$snap1" != "$snap2" ]; then
  echo "SKIP: '$SESSION' is animating (a turn is in progress) — not injecting tonight."
  exit 0
fi

# 3. Both repos must be clean on main (loop commits to ui-shell; pages ship to web), or bail.
for r in "$REPO" "$WEB"; do
  cd "$r" || { echo "FATAL: cannot cd $r"; exit 1; }
  git checkout main >/dev/null 2>&1
  git pull --ff-only >/dev/null 2>&1 || echo "WARN: $(basename "$r") main not fast-forward; continuing."
  if [ -n "$(git status --porcelain)" ]; then
    echo "SKIP: $(basename "$r") working tree dirty — leaving it for Jason."
    exit 0
  fi
done

# 4. Inject the one-line nightly prompt and submit it robustly.
PROMPT='NIGHTLY RCC WEBSITE ITERATION. cd ~/dev/rcc/ui-shell && git pull, then read docs/NIGHTLY-LOOP.md and follow it EXACTLY. BUILD TARGET IS THE web REPO (~/dev/rcc/web) — real Nuxt pages, NOT static mockups. cd ~/dev/rcc/web && git checkout main && git pull. Take the FIRST unchecked section from the queue. Research the model churches for THAT section only (single-site cohort first — E91, Venture, Real Life Sac, Motivation, Fusion, Brooklake — via the raw audits at ~/dev/rcc/web/docs/research/church-site-audits-2026-08.json plus live fetches). EACH section must earn >=2 concrete model borrowings — name them in the report; do not invent sections the cohort does not justify. Pull real RCC copy from https://riverchristian.church; cross-check the sitemap artifact for decided IA (it can CUT things). RCC content takes precedence — edit only for grammar/flow; any copy you invent gets a .rcc-draft/.rcc-draft-chip DRAFT badge until Jason reviews. Build web/pages/<section>.vue (+ web/components/* as needed) with useHead for title/description; nav/footer/supra live in web/layouts/default.vue (pages supply content only). Use ui-shell classes; NO hardcoded colors/fonts. If you need a NEW shared token/component, add it to ui-shell/src/css FIRST, bump ui-shell version+tag (git tag vX; push), then npm i @riverchristianchurch/ui-shell@github:RiverChristianChurch/ui-shell#vX in web and use it. Give never highlighted; supra carries Preschool + This Week; taxonomy undecided -> current ministry names. Never touch ui-shell/options/ or brand-guide decisions (accent/type/logo tiers/seasonal) — propose via issue. VALIDATE: cd ~/dev/rcc/web && npm run build must pass; boot node .output/server/index.mjs and curl the route to confirm SSR renders real content; internal links/anchors resolve; responsive 768/1024; no hardcoded colors. SHIP: small commits to web main + push (Vercel deploys); if ui-shell changed, push it + its new tag first. Then check the section box in ui-shell docs/NIGHTLY-LOOP.md (commit to ui-shell), and update that section status dot in the sitemap artifact (pass URL https://claude.ai/code/artifact/8f944e6e-eb71-4f83-9e4a-61e3445562c0 to the Artifact tool) from open to partial/done. REPORT: append to ui-shell docs/NIGHTLY-REPORTS.md — date, section, route shipped, the >=2 borrowings, DRAFT-flagged list, decisions needed. Anything needing Jason = a GitHub issue labeled needs-jason (repo you touched; default RiverChristianChurch/web). Then call PushNotification ONCE with a phone-readable summary. ONE section per night — STOP after the report. Never commit secrets. Begin now.'

tmux send-keys -t "$SESSION" -l "$PROMPT"
sleep 2
tmux send-keys -t "$SESSION" Enter
sleep 2
# If Claude Code staged the text as a paste chip instead of submitting, press Enter again.
for k in 1 2 3; do
  p=$(tmux capture-pane -t "$SESSION" -p -S -5 2>/dev/null)
  if echo "$p" | grep -qiE "Pasted text|paste again to expand"; then
    tmux send-keys -t "$SESSION" Enter
    sleep 2
  else
    break
  fi
done

echo "Injected nightly prompt into '$SESSION'. It will build one section and PushNotify Jason."
echo "========== rcc-web nightly done $(date '+%Y-%m-%d %H:%M:%S') =========="
