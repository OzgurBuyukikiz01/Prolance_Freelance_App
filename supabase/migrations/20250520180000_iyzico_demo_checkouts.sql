-- Demo wallet top-ups via iyzico Checkout Form (sandbox).

create table if not exists public.iyzico_demo_checkouts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  conversation_id text not null unique,
  amount_cents integer not null check (amount_cents >= 100 and amount_cents <= 10000000),
  checkout_token text,
  status text not null default 'pending' check (status in ('pending', 'completed', 'failed')),
  iyzico_payment_status text,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create index if not exists iyzico_demo_checkouts_token_idx
  on public.iyzico_demo_checkouts (checkout_token);

create index if not exists iyzico_demo_checkouts_profile_id_idx
  on public.iyzico_demo_checkouts (profile_id);

alter table public.iyzico_demo_checkouts enable row level security;

comment on table public.iyzico_demo_checkouts is
  'Sandbox iyzico checkout sessions; callback credits profiles.demo_balance_cents.';
