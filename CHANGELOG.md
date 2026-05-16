# Changelog

All notable changes to this project are documented here (Keep a Changelog style).

## [Unreleased]

### Added
- Supabase local schema: profiles, jobs, job_saves, proposals, conversations, messages, escrow, tickets, reviews, notifications, admin audit log + RLS.
- Flutter: `supabase_flutter`, JWT via `jwt_decoder`, `GoRouter`, `AuthService`, `SupabaseJobRepository`, mock escrow UI + `PaymentService`.
- Edge Function skeleton: `supabase/functions/escrow`.
- Next.js apps: `packages/landing` (3D hero), `packages/admin` (service-role dashboard).
- Tests: unit (escrow model, JWT), smoke (`test/smoke/`), widget splash.
- Monorepo helper: `melos.yaml`.
- Cursor rules: `.cursor/rules/prolance.mdc`.

### Changed
- Auth moved from SharedPreferences demo to Supabase Auth when enabled.
- Navigation migrated from `Navigator` named routes to `GoRouter`.

### Notes
- Per-phase notes live under [`docs/changelog/`](docs/changelog/).
