-- Allow additional deliverable rows after first upload (lifecycle already "delivered").

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

  if v_prop.lifecycle_phase is distinct from 'escrow_funded'
     and v_prop.lifecycle_phase is distinct from 'delivered' then
    return jsonb_build_object('ok', false, 'err', 'invalid_phase');
  end if;

  insert into public.proposal_deliveries (proposal_id, file_name, storage_path)
  values (p_proposal_id, left(p_file_name, 512), left(p_storage_path, 1024));

  update public.proposals
    set lifecycle_phase = 'delivered'
  where id = p_proposal_id
    and lifecycle_phase = 'escrow_funded';

  return jsonb_build_object('ok', true);
end;
$$;
