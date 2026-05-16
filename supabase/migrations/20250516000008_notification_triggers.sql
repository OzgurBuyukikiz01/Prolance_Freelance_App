-- Server-side notifications for proposals and messages (SECURITY DEFINER bypasses RLS).

create or replace function public.notify_job_owner_on_proposal()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications (profile_id, title, body, type)
  select j.client_id,
         'Yeni Teklif',
         'İlanınıza yeni bir teklif geldi.',
         'proposal'
  from public.jobs j
  where j.id = new.job_id;
  return new;
end;
$$;

drop trigger if exists on_proposal_insert on public.proposals;
create trigger on_proposal_insert
  after insert on public.proposals
  for each row
  execute function public.notify_job_owner_on_proposal();

create or replace function public.notify_on_new_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications (profile_id, title, body, type)
  select pid,
         'Yeni Mesaj',
         'Yeni bir mesajınız var.',
         'message'
  from unnest(
    (
      select c.participant_ids
      from public.conversations c
      where c.id = new.conversation_id
    )
  ) as pid
  where pid is not null
    and pid <> new.sender_id;
  return new;
end;
$$;

drop trigger if exists on_message_insert on public.messages;
create trigger on_message_insert
  after insert on public.messages
  for each row
  execute function public.notify_on_new_message();

create or replace function public.notify_freelancer_on_proposal_accepted()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'accepted'
     and (tg_op = 'INSERT' or old.status is distinct from 'accepted') then
    insert into public.notifications (profile_id, title, body, type)
    values (
      new.freelancer_id,
      'Teklif Kabul Edildi',
      'Teklifiniz kabul edildi.',
      'proposal'
    );
  end if;
  return new;
end;
$$;

drop trigger if exists on_proposal_status_accepted on public.proposals;
create trigger on_proposal_status_accepted
  after insert or update of status on public.proposals
  for each row
  execute function public.notify_freelancer_on_proposal_accepted();
