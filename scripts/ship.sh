#!/usr/bin/env bash
#
# ship.sh — save your changes and/or update the public site (shivaram.net), any time.
#
#   ./scripts/ship.sh                       # suggest a message (Enter = accept, type your own, e = editor, q = cancel)
#   ./scripts/ship.sh "my message"          # your message (bare argument)
#   ./scripts/ship.sh -m "Subject" -m "A paragraph of detail" -m "Another"   # multi-paragraph message
#   ./scripts/ship.sh -e                    # write the message in $EDITOR (git's usual commit editor)
#   ./scripts/ship.sh -p _posts -p WRITING.md "msg"   # stage ONLY these paths (repeatable); default: everything
#
#   -y, --yes          never prompt
#   -n, --dry-run      show what would happen, change nothing
#       --no-build     skip the pre-commit build check
#       --no-push      commit only (no push, no deploy)
#       --no-deploy    commit + push the source, leave the live site alone
#       --deploy-only  skip commit/push; just rebuild and publish what is already committed
#   -h, --help         this text
#
# Default flow: build check -> show changes -> commit -> pull --rebase -> push -> `rake publish`
# (clean build of HEAD, force-push to gh-pages) -> wait until shivaram.net serves the new build.
# The commit is yours alone: no co-author trailer is added.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

YES=0; DRY=0; BUILD=1; PUSH=1; DEPLOY=1; DEPLOY_ONLY=0; EDIT=0
MSGS=(); PATHS=()
usage() { sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) YES=1 ;;
    -n|--dry-run) DRY=1 ;;
    --no-build) BUILD=0 ;;
    --no-push) PUSH=0; DEPLOY=0 ;;
    --no-deploy) DEPLOY=0 ;;
    --deploy-only) DEPLOY_ONLY=1 ;;
    -e|--edit) EDIT=1 ;;
    -m|--message) shift; [ $# -gt 0 ] || { echo "-m needs a message"; exit 2; }; MSGS+=("$1") ;;
    -p|--path) shift; [ $# -gt 0 ] || { echo "-p needs a path"; exit 2; }; PATHS+=("$1") ;;
    -h|--help) usage; exit 0 ;;
    --) shift; PATHS+=("$@"); break ;;
    -*) echo "Unknown option: $1"; usage; exit 2 ;;
    *) MSGS+=("$1") ;;
  esac
  shift
done

run() { if [ "$DRY" -eq 1 ]; then echo "  (dry run) $*"; else "$@"; fi; }

branch="$(git rev-parse --abbrev-ref HEAD)"
[ "$branch" = "HEAD" ] && { echo "Detached HEAD; check out a branch first."; exit 1; }

deploy() {
  echo "Deploying to gh-pages..."
  if [ "$DRY" -eq 1 ]; then echo "  (dry run) bundle exec rake publish"; return 0; fi
  bundle exec rake publish 2>&1 | tail -4
  [ "${PIPESTATUS[0]}" -eq 0 ] || { echo "Deploy failed."; return 1; }
  stamp="$(grep -o 'site.css?v=[0-9]*' _site/index.html | head -1)"
  echo "Waiting for the live site ($stamp)..."
  for i in $(seq 1 40); do
    if curl -s "https://shivaram.net/?x=$RANDOM" | grep -q "$stamp"; then echo "Live: https://shivaram.net"; return 0; fi
    sleep 5
  done
  echo "Deployed, but the live site has not shown the new build yet (CDN cache). Check https://shivaram.net in a minute."
}

if [ "$DEPLOY_ONLY" -eq 1 ]; then deploy; exit $?; fi

# ---- stage ----
if [ "${#PATHS[@]}" -gt 0 ]; then
  run git add -A -- "${PATHS[@]}"
else
  run git add -A -- . ':!.DS_Store' ':!**/.DS_Store' ':!.publish.*.log'
fi

