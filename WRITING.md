# Writing guide — shivaram.net

Personal reference for adding content to the site. Covers the daily
workflow, blog posts vs notes, every embed type, syntax rules, and
deploy.

---

## 0. Two repos on disk — know which you're in

| Path | Branch | Role |
|------|--------|------|
| `~/Documents/Coding/shirakugit.github.io`   | `main`      | **Source.** Edit here. |
| `~/Documents/Coding/shirakugit.github.io-1` | `gh-pages`  | Built output. **Don't edit.** Overwritten on every deploy. |

Always `cd ~/Documents/Coding/shirakugit.github.io` before doing
anything below.

---

## 1. Daily workflow

```bash
cd ~/Documents/Coding/shirakugit.github.io

# Preview locally (auto-reloads on save)
bundle exec jekyll serve --livereload

# Visit http://127.0.0.1:4000/ in browser
# Write / edit / preview
# Stop with Ctrl-C

# Deploy when happy
bundle exec rake publish
```

Live site: <https://shivaram.net>.

**Plugin changes** (`_plugins/*.rb`) require a server restart — Jekyll
only loads plugins once. Layout, CSS, content, and config changes
auto-reload.

---

## 2. Blog posts vs notes — when to use which

| | **Blog post** (`_posts/`) | **Note** (`_notes/`) |
|--|--|--|
| Tone | Polished, public-facing | Working draft, "garden" |
| Audience | Anyone | Mostly me, sometimes researchers |
| Date model | Pinned publish date | `updated` field, recategorized over time |
| URL | `/2026/06/14/your-title.html` | `/notes/your-slug/` |
| Listing | `/blogs/` (chronological) | `/notes/` (filter by category) |
| Use it for | A finished essay, an announcement, a tutorial I want to share | Lecture notes, paper notes, half-baked thoughts, sketches, tutorial walkthroughs |

If unsure — start as a note. Promote to a post later by copying.

---

## 3. New blog post

```bash
./new-post.sh "My Post Title" tag1 tag2
```

Creates `_posts/YYYY-MM-DD-my-post-title.md` with front matter:

```yaml
---
layout: post
title: "My Post Title"
date: 2026-06-04
author: Shivaram Kumar Jagannathan
tags: [tag1, tag2]
---
```

Then write markdown. Filename **must** be `YYYY-MM-DD-slug.md` — Jekyll
parses the date from there.

---

## 4. New note

```bash
./new-note.sh "Title" [category] [tag1 tag2 ...]
```

Examples:

```bash
./new-note.sh "CS231n Lecture 2 — linear classifier" course cs231n cv
./new-note.sh "Reading: Sutton & Barto Ch.4" book rl sutton
./new-note.sh "nanoGPT attention block" tutorial llm karpathy
```

Or hand-create any `.md` in `_notes/` with this front matter:

```yaml
---
title: "..."
category: course        # course | paper | book | tutorial | lab | art | misc
status: wip             # wip | draft | done  (optional badge)
updated: 2026-06-04     # YYYY-MM-DD, used for sort + display
tags: [tag1, tag2]
summary: "One-line subtitle shown on the card"
source: "https://..."   # optional external link, shown next to date
---
```

**Subfolders work.** `_notes/cs231n/lec02.md` → `/notes/cs231n/lec02/`.
Listing page stays flat.

**Categories grow organically.** Add any new value in `category:`. To
give it a custom badge color, edit `_sass/SHB_css.scss`:

```scss
.note-category-<your-category> { background: #yourcolor; }
```

Otherwise it falls back to the grey `misc` badge.

---

## 5. Markdown syntax — common patterns

Standard kramdown (GitHub-flavored). The basics:

```markdown
# H1   ## H2   ### H3
**bold**   *italic*   `inline code`
- bullet
1. numbered
> blockquote
[link text](https://example.com)
---  (horizontal rule)
```

**Tables:**

