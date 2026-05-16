#!/usr/bin/env bash
# Lightweight static check for critical migration artifacts (no database required).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATION="$ROOT/supabase/migrations/20250517_job_schedule_items.sql"

if [[ ! -f "$MIGRATION" ]]; then
  echo "FAIL: missing migration file: $MIGRATION"
  exit 1
fi

content="$(cat "$MIGRATION")"
required=(
  'job_schedule_items'
  'job_schedule_select_participants'
  'job_schedule_insert_participants'
  'job_schedule_update_participants'
  'enable row level security'
)

for token in "${required[@]}"; do
  if ! grep -qi "$token" <<<"$content"; then
    echo "FAIL: expected '$token' in $MIGRATION"
    exit 1
  fi
done

echo "OK: migration smoke check passed for job_schedule_items"
