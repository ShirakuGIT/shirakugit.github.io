---
title: "Welcome to the notes garden"
category: misc
status: wip
updated: 2026-06-04
tags: [meta]
description: "What lives here, how it's organized, and what to expect."
summary: "What lives here, how it's organized, and what to expect."
---

This section is a working garden — a low-friction place to dump
study notes, paper digests, book reactions, tutorial walkthroughs,
sketches, and rough drafts. Things here are intentionally
**unfinished**. Some entries are a few bullets; some are full
write-ups. They get tidied (or deleted) over time.

## Categories

Filter at the top of `/notes/`. Current ones — they grow organically:

- **course** — lecture notes for a class I'm taking (CS231n, etc.)
- **paper** — notes on a research paper I'm studying
- **book** — reading notes / margin commentary
- **tutorial** — implementation walkthroughs (nanoGPT, etc.)
- **lab** — bench / experiment notes, debugging logs
- **art** — sketches, photos, visual experiments
- **misc** — everything else

## What works inside a note

Same markdown features as the blog: LaTeX, figures, video, GIFs, code
blocks. Plus embedded Jupyter notebooks (the `.ipynb` is rendered
inline at build time):

```liquid
{% raw %}{% jupyter_notebook "/assets/notebooks/yourfile.ipynb" %}{% endraw %}
```

## Quick scaffold

```bash
./new-note.sh "Reading Sutton & Barto Ch.4" book sutton rl
```

That makes `_notes/reading-sutton-barto-ch-4.md` with starter front
matter. Edit `category`, `tags`, `summary`, `source`, `status` as needed.
