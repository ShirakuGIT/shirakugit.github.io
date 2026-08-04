---
title: "LaTeX compilation — demo"
category: misc
status: done
updated: 2026-08-04
tags: [meta, syntax, latex]
summary: "Compile research-grade LaTeX in place — like a notebook cell, but for academic papers. Drop a {% raw %}{% tex_cell %}{% endraw %} or point at a .tex file and get a rendered PDF, embedded page images, and a download link."
---

Research notes sometimes deserve to *look* like a paper — title, abstract,
sections, tables, bibliography — not just inline math. This site can now
compile full LaTeX documents at build time and render them in place, in the
same spirit as the `.ipynb` notebook cells.

Two tags, both powered by pdfLaTeX:

| Tag | What it does |
| --- | --- |
| `{% raw %}{% tex_cell %}{% endraw %}` | Compiles the inline LaTeX in the tag body |
| `{% raw %}{% tex_file "path.tex" %}{% endraw %}` | Compiles an external `.tex` file |

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

The cell above compiled to a one-page PDF with `\maketitle`, an abstract, a
table, and a caption — no build config, no helper scripts.

## Full paper from a file

For a real manuscript, keep the `.tex` under `assets/papers/` and embed it
with `tex_file`. The file carries its own `\documentclass` so it is compiled
verbatim — bibliography via `\begin{thebibliography}` and all:

{% tex_file "/assets/papers/example-paper.tex" %}

Note the hyperlinks, the labelled equation and table, and the manual
bibliography — a full research paper, rendered in place.

## Every cell gets

- **Page images** — each PDF page is rasterised and stacked, so it reads like
  the paper itself.
- **A `.pdf` download** — the compiled file is staged next to the page images.
- **A collapsible `.tex` source** — syntax-highlighted, so readers can copy the
  source directly.

## Errors surface instead of crashing the build

pdfLaTeX failures don't break the site — they render an error card with the
tail of the log, so you can fix the source. This cell is deliberately broken:

{% tex_cell label=broken-cell %}
\section{This section is
never closed, so pdfLaTeX will choke right about here.
{% endtex_cell %}

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
- Requires `pdflatex` (TeX Live) and `pdftoppm` (poppler) on the machine that
  builds the site. Binary paths can be overridden with the `PDFLATEX` /
  `PDFTOPPM` env vars.