```markdown
| Col A | Col B |
|-------|-------|
| 1     | 2     |
```

**Footnotes:**

```markdown
Some claim.[^1]

[^1]: Source: paper X, 2024.
```

**Auto-IDs on headings** — kramdown gives every heading an anchor,
e.g. `## My Section` becomes `#my-section`. Link with
`[jump](#my-section)`.

---

## 6. Math (LaTeX)

MathJax is loaded site-wide.

**Inline:** `$E = mc^2$`

**Block:**

```markdown
$$
J(\theta) = \tfrac{1}{2} \sum_i (h_\theta(x_i) - y_i)^2
$$
```

Supports labels and `\eqref` because `tags: 'ams'` is set in
`_includes/mathjax.html`.

---

## 7. Code blocks

Triple-backtick + language. Rouge highlights it.

````markdown
```python
def fuse(imu, lidar):
    return kalman_update(imu, lidar)
```
````

Common languages: `python`, `bash`, `ruby`, `js`, `cpp`, `rust`, `go`,
`yaml`, `json`, `liquid`, `scss`, `html`.

For Liquid examples that should **not** execute, wrap in `{% raw %}`:

```markdown
{% raw %}{% include figure.html src="/images/x.jpg" %}{% endraw %}
```

---

## 8. Images / figures

Drop the image under `images/` then:

```liquid
{% include figure.html src="/images/feynman.jpg" caption="An image with a caption." width="70%" %}
```

`width` is optional (defaults to full container).

For a plain `<img>` without caption, just standard markdown:

```markdown
![alt text](/images/feynman.jpg)
```

---

## 9. Video (YouTube / Vimeo / hosted mp4)

```liquid
{% include video.html youtube="aircAruvnKk" caption="Optional caption." %}
{% include video.html vimeo="123456789" %}
{% include video.html mp4="/videos/clip.mp4" %}
```

---

## 10. GIFs (or silent looping mp4)

```liquid
{% include gif.html src="/images/demo.gif" caption="A looping demo." %}
{% include gif.html mp4="/images/demo.mp4" caption="Same as mp4 — much smaller." %}
```

Prefer the mp4 form for anything > a couple of seconds. GIFs are huge.

---

## 11. Jupyter notebooks

1. Save the `.ipynb` under `assets/notebooks/` (any subfolder OK).
2. In any `.md` (post **or** note), embed it:

```liquid
{% jupyter_notebook "/assets/notebooks/nanogpt-train.ipynb" %}
```

Renders at build time:
- Markdown cells → kramdown
- Code cells → syntax-highlighted (language auto-detected from notebook
  kernel metadata)
- `In[n]` / `Out[n]` prompts in the gutter
- stdout, stderr, error tracebacks (ANSI stripped)
- PNG / JPEG / SVG plots inline (PNG/JPEG base64-embedded — no extra
  files needed)
- HTML outputs (pandas DataFrames render as tables)
- LaTeX in outputs (MathJax picks it up)

Toolbar at the top has a `.ipynb` download link for reproducibility.

**Path rules:** absolute paths starting with `/`. Always.

**No Python dependency.** Pure Ruby plugin — works on any build env
that builds the rest of the site.

---

## 12. Mixing it all — example note body

```markdown
## Bigram baseline

First pass: just look up the next token in a table. Loss bottoms out
around $2.5$ on tinyshakespeare — way better than random ($\log 65$),
way worse than a transformer.

{% include figure.html src="/images/notes/bigram-loss.png" caption="Training curve, 5k steps." width="80%" %}

## Walkthrough notebook

{% jupyter_notebook "/assets/notebooks/bigram.ipynb" %}

## Demo

{% include video.html youtube="kCc8FmEb1nY" caption="Karpathy's full nanoGPT video." %}
```

(Wrap `{% raw %}` around the snippets if you ever quote the syntax in
documentation, like this WRITING.md does — see Section 7.)

---

## 13. The one kramdown gotcha to remember

