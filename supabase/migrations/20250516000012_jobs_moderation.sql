-- Job moderation: rejection reason, moderator audit, owner notifications.

alter table public.jobs
  add column if not exists rejection_reason text,
  add column if not exists moderated_by uuid references public.profiles (id);

create or replace function public.notify_job_moderation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status in ('open', 'rejected') and old.status = 'pending_review' then
    insert into public.notifications (profile_id, title, body, type)
    select j.client_id,
      case
        when new.status = 'open' then 'İlanınız onaylandı'
        else 'İlanınız reddedildi'
      end,
      case
        when new.status = 'open' then '"' || new.title || '" yayına alındı.'
        else '"' || new.title || '" reddedildi: ' || coalesce(new.rejection_reason, '')
      end,
      'job'
    from public.jobs j
    where j.id = new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists on_job_moderation on public.jobs;
create trigger on_job_moderation
  after update of status on public.jobs
  for each row
  execute function public.notify_job_moderation();
