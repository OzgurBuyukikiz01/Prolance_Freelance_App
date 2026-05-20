# send-support-email

Edge Function that emails support using [Resend](https://resend.com). The Flutter app never sees `RESEND_API_KEY`.

Support tickets are always sent **to** `ozgurbuyukikiz@gmail.com`. The user’s address from the ticket form is used as **reply_to** (Resend field `reply_to`).

`from` must be a **verified domain** in Resend. If `RESEND_FROM_EMAIL` uses consumer mail (Gmail, Yahoo, etc.), the function automatically uses **`Prolance <onboarding@resend.dev>`** so sends still work.

## Secrets (hosted)

```bash
supabase secrets set RESEND_API_KEY=re_xxxxxxxx
# Optional — use a verified domain sender; Gmail as From will be replaced at runtime.
supabase secrets set RESEND_FROM_EMAIL="Prolance <noreply@yourdomain.com>"
supabase functions deploy send-support-email
```

## One-off demo email (terminal)

Replace `re_YOUR_KEY` with your key (never commit it). Sends from Resend’s onboarding sender to the support inbox:

```bash
curl -sS -X POST 'https://api.resend.com/emails' \
  -H 'Authorization: Bearer re_YOUR_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"from":"Prolance <onboarding@resend.dev>","to":["ozgurbuyukikiz@gmail.com"],"subject":"[Prolance] Demo","html":"<p>Resend demo OK.</p>"}'
```

## Local

Copy `supabase/.env.example` → `supabase/.env`, fill `RESEND_*` only, then:

```bash
supabase functions serve send-support-email --env-file supabase/.env
```

Invoke from the app while pointing the client at local functions URL (advanced); against production project, deploy the function and set secrets in the Dashboard.
