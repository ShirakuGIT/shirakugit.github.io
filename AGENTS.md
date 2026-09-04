# AGENTS.md — Agent runbook for shivaram.net

Operational guide for AI agents (and humans) working in this repo. It gives you
context over the whole environment so you don't have to re-discover it. Read
the whole file once; skim the table below on later visits.

Sibling doc: **`WRITING.md`** is the content-authoring guide (embeds, syntax,
post-vs-note). This file is the environment + workflow runbook. Read both.

---

## 0. What this repository is

A statically generated **Jekyll 4.3.3** site — the personal/academic homepage
of **Shivaram Kumar Jagannathan** (robotics researcher, Algorithmic Robotics
Group, NTU Singapore). Live at **https://shivaram.net**.

- Source branch: `main` (this directory).
- Built output: `_site/`, which is force-pushed to the **`gh-pages`** branch of
  the same GitHub repo and served by GitHub Pages behind the `CNAME`.
- Owner/person: Shiva — robotics, spatial intelligence, 3D reconstruction,
  robot deployments. Brand voice: technical, concise, occasionally personal.

Three repos have to be tracked separately:

| Path | Branch | Role |
|------|--------|------|
| `~/Documents/Coding/shirakugit.github.io`   | `main`      | **Source. Edit here.** |
| `~/Documents/Coding/shirakugit.github.io-1` | `gh-pages`  | Built output. **Never edit.** Overwritten on every deploy. |
| github.com/ShirakuGIT/... (remote `origin`) | both        | Remote backing each branch |

---

## 1. Fast facts for agents

| Thing | Where | Notes |
|-------|-------|-------|
| Site config, nav, collections, SEO | `_config.yml` | `nav_pages:`, `collections: {notes}`, `scholar:` block |
| Personal data (name, photo, cv, socials, education) | `_data/pi.yml` | Sidebar + about page |
| Projects | `_data/projects.yml` | Driven by `_pages/projects.md` (bento grid) |
| News | `_data/news.yml` | Home sidebar shows `limit:3`, links to `allnews.html` |
| Photography feed | `_data/photography.yml` + `images/photography/` | Newest first |
| Bibliography | `assets/ref.bib` | Rendered by jekyll-scholar (publications page) |
| Pages | `_pages/*.md` | Front matter drives layout + permalink |
| Blog posts | `_posts/YYYY-MM-DD-slug.md` | Requires date in filename |
| Notes | `_notes/*.md` | "digital garden", `updated:` field, category filter |
| Layouts | `_layouts/*.html` | `default` → `homelay`/`gridlay`/`page`/`post`/`note`/... |
| Reusable snippets | `_includes/*.html` | `figure video gif jupyter_notebook calendar …` |
| Custom plugins | `_plugins/*.rb` | Require Jekyll restart |
| Styles | `_sass/SHB_css.scss` | House theme; **two SCSS entry wobbles below** |
| Deploy | `scripts/publish.sh`, `Rakefile` | `rake publish` = build+push gh-pages |
| Live data (visitor map) | `assets/visits.json` | Auto-updated daily by CI bot — don't hand-edit |
| Current server log | `.jekyll-serve.log` | Generated, gitignored |

---

## 2. Commands (the whole workflow)

```bash
# Preview locally (auto-reloads on save)
bundle exec jekyll serve --livereload
# → http://127.0.0.1:4000/  (live reload socket :35729)

# Clean one-shot build (also the verification step before anything ships)
bundle exec jekyll build

# Full width layout sanity check (compile CSS + HTML, no serve)
bundle exec jekyll build --limit_posts 0

# Deploy built _site/ to gh-pages (force-push)
bundle exec rake publish

# One-shot publisher: process photos → build+verify → auto-commit → preview →
# prompts for approval before deploying (rebase-aware)
./scripts/publish.sh [optional commit message]

# Scaffold new content
./new-post.sh "My Post Title" tag1 tag2
./new-note.sh "My Note Title" course cs231n cv
./new-project.sh "Name" "Subtitle" "https://github.com/u/r" \
  "https://raw.githubusercontent.com/u/r/main/demo.gif" "Caption" "Description."
```

**Never commit/push unless explicitly asked.** When you do: stage only intended
files, write a conventional message (see `git log --oneline -10` for style:
`chore:`, `content:`, `tex:`, `feat:`), and rebase before pushing (see §5).

