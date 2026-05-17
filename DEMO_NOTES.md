# Prolance Demo Script — Presentation Day

## Demo Credentials

| Role       | Email                    | Password   |
|------------|--------------------------|------------|
| Client     | client@prolance.dev      | demo1234   |
| Freelancer | freelancer@prolance.dev  | demo1234   |
| Admin      | admin@prolance.dev       | admin1234  |

> **Important:** If logging in on the cloud Supabase project, these users must exist.
> If they do not, register new accounts manually via `/login` and set the correct role.
> After registration, run the migration SQL in Supabase Studio to ensure demo_balance_cents is topped up.

---

## Pre-Demo Checklist

1. Open two browser windows / two devices:
   - **Device 1 (Client):** Log in as `client@prolance.dev`
   - **Device 2 (Freelancer):** Log in as `freelancer@prolance.dev`
2. Make sure there is at least one job posted by the client visible at `/portal/jobs`.
   - If not: client creates a job (or use a seed job from the database).
3. Make sure the freelancer has submitted a proposal on that job.
   - If not: freelancer browses `/portal/jobs`, opens the job, submits a proposal.

---

## Two-Device Demo Flow

### Step 1 — Client Accepts Proposal
**Device 1 (Client):**
1. Go to `/portal/jobs` → open the job.
2. Scroll to "Gelen teklifler" (Incoming proposals).
3. Click **"Kabul et"** on the freelancer's proposal.
4. Confirmation: "Teklif kabul edildi ve escrow kaydı oluşturuldu."
5. The escrow is now funded from the client's demo balance.

---

### Step 2 — Freelancer Submits Delivery
**Device 2 (Freelancer):**
1. Go to `/portal/contracts`.
2. Click the accepted contract card.
3. Phase shows: **"Escrow'da Bekliyor"**.
4. Fill in the **"Teslimat Notu"** (e.g. "Projeyi tamamladım, Google Drive linkinde mevcut.").
5. Optionally paste a URL (Google Drive, GitHub, etc.).
6. Click **"Teslimatı Gönder"**.
7. Phase updates to: **"İnceleme Bekliyor"**.

---

### Step 3 — Client Reviews and Accepts Delivery
**Device 1 (Client):**
1. Go to `/portal/contracts`.
2. Click the contract — phase now shows **"İnceleme Bekliyor"**.
3. Read the delivery note and optional link.
4. Click **"✓ Teslimatı Kabul Et"**.
5. Phase updates to: **"Ödeme Bekliyor"** + 24-hour countdown timer appears.
6. Escrow status → RELEASED; freelancer's pending balance is set.

---

### Step 4 — Freelancer Sees Pending Balance
**Device 2 (Freelancer):**
1. Go to `/portal` (dashboard) — see "Bekleyen Ödeme" amount.
2. Or go to `/portal/contracts` → open the contract.
3. Phase shows **"Ödeme Bekliyor"** with the pending amount highlighted in purple.

---

### Step 5 — Demo: Simulate 24 Hours Passing
**Device 1 (Client)** (or Device 2):
1. Still on the contract detail page.
2. At the bottom, find the dashed **"DEMO MODU"** section.
3. Click **"⚡ Demo: 24 Saati Geç (Sunum için)"**.
4. The dispute deadline is now set to 2 minutes ago.

---

### Step 6 — Client's Report Window Has Expired
**Device 1 (Client):**
- Refresh the contract page.
- "Sorun Bildir" option is no longer visible (deadline passed).
- Phase still shows "Ödeme Bekliyor" but countdown shows "Süre doldu".

---

### Step 7 — Freelancer Claims Earnings
**Device 2 (Freelancer):**
1. Go to `/portal/contracts` → open the contract.
2. Phase: **"Ödeme Bekliyor"** — now shows **"Ödemeyi Al"** button.
3. Click it.
4. Phase updates to **"Tamamlandı"** (closed).
5. Go to `/portal` dashboard — "Kullanılabilir Bakiye" is now updated.

---

### Step 8 — Client Leaves a Review (Optional but impressive)
**Device 1 (Client):**
1. Go to the closed contract at `/portal/contracts`.
2. Scroll down to **"Freelancer'ı Değerlendir"** section.
3. Select star rating (click a star).
4. Write a comment (optional).
5. Click **"Değerlendirmeyi Gönder"**.

---

### Step 9 — Review Appears on Freelancer Profile
**Device 2 (Freelancer):**
1. Go to `/portal/profile`.
2. Scroll down to **"Değerlendirmeler"** section.
3. The review appears with star rating, comment, and reviewer name.
4. Average rating is updated.

---

## Demo: Report an Issue Flow (Bonus Demo, if time permits)

After Step 4 (client has accepted, 24h window is open, do NOT expire deadline yet):

**Device 1 (Client):**
1. On the contract detail page, find **"⚠ Sorun Bildir (İtiraz)"** — click to expand.
2. Type a reason (at least 10 characters).
3. Click **"Sorun Gönder"**.
4. Result: escrow is refunded to client; phase becomes "İtiraz Edildi".

---

## Environment Setup

### Local Development
```bash
cd web
npm install
npm run dev  # runs on http://localhost:3000
```

### Apply Migration to Supabase (Cloud)
1. Open Supabase Studio → SQL Editor.
2. Paste the contents of `supabase/migrations/20250518000008_demo_and_reviews.sql`.
3. Run it. This adds the demo helper RPC, review policies, and tops up client balance.

### Verify Vercel Deployment
- Production URL: `https://web-silk-psi-73ktdeeavc.vercel.app`
- Push to `main` branch → Vercel auto-deploys.
- Check Vercel dashboard for build status.

### Check Demo Balance (Supabase Studio)
If the client cannot accept proposals (insufficient balance error):
```sql
-- Top up demo client balance (run in Supabase Studio)
UPDATE profiles
SET demo_balance_cents = 100000000
WHERE email = 'client@prolance.dev';
```

---

## Remaining Demo-Only Notes

- **No real payments:** All money is simulated via `demo_balance_cents` and `earnings_available_cents` columns.
- **No real file upload:** Delivery uses a text note + optional URL. Actual file upload to Supabase Storage is not implemented in the web portal (Flutter mobile has this).
- **The "⚡ Demo: 24 Saati Geç" button** is only visible in payout_pending phase and is intentionally labeled DEMO MODU so the audience understands it's for presentation purposes.
- **Flutter mobile app** has a more complete delivery/escrow UI but is not required for the web demo.

---

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "insufficient_demo_balance" error | Run the SQL above in Supabase Studio to top up balance |
| Proposal not showing as accepted | Check lifecycle_phase in Supabase Studio → proposals table |
| Review not saving | Check reviews RLS policies; ensure migration 00008 was applied |
| Delivery not advancing phase | Make sure lifecycle_phase was 'escrow_funded' before submitting |
| Can't log in | Check Supabase auth.users table; register new users if needed |