if [ "$DRY" -eq 0 ] && git diff --cached --quiet; then
  echo "Nothing to commit."
  git fetch -q origin "$branch" 2>/dev/null
  ahead="$(git rev-list --count "origin/$branch..HEAD" 2>/dev/null || echo 0)"
  if [ "$PUSH" -eq 1 ] && [ "$ahead" -gt 0 ]; then echo "$ahead local commit(s) unpushed; pushing."; git push origin "$branch" || exit 1; fi
  [ "$DEPLOY" -eq 1 ] && deploy
  exit $?
fi

echo "Changes to commit on '$branch':"
if [ "$DRY" -eq 1 ]; then git status --short | sed 's/^/  /'; else git diff --cached --name-status | sed 's/^/  /'; fi
echo

# ---- build check ----
if [ "$BUILD" -eq 1 ]; then
  if ! out="$(bundle exec jekyll build 2>&1)" || echo "$out" | grep -qE "Liquid Exception|YAML Exception|^ *Error:"; then
    echo "$out" | grep -E "Exception|Error" | head -8; echo "Build failed; not committing. (Use --no-build to override.)"
    [ "$DRY" -eq 1 ] || git reset -q; exit 1
  fi
  echo "Build OK."
fi

# ---- message ----
suggest() {
  files="$(git diff --cached --name-only)"; [ "$DRY" -eq 1 ] && files="$(git status --short | awk '{print $2}')"
  if   echo "$files" | grep -qE '^_(posts|notes)/'; then prefix="content"
  elif echo "$files" | grep -qE '^(assets/|_layouts/|_includes/|_sass/)'; then prefix="feat"
  else prefix="chore"; fi
  n="$(echo "$files" | grep -c .)"; first="$(echo "$files" | head -1)"
  echo "$prefix: update $first$( [ "$n" -gt 1 ] && echo " and $((n-1)) more")"
}

COMMIT_ARGS=()
if [ "${#MSGS[@]}" -gt 0 ]; then
  for m in "${MSGS[@]}"; do COMMIT_ARGS+=(-m "$m"); done
elif [ "$EDIT" -eq 1 ]; then
  COMMIT_ARGS+=(-e)
elif [ "$YES" -eq 1 ] || [ "$DRY" -eq 1 ]; then
  COMMIT_ARGS+=(-m "$(suggest)")
else
  s="$(suggest)"
  echo "Commit message: Enter = suggestion, type your own, e = open editor, q = cancel."
  printf '  [%s]\n> ' "$s"; read -r ans
  case "$ans" in
    q|Q) git reset -q; echo "Cancelled; nothing committed."; exit 0 ;;
    e|E) COMMIT_ARGS+=(-e -m "$s") ;;
    "")  COMMIT_ARGS+=(-m "$s") ;;
    *)   COMMIT_ARGS+=(-m "$ans") ;;
  esac
fi

if [ "$YES" -ne 1 ] && [ "$DRY" -eq 0 ] && { [ "${#MSGS[@]}" -gt 0 ] || [ "$EDIT" -eq 1 ]; }; then
  printf 'Commit%s? [Y/n] ' "$([ "$PUSH" -eq 1 ] && echo ", push")$([ "$DEPLOY" -eq 1 ] && echo " and deploy")"; read -r ans
  case "$ans" in n|N|no|NO) git reset -q; echo "Cancelled; nothing committed."; exit 0 ;; esac
fi

# ---- commit / push / deploy ----
run git commit -q "${COMMIT_ARGS[@]}" || { echo "Commit failed."; exit 1; }
if [ "$PUSH" -eq 1 ]; then
  run git pull --rebase -q origin "$branch" || { echo "Rebase hit a conflict. Resolve it, 'git rebase --continue', then re-run."; exit 1; }
  run git push origin "$branch" || exit 1
  [ "$DRY" -eq 1 ] || echo "Pushed $(git rev-parse --short HEAD) to origin/$branch."
fi
[ "$DEPLOY" -eq 1 ] && { deploy; exit $?; }
exit 0
