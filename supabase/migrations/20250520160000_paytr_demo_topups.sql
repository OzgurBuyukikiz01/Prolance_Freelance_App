-- Pending / completed PayTR sandbox top-ups (credited in Edge notify using service role).

create table if not exists public.paytr_demo_topups (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  merchant_oid text not null unique,
  amount_cents integer not null check (amount_cents >= 100 and amount_cents <= 10000000),
  status text not null default 'pending' check (status in ('pending', 'completed', 'failed')),
  paytr_callback_status text,
  paytr_total_amount text,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create index if not exists paytr_demo_topups_merchant_oid_idx
  on public.paytr_demo_topups (merchant_oid);

create index if not exists paytr_demo_topups_profile_id_idx
  on public.paytr_demo_topups (profile_id);

alter table public.paytr_demo_topups enable row level security;

-- No policies: only service role (Edge Functions) may access.

comment on table public.paytr_demo_topups is
  'PayTR iFrame sandbox demo credits; notify handler updates profiles.demo_balance_cents.';
