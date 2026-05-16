#!/usr/bin/env bash
# Build Flutter web + Next.js (web/) for Vercel.
# Embeds app at web/public/app/ — set NEXT_PUBLIC_APP_URL=/app on Vercel.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

bash scripts/build-web.sh --base-href=/app/

mkdir -p web/public/app
cp -r client/build/web/. web/public/app/

cd web
npm ci
npm run build

echo ""
echo "Vercel web build complete."
echo "Set NEXT_PUBLIC_APP_URL=/app so the hero iframe loads the embedded Flutter app."
