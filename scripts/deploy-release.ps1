# Full release: preflight (GitHub / Vercel Youmiko / Supabase Ozgurozan) + optional push + deploy.
#
# Usage:
#   .\scripts\deploy-release.ps1 -CheckOnly
#   .\scripts\deploy-release.ps1 -Vercel
#   .\scripts\deploy-release.ps1 -Supabase
#   .\scripts\deploy-release.ps1 -GitPush
#   .\scripts\deploy-release.ps1 -Full
#   .\scripts\deploy-release.ps1 -Full -Force

param(
    [switch]$CheckOnly,
    [switch]$GitPush,
    [switch]$Supabase,
    [switch]$Vercel,
    [switch]$Full,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if ($Full) {
    $GitPush = $true
    $Supabase = $true
    $Vercel = $true
}

if (-not ($CheckOnly -or $GitPush -or $Supabase -or $Vercel)) {
    Write-Host "Pass -CheckOnly, -GitPush, -Supabase, -Vercel, or -Full" -ForegroundColor Yellow
    exit 1
}

$ConfigExample = Join-Path $Root "scripts\deploy.config.example"
$ConfigLocal = Join-Path $Root "scripts\deploy.local.env"
$WebVercelJson = Join-Path $Root "web\.vercel\project.json"
$script:DeployCfg = @{}

function Load-ConfigFile {
    $path = if (Test-Path $ConfigLocal) { $ConfigLocal } else { $ConfigExample }
    if (-not (Test-Path $path)) { throw "Missing config: $path" }
    foreach ($raw in Get-Content $path) {
        $line = $raw.Trim()
        if ($line -eq "" -or $line.StartsWith("#")) { continue }
        $eq = $line.IndexOf("=")
        if ($eq -lt 1) { continue }
        $name = $line.Substring(0, $eq).Trim()
        $value = $line.Substring($eq + 1).Trim().Trim('"')
        if ($script:DeployCfg.ContainsKey($name)) {
            $script:DeployCfg.Remove($name) | Out-Null
        }
        $null = $script:DeployCfg.Add($name, $value)
    }
}

function Get-DeployCfg([string]$Key) {
    if ($script:DeployCfg.ContainsKey($Key)) { return $script:DeployCfg.Item($Key) }
    return ""
}

function Write-Ok($msg) { Write-Host "OK: $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "WARN: $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

Load-ConfigFile
if ($script:DeployCfg.Count -lt 5) {
    Write-Err "Config not loaded ($($script:DeployCfg.Count) keys). Check scripts/deploy.local.env"
}

function Show-AuthReminder {
    Write-Host ""
    Write-Host "--- Account checklist ---"
    Write-Host "  GitHub push : OzgurOzana (or collaborator with push access)"
    Write-Host "  Vercel      : Youmiko -> project $(Get-DeployCfg 'VERCEL_PROJECT_NAME') ($(Get-DeployCfg 'VERCEL_PROJECT_ID'))"
    Write-Host "  Supabase    : Ozgurozan -> $(Get-DeployCfg 'SUPABASE_PROJECT_REF')"
    Write-Host "  Production  : $(Get-DeployCfg 'PRODUCTION_URL')"
    Write-Host ""
    Write-Host "Auth URL (manual):"
    Write-Host "  https://supabase.com/dashboard/project/$(Get-DeployCfg 'SUPABASE_PROJECT_REF')/auth/url-configuration"
    Write-Host ""
}

function Ensure-VercelLink {
    $dir = Split-Path $WebVercelJson -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $expected = @{
        projectId   = (Get-DeployCfg "VERCEL_PROJECT_ID")
        orgId       = (Get-DeployCfg "VERCEL_ORG_ID")
        projectName = (Get-DeployCfg "VERCEL_PROJECT_NAME")
    } | ConvertTo-Json

    if (Test-Path $WebVercelJson) {
        $current = Get-Content $WebVercelJson -Raw | ConvertFrom-Json
        if ($current.projectId -ne (Get-DeployCfg "VERCEL_PROJECT_ID") -or $current.orgId -ne (Get-DeployCfg "VERCEL_ORG_ID")) {
            Write-Err "web/.vercel/project.json mismatch. Expected $(Get-DeployCfg 'VERCEL_PROJECT_ID')"
        }
        Write-Ok "Vercel link -> $(Get-DeployCfg 'VERCEL_PROJECT_NAME') ($(Get-DeployCfg 'VERCEL_PROJECT_ID'))"
    }
    else {
        $expected | Set-Content -Path $WebVercelJson -Encoding utf8
        Write-Ok "Created $WebVercelJson"
    }
}

function Test-Git {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Err "git not found" }
    $remote = (git remote get-url origin 2>$null)
    if (-not $remote) { Write-Err "No origin remote. Add: $(Get-DeployCfg 'GITHUB_REMOTE_URL')" }

    $owners = (Get-DeployCfg "GITHUB_OWNER_EXPECTED") -split '[,|]' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $ownerOk = $false
    foreach ($o in $owners) { if ($remote -match [regex]::Escape($o)) { $ownerOk = $true; break } }
    if (-not $ownerOk) {
        if ($Force) { Write-Warn "Git remote owner mismatch: $remote" }
        else { Write-Err "Git remote should match one of: $($owners -join ', '). Got: $remote" }
    }
    else { Write-Ok "Git remote -> $remote" }

    $branch = (git rev-parse --abbrev-ref HEAD 2>$null)
    if ($branch -ne (Get-DeployCfg "GITHUB_BRANCH")) {
        Write-Warn "On branch '$branch', expected '$(Get-DeployCfg 'GITHUB_BRANCH')'"
    }
    if (git status --porcelain 2>$null) { Write-Warn "Uncommitted changes present" }
}

function Test-Vercel {
    if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) { Write-Err "vercel CLI not found" }
    $whoami = (vercel whoami 2>&1 | Out-String).Trim()
    if (-not $whoami) { Write-Err "Not logged in to Vercel. Run: vercel login (Youmiko)" }

    $allowed = (Get-DeployCfg "VERCEL_ACCOUNT_EXPECTED") -split '[,|]' | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ }
    $whoLower = $whoami.ToLower()
    $match = $false
    foreach ($a in $allowed) { if ($whoLower -like "*$a*") { $match = $true; break } }
    if (-not $match) {
        if ($Force) { Write-Warn "Vercel user '$whoami' not in: $(Get-DeployCfg 'VERCEL_ACCOUNT_EXPECTED')" }
        else { Write-Err "Vercel '$whoami' not allowed (expected: $(Get-DeployCfg 'VERCEL_ACCOUNT_EXPECTED')). Run: vercel login" }
    }
    else { Write-Ok "Vercel CLI -> $whoami" }

    Ensure-VercelLink
}

