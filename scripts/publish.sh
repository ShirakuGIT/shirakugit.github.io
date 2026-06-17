#!/usr/bin/env bash
#
# publish.sh — one-shot content publisher for shivaram.net
#
#   ./scripts/publish.sh                 # full interactive flow
#   ./scripts/publish.sh "commit msg"    # override the auto commit message
#
# Flow:
#   1. process any raw photos dropped in images/photography/  (add_photos.py)
#   2. show what changed, grouped by section (blogs/notes/photography/...)
#   3. build the site with debug/trace + profile, surface warnings
#   4. auto-commit to the current branch
#   5. start a local live preview and open it in your browser
#   6. ask for approval — only on "y" does it deploy (rake publish + git push)
#
# Nothing leaves your machine until you approve at step 6.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
ROOT="$(pwd)"
PORT="${PORT:-4000}"
BUILD_LOG="$ROOT/.publish.build.log"
SERVE_LOG="$ROOT/.publish.serve.log"
SERVE_PID=""

# ---- pretty output ---------------------------------------------------------
if [[ -t 1 ]]; then
  B=$'\e[1m'; DIM=$'\e[2m'; R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; BL=$'\e[34m'; X=$'\e[0m'
else B=; DIM=; R=; G=; Y=; BL=; X=; fi
say()  { printf '\n%s==>%s %s%s\n' "$B$BL" "$X" "$B" "$*$X"; }
ok()   { printf '%s  ✓ %s%s\n' "$G" "$*" "$X"; }
warn() { printf '%s  ! %s%s\n' "$Y" "$*" "$X"; }
die()  { printf '%s  ✗ %s%s\n' "$R" "$*" "$X" >&2; exit 1; }

cleanup() { [[ -n "$SERVE_PID" ]] && kill "$SERVE_PID" 2>/dev/null; SERVE_PID=""; }
trap cleanup EXIT INT TERM

command -v bundle >/dev/null || die "bundle not found — is the Ruby toolchain set up?"
[[ -d .git ]] || die "not a git repo"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# ---- 1. process dropped photos --------------------------------------------
say "Processing new photos (if any)"
if [[ -f scripts/add_photos.py ]]; then
  python3 scripts/add_photos.py || warn "photo step reported a problem — continuing"
else
  warn "scripts/add_photos.py missing — skipping photo step"
fi

# ---- 2. what changed, by section ------------------------------------------
say "Changes since last commit (branch: $BRANCH)"
PORC="$(git status --porcelain)"
if [[ -z "$PORC" ]]; then
  ok "Working tree clean — nothing to publish."
  exit 0
fi
# bucket changed paths into human sections
printf '%s\n' "$PORC" | awk '
  { path=$2; if ($1 ~ /R/) path=$4 }
  /_posts\//                                  {b["Blog posts"]++; next}
  /_notes\//                                  {b["Notes"]++; next}
  /images\/photography\/|_data\/photography/  {b["Photography"]++; next}
  /_pages\/research|research_default|_layouts\/research/ {b["Research"]++; next}
  /ref\.bib|_pages\/publications|_layouts\/publications/ {b["Publications"]++; next}
  /_pages\/projects|_pages\/software/         {b["Projects"]++; next}
  /^.*cv\//                                   {b["CV"]++; next}
  /_pages\//                                  {b["Pages"]++; next}
  /_data\//                                   {b["Data"]++; next}
  /_sass\/|_includes\/|_layouts\/|assets\//   {b["Layout/CSS/JS"]++; next}
  /_config\.yml/                              {b["Config"]++; next}
  /scripts\//                                 {b["Scripts"]++; next}
  {b["Other"]++}
  END { for (k in b) printf "    %-16s %d file(s)\n", k, b[k] }
' | sort
echo "$DIM"; git -c color.ui=never status --short; echo "$X"

