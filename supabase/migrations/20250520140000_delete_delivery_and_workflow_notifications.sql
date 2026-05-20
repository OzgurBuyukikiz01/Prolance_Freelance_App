-- Freelancer: remove a deliverable row (and client deletes storage object) while
-- escrow_funded or awaiting_client_review. Storage delete policy for authenticated freelancer.
-- Client: notification when freelancer submits for review (lifecycle → awaiting_client_review).
-- Freelancer: notification when client accepts delivery (lifecycle → payout_pending).

-- ---------------------------------------------------------------------------
-- Storage: freelancer may delete own deliverable objects
-- ---------------------------------------------------------------------------
drop policy if exists "deliverables delete freelancer" on storage.objects;
create policy "deliverables delete freelancer"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'deliverables'
    and exists (
      select 1
      from public.proposals p
      where p.id::text = (storage.foldername(name))[1]
        and p.freelancer_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- RPC: delete one delivery metadata row (freelancer, allowed phases)
-- ---------------------------------------------------------------------------
create or replace function public.rpc_delete_proposal_delivery(p_delivery_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_row record;
  v_prop record;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'err', 'not_authenticated');
  end if;

  select d.id, d.proposal_id, d.storage_path
    into v_row
  from public.proposal_deliveries d
  where d.id = p_delivery_id
  for update;

  if not found then
    return jsonb_build_object('ok', false, 'err', 'not_found');
  end if;

  select * into v_prop from public.proposals where id = v_row.proposal_id for update;
  if not found then
    return jsonb_build_object('ok', false, 'err', 'proposal_not_found');
  end if;

  if v_prop.freelancer_id is distinct from v_uid then
    return jsonb_build_object('ok', false, 'err', 'not_freelancer');
  end if;

  if v_prop.lifecycle_phase is distinct from 'escrow_funded'
     and v_prop.lifecycle_phase is distinct from 'awaiting_client_review' then
    return jsonb_build_object('ok', false, 'err', 'invalid_phase');
  end if;

  delete from public.proposal_deliveries where id = p_delivery_id;

  return jsonb_build_object(
    'ok', true,
    'storage_path', v_row.storage_path
  );
end;
$$;

grant execute on function public.rpc_delete_proposal_delivery(uuid) to authenticated;
revoke execute on function public.rpc_delete_proposal_delivery(uuid) from anon;

-- ---------------------------------------------------------------------------
-- Notify client when freelancer moves contract to client review
-- ---------------------------------------------------------------------------
create or replace function public.notify_client_on_delivery_submitted_for_review()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.lifecycle_phase = 'awaiting_client_review'
     and old.lifecycle_phase is distinct from 'awaiting_client_review'
     and new.status = 'accepted' then
    insert into public.notifications (profile_id, title, body, type, payload)
    select j.client_id,
           'Teslim incelemesi',
           'Freelancer teslim dosyalarını gönderdi. Ana sayfadaki tekliflerinizden veya ilgili iş tekliflerinden indirip onaylayabilirsiniz.',
           'proposal',
           '{"ui":"dialog","event":"delivery_submitted"}'::jsonb
    from public.jobs j
    where j.id = new.job_id;
  end if;
  return new;
end;
$$;

drop trigger if exists proposals_notify_client_delivery_submitted on public.proposals;
create trigger proposals_notify_client_delivery_submitted
  after update of lifecycle_phase on public.proposals
  for each row
  execute function public.notify_client_on_delivery_submitted_for_review();

-- ---------------------------------------------------------------------------
-- Notify freelancer when client accepts delivered work (24h dispute window)
-- ---------------------------------------------------------------------------
create or replace function public.notify_freelancer_on_client_accepted_delivery()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.lifecycle_phase = 'payout_pending'
     and old.lifecycle_phase is distinct from 'payout_pending'
     and new.status = 'accepted' then
    insert into public.notifications (profile_id, title, body, type, payload)
    values (
      new.freelancer_id,
      'Teslim onaylandı',
      'İşveren teslimatı onayladı. Bakiyeniz 24 saat sonra çekilebilir olacaktır.',
      'proposal',
      '{"ui":"dialog","event":"delivery_accepted"}'::jsonb
    );
  end if;
  return new;
end;
$$;

drop trigger if exists proposals_notify_freelancer_delivery_accepted on public.proposals;
create trigger proposals_notify_freelancer_delivery_accepted
  after update of lifecycle_phase on public.proposals
  for each row
  execute function public.notify_freelancer_on_client_accepted_delivery();

revoke execute on function public.notify_client_on_delivery_submitted_for_review() from public;
revoke execute on function public.notify_client_on_delivery_submitted_for_review() from anon, authenticated;
revoke execute on function public.notify_freelancer_on_client_accepted_delivery() from public;
revoke execute on function public.notify_freelancer_on_client_accepted_delivery() from anon, authenticated;
