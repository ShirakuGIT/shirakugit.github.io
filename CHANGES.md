# CHANGES.md — Performance Pass (2026-06-07)

Rollback log for the perf fixes. Originals backed up in `.backup-perf/`.

## What changed

| Item | Before | After | Reduction |
|------|--------|-------|-----------|
| `images/headshot.jpg` | 2048×2048, 5.0 MB | 1024×1024, 108 KB q65 JPEG | -98% |
| `_includes/head.html` og:image meta | width/height = 2048 | width/height = 1024 | — |

That's it. The other slowness suspects in `shirakugit.github.io-1` (gh-pages-1) were already fixed in source but never deployed; this pass re-runs `rake publish` so those land too.

## What was already fine in source (no action needed)

- Academicons / FontAwesome already moved off dead `cdn.rawgit.com` → `cdn.jsdelivr.net` in `_includes/head.html`.
- Analytics with empty IDs already gated behind `{% if jekyll.environment == 'production' %}`.
- Navbar no longer inlines the 216 KB `bnw.ico` — uses `images/logo-light.png` (15 KB).
- Modern PNG favicons (96/48/32/16, apple-touch-icon) already in place; `favicon.ico` is 8.7 KB.
- Photography in `images/photography/` already compressed (≤1.1 MB each, 8 MB total). The 77 MB pile in the `shirakugit.github.io-1` working tree is untracked and never deploys via rake publish.

## Why the live site (shivaram.net) was slow

The last `rake publish` predates the source-side fixes. So gh-pages was still serving:
- `headshot.jpg` 5 MB rendered at 60% width on the home jumbotron
- `bnw.ico` 216 KB used as favicon AND inline nav logo at 30×30
- A blocking `<link>` to dead `cdn.rawgit.com/jpswalsh/academicons` (301 → fail)
- 3 analytics scripts firing with empty IDs

This pass: shrink the headshot, then redeploy so all the queued source improvements ship.

## Rollback

### Just revert the headshot

```bash
cd /Users/shiraku/Documents/Coding/shirakugit.github.io
cp .backup-perf/headshot.jpg.orig images/headshot.jpg
# undo og:image dims
sed -i '' 's|content="1024"|content="2048"|g' _includes/head.html
bundle exec rake publish
```

### Full revert via git (after the commit lands)

```bash
cd /Users/shiraku/Documents/Coding/shirakugit.github.io
git log --oneline | head           # find the perf commit
git revert <perf-commit-sha>       # creates inverse commit
bundle exec rake publish           # redeploy gh-pages from reverted source
```

### Nuclear option (re-deploy a known-good gh-pages snapshot)

`rake publish` force-pushes `gh-pages`, so the old branch tip is gone from the remote. If a snapshot is needed before rolling forward, grab the previous gh-pages tip SHA from local `shirakugit.github.io-1/.git` and force-push that back up:

```bash
cd /Users/shiraku/Documents/Coding/shirakugit.github.io-1
git log gh-pages --oneline | head  # pick a prior snapshot SHA
git push -f origin <sha>:gh-pages
```

## Backups

`/.backup-perf/headshot.jpg.orig` — original 2048×2048 5.0 MB headshot.
`/.backup-perf/bnw.ico.orig` — original 216 KB bnw.ico (untouched in this pass; kept for safety).
