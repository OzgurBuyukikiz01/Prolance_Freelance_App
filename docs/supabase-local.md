# Supabase (local)

1. Install [Supabase CLI](https://supabase.com/docs/guides/cli).
2. From repo root: `supabase start`
3. Studio: `http://127.0.0.1:54323`
4. Apply migrations (first start does this): `supabase db reset` to re-run migrations + `seed.sql`.

## Flutter / web keys (local defaults)

Use `--dart-define` or rely on defaults in `lib/core/config/supabase_config.dart`:

| Variable | Local default |
|----------|----------------|
| `SUPABASE_URL` | `http://127.0.0.1:54321` |
| `SUPABASE_ANON_KEY` | JWT from `supabase status` (see CLI output) |

The anon JWT for local Supabase is stable across installs; see [Local development docs](https://supabase.com/docs/guides/cli/local-development#access-your-projects-services).

## Seed users (`supabase/seed.sql`)

- `employer@prolance.local` / `password123` (admin flag for admin UI flows)
- `freelancer@prolance.local` / `password123`
