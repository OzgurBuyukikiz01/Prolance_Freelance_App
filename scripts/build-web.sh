#!/usr/bin/env bash
# Build Flutter web from client/ for static hosting
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/client"

: "${SUPABASE_URL:=https://cgxzpdhcaxiopdylwstr.supabase.co}"
: "${SUPABASE_ANON_KEY:=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNneHpwZGhjYXhpb3BkeWx3c3RyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5NDIzNzksImV4cCI6MjA5NDUxODM3OX0.lNOk6lL3CmMFh8gXoA6hrnW1QcWxpaz2sTTKVOY83fg}"

flutter pub get
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  "$@"

echo "Output: client/build/web/"
