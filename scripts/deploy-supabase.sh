#!/usr/bin/env bash
# Link project, push DB migrations, and deploy Edge Functions.
set -euo pipefail

PROJECT_REF="${PROJECT_REF:-${1:-}}"

if [[ -z "$PROJECT_REF" ]]; then
  echo "Error: PROJECT_REF is required." >&2
  echo "Usage: PROJECT_REF=your-ref bash scripts/deploy-supabase.sh" >&2
  echo "   or: bash scripts/deploy-supabase.sh your-ref" >&2
  exit 1
fi

echo "Deploying to Supabase project: $PROJECT_REF"

supabase login
supabase link --project-ref "$PROJECT_REF"
supabase db push
supabase functions deploy agora-token
supabase functions deploy send-push

echo ""
echo "Deploy complete."
echo ""
echo "Optional for mobile push (MVP can skip):"
echo "  supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON='<service-account-json>'"
echo ""
echo "Without this secret, send-push may no-op; web push is not required for MVP."