# ---- 3. build with debug ---------------------------------------------------
say "Building site (jekyll build --trace --profile)"
if JEKYLL_ENV=production bundle exec jekyll build --trace --profile >"$BUILD_LOG" 2>&1; then
  # Jekyll exits 0 even when it skips a file with bad front matter, so check the log.
  ERRS=$(grep -cE 'YAML Exception|Liquid Exception|^[[:space:]]*Error:' "$BUILD_LOG" || true)
  W=$(grep -ci 'warning' "$BUILD_LOG" || true)
  tail -n 12 "$BUILD_LOG"
  if [[ "$ERRS" -gt 0 ]]; then
    echo "$R"; grep -nE 'YAML Exception|Liquid Exception|Error:' "$BUILD_LOG"; echo "$X"
    die "Build reported $ERRS error(s) — e.g. malformed front matter. Fix before deploying. Log: $BUILD_LOG"
  fi
  [[ "$W" -gt 0 ]] && warn "$W warning line(s) (Sass deprecations etc.) — see $BUILD_LOG"
  ok "Build succeeded (full log: $BUILD_LOG)"
else
  echo "$R"; tail -n 30 "$BUILD_LOG"; echo "$X"
  die "Build FAILED — fix the above, nothing was committed. Full log: $BUILD_LOG"
fi

# ---- 4. auto-commit --------------------------------------------------------
say "Committing to $BRANCH"
git add -A
if git diff --cached --quiet; then
  warn "Nothing staged to commit."
else
  MSG="${1:-}"
  if [[ -z "$MSG" ]]; then
    parts=$(git diff --cached --name-only | awk '
      /_posts\//{p["blog"]=1;next} /_notes\//{p["notes"]=1;next}
      /images\/photography\/|_data\/photography/{p["photography"]=1;next}
      /ref\.bib|_pages\/publications/{p["publications"]=1;next}
      /_pages\/research|research_default/{p["research"]=1;next}
      /_pages\/projects|_pages\/software/{p["projects"]=1;next}
      /cv\//{p["cv"]=1;next} /_pages\//{p["pages"]=1;next}
      /_sass\/|_includes\/|_layouts\/|assets\//{p["site"]=1;next}
      {p["misc"]=1}
      END{o="";for(k in p)o=o (o?", ":"") k; print o}')
    MSG="content: update ${parts:-site}"
  fi
  git commit -q -m "$MSG" && ok "Committed: $MSG"
fi

# ---- 5. local preview ------------------------------------------------------
say "Starting local preview at http://127.0.0.1:$PORT/"
bundle exec jekyll serve --livereload --port "$PORT" --skip-initial-build >"$SERVE_LOG" 2>&1 &
SERVE_PID=$!
for _ in $(seq 1 40); do
  curl -fsS "http://127.0.0.1:$PORT/" >/dev/null 2>&1 && break
  sleep 0.5
done
if curl -fsS "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
  open "http://127.0.0.1:$PORT/" 2>/dev/null || true
  ok "Preview is live — review it in your browser."
else
  warn "Preview didn't come up; check $SERVE_LOG"
fi

# ---- 6. approve + deploy ---------------------------------------------------
printf '\n%sDeploy this to shivaram.net? [y/N] %s' "$B" "$X"
read -r ans
cleanup   # stop the preview server before deploying

if [[ "$ans" =~ ^[Yy]$ ]]; then
  # The visitor-map bot pushes to this branch daily, so the remote is usually
  # ahead. Rebase first or the source push gets rejected (fetch first).
  say "Syncing $BRANCH with origin (visitor-map bot also pushes here)"
  git pull --rebase origin "$BRANCH" || die "rebase on origin/$BRANCH failed — resolve, then re-run."
  say "Deploying"
  bundle exec rake publish || die "rake publish failed — gh-pages NOT updated."
  git push origin "$BRANCH"   || warn "source push failed — run: git pull --rebase origin $BRANCH && git push"
  ok "Deployed. Live at https://shivaram.net (GitHub Pages CDN ~1 min)."
else
  warn "Skipped deploy. The commit is local only on '$BRANCH'."
  echo "    Deploy later:  bundle exec rake publish && git push"
  echo "    Undo commit:   git reset --soft HEAD~1"
fi
