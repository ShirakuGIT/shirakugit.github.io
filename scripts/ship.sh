#!/usr/bin/env bash
#
# ship.sh — build, commit and push in one go, with no preview and no prompt.
#
#   ./scripts/ship.sh "feat: what changed"
#
# Steps: clean build (fails on any Liquid/YAML error) → git add -A and commit
# → git pull --rebase → rake publish (gh-pages) → git push (main).
# Use scripts/publish.sh instead if you want photos processed, a preview and an approval step.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

MSG="${1:-}"
[[ -n "$MSG" ]] || { echo "usage: ./scripts/ship.sh \"commit message\"" >&2; exit 1; }

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
LOG=".ship.build.log"
die() { echo "✗ $*" >&2; exit 1; }

echo "==> Building"
JEKYLL_ENV=production bundle exec jekyll build --trace >"$LOG" 2>&1 || { tail -n 30 "$LOG"; die "build failed, nothing committed (log: $LOG)"; }
if grep -qE 'YAML Exception|Liquid Exception|^[[:space:]]*Error:' "$LOG"; then
  grep -nE 'YAML Exception|Liquid Exception|Error:' "$LOG"
  die "build reported errors, nothing committed (log: $LOG)"
fi
tail -n 2 "$LOG"

echo "==> Committing to $BRANCH"
git add -A
if git diff --cached --quiet; then
  echo "  nothing new to commit, deploying the current commit"
else
  git commit -q -m "$MSG

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>" || die "commit failed"
  git --no-pager log --oneline -1
fi

echo "==> Syncing with origin/$BRANCH"
git pull --rebase origin "$BRANCH" || die "rebase failed, resolve it and re-run"

echo "==> Deploying gh-pages"
bundle exec rake publish || die "rake publish failed, gh-pages not updated"

echo "==> Pushing $BRANCH"
git push origin "$BRANCH" || die "push failed, run: git pull --rebase origin $BRANCH && git push"

echo "✓ Live at https://shivaram.net in about a minute."
