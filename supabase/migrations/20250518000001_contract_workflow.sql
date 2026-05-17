-- Contract workflow: demo employer balance, proposal lifecycle, deliveries,
-- escrow<->proposal link, RPCs for accept / delivery / client review / dispute / finalize.

-- ---------------------------------------------------------------------------
-- profiles: demo spend + freelancer earnings
-- ---------------------------------------------------------------------------
alter table public.profiles
  add column if not exists demo_balance_cents bigint not null default 0,
  add column if not exists earnings_available_cents bigint not null default 0;

alter table public.proposals
  add column if not exists lifecycle_phase text not null default 'submitted',
  add column if not exists funded_amount_cents bigint,
  add column if not exists freelancer_payout_cents bigint,
  add column if not exists delivery_dispute_deadline timestamptz,
  add column if not exists payout_finalized boolean not null default false,
  add column if not exists dispute_note text;

comment on column public.proposals.lifecycle_phase is
  'submitted|escrow_funded|awaiting_client_review|delivered|payout_pending|closed|disputed';

alter table public.escrow_transactions
  add column if not exists proposal_id uuid references public.proposals (id) on delete set null;

create index if not exists escrow_proposal_id_idx
  on public.escrow_transactions (proposal_id);

-- ---------------------------------------------------------------------------
-- Deliverables metadata (bytes live in storage.deliverables)
-- ---------------------------------------------------------------------------
create table if not exists public.proposal_deliveries (
  id uuid primary key default gen_random_uuid(),
  proposal_id uuid not null references public.proposals (id) on delete cascade,
  file_name text not null,
  storage_path text not null,
  created_at timestamptz not null default now()
);

create index if not exists proposal_deliveries_proposal_id_idx
  on public.proposal_deliveries (proposal_id);

alter table public.proposal_deliveries enable row level security;

create policy "proposal_deliveries_select_participants"
  on public.proposal_deliveries for select
  to authenticated
  using (
    exists (
      select 1
      from public.proposals p
      join public.jobs j on j.id = p.job_id
      where p.id = proposal_deliveries.proposal_id
        and (p.freelancer_id = auth.uid() or j.client_id = auth.uid())
    )
  );

-- ---------------------------------------------------------------------------
-- RPC: accept proposal (deduct demo balance, escrow HELD, single winner / job)
-- ---------------------------------------------------------------------------
create or replace function public.rpc_accept_proposal(p_proposal_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_prop record;
  v_job record;
  v_cost bigint;
  v_bal bigint;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'err', 'not_authenticated');
  end if;

  select * into v_prop from public.proposals where id = p_proposal_id for update;
  if not found then
    return jsonb_build_object('ok', false, 'err', 'proposal_not_found');
  end if;

  if v_prop.status is distinct from 'pending' then
    return jsonb_build_object('ok', false, 'err', 'not_pending');
  end if;

  select * into v_job from public.jobs where id = v_prop.job_id;
  if not found then
    return jsonb_build_object('ok', false, 'err', 'job_not_found');
  end if;

  if v_job.client_id is distinct from v_uid then
    return jsonb_build_object('ok', false, 'err', 'not_job_owner');
  end if;

  if exists (
    select 1 from public.proposals p2
    where p2.job_id = v_prop.job_id
      and p2.status = 'accepted'
      and p2.id is distinct from p_proposal_id
  ) then
    return jsonb_build_object('ok', false, 'err', 'job_already_accepted');
  end if;

  v_cost := greatest(0, round(v_prop.bid * 100))::bigint;

  select demo_balance_cents into v_bal from public.profiles where id = v_uid for update;
  if coalesce(v_bal, 0) < v_cost then
    return jsonb_build_object('ok', false, 'err', 'insufficient_demo_balance');
  end if;

  update public.profiles
    set demo_balance_cents = demo_balance_cents - v_cost
  where id = v_uid;

  update public.proposals
    set status = 'accepted',
        lifecycle_phase = 'escrow_funded',
        funded_amount_cents = v_cost
  where id = p_proposal_id;

  insert into public.escrow_transactions (
    job_id, employer_id, freelancer_id, amount_cents, status, proposal_id
  ) values (
    v_prop.job_id, v_uid, v_prop.freelancer_id, v_cost, 'HELD', p_proposal_id
  );

  return jsonb_build_object('ok', true, 'funded_cents', v_cost);
end;
$$;

-- ---------------------------------------------------------------------------
-- RPC: freelancer registers a delivery (metadata only; upload client-side)
-- ---------------------------------------------------------------------------
create or replace function public.rpc_register_proposal_delivery(
  p_proposal_id uuid,
  p_file_name text,
  p_storage_path text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_prop record;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'err', 'not_authenticated');
  end if;

  select * into v_prop from public.proposals where id = p_proposal_id for update;
  if not found then
    return jsonb_build_object('ok', false, 'err', 'proposal_not_found');
  end if;

  if v_prop.freelancer_id is distinct from v_uid then
    return jsonb_build_object('ok', false, 'err', 'not_freelancer');
  end if;

  if v_prop.lifecycle_phase is distinct from 'escrow_funded'
     or v_prop.status is distinct from 'accepted' then
    return jsonb_build_object('ok', false, 'err', 'invalid_phase');
  end if;

  insert into public.proposal_deliveries (proposal_id, file_name, storage_path)
  values (p_proposal_id, left(p_file_name, 512), left(p_storage_path, 1024));

  update public.proposals
    set lifecycle_phase = 'delivered'
  where id = p_proposal_id;

  return jsonb_build_object('ok', true);
end;
$$;

