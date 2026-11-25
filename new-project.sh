#!/bin/bash
# Scaffold a new project card in _data/projects.yml.
# Usage: ./new-project.sh "Project Name" "Subtitle" "https://github.com/user/repo" "media" "Caption" "Short description."
#
# The "media" argument can be either:
#   - A full URL:    https://raw.githubusercontent.com/user/repo/main/demo.gif
#   - A local path:  /images/projects/demo.gif
#
# Only the first three arguments are required. If media is omitted, a placeholder
# image is used so the card still renders.
#
# Example (remote GIF):
#   ./new-project.sh "ATOM" "ROS 2 teleoperation" "https://github.com/ShirakuGIT/atom" \
#     "https://raw.githubusercontent.com/ShirakuGIT/atom/main/teleop.gif" \
#     "Human-to-robot motion mimicry" \
#     "Maps tracked human motion to robot joints using adaptive IK."
#
# Example (local GIF):
#   ./new-project.sh "My Project" "Cool subtitle" "https://github.com/ShirakuGIT/my-project" \
#     "/images/projects/my-project.gif" \
#     "Demo" \
#     "A short description of the project."
set -e

if [ "$#" -lt 3 ]; then
  echo "Usage: ./new-project.sh \"Project Name\" \"Subtitle\" \"https://github.com/user/repo\" [media] [\"Caption\"] [\"Short description.\"]"
  echo ""
  echo "media can be a full URL (e.g. raw.githubusercontent.com/...) or a local path (e.g. /images/projects/demo.gif)"
  exit 1
fi

NAME="$1"
SUBTITLE="$2"
REPO="$3"
MEDIA="${4:-/images/projects/placeholder.png}"
CAPTION="${5:-$NAME demo}"
DESCRIPTION="${6:-}"

DATA="_data/projects.yml"
mkdir -p "$(dirname "$DATA")"

# Build the YAML entry
ENTRY="- name: \"$NAME\"
  repo: $REPO
  media: $MEDIA
  caption: \"$CAPTION\"
  subtitle: \"$SUBTITLE\""

if [ -n "$DESCRIPTION" ]; then
  ENTRY="$ENTRY
  description: \"$DESCRIPTION\""
fi

# Append a blank line + entry to the data file
printf "\n%s\n" "$ENTRY" >> "$DATA"

echo "Added \"$NAME\" to $DATA"
echo "Preview locally with: bundle exec jekyll serve"