---

## 3. Directory map

```
config          _config.yml          # mirrors TITLE/description in _data and head
data            _data/*.yml          # single source of truth for most pages
pages           _pages/*.md          # about projects research blogs notes photography ...
layouts         _layouts/*.html      # page scaffolds
includes        _includes/*.html     # reusable embeds + header/footer/sidebar
plugins         _plugins/*.rb        # custom Liquid tags + hooks
content         _posts/, _notes/     # blog posts + digital garden
assets          main.scss, ref.bib, notebooks/, papers/, visits.json, fonts/, javascript/
images          headshot, logos/, photography/, projects/, *.png infographics
styles          _sass/SHB_css.scss + bootstrap/ + bootstrap.scss (bootswatch Darkly)
scripts         publish.sh, add_photos.py, fetch_visits.py
scaffolds       new-post.sh, new-note.sh, new-project.sh
generated       _site/ (.gitignored) gh-pages branch output — do not hand-edit
cache/logs      .jekyll-cache/ (tex compile cache) .jekyll-serve.log .publish*.log
```

Generated and forces you to ignore them: `_site/`, `.jekyll-cache/`,
`.sass-cache/`, `.jekyll-metadata`, logs. `_site` in `.gitignore`. The
`gh-pages` sibling directory is disposable.

---

## 4. Tech stack & how the build works

- **Jekyll 4.3.3** (pinned in `Gemfile`), Ruby, kramdown with `input: GFM` and
  **`parse_block_html: true`**.
- **Bootstrap 5** compiled from `_sass/bootstrap.scss` (bootswatch Darkly
  override) + custom `_sass/SHB_css.scss` shipped as one `assets/main.css`.
- **jekyll-scholar** for the publications page (config under `scholar:`).
  `_plugins/ext.rb` just requires `jekyll/scholar`.
- **jekyll-seo-tag**, **jekyll-sitemap**, **jekyll-feed**.
- Icon sets loaded in `_includes/head.html`: Phosphor (`.ph-*`), Font Awesome 6
  (`.fa-brands/.fa-solid/.fa-regular`), Academicons (`.ai-*`). All available on
  every page — use whatever fits the component.
- MathJax loaded site-wide (`_includes/mathjax.html`, `tags: 'ams'` so
  `\label`/`\eqref` work).
- Custom plugins: `tex_compile.rb` (LaTeX→HTML + PDF), `jupyter_notebook.rb`
  (embed `.ipynb`), `markdown.rb` (`{% markdown file %}`), `ext.rb`.

### Custom embeds in markdown

```liquid
{% include figure.html src="/images/x.jpg" caption="..." width="80%" %}
{% include video.html youtube="ID" caption="..." %} | vimeo="ID" | mp4="/videos/x.mp4"
{% include gif.html src="/images/x.gif" %} | gif.html mp4="/images/x.mp4"
{% jupyter_notebook "/assets/notebooks/file.ipynb" %}           # absolute /assets paths only
{% tex_cell label=my-paper %} ... \section{...} ... {% endtex_cell %}
{% tex_file "/assets/papers/example.tex" %}
```

`tex_compile.rb` requires **pandoc, pdfLaTeX (TeX Live), pdfinfo** (poppler) on
PATH; overridable via `PANDOC`/`PDFLATEX`/`PDFINFO`/`PDFTOCAIRO` env vars.
Compiled PDFs + TikZ SVGs are cached in `.jekyll-cache/tex/<sha>/`. The white
background paper keeps original colors; SVG diagrams are auto-brightened for the
dark theme. Rendering happens at build time; failures degrade gracefully to an
error card. The `research` page is meant to showcase this eventually.

> **Jekyll restart rule:** changes to `_plugins/*.rb` require a server restart
> (Jekyll loads plugins once). Config/CSS/Liquid/content reload automatically.

---

## 5. Deployment topology & CI (read before pushing anything)

- `bundle exec rake publish` builds `_site/` (production Jekyll) then initializes
  a throwaway git repo in a tmpdir with `_site/.` and force-pushes it to
  `origin gh-pages`. GitHub Pages serves `gh-pages` at the `CNAME` domain.
