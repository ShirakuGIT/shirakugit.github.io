#!/bin/bash
# Build and serve the site locally with live reload.
# Kills any existing Jekyll server on port 4000, then opens
# http://127.0.0.1:4000/ and rebuilds automatically when files change.
#
# Usage: ./host.sh
set -e

# Stop any previously running Jekyll server on port 4000.
PID=$(lsof -ti:4000 2>/dev/null || true)
if [ -n "$PID" ]; then
  echo "Stopping existing Jekyll server (pid $PID)..."
  kill "$PID" 2>/dev/null || true
  sleep 1
fi

echo "Starting Jekyll server with live reload..."
echo "Open http://127.0.0.1:4000/ in your browser."
echo "Press Ctrl-C to stop."
echo ""

bundle exec jekyll serve --livereload --host 127.0.0.1 --port 4000
