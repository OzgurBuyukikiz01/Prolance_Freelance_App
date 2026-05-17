-- Two-step delivery: freelancer uploads (stays escrow_funded), then confirms submission;
-- client then reviews (downloads) and accepts → payout_pending + 24h dispute.

update public.proposals
set lifecycle_phase = 'awaiting_client_review'
where status = 'accepted'
  and lifecycle_phase = 'delivered';

comment on column public.proposals.lifecycle_phase is
  'submitted|escrow_funded|awaiting_client_review|delivered|payout_pending|closed|disputed';

-- Upload only registers files; does not advance lifecycle.
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

  if v_prop.status is distinct from 'accepted' then
    return jsonb_build_object('ok', false, 'err', 'invalid_phase');
  end if;

  if v_prop.lifecycle_phase is distinct from 'escrow_funded' then
    return jsonb_build_object('ok', false, 'err', 'invalid_phase');
  end if;

  insert into public.proposal_deliveries (proposal_id, file_name, storage_path)
  values (p_proposal_id, left(p_file_name, 512), left(p_storage_path, 1024));

  return jsonb_build_object('ok', true);
end;
$$;

-- Freelancer confirms files are ready for client review (UI: "Accept delivery").
create or replace function public.rpc_freelancer_confirm_delivery_submission(p_proposal_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_prop record;
  v_n int;
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

  if v_prop.status is distinct from 'accepted'
     or v_prop.lifecycle_phase is distinct from 'escrow_funded' then
    return jsonb_build_object('ok', false, 'err', 'invalid_phase');
  end if;

  select count(*)::int into v_n from public.proposal_deliveries where proposal_id = p_proposal_id;
  if coalesce(v_n, 0) < 1 then
    return jsonb_build_object('ok', false, 'err', 'no_deliverables');
  end if;

  update public.proposals
    set lifecycle_phase = 'awaiting_client_review'
  where id = p_proposal_id;

  return jsonb_build_object('ok', true);
end;
$$;

-- Client review only after freelancer submitted for review.
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

  if v_prop.lifecycle_phase is distinct from 'awaiting_client_review' then
    return jsonb_build_object('ok', false, 'err', 'not_ready_for_client_review');
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

grant execute on function public.rpc_freelancer_confirm_delivery_submission(uuid) to authenticated;
revoke execute on function public.rpc_freelancer_confirm_delivery_submission(uuid) from anon;
