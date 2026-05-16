#!/usr/bin/env bash
# Serve Flutter web build locally
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB_BUILD="$ROOT/client/build/web"

if [[ ! -d "$WEB_BUILD" ]]; then
  bash scripts/build-web.sh
fi

PORT="${PORT:-5000}"
echo "Serving $WEB_BUILD on port $PORT"
cd "$WEB_BUILD"
python3 -m http.server "$PORT" 2>/dev/null || python -m http.server "$PORT"
