#!/bin/bash
# Scaffold a new note in _notes/.
# Usage:  ./new-note.sh "My Note Title" [category] [tag1 tag2 ...]
#
# category defaults to "misc". Known categories: course, paper, book,
# tutorial, lab, art, misc — anything works, listing page auto-discovers.
#
# Examples:
#   ./new-note.sh "CS231n Lecture 2" course cs231n cv
#   ./new-note.sh "Reading: Sutton & Barto Ch.4" book rl sutton
#   ./new-note.sh "nanoGPT attention block" tutorial llm karpathy
set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: ./new-note.sh \"Title\" [category] [tag1 tag2 ...]"
  exit 1
fi

TITLE="$1"; shift
CATEGORY="${1:-misc}"
if [ "$#" -gt 0 ]; then shift; fi
TAGS="$*"
DATE=$(date +%Y-%m-%d)
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
FILE="_notes/${SLUG}.md"

mkdir -p _notes
if [ -e "$FILE" ]; then
  echo "Already exists: $FILE"; exit 1
fi

cat > "$FILE" <<EOF
---
title: "${TITLE}"
category: ${CATEGORY}
status: wip
updated: ${DATE}
tags: [${TAGS// /, }]
summary: ""
# source: "https://..."
---

Write your note here. Markdown, LaTeX, code, figures, video, GIFs, and
embedded Jupyter notebooks all work.

<!-- LaTeX -->
\$\$ E = mc^2 \$\$

<!-- Figure -->
{% raw %}{% include figure.html src="/images/your-image.jpg" caption="A caption." width="80%" %}{% endraw %}

<!-- Jupyter notebook -->
{% raw %}{% jupyter_notebook "/assets/notebooks/your-notebook.ipynb" %}{% endraw %}
EOF

echo "Created $FILE"
