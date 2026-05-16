# Prolance monorepo health check (Windows).
# Usage: pwsh -File scripts/doctor.ps1
$ErrorActionPreference = 'Stop'
$Root = Resolve-Path (Join-Path $PSScriptRoot '..')
$failed = $false

function Step([string]$Title, [scriptblock]$Action) {
  Write-Host "`n=== $Title ===" -ForegroundColor Cyan
  try {
    & $Action
    Write-Host "OK: $Title" -ForegroundColor Green
  } catch {
    Write-Host "FAIL: $Title`n$_" -ForegroundColor Red
    $script:failed = $true
  }
}

Step 'Flutter pub get' {
  Push-Location (Join-Path $Root 'client')
  flutter pub get
  Pop-Location
}

Step 'Flutter analyze' {
  Push-Location (Join-Path $Root 'client')
  flutter analyze
  Pop-Location
}

Step 'Flutter test' {
  Push-Location (Join-Path $Root 'client')
  flutter test
  Pop-Location
}

Step 'Flutter doctor (informational)' {
  flutter doctor -v
}

Step 'Web npm ci' {
  Push-Location (Join-Path $Root 'web')
  if (Test-Path 'package-lock.json') { npm ci } else { npm install }
  Pop-Location
}

Step 'Web lint' {
  Push-Location (Join-Path $Root 'web')
  npm run lint
  Pop-Location
}

Step 'Web build' {
  Push-Location (Join-Path $Root 'web')
  npm run build
  Pop-Location
}

Step 'Web unit tests (Vitest)' {
  Push-Location (Join-Path $Root 'web')
  npm run test
  Pop-Location
}

Step 'Web e2e (Playwright, optional)' {
  Push-Location (Join-Path $Root 'web')
  $browsers = Join-Path $env:USERPROFILE '.cache\ms-playwright'
  if (-not (Test-Path $browsers)) {
    Write-Host 'SKIP: Playwright browsers not installed. Run: npx playwright install chromium' -ForegroundColor Yellow
    return
  }
  npm run test:e2e
  Pop-Location
}

Step 'Supabase functions deno check' {
  $functions = Get-ChildItem (Join-Path $Root 'supabase\functions\*\index.ts')
  foreach ($fn in $functions) {
    Write-Host "deno check $($fn.FullName)"
    deno check $fn.FullName
  }
}

Step 'Supabase escrow deno test' {
  $testFile = Join-Path $Root 'supabase\functions\escrow\index_test.ts'
  if (Test-Path $testFile) {
    deno test --allow-env $testFile
  }
}

Step 'Migration smoke (optional)' {
  $sh = Join-Path $Root 'scripts\check-migration-smoke.sh'
  if (Get-Command bash -ErrorAction SilentlyContinue) {
    bash $sh
  } else {
    Write-Host 'SKIP: bash not available for migration smoke script' -ForegroundColor Yellow
  }
}

Write-Host "`nOptional: integration_test (not run in doctor by default):" -ForegroundColor DarkGray
Write-Host "  cd client && flutter test integration_test" -ForegroundColor DarkGray

if ($failed) {
  Write-Host "`nDoctor finished with failures." -ForegroundColor Red
  exit 1
}

Write-Host "`nDoctor finished successfully." -ForegroundColor Green
exit 0