- `scripts/publish.sh` is the safe path: adds photos, builds with
  `--trace --profile`, greps the build log for real errors (Jekyll exits 0 even
  on bad front matter), commits, previews locally, then **waits for explicit
  "y"** before `rake publish` + `git push`.
- **The visitor-map bot pushes commits every day.** GitHub Action
  `.github/workflows/update-visits.yml` runs at `04:17 UTC`: fetches Cloudflare
  RUM counts into `assets/visits.json`, commits to `main`, then mirrors the
  same JSON into `gh-pages`. Consequence: `main` is frequently ahead of your
  local copy. **Always `git pull --rebase origin main` before pushing** or the
  push is rejected. Handle any rebase conflict by keeping theirs for
  `assets/visits.json`.
- Don't hand-edit `assets/visits.json`; run `bash scripts/fetch_visits.py` (or
  the workflow's env vars) if a refresh is needed.

---

## 6. Content model

| | Blog post (`_posts/`) | Note (`_notes/`) |
|--|--|--|
| Tone | Polished, public | Working draft, garden |
| Date model | Pinned publish date | `updated:` field |
| URL | `/YYYY/MM/DD/slug.html` | `/notes/slug/` |
| Listing | `/blogs/` chrono | `/notes/` category tabs |
| Front matter | `layout: post, title, date, author, tags` | `title, category, status, updated, tags, summary, source` |

- Filename **must** be `YYYY-MM-DD-slug.md` for posts — Jekyll parses date from it.
- Note categories are open-ended (`course|paper|book|tutorial|lab|art|misc`);
  listing auto-discovers. Custom badge color → add `.note-category-<cat>` in
  `SHB_css.scss`.
- Subfolders work under `_notes/` (`_notes/cs231n/lec02.md` → `/notes/cs231n/lec02/`).
- Pages live in `_pages/` with front matter `title/layout/sitemap/permalink`.
  Required on every page.

### To add a new navbar entry
1. Create `_pages/<name>.md` with a unique `permalink`.
2. Add `- name: <name>` to `nav_pages:` in `_config.yml` (cabist: it just
   links `/`, `/about`, ... and capitalizes the label).

### To add a new note category badge
```scss
.note-category-<name> { background: #yourcolor; }
```
otherwise it falls back to grey `misc`.

---

## 7. Design system (the house style)

- **Palette** (`SHB_css.scss` top):
  - `$earth-orange #bd5d34` lite `#d07a3f` dark `#9c4a28` (accents, hovers)
  - `$earth-green #8f9e6a` (links at rest, kickers)
  - `$earth-ink #201f1c` / `$earth-raise #2b2823` / `$earth-line #3a352e` (bg layers)
  - `$earth-text #c4baa9` / `$earth-muted #8c8576`
  - Cream accents used for headings: e.g. `#efe6d3`, `#e2d7bd`.
- **Fonts**: SF-system stack (`$font-sf`) for body/UI; **EB Garamond**
  (`$font-garamond`) for display titles (project cards, hero). Defined at
  `SHB_css.scss` (search `$font-garamond`).
- **Feel**: dark, warm "earthy" minimal — generous radii (16–18px), hairline
  borders (`rgba($earth-green,.2~.25)`), subtle glass (backdrop blur) pills,
  lifted shadows on hover, orange for the interactive element.
- **Reading column**: `.container-fluid { max-width: 720px }` site-wide.
  **Exception:** `body.projects-page .container-fluid { max-width: 1280px }` —
  the only page that escapes the reading column.
- **Per-page body class mechanism** (added recently): `default.html` renders
  `<body class="{{ page.body_class }}">`; any page can declare `body_class:` in
  front matter to scope page-specific styles.

### Projects page (bento grid) — the current showcase
Built from `_data/projects.yml`; `_pages/projects.md` emits the grid; all
styling in `SHB_css.scss` under "Projects page — bento grid".

- 12-col grid, `grid-auto-rows: minmax(320px,auto)`, gap 22px.
- Tile spans (via Liquid `case forloop.index0`):
  - index 0 → `.bento-cell--feature` (span 7, double height)
  - index 1,2 → `.bento-cell--pair` (span 5)
  - index 3 → `.bento-cell--wide` (span 12 full-width banner)
  - else → pair (extras tile 2-across)
