# Prolance deployment

## Repository layout

| Path | Role |
|------|------|
| `client/` | Flutter mobile (Android, iOS) + web build output |
| `web/` | Next.js 15 — marketing site, user portal, and admin panel |
| `supabase/` | Database migrations + Edge Functions |

## Makefile

```bash
make help
make dev              # Flutter mobile (client/)
make dev-web-app      # Next.js on :3000 (web/)
make build-vercel     # client/build/web → web/public/app + next build
make deploy-web       # vercel --prod from web/
make deploy-supabase  # Supabase CLI (ref: cgxzpdhcaxiopdylwstr)
```

## Vercel (single project only)

Use **one** Vercel project linked from `web/` with **Root Directory** = `web`.

| Item | Value |
|------|--------|
| Project name | `web` |
| Team | `mikailulsys-projects` |
| **Canonical production URL** | `https://web-silk-psi-73ktdeeavc.vercel.app` |

Legacy Vercel projects **`landing`** and **`admin`** were removed (March 2026). Do not recreate them; all routes live on the `web` project.

### Link locally

```bash
cd web
vercel link    # select project: web
vercel env pull   # optional: sync .env.local
```

Keep only `web/.vercel/`. Remove any `.vercel` folder at the repo root or under `client/` if it appears.

### Environment variables (project `web` only)

| Variable | Notes |
|----------|--------|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://cgxzpdhcaxiopdylwstr.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anon key |
| `NEXT_PUBLIC_APP_URL` | `/app` (Flutter web on same host) |
| `NEXT_PUBLIC_SITE_URL` | Full production URL, e.g. `https://web-silk-psi-73ktdeeavc.vercel.app` (no trailing slash) |
| `SUPABASE_SERVICE_ROLE_KEY` | Server only — admin panel; never expose as `NEXT_PUBLIC_` |

Do not store secrets in git. Set values in the Vercel dashboard or via `vercel env add`.

### Routes (single host)

- `/` — landing
- `/login` — user auth
- `/portal` — user area
- `/admin/login` — admin auth
- `/dashboard`, `/jobs`, `/tickets`, `/disputes`, `/users`, `/audit` — admin
- `/app` — Flutter web (after `make build-vercel`)

### Build with embedded Flutter app

Vercel does not include the Flutter SDK. Run locally or in CI:

```bash
export SUPABASE_URL=https://cgxzpdhcaxiopdylwstr.supabase.co
export SUPABASE_ANON_KEY=your_anon_key
make build-vercel
cd web && vercel --prod
```

### Removing old Vercel projects (reference)

If CLI delete is needed again:

```bash
vercel project ls
# When prompted, confirm with y:
vercel project remove landing
vercel project remove admin
```

Dashboard: Team → Project → Settings → **Delete Project**.

## Supabase Auth URL configuration

Project ref: `cgxzpdhcaxiopdylwstr`

Dashboard: [Authentication → URL Configuration](https://supabase.com/dashboard/project/cgxzpdhcaxiopdylwstr/auth/url-configuration)

| Setting | Value |
|---------|--------|
| **Site URL** | `https://web-silk-psi-73ktdeeavc.vercel.app` |
| **Redirect URLs** | `https://web-silk-psi-73ktdeeavc.vercel.app/**` |
| | `http://localhost:3000/**` |

Remove any entries for deleted hosts, for example:

- `https://landing-*.vercel.app/**`
- `https://admin-*.vercel.app/**`

The Supabase MCP tools in Cursor cannot change Auth URL settings; apply the above in the dashboard (or Management API) manually.

After adding a custom domain on Vercel, update Site URL and Redirect URLs to that domain.

## Supabase (database / functions)

```bash
make deploy-supabase
# or: bash scripts/deploy-supabase.sh cgxzpdhcaxiopdylwstr
```

Dashboard: https://supabase.com/dashboard/project/cgxzpdhcaxiopdylwstr

## Mobile stores

From `client/`:

```bash
flutter build apk --release
flutter build ios --release
```

Use `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...` for production keys.