#!/bin/bash
# Scaffold a new blog post in _posts/.
# Usage:  ./new-post.sh "My Post Title" [tag1 tag2 ...]
set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: ./new-post.sh \"My Post Title\" [tag1 tag2 ...]"
  exit 1
fi

TITLE="$1"; shift
TAGS="$*"
DATE=$(date +%Y-%m-%d)
# slug: lowercase, spaces -> dashes, strip non-alnum/dash
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
FILE="_posts/${DATE}-${SLUG}.md"

mkdir -p _posts
if [ -e "$FILE" ]; then
  echo "Already exists: $FILE"; exit 1
fi

cat > "$FILE" <<EOF
---
layout: post
title: "${TITLE}"
date: ${DATE}
author: Shivaram Kumar Jagannathan
tags: [${TAGS// /, }]
---

Write your post here. Markdown, LaTeX, images, GIFs and video all work.

<!-- LaTeX:  inline \$E = mc^2\$  or a display block: -->
\$\$ \\nabla \\cdot \\mathbf{B} = 0 \$\$

<!-- Image with caption -->
{% raw %}{% include figure.html src="/images/thumbs/3dtrain.jpeg" caption="A caption." width="80%" %}{% endraw %}

<!-- YouTube video -->
{% raw %}{% include video.html youtube="dQw4w9WgXcQ" %}{% endraw %}

<!-- GIF (or a silent looping mp4) -->
{% raw %}{% include gif.html src="/images/demo.gif" caption="A demo." %}{% endraw %}
EOF

echo "Created $FILE"
EOF_DONE=1
