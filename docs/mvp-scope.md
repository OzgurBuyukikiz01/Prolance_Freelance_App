# MVP scope — intentionally out of scope

Items below are known gaps for the first cross-platform release. They are not blockers for web + mobile auth parity, portal support, or admin moderation.

| Area | Status | Notes |
|------|--------|--------|
| Real payments | Out of scope | Escrow Edge Function is mock; no production PSP |
| Google sign-in (web) | Out of scope | UI shows “coming soon”; mobile OAuth needs prod redirect URLs |
| Web favorites | Out of scope | `job_saves` used on mobile only; no portal favorites UI |
| Video calls (web) | Out of scope | Agora via `agora-token` on mobile only |
| Push notifications | Optional | `send-push` + trigger exist; configure `app.settings` or webhook in prod ([DEPLOY.md](../DEPLOY.md)) |
| Admin on mobile | Out of scope | Admin panel is web-only by design |
| App store release | Out of scope | Flutter build/signing/store listing not part of this MVP |
| Portal Playwright (logged-in) | Partial | Smoke covers auth redirects; full flows need test user + env |

## In scope for MVP

- Shared Supabase Auth (`auth.users` + `profiles` trigger) for web and mobile
- Portal: jobs, proposals, messages, calendar, support tickets, post job, reviews, escrow dispute UI
- Mobile: schedule, favorites (`job_saves`), support tickets
- Admin: `is_admin` guard on web routes; tickets, jobs, disputes moderation
- Migrations: schedule items, proposals DELETE RLS, avatar public read (apply with `supabase db push`)
