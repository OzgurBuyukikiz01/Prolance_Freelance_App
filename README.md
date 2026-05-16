# Prolance Freelance App

Monorepo layout:

```
client/     Flutter mobile app (Android, iOS, Web)
web/        Next.js — marketing site + admin panel
supabase/   Backend (Postgres, Auth, Storage, Edge Functions)
```

## Quick start

### Mobile (Flutter)

```bash
cd client
flutter pub get
flutter run
```

### Web (landing + admin)

```bash
cd web
cp .env.example .env.local   # add SUPABASE_SERVICE_ROLE_KEY for admin actions
npm install
npm run dev
```

- Site: http://localhost:3000
- User login: `/login`
- Admin login: `/admin/login`
- Admin dashboard: `/dashboard`

### Supabase

Project ref: `cgxzpdhcaxiopdylwstr`

```bash
make deploy-supabase
```

## Makefile

```bash
make help
make dev              # Flutter mobile
make dev-web-app      # Next.js
make build-vercel     # Flutter web + Next.js for Vercel
make deploy-web       # Vercel production
```

See [DEPLOY.md](DEPLOY.md) for deployment details.
