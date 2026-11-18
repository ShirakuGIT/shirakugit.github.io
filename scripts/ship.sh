#!/usr/bin/env bash
#
# ship.sh — save your changes AND update the public site (shivaram.net), any time.
#
#   ./scripts/ship.sh                  # auto message from what changed, asks once, then ships
#   ./scripts/ship.sh "my message"     # your own commit message
#   ./scripts/ship.sh -y               # no prompt (also: ./scripts/ship.sh -y "message")
#   ./scripts/ship.sh --no-deploy      # commit + push the source only, skip the live site
#
# Flow: verify the site builds -> show changes -> commit -> pull --rebase -> push main
#       -> `rake publish` (clean build of HEAD, force-push to gh-pages) -> wait until it is live.
# Works for new blog posts, notes, design tweaks, anything in this repo.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

YES=0; MSG=""; DEPLOY=1
for a in "$@"; do
  case "$a" in -y|--yes) YES=1 ;; --no-deploy) DEPLOY=0 ;; *) MSG="$a" ;; esac
done

branch="$(git rev-parse --abbrev-ref HEAD)"
[ "$branch" = "HEAD" ] && { echo "Detached HEAD; check out a branch first."; exit 1; }

# Never stage OS junk, even if .gitignore misses it.
git add -A -- . ':!.DS_Store' ':!**/.DS_Store' ':!.publish.*.log' 2>/dev/null

if git diff --cached --quiet; then
  echo "Nothing to commit."
  git fetch -q origin "$branch" 2>/dev/null
  ahead="$(git rev-list --count "origin/$branch..HEAD" 2>/dev/null || echo 0)"
  if [ "$ahead" -gt 0 ]; then echo "…but $ahead local commit(s) are unpushed; pushing."; git push origin "$branch" || exit 1; fi
  [ "$DEPLOY" -eq 1 ] || exit 0
  NOTHING=1
fi

if [ "${NOTHING:-0}" -ne 1 ]; then
echo "Changes to commit on '$branch':"
git status --short | sed 's/^/  /'
echo

# Build check: a broken site should not be committed by accident.
if ! out="$(bundle exec jekyll build 2>&1)"; then
  echo "$out" | tail -15; echo "Build failed; not committing."; git reset -q; exit 1
fi
if echo "$out" | grep -qE "Liquid Exception|YAML Exception|^ *Error:"; then
  echo "$out" | grep -E "Exception|Error:" | head; echo "Build has errors; not committing."; git reset -q; exit 1
fi
echo "Build OK."

# Auto message: prefix by what changed, plus the file count.
if [ -z "$MSG" ]; then
  files="$(git diff --cached --name-only)"
  if   echo "$files" | grep -qE '^_(posts|notes)/';            then prefix="content"
  elif echo "$files" | grep -qE '^(assets/|_layouts/|_includes/|_sass/)'; then prefix="feat"
  else prefix="chore"; fi
  n="$(echo "$files" | wc -l | tr -d ' ')"
  first="$(echo "$files" | head -1)"
  MSG="$prefix: update $first$( [ "$n" -gt 1 ] && echo " and $((n-1)) more")"
fi

if [ "$YES" -ne 1 ]; then
  printf "Commit and push with message \"%s\"? [Y/n] " "$MSG"
  read -r ans
  case "$ans" in n|N|no|NO) git reset -q; echo "Cancelled; nothing committed."; exit 0 ;; esac
fi

git commit -q -m "$MSG" -m "Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>" || { echo "Commit failed."; exit 1; }

if ! git pull --rebase -q origin "$branch"; then
  echo "Rebase hit a conflict. Resolve it, run 'git rebase --continue', then re-run this script."; exit 1
fi
git push origin "$branch" && echo "Pushed $(git rev-parse --short HEAD) to origin/$branch." || exit 1
fi

[ "$DEPLOY" -eq 1 ] || { echo "Source pushed; live site not touched (--no-deploy)."; exit 0; }

echo "Deploying to gh-pages..."
bundle exec rake publish 2>&1 | tail -4 || { echo "Deploy failed."; exit 1; }

# GitHub Pages / the CDN can take a minute: poll until the new build stamp is served.
stamp="$(grep -o 'site.css?v=[0-9]*' _site/index.html | head -1)"
echo "Waiting for the live site ($stamp)..."
for i in $(seq 1 40); do
  if curl -s "https://shivaram.net/?x=$RANDOM" | grep -q "$stamp"; then echo "Live: https://shivaram.net"; exit 0; fi
  sleep 5
done
echo "Pushed, but the live site has not shown the new build yet (CDN cache). Check https://shivaram.net in a minute."
