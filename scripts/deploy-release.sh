#!/usr/bin/env bash
# Full release: preflight (GitHub / Vercel Youmiko / Supabase Ozgurozan) + optional push + deploy.
#
# Usage:
#   bash scripts/deploy-release.sh --check-only
#   bash scripts/deploy-release.sh --vercel
#   bash scripts/deploy-release.sh --supabase
#   bash scripts/deploy-release.sh --git-push
#   bash scripts/deploy-release.sh --full
#   bash scripts/deploy-release.sh --full --force   # skip account warnings
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIG_EXAMPLE="$ROOT/scripts/deploy.config.example"
CONFIG_LOCAL="$ROOT/scripts/deploy.local.env"
WEB_VERCEL_JSON="$ROOT/web/.vercel/project.json"

DO_GIT=0
DO_SUPABASE=0
DO_VERCEL=0
CHECK_ONLY=0
FORCE=0

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-only) CHECK_ONLY=1 ;;
    --git-push) DO_GIT=1 ;;
    --supabase) DO_SUPABASE=1 ;;
    --vercel) DO_VERCEL=1 ;;
    --full) DO_GIT=1; DO_SUPABASE=1; DO_VERCEL=1 ;;
    --force) FORCE=1 ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
  shift
done

if [[ "$DO_GIT$DO_SUPABASE$DO_VERCEL$CHECK_ONLY" == "000" ]]; then
  echo "Nothing to do. Pass --check-only, --vercel, --supabase, --git-push, or --full." >&2
  usage 1
fi

