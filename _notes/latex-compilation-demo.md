---
title: "LaTeX compilation — demo"
category: misc
status: done
updated: 2026-08-04
tags: [meta, syntax, latex]
summary: "Compile research-grade LaTeX in place — like a notebook cell, but for academic papers. Drop a {% raw %}{% tex_cell %}{% endraw %} or point at a .tex file and get the paper as real page content (ar5iv-style), with the compiled PDF for download."
---

Research notes sometimes deserve to *look* like a paper — title, abstract,
sections, tables, bibliography — not just inline math. This site can now
compile full LaTeX documents at build time and render them *in the page* as
real content (ar5iv-style), in the same spirit as the `.ipynb` notebook cells.

Two tags — pandoc turns the LaTeX into page content, pdfLaTeX compiles the
same source to a PDF for download:

| Tag | What it does |
| --- | --- |
| `{% raw %}{% tex_cell %}{% endraw %}` | Renders the inline LaTeX in the tag body |
| `{% raw %}{% tex_file "path.tex" %}{% endraw %}` | Renders an external `.tex` file |

## Inline cell

The tag body is wrapped in a small `article` preamble for you (unless it
already contains `\documentclass`), so you can just write the paper:

{% tex_cell label=short-note %}
\title{A Short Note on Why I Like Robots}
\author{Shivaram Kumar Jagannathan}
\date{\today}
\maketitle

\begin{abstract}
This note exists purely to show that inline LaTeX compiles to a real,
down-loadable PDF.
\end{abstract}

\section{Why robots}
Robots are fun. Table~\ref{tab:robots} summarises the evidence.

\begin{table}[h]
\centering
\begin{tabular}{lcc}
\toprule
Robot & Fun & Upside \\
\midrule
Wheeled & High & Medium \\
Legged & Higher & High \\
\bottomrule
\end{tabular}
\caption{Funness by platform.}
\label{tab:robots}
\end{table}

\section{Conclusion}
More robots, more fun.
{% endtex_cell %}

The cell above rendered a full title block, abstract, table, and caption as
selectable page content — no build config, no helper scripts.

## Full paper from a file

For a real manuscript, keep the `.tex` under `assets/papers/` and embed it
with `tex_file`. The file carries its own `\documentclass` so it is compiled
verbatim — bibliography via `\begin{thebibliography}` and all:

{% tex_file "/assets/papers/example-paper.tex" %}

Note the numbered equation cross-references (`\eqref`) and citations
(`[1]`, `[2]`, `[3]`) that resolve against the manual bibliography — a full
research paper, rendered in place in Computer Modern, the classic LaTeX font.

## Every cell gets

- **Real page content** — pandoc converts the LaTeX to HTML: selectable,
  searchable, mobile-friendly text in **Computer Modern** (self-hosted Latin
  Modern). Math stays as TeX and is typeset by the site's MathJax with `ams`
  equation numbering.
- **A `.pdf` download** — the same source is compiled with pdfLaTeX and staged
  next to the page for download.
- **A collapsible `.tex` source** — syntax-highlighted, so readers can copy the
  source directly.

## Clear build diagnostics

Invalid sources are isolated to their own cell instead of stopping the rest of
the site from building. The build log identifies the source and reports the
converter or compiler output needed to fix it. If pandoc can render the page
content but pdfLaTeX cannot produce a PDF—for example, because a package is
missing—the HTML remains available and the toolbar reports that the download
could not be generated.

This page keeps every example valid so it also serves as a clean visual check
for the complete HTML, PDF, bibliography, equation, and TikZ pipeline.

## Syntax reference

```liquid
{% raw %}{% tex_cell label=my-paper %}          <!-- optional name for the .pdf -->
\title{...}\maketitle
\begin{abstract}...\end{abstract}
\section{...}...
{% endtex_cell %}{% endraw %}
```

```liquid
{% raw %}{% tex_file "/assets/papers/example-paper.tex" %}{% endraw %}
```

- `tex_cell` auto-wraps in `\documentclass[11pt]{article}` + `geometry`,
  `amsmath`, `hyperref`, `booktabs`, `enumitem`, etc. Write a full
  `\documentclass` yourself to opt out.
- Compiled artifacts are cached in `.jekyll-cache/tex/` and only recompiled
  when the source changes.
- Requires `pandoc` (HTML), `pdflatex` (TeX Live, PDF), and `pdfinfo` (poppler,
  page count) on the machine that builds the site. Binary paths can be
  overridden with the `PANDOC` / `PDFLATEX` / `PDFINFO` env vars.