`_config.yml` has `parse_block_html: true`. That means kramdown
re-parses block-level HTML inside `.md` files and **mangles it**.

If you ever write a chunk of raw HTML by hand inside a `.md`, wrap
it in `nomarkdown` markers so kramdown emits it verbatim:

```markdown
{::nomarkdown}
<div class="my-fancy-block">
  <button>Click</button>
</div>
{:/nomarkdown}
```

The Jupyter notebook plugin and Liquid `include` files already handle
this for you. You only need it when authoring raw HTML directly.

---

## 14. Customizing

| Task | Where |
|------|-------|
| Add new category badge color | `_sass/SHB_css.scss` → `.note-category-<name>` |
| Change palette | `_sass/SHB_css.scss` → `$earth-orange`, `$earth-green`, etc. |
| Add navbar entry | `_config.yml` → `nav_pages:` |
| Edit site title / description / domain | `_config.yml` (top) |
| Social icons | `_data/pi.yml` |
| Sidebar bio | `_pages/about.md` |
| Calendly link | `_config.yml` → `calendly:` |

---

## 15. Deploy

```bash
bundle exec rake publish
```

What it does:
1. Builds `_site/` with `jekyll build`.
2. Force-pushes `_site/` to the `gh-pages` branch of
   `github.com/ShirakuGIT/shirakugit.github.io`.
3. GitHub Pages serves `gh-pages` at `shivaram.net` (custom domain via
   `CNAME` file).

Also commit + push the source on `main`:

```bash
git add -A
git commit -m "notes: add CS231n Lecture 2"
git push origin main
```

(Source `main` and built `gh-pages` are independent. `rake publish`
takes care of `gh-pages` only.)

---

## 16. File tree — quick reference

```
shirakugit.github.io/
├── _config.yml                # site settings, nav, collections, defaults
├── _posts/                    # blog posts (YYYY-MM-DD-slug.md)
├── _notes/                    # personal notes (any slug.md)
├── _pages/                    # standalone pages (about, blogs, notes, ...)
├── _layouts/                  # HTML scaffolds (post, note, page, default, ...)
├── _includes/                 # reusable snippets (figure, video, gif, head, ...)
├── _plugins/
│   ├── ext.rb                 # jekyll-scholar bootstrap
│   ├── markdown.rb            # {% markdown %} tag
│   └── jupyter_notebook.rb    # {% jupyter_notebook %} tag
├── _sass/
│   ├── bootstrap/             # bootstrap source
│   ├── bootstrap.scss         # bootswatch Darkly override
│   └── SHB_css.scss           # site custom styles + earth palette
├── assets/
│   ├── main.scss              # entry stylesheet
│   ├── notebooks/             # .ipynb files to embed
│   ├── ref.bib                # bibliography (jekyll-scholar)
│   └── visits.json            # live RUM counts (auto-updated by CI)
├── images/                    # all images (figures, logos, headshot, favicons)
├── new-post.sh                # scaffold a blog post
├── new-note.sh                # scaffold a note
├── CNAME                      # shivaram.net
└── Rakefile                   # `rake publish` deploys to gh-pages
```

---

## 17. Cheatsheet

```liquid
{% raw %}{% include figure.html src="/images/x.jpg" caption="..." width="80%" %}
{% include video.html youtube="VIDEO_ID" caption="..." %}
{% include video.html mp4="/videos/clip.mp4" %}
{% include gif.html src="/images/demo.gif" %}
{% include gif.html mp4="/images/demo.mp4" %}
{% jupyter_notebook "/assets/notebooks/file.ipynb" %}{% endraw %}
```

```markdown
$E = mc^2$              # inline math
$$ a^2 + b^2 = c^2 $$   # block math
[text](url)             # link
![alt](/images/x.jpg)   # plain image
| col | col |           # table (with header sep)
> quote                 # blockquote
- bullet                # list
1. numbered             # ordered list
```
