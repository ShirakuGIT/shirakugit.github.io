# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This repo already has two hand-maintained docs written specifically for agents — **read them, don't just read this file**:

- **`AGENTS.md`** — full environment/workflow runbook (topology, commands, deploy/CI, design system, gotchas).
- **`WRITING.md`** — content-authoring guide (blog posts vs. notes, embed syntax, front matter).

This file is a condensed pointer to both, kept short on purpose.

## What this is

A statically generated **Jekyll 4.3.3** site — Shivaram Kumar Jagannathan's personal/academic homepage (robotics researcher, Algorithmic Robotics Group, NTU Singapore), live at **https://shivaram.net**.

## Repo topology (important — two other dirs exist)

| Path | Branch | Role |
|------|--------|------|
| `~/Documents/Coding/shirakugit.github.io` (this repo) | `main` | **Source. Edit here.** |
| `~/Documents/Coding/shirakugit.github.io-1` | `gh-pages` | Built output, force-pushed by `rake publish`. **Never edit.** |

`_site/` (this repo's build output) is also generated/gitignored — never hand-edit it either.

## Commands

```bash
# Preview locally (auto-reloads on save)
bundle exec jekyll serve --livereload      # http://127.0.0.1:4000/

# Clean build — this is the verification/"typecheck" step; no test suite exists
bundle exec jekyll build

# Deploy built _site/ to gh-pages (force-push)
bundle exec rake publish

# Safer one-shot publisher: process photos → build+verify → auto-commit → local preview → prompts before deploying
./scripts/publish.sh [optional commit message]

# Scaffold new content
./new-post.sh "My Post Title" tag1 tag2
./new-note.sh "My Note Title" category tag1 tag2
./new-project.sh "Name" "Subtitle" "https://github.com/u/r" "https://raw.githubusercontent.com/u/r/main/demo.gif" "Caption" "Description."
```

A build is "passing" if it ends with `done in Xs` and has no `Liquid Exception` / `YAML Exception` / `Error:` lines — Sass deprecation warnings from Bootstrap are noise. `bundle exec jekyll build --trace --profile` matches what `scripts/publish.sh` greps for real errors.

Changes to `_plugins/*.rb` need a server restart (Jekyll loads plugins once); config/CSS/Liquid/content hot-reload.

## Architecture

- `_config.yml` — site config, nav (`nav_pages:`), collections (`notes`), SEO, jekyll-scholar settings.
- `_data/*.yml` — single source of truth for most pages: `pi.yml` (bio/sidebar), `projects.yml` (bento grid on `_pages/projects.md`), `news.yml`, `photography.yml`, `awards.yml`. **Edit data files, not hardcoded markup, when changing this kind of content.**
- `_pages/*.md` — top-level pages (about, projects, research, blogs, notes, photography...); front matter drives layout + permalink.
- `_posts/YYYY-MM-DD-slug.md` — polished public blog posts (date parsed from filename).
- `_notes/*.md` — "digital garden" working notes with an `updated:` field and open-ended `category:`; subfolders are allowed.
- `_layouts/*.html` + `_includes/*.html` — page scaffolds and reusable embeds (`figure`, `video`, `gif`, `jupyter_notebook`, tex includes, header/footer/sidebar).
- `_plugins/*.rb` — custom Liquid tags: `tex_compile.rb` (LaTeX→HTML+PDF via pandoc/pdfLaTeX/pdfinfo on PATH, cached under `.jekyll-cache/tex/<sha>/`), `jupyter_notebook.rb`, `markdown.rb`, `ext.rb` (loads jekyll-scholar for the publications page, driven by `assets/ref.bib`).
- `_sass/SHB_css.scss` — the house theme (dark "earthy" palette, EB Garamond display titles) on top of a Bootstrap 5 / Bootswatch Darkly base; compiled into `assets/main.css`.
- `assets/visits.json` — visitor-map data auto-refreshed **daily by a GitHub Actions bot** (`.github/workflows/update-visits.yml`, 04:17 UTC) that commits directly to `main` and mirrors into `gh-pages`. **Always `git pull --rebase origin main` before pushing**, or the push will be rejected; resolve conflicts on this file by keeping theirs. Don't hand-edit it — run `scripts/fetch_visits.py` instead.

## Gotchas

- **kramdown mangles raw HTML in `.md` files** (`parse_block_html: true`). Any hand-written HTML/JS block in a markdown page must be wrapped in `{::nomarkdown} ... {:/nomarkdown}` (Liquid still works inside it). The built-in `include`s (figure/video/gif/jupyter/tex) already handle this themselves.
- **Never commit or push unless explicitly asked.** When you do, follow the existing commit style (`chore:`, `content:`, `tex:`, `feat:` — check `git log --oneline -10`) and rebase before pushing per the CI-bot note above.
- Match the existing design system (palette, fonts, the projects bento-grid's click-to-expand interaction contract) rather than second-guessing it — see `AGENTS.md` §7 for the specifics if you're touching styling.