- Each tile: media fills behind a bottom `<div class="bento-shade">` gradient;
  `.bento-head` holds the **GitHub chip + arrow** (the only navigation);
  `.bento-body` sits at the bottom (flex column `justify-content: flex-end`).
- **Interaction contract (important, done deliberately):**
  - The card wrapper is `role="button"` `tabindex="0"`, NOT an anchor.
  - Tap/click (or Enter/Space) toggles a `.is-open` class → description
    unrolls (`.bento-desc` is `max-height:0` collapsed otherwise).
  - Hover also unrolls it on desktop.
  - The GitHub chip and arrow are the *only* links; they navigate, not toggle.
  - `aria-expanded` is kept in sync by the inline script in `projects.md`.
- If you redesign/extend this page, preserve: full-width escape, text pinned
  bottom, click-to-expand (mobile has no hover), explicit redirect buttons,
  the earth palette + Garamond titles.

---

## 8. kramdown gotcha (the one that bites)

`parse_block_html: true` — kramdown re-parses block HTML inside `.md` and
**mangles it**. Any hand-written chunk of HTML/JS in a markdown page must be
wrapped:

```
{::nomarkdown}
<div class="...">…raw HTML…</div>
<script>…</script>
{:/nomarkdown}
```

Liquid `include`s (figure/video/gif/jupyter/tex) handle this themselves. You
only need nomarkdown when authoring raw HTML directly (see `projects.md`,
`notes.md` for the pattern). Liquid still runs inside nomarkdown — safe.

---

## 9. Terminals / servers / processes

- Dev server: `bundle exec jekyll serve --livereload`. Check it didn't die:
  `lsof -i :4000` / `lsof -i :35729`. Kill stale ones before starting a new
  server (or you'll get two processes hopping ports).
- `.jekyll-pid` is gitignored and often stale — don't trust it.
- Build output/log files: `.publish.build.log`, `.publish.serve.log`,
  `.jekyll-serve.log` (all gitignored).
- Sass deprecation warnings (Bootstrap's `red()/green()` math) are **noise**,
  not errors. A build is successful if it ends with `done in Xs`, no
  `Liquid Exception` / `YAML Exception` / `Error:` lines.

---

## 10. Tools-available notes (agents)

- Binaries on PATH include `pdflatex`, `pandoc`, `pdfinfo`, `pdftocairo`,
  `python3`, `bundler`/`jekyll`. The tex pipeline therefore works locally.
- No linter/prettier configured. "Typecheck/lint step": `bundle exec jekyll
  build` + the error grep from `publish.sh` (§5). Run it before claiming work.
- There is **no runtime test suite**. Verification = clean build + eyeballing
  the rendered page + `curl http://127.0.0.1:4000/<path>` returns 200.

---

## 11. Current state at time of writing (fresh eyes, high fidelity)

- Projects page has been redesigned to a full-width bento grid (see §7) and is
  working in local preview. If things look off there, check §7 invariants.
- `_pages/research.md` is a stub ("Coming soon!") but there is a working LaTeX
  pipeline (`tex_compile.rb`) and a demo paper/notes ready to power it.
- `_posts/` has two posts; `_notes/` has six notes (cs231n, nanoGPT,
  latex-compilation-demo, reading-list, welcome plate, inline-notebook-snippets).
- `_data/awards.yml`, `_pages/publications_default_template.md`, `talks.md`,
  `teaching.md`, `software.md`, `team.md` are template/placeholder pages.
- News list has a single entry (joined ARG @ NTU, Jan 2026).
- The home hero + about bio: robotics researcher, ARG @ NTU under Dr. Yoonchang
  Sung; visual priors, 3D reconstruction, object search. B.Tech IT, Manipal.

---

## 12. Rules of engagement (short version)

1. Read `AGENTS.md` + `WRITING.md` before acting.
2. Data-first: edit `_data/*.yml`, not hardcoded markup.
3. Verify with `bundle exec jekyll build` (greps for real errors).
4. Never edit the `gh-pages` worktree (`...-1`) or `_site/`.
5. `git pull --rebase origin main` before any push (CI bot owns commits daily).
6. Never commit/push without an explicit ask.
7. Match house style (§7) — it is deliberate. Don't second-guess the palette.
8. Fresh HTML/JS in `.md` → wrap in `{::nomarkdown}`.
9. Plugin edits → restart the server before testing.