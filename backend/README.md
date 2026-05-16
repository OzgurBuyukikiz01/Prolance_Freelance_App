# Prolance API (Prisma + PostgreSQL)

## Quick start

1. Copy `.env.example` to `.env` and adjust if needed.
2. Start Postgres: `docker compose up -d`
3. Install deps: `npm install`
4. `npx prisma generate`
5. `npx prisma db push`
6. `npm run db:seed`
7. `npm run dev`

The Flutter app can target this API with:

`flutter run --dart-define=API_BASE_URL=http://localhost:3000`

## Routes

- `GET /v1/jobs` — list jobs (Flutter-shaped JSON)
- `POST /v1/jobs` — create job
- `POST /v1/jobs/:jobId/proposals` — submit proposal (increments proposal count)
- `GET /v1/users/me` — demo stub
- `GET /v1/conversations` — stub list for future messaging
