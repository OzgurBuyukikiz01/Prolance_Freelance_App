-- Prolance: initial schema (public app tables + escrow + tickets + reviews + notifications)
-- Aligns with Flutter JobModel / UserModel and extends Prisma concepts.

create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
do $$ begin
  create type public.app_role as enum ('CLIENT', 'FREELANCER');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type public.escrow_status as enum (
    'FUNDED',
    'HELD',
    'RELEASED',
    'DISPUTED',
    'REFUNDED'
  );
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type public.ticket_status as enum ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type public.ticket_priority as enum ('LOW', 'NORMAL', 'HIGH', 'URGENT');
exception
  when duplicate_object then null;
end $$;

-- ---------------------------------------------------------------------------
-- Profiles (1:1 with auth.users)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  full_name text not null default '',
  avatar_url text not null default '',
  role public.app_role not null default 'FREELANCER',
  skills jsonb not null default '[]'::jsonb,
  location text not null default 'Remote',
  title text not null default '',
  bio text not null default '',
  hourly_rate double precision not null default 0,
  website text not null default '',
  rating double precision not null default 0,
  completed_jobs integer not null default 0,
  total_earnings integer not null default 0,
  is_admin boolean not null default false,
  is_banned boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists profiles_email_idx on public.profiles (email);
create index if not exists profiles_role_idx on public.profiles (role);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'avatar_url', ''),
    case
      when new.raw_user_meta_data->>'role' in ('CLIENT', 'FREELANCER')
        then (new.raw_user_meta_data->>'role')::public.app_role
      else 'FREELANCER'::public.app_role
    end
  )
  on conflict (id) do update
    set email = excluded.email,
        updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Jobs
-- ---------------------------------------------------------------------------
create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  description text not null,
  client_name text not null,
  client_avatar text not null,
  budget_min double precision not null,
  budget_max double precision not null,
  budget_type text not null default 'fixed',
  category text not null,
  skills jsonb not null default '[]'::jsonb,
  experience_level text not null default 'Intermediate',
  duration text not null default '1-3 months',
  proposal_count integer not null default 0,
  is_user_posted boolean not null default false,
  listing_kind text not null default 'job_offer',
  status text not null default 'open',
  posted_date timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists jobs_client_id_idx on public.jobs (client_id);
create index if not exists jobs_status_idx on public.jobs (status);
create index if not exists jobs_posted_date_idx on public.jobs (posted_date desc);

-- ---------------------------------------------------------------------------
-- Job saves (favorites per user)
-- ---------------------------------------------------------------------------
create table if not exists public.job_saves (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  job_id uuid not null references public.jobs (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (profile_id, job_id)
);

-- ---------------------------------------------------------------------------
-- Proposals
-- ---------------------------------------------------------------------------
create table if not exists public.proposals (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs (id) on delete cascade,
  freelancer_id uuid not null references public.profiles (id) on delete cascade,
  bid double precision not null,
  delivery_days integer not null,
  cover_letter text not null,
  attachments jsonb not null default '[]'::jsonb,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create index if not exists proposals_job_id_idx on public.proposals (job_id);
create index if not exists proposals_freelancer_id_idx on public.proposals (freelancer_id);

-- ---------------------------------------------------------------------------
-- Conversations & messages
-- ---------------------------------------------------------------------------
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  participant_ids uuid[] not null default '{}',
  last_message_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  body text not null,
  attachment_url text,
  created_at timestamptz not null default now()
);

create index if not exists messages_conversation_id_idx on public.messages (conversation_id);

-- ---------------------------------------------------------------------------
-- Escrow (mock amounts — no PSP)
-- ---------------------------------------------------------------------------
create table if not exists public.escrow_transactions (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs (id) on delete cascade,
  employer_id uuid not null references public.profiles (id) on delete cascade,
  freelancer_id uuid references public.profiles (id) on delete set null,
  amount_cents bigint not null check (amount_cents >= 0),
  currency text not null default 'TRY',
  status public.escrow_status not null default 'FUNDED',
  dispute_reason text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists escrow_job_id_idx on public.escrow_transactions (job_id);
create index if not exists escrow_status_idx on public.escrow_transactions (status);

-- ---------------------------------------------------------------------------
-- Support tickets
-- ---------------------------------------------------------------------------
create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles (id) on delete cascade,
  subject text not null,
  body text not null,
  status public.ticket_status not null default 'OPEN',
  priority public.ticket_priority not null default 'NORMAL',
  admin_reply text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists tickets_author_id_idx on public.tickets (author_id);
create index if not exists tickets_status_idx on public.tickets (status);

-- ---------------------------------------------------------------------------
-- Reviews (post-completion)
-- ---------------------------------------------------------------------------
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs (id) on delete cascade,
  reviewer_id uuid not null references public.profiles (id) on delete cascade,
  reviewee_id uuid not null references public.profiles (id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  comment text not null default '',
  created_at timestamptz not null default now(),
  unique (job_id, reviewer_id)
);

-- ---------------------------------------------------------------------------
-- Notifications queue (Realtime-friendly)
-- ---------------------------------------------------------------------------
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  body text not null,
  type text not null default 'generic',
  read_at timestamptz,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists notifications_profile_id_idx on public.notifications (profile_id);
create index if not exists notifications_created_at_idx on public.notifications (created_at desc);

-- ---------------------------------------------------------------------------
-- Admin audit log
-- ---------------------------------------------------------------------------
create table if not exists public.admin_audit_log (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid references public.profiles (id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Helpers: updated_at
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists jobs_set_updated_at on public.jobs;
create trigger jobs_set_updated_at
  before update on public.jobs
  for each row execute function public.set_updated_at();

drop trigger if exists escrow_set_updated_at on public.escrow_transactions;
create trigger escrow_set_updated_at
  before update on public.escrow_transactions
  for each row execute function public.set_updated_at();

drop trigger if exists tickets_set_updated_at on public.tickets;
create trigger tickets_set_updated_at
  before update on public.tickets
  for each row execute function public.set_updated_at();

-- Increment proposal_count on insert
create or replace function public.increment_job_proposal_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.jobs
  set proposal_count = proposal_count + 1,
      updated_at = now()
  where id = new.job_id;
  return new;
end;
$$;

drop trigger if exists proposals_after_insert on public.proposals;
create trigger proposals_after_insert
  after insert on public.proposals
  for each row execute function public.increment_job_proposal_count();