# shellcheck disable=SC1091
if [[ -f "$CONFIG_LOCAL" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_LOCAL"
elif [[ -f "$CONFIG_EXAMPLE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_EXAMPLE"
else
  echo "Missing $CONFIG_EXAMPLE" >&2
  exit 1
fi

warn() { echo "WARN: $*" >&2; }
die() { echo "ERROR: $*" >&2; exit 1; }
ok() { echo "OK: $*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Command not found: $1"
}

ensure_vercel_link() {
  mkdir -p "$(dirname "$WEB_VERCEL_JSON")"
  if [[ -f "$WEB_VERCEL_JSON" ]]; then
    local pid oid
    pid="$(node -e "const j=require('$WEB_VERCEL_JSON'); process.stdout.write(j.projectId||'')")"
    oid="$(node -e "const j=require('$WEB_VERCEL_JSON'); process.stdout.write(j.orgId||'')")"
    if [[ "$pid" != "$VERCEL_PROJECT_ID" || "$oid" != "$VERCEL_ORG_ID" ]]; then
      die "web/.vercel/project.json mismatch. Expected project $VERCEL_PROJECT_ID"
    fi
    ok "Vercel link file → $VERCEL_PROJECT_NAME ($VERCEL_PROJECT_ID)"
    return
  fi

  echo "Writing web/.vercel/project.json (link to $VERCEL_PROJECT_NAME)..."
  node -e "
    const fs = require('fs');
    fs.writeFileSync(
      '$WEB_VERCEL_JSON',
      JSON.stringify({
        projectId: '$VERCEL_PROJECT_ID',
        orgId: '$VERCEL_ORG_ID',
        projectName: '$VERCEL_PROJECT_NAME',
      }, null, 2) + '\n'
    );
  "
  ok "Created $WEB_VERCEL_JSON"
}

check_git() {
  require_cmd git
  local remote branch
  remote="$(git remote get-url origin 2>/dev/null || true)"
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

  [[ -n "$remote" ]] || die "No git remote 'origin'. Set: git remote add origin $GITHUB_REMOTE_URL"

  local owner_ok=0 part
  IFS=',' read -ra _owners <<< "${GITHUB_OWNER_EXPECTED}"
  for part in "${_owners[@]}"; do
    part="$(echo "$part" | tr -d '[:space:]')"
    [[ -z "$part" ]] && continue
    if [[ "$remote" == *"$part"* ]]; then owner_ok=1; break; fi
  done
  if [[ "$owner_ok" -ne 1 ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      warn "Git remote owner not in list: $GITHUB_OWNER_EXPECTED (got: $remote)"
    else
      die "Git remote owner mismatch. Expected one of: $GITHUB_OWNER_EXPECTED. Got: $remote"
    fi
  else
    ok "Git remote → $remote"
  fi

  if [[ "$branch" != "$GITHUB_BRANCH" ]]; then
    warn "Current branch is '$branch', config expects '$GITHUB_BRANCH'"
  fi

  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    warn "Working tree has uncommitted changes"
  fi
}

check_vercel() {
  require_cmd vercel
  require_cmd node
  local whoami
  whoami="$(vercel whoami 2>/dev/null | tr -d '\r' || true)"
  [[ -n "$whoami" ]] || die "Not logged in to Vercel. Run: vercel login (Youmiko account)"

  local whoami_lc allowed match=0 part
  whoami_lc="$(echo "$whoami" | tr '[:upper:]' '[:lower:]')"
  IFS=',' read -ra _parts <<< "${VERCEL_ACCOUNT_EXPECTED}"
  for part in "${_parts[@]}"; do
    part="$(echo "$part" | tr '[:upper:]' '[:lower:]' | xargs)"
    [[ -z "$part" ]] && continue
    if [[ "$whoami_lc" == *"$part"* ]]; then match=1; break; fi
  done
  if [[ "$match" -ne 1 ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      warn "Vercel user '$whoami' not in allowed list: $VERCEL_ACCOUNT_EXPECTED"
    else
      die "Vercel account mismatch. Logged in as '$whoami'. Allowed: $VERCEL_ACCOUNT_EXPECTED (Youmiko team). Run: vercel login"
    fi
  else
    ok "Vercel CLI → $whoami"
  fi

  ensure_vercel_link
}

check_supabase() {
  if ! command -v supabase >/dev/null 2>&1; then
    if [[ "$DO_SUPABASE" -eq 1 ]]; then
      die "supabase CLI not found. Install: https://supabase.com/docs/guides/cli"
    fi
    warn "supabase CLI not in PATH (Ozgurozan deploy skipped in preflight)"
    return
  fi
  local projects
  projects="$(supabase projects list 2>/dev/null || true)"
  if [[ -z "$projects" ]]; then
    die "Supabase CLI not authenticated. Run: supabase login (Ozgurozan account)"
  fi

  if [[ -n "${SUPABASE_ACCOUNT_HINT:-}" ]]; then
    ok "Supabase CLI authenticated (hint: ${SUPABASE_ACCOUNT_HINT})"
  else
    ok "Supabase CLI authenticated"
  fi

  if [[ "$projects" != *"$SUPABASE_PROJECT_REF"* ]]; then
    warn "Project ref $SUPABASE_PROJECT_REF not visible in 'supabase projects list' — wrong Supabase login?"
  else
    ok "Supabase project visible → $SUPABASE_PROJECT_REF"
  fi
}

print_auth_reminder() {
  cat <<EOF

--- Account checklist ---
  GitHub push : OzgurOzana (or collaborator with push access)
  Vercel      : Youmiko → project ${VERCEL_PROJECT_NAME} (${VERCEL_PROJECT_ID})
  Supabase    : Ozgurozan → ${SUPABASE_PROJECT_REF}
  Production  : ${PRODUCTION_URL}

Auth URL (manual, Supabase dashboard):
  https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/auth/url-configuration
  Site URL + redirects → ${PRODUCTION_URL}/**

EOF
}

run_git_push() {
  check_git
  echo "Pushing to origin/$GITHUB_BRANCH..."
  git push -u origin "$GITHUB_BRANCH"
  ok "Git push complete"
}

run_supabase() {
  check_supabase
  PROJECT_REF="$SUPABASE_PROJECT_REF" bash "$ROOT/scripts/deploy-supabase.sh"
  if [[ -d "$ROOT/supabase/functions/escrow" ]]; then
    echo "Deploying escrow edge function..."
    supabase functions deploy escrow
  fi
}

run_vercel() {
  check_vercel
  if [[ "${INCLUDE_FLUTTER_APP:-0}" == "1" ]]; then
    echo "Building Flutter web + Next.js (INCLUDE_FLUTTER_APP=1)..."
    bash "$ROOT/scripts/build-vercel.sh"
  else
    echo "Skipping Flutter /app embed (set INCLUDE_FLUTTER_APP=1 in deploy.local.env to include)"
    cd "$ROOT/web"
    npm ci
    npm run build
    cd "$ROOT"
  fi
  echo "Deploying to Vercel production (${VERCEL_PROJECT_ID})..."
  cd "$ROOT/web"
  vercel --prod --yes
  ok "Vercel production deploy finished → ${PRODUCTION_URL}"
}

echo "=== Prolance deploy-release ==="
print_auth_reminder

check_git
check_vercel
check_supabase

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  ok "Preflight passed (--check-only)"
  exit 0
fi

[[ "$DO_GIT" -eq 1 ]] && run_git_push
[[ "$DO_SUPABASE" -eq 1 ]] && run_supabase
[[ "$DO_VERCEL" -eq 1 ]] && run_vercel

echo ""
ok "Done."
