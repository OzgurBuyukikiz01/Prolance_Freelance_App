-- Demo helper: instantly expire the 24h dispute window for testing
-- Also ensures reviews RLS insert policy and rating recalc RPC exist.

-- ---------------------------------------------------------------------------
-- Demo: set dispute deadline to the past so freelancer can claim earnings
-- ---------------------------------------------------------------------------
create or replace function public.rpc_demo_expire_deadline(p_proposal_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_prop record;
  v_job  record;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'err', 'not_authenticated');
  end if;

  select * into v_prop from public.proposals where id = p_proposal_id;
  if not found then
    return jsonb_build_object('ok', false, 'err', 'proposal_not_found');
  end if;

  select * into v_job from public.jobs where id = v_prop.job_id;

  -- Only a participant (client or freelancer) may call this
  if v_job.client_id is distinct from v_uid
     and v_prop.freelancer_id is distinct from v_uid then
    return jsonb_build_object('ok', false, 'err', 'not_participant');
  end if;

  if v_prop.lifecycle_phase is distinct from 'payout_pending' then
    return jsonb_build_object('ok', false, 'err', 'not_payout_pending');
  end if;

  if coalesce(v_prop.payout_finalized, false) = true then
    return jsonb_build_object('ok', false, 'err', 'already_finalized');
  end if;

  update public.proposals
    set delivery_dispute_deadline = now() - interval '2 minutes'
  where id = p_proposal_id;

  return jsonb_build_object('ok', true);
end;
$$;

grant execute on function public.rpc_demo_expire_deadline(uuid) to authenticated;
revoke execute on function public.rpc_demo_expire_deadline(uuid) from anon;

-- ---------------------------------------------------------------------------
-- Reviews: ensure insert policy exists
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename  = 'reviews'
      and policyname = 'reviews_insert_reviewer'
  ) then
    execute $policy$
      create policy "reviews_insert_reviewer"
        on public.reviews for insert
        to authenticated
        with check (reviewer_id = auth.uid())
    $policy$;
  end if;
end;
$$;

-- Reviews: ensure select policy exists so clients and freelancers can read reviews
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename  = 'reviews'
      and policyname = 'reviews_select_participants'
  ) then
    execute $policy$
      create policy "reviews_select_participants"
        on public.reviews for select
        to authenticated
        using (reviewer_id = auth.uid() or reviewee_id = auth.uid())
    $policy$;
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- RPC: recalculate freelancer rating + completed_jobs after a new review
-- ---------------------------------------------------------------------------
create or replace function public.rpc_update_freelancer_rating(p_freelancer_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
    set rating = (
          select avg(rating)::numeric(3,2)
          from public.reviews
          where reviewee_id = p_freelancer_id
        ),
        completed_jobs = (
          select count(*)
          from public.proposals
          where freelancer_id = p_freelancer_id
            and lifecycle_phase = 'closed'
        )
  where id = p_freelancer_id;
end;
$$;

grant execute on function public.rpc_update_freelancer_rating(uuid) to authenticated;
revoke execute on function public.rpc_update_freelancer_rating(uuid) from anon;

-- ---------------------------------------------------------------------------
-- Ensure demo client has enough demo_balance_cents (1 000 000 TRY = 100 000 000 ¢)
-- Only updates the seed user; safe to run on cloud (no-op if user doesn't exist).
-- ---------------------------------------------------------------------------
update public.profiles
  set demo_balance_cents = greatest(coalesce(demo_balance_cents, 0), 100000000)
where id = 'aaaaaaaa-0001-4000-8000-000000000001';