-- ---------------------------------------------------------------------------
-- RPC: client accepts or declines delivered work
-- ---------------------------------------------------------------------------
create or replace function public.rpc_client_review_delivery(
  p_proposal_id uuid,
  p_accept boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_prop record;
  v_job record;
  v_cost bigint;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'err', 'not_authenticated');
  end if;

  select * into v_prop from public.proposals where id = p_proposal_id for update;
  if not found then
    return jsonb_build_object('ok', false, 'err', 'proposal_not_found');
  end if;

  select * into v_job from public.jobs where id = v_prop.job_id;
  if v_job.client_id is distinct from v_uid then
    return jsonb_build_object('ok', false, 'err', 'not_job_owner');
  end if;

  if v_prop.lifecycle_phase is distinct from 'delivered' then
    return jsonb_build_object('ok', false, 'err', 'not_delivered');
  end if;

  v_cost := coalesce(v_prop.funded_amount_cents, round(v_prop.bid * 100)::bigint);

  if not p_accept then
    update public.profiles
      set demo_balance_cents = demo_balance_cents + v_cost
    where id = v_uid;

    update public.escrow_transactions
      set status = 'DISPUTED'::public.escrow_status,
          dispute_reason = 'Client declined delivered work (demo).',
          updated_at = now()
    where proposal_id = p_proposal_id
      and status = 'HELD'::public.escrow_status;

    update public.proposals
      set lifecycle_phase = 'disputed',
          dispute_note = coalesce(dispute_note, '') || ' [declined_delivery]'
    where id = p_proposal_id;

    return jsonb_build_object('ok', true, 'branch', 'declined');
  end if;

  update public.escrow_transactions
    set status = 'RELEASED'::public.escrow_status,
        updated_at = now()
  where proposal_id = p_proposal_id
    and status = 'HELD'::public.escrow_status;

  update public.proposals
    set lifecycle_phase = 'payout_pending',
        freelancer_payout_cents = v_cost,
        delivery_dispute_deadline = now() + interval '24 hours',
        payout_finalized = false
  where id = p_proposal_id;

  return jsonb_build_object('ok', true, 'branch', 'accepted');
end;
$$;

-- ---------------------------------------------------------------------------
-- RPC: client disputes during 24h window (refund demo balance; freeze contract)
-- ---------------------------------------------------------------------------
create or replace function public.rpc_dispute_delivery_timeline(p_proposal_id uuid, p_note text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_prop record;
  v_job record;
  v_pay bigint;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'err', 'not_authenticated');
  end if;

  select * into v_prop from public.proposals where id = p_proposal_id for update;
  if not found then
    return jsonb_build_object('ok', false, 'err', 'proposal_not_found');
  end if;

  select * into v_job from public.jobs where id = v_prop.job_id;
  if v_job.client_id is distinct from v_uid then
    return jsonb_build_object('ok', false, 'err', 'not_job_owner');
  end if;

  if v_prop.lifecycle_phase is distinct from 'payout_pending' then
    return jsonb_build_object('ok', false, 'err', 'not_in_dispute_window');
  end if;

  if v_prop.payout_finalized is true then
    return jsonb_build_object('ok', false, 'err', 'already_finalized');
  end if;

  if v_prop.delivery_dispute_deadline is not null
     and v_prop.delivery_dispute_deadline < now() then
    return jsonb_build_object('ok', false, 'err', 'dispute_window_closed');
  end if;

  v_pay := coalesce(v_prop.freelancer_payout_cents, v_prop.funded_amount_cents, 0);

  update public.profiles
    set demo_balance_cents = demo_balance_cents + v_pay
  where id = v_uid;

  update public.proposals
    set lifecycle_phase = 'disputed',
        dispute_note = left(coalesce(p_note, ''), 2000),
        payout_finalized = true
  where id = p_proposal_id;

  return jsonb_build_object('ok', true);
end;
$$;

-- ---------------------------------------------------------------------------
-- RPC: move payout_pending -> closed and credit freelancer (after 24h)
-- ---------------------------------------------------------------------------
create or replace function public.rpc_finalize_proposal_payouts()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  r record;
  n int := 0;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'err', 'not_authenticated');
  end if;

  for r in
    select id, freelancer_id, freelancer_payout_cents
    from public.proposals
    where freelancer_id = v_uid
      and lifecycle_phase = 'payout_pending'
      and payout_finalized = false
      and delivery_dispute_deadline is not null
      and delivery_dispute_deadline <= now()
  loop
    update public.proposals
      set lifecycle_phase = 'closed',
          payout_finalized = true
    where id = r.id;

    update public.profiles
      set earnings_available_cents = earnings_available_cents
        + greatest(0, coalesce(r.freelancer_payout_cents, 0))
    where id = r.freelancer_id;

    n := n + 1;
  end loop;

  return jsonb_build_object('ok', true, 'finalized', n);
end;
$$;

grant execute on function public.rpc_accept_proposal(uuid) to authenticated;
grant execute on function public.rpc_register_proposal_delivery(uuid, text, text) to authenticated;
grant execute on function public.rpc_client_review_delivery(uuid, boolean) to authenticated;
grant execute on function public.rpc_dispute_delivery_timeline(uuid, text) to authenticated;
grant execute on function public.rpc_finalize_proposal_payouts() to authenticated;

revoke execute on function public.rpc_accept_proposal(uuid) from anon;
revoke execute on function public.rpc_register_proposal_delivery(uuid, text, text) from anon;
revoke execute on function public.rpc_client_review_delivery(uuid, boolean) from anon;
revoke execute on function public.rpc_dispute_delivery_timeline(uuid, text) from anon;
revoke execute on function public.rpc_finalize_proposal_payouts() from anon;
