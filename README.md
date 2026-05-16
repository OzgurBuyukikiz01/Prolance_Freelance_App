# Prolance

Cross-platform freelance marketplace (Flutter) with **Supabase** (Postgres + Auth + RLS + optional Edge Functions), **mock escrow**, **Next.js 3D landing**, and **Next.js admin** (service role).

## Quick start — Flutter

```bash
flutter pub get
flutter run --dart-define=USE_SUPABASE=true   # default
```

Local Supabase: see [`docs/supabase-local.md`](docs/supabase-local.md).

## Quick start — Supabase CLI

```bash
supabase start
supabase db reset   # migrations + seed
```

## Monorepo layout

| Path | Stack |
|------|--------|
| `/` (this repo root) | Flutter app |
| [`packages/landing`](packages/landing) | Next.js 15 + R3F hero |
| [`packages/admin`](packages/admin) | Next.js 15 + Supabase service client |
| [`supabase/`](supabase) | Migrations, Edge Functions, `seed.sql` |

## Scripts (Melos optional)

```bash
dart pub global activate melos
melos bootstrap   # if you extend workspace later
flutter analyze lib test
flutter test
```

## Docs

- [`CHANGELOG.md`](CHANGELOG.md)
- [`docs/changelog/`](docs/changelog/) — phase / release notes (Obsidian-style)
- [`.cursor/rules/prolance.mdc`](.cursor/rules/prolance.mdc) — AI / contributor conventions

## Legacy backend

[`backend/`](backend/) — Express + Prisma (optional bridge); primary data path is Supabase.
