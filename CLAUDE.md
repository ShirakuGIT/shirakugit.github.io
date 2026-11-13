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
- **`assets/site.css` — the site's design ("homepage" style, Nov 2026)**: an early-2000s academic homepage — wide 980px page, Latin Modern Roman 8 (self-hosted in `assets/fonts/`), very few colours as CSS variables, dark mode via `prefers-color-scheme`. Plain CSS, no Bootstrap, no icon fonts. Read `AGENTS.md` §7.0 before any styling work.
- `_sass/SHB_css.scss` / `assets/main.scss` — the retired dark "earthy" Bootstrap theme, no longer linked; slated for deletion. `_plugins/plain_preview.rb` + `/plain/` are the design prototypes used to choose the style (also slated for removal).
- `scripts/ab_compare.py` — A/B regression harness: compares two production builds page by page (SEO head, content text, links, anchors, broken refs; `--shots` for side-by-side screenshots). Run it for any layout/style change.
- `assets/visits.json` — visitor-map data. The daily GitHub Actions bot that used to commit it was removed in `8fe9ef0` (Nov 2026); refresh with `scripts/fetch_visits.py`, don't hand-edit. Still `git pull --rebase origin main` before pushing.

## Gotchas

- **kramdown mangles raw HTML in `.md` files** (`parse_block_html: true`). Any hand-written HTML/JS block in a markdown page must be wrapped in `{::nomarkdown} ... {:/nomarkdown}` (Liquid still works inside it). The built-in `include`s (figure/video/gif/jupyter/tex) already handle this themselves.
- **Never commit or push unless explicitly asked.** When you do, follow the existing commit style (`chore:`, `content:`, `tex:`, `feat:` — check `git log --oneline -10`) and rebase before pushing per the CI-bot note above.
- Styling follows the **homepage style** (`AGENTS.md` §7.0): wide, LM Roman 8, minimal colours (variables, light + dark), plain HTML, no added chrome. Verify with `scripts/ab_compare.py`.
- Shiva's machine runs warm: keep screenshot passes and extra servers to a minimum and stop them when done.
- Shiva often has their own `jekyll serve` on :4000 — don't kill it. For plugin changes (which need a restart), run a second server on another port.
