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
# section every night). Work happens in ~/dev/rcc/ui-shell; research audits are read from
# ~/dev/rcc/web/docs/research/.
set -uo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
SESSION="rcc-web"
REPO="$HOME/dev/rcc/ui-shell"
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

# 3. Clean tree on main in the ui-shell repo (that's what the loop commits), or bail.
cd "$REPO" || { echo "FATAL: cannot cd $REPO"; exit 1; }
git checkout main >/dev/null 2>&1
git pull --ff-only >/dev/null 2>&1 || echo "WARN: main not fast-forward; continuing."
if [ -n "$(git status --porcelain)" ]; then
  echo "SKIP: ui-shell working tree dirty — leaving it for Jason."
  exit 0
fi

# 4. Inject the one-line nightly prompt and submit it robustly.
PROMPT='NIGHTLY RCC WEBSITE ITERATION. cd ~/dev/rcc/ui-shell && git pull, then follow docs/NIGHTLY-LOOP.md EXACTLY. Take the FIRST unchecked section from the queue in that file. Research the model churches for THAT section only (single-site cohort first — E91, Venture, Real Life Sac, Motivation, Fusion, Brooklake — via the raw audits at ~/dev/rcc/web/docs/research/church-site-audits-2026-08.json plus live fetches; note 2-3 concrete borrowings in the report). Pull real RCC copy from https://riverchristian.church. HARD RULES: RCC content takes precedence — edit only for grammar and flow; any copy you invent gets an inline .rcc-draft badge ("DRAFT — needs review") until Jason reviews. Tokens and rcc- prefixed components only, no hardcoded colors/fonts; follow brand/index.html. Give is never visually highlighted; the supra-menu carries Preschool + This Week; taxonomy is undecided so use current ministry names verbatim. Never touch options/ or brand-guide decisions (accent/type/logo tiers/seasonal) — propose those via issue. Build beta/<section>.html pages using existing tokens/components; link every new page from the beta switcher + beta/index.html. VALIDATE: links resolve on Pages paths, responsive at 768/1024, both logo tiers correct, no console errors, no hardcoded colors. SHIP: small commits to main, push (Pages auto-publishes). Then check the section box in docs/NIGHTLY-LOOP.md (commit it), and update that section status dot in the sitemap artifact (pass its URL https://claude.ai/code/artifact/8f944e6e-eb71-4f83-9e4a-61e3445562c0 to the Artifact tool) from open to partial/done. REPORT: append to docs/NIGHTLY-REPORTS.md — date, section, what shipped (URLs), borrowings, list of DRAFT-flagged copy, decisions needed. Anything needing Jason = a GitHub issue on RiverChristianChurch/ui-shell labeled needs-jason. Then call PushNotification ONCE with a phone-readable summary (what shipped + any decisions). ONE section per night — STOP after the report. Never commit secrets. Begin now.'

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