function Test-SupabaseCli {
    if (-not (Get-Command supabase -ErrorAction SilentlyContinue)) {
        if ($Supabase) { Write-Err "supabase CLI not found. Install: https://supabase.com/docs/guides/cli" }
        Write-Warn "supabase CLI not in PATH (Ozgurozan deploy skipped in preflight)"
        return
    }
    $projects = (supabase projects list 2>&1 | Out-String)
    if (-not $projects) { Write-Err "Supabase not logged in. Run: supabase login (Ozgurozan)" }

    Write-Ok "Supabase CLI ($(Get-DeployCfg 'SUPABASE_ACCOUNT_HINT'))"
    $ref = Get-DeployCfg "SUPABASE_PROJECT_REF"
    if ($projects -notmatch $ref) {
        Write-Warn "Project $ref not listed - wrong Supabase account?"
    }
    else { Write-Ok "Supabase project -> $ref" }
}

function Invoke-GitPush {
    Test-Git
    $branch = Get-DeployCfg "GITHUB_BRANCH"
    Write-Host "Pushing origin/$branch..."
    git push -u origin $branch
    Write-Ok "Git push complete"
}

function Invoke-SupabaseDeploy {
    Test-SupabaseCli
    $env:PROJECT_REF = Get-DeployCfg "SUPABASE_PROJECT_REF"
    if (Get-Command bash -ErrorAction SilentlyContinue) {
        bash "$Root/scripts/deploy-supabase.sh"
    }
    else {
        supabase link --project-ref (Get-DeployCfg "SUPABASE_PROJECT_REF")
        supabase db push
        supabase functions deploy agora-token
        supabase functions deploy send-push
        if (Test-Path "$Root/supabase/functions/escrow") { supabase functions deploy escrow }
    }
}

function Invoke-VercelDeploy {
    Test-Vercel
    if ((Get-DeployCfg "INCLUDE_FLUTTER_APP") -eq "1") {
        if (Get-Command bash -ErrorAction SilentlyContinue) {
            bash "$Root/scripts/build-vercel.sh"
        }
        else { Write-Err "INCLUDE_FLUTTER_APP=1 requires Git Bash (bash) on Windows" }
    }
    else {
        Write-Host "Skipping Flutter /app (INCLUDE_FLUTTER_APP=1 to embed)"
        Push-Location "$Root\web"
        npm ci
        npm run build
        Pop-Location
    }
    Push-Location "$Root\web"
    vercel --prod --yes
    Pop-Location
    Write-Ok "Vercel deploy -> $(Get-DeployCfg 'PRODUCTION_URL')"
}

Write-Host "=== Prolance deploy-release ===" -ForegroundColor Cyan
Show-AuthReminder
Test-Git
Test-Vercel
Test-SupabaseCli

if ($CheckOnly) {
    Write-Ok "Preflight passed (-CheckOnly)"
    exit 0
}

if ($GitPush) { Invoke-GitPush }
if ($Supabase) { Invoke-SupabaseDeploy }
if ($Vercel) { Invoke-VercelDeploy }

Write-Host ""
Write-Ok "Done."
