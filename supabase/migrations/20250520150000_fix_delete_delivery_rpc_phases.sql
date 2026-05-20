-- Align delete RPC with UI: legacy `delivered` phase is treated like client review
-- (same as awaiting_client_review). Safer row lookup without composite SELECT INTO quirks.

create or replace function public.rpc_delete_proposal_delivery(p_delivery_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_proposal_id uuid;
  v_storage_path text;
  v_prop record;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'err', 'not_authenticated');
  end if;

  select d.proposal_id, d.storage_path
    into v_proposal_id, v_storage_path
  from public.proposal_deliveries d
  where d.id = p_delivery_id
  for update;

  if not found then
    return jsonb_build_object('ok', false, 'err', 'not_found');
  end if;

  select * into v_prop from public.proposals where id = v_proposal_id for update;
  if not found then
    return jsonb_build_object('ok', false, 'err', 'proposal_not_found');
  end if;

  if v_prop.freelancer_id is distinct from v_uid then
    return jsonb_build_object('ok', false, 'err', 'not_freelancer');
  end if;

  if v_prop.lifecycle_phase is distinct from 'escrow_funded'
     and v_prop.lifecycle_phase is distinct from 'awaiting_client_review'
     and v_prop.lifecycle_phase is distinct from 'delivered' then
    return jsonb_build_object('ok', false, 'err', 'invalid_phase');
  end if;

  delete from public.proposal_deliveries where id = p_delivery_id;

  return jsonb_build_object(
    'ok', true,
    'storage_path', v_storage_path
  );
end;
$$;
