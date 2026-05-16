-- Harden trigger helpers: no public RPC; fix search_path; tighten avatar listing.

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke execute on function public.dispatch_push_for_notification() from public;
revoke execute on function public.handle_new_user() from public;
revoke execute on function public.increment_job_proposal_count() from public;
revoke execute on function public.notify_freelancer_on_proposal_accepted() from public;
revoke execute on function public.notify_job_moderation() from public;
revoke execute on function public.notify_job_owner_on_proposal() from public;
revoke execute on function public.notify_on_new_message() from public;

revoke execute on function public.dispatch_push_for_notification() from anon, authenticated;
revoke execute on function public.handle_new_user() from anon, authenticated;
revoke execute on function public.increment_job_proposal_count() from anon, authenticated;
revoke execute on function public.notify_freelancer_on_proposal_accepted() from anon, authenticated;
revoke execute on function public.notify_job_moderation() from anon, authenticated;
revoke execute on function public.notify_job_owner_on_proposal() from anon, authenticated;
revoke execute on function public.notify_on_new_message() from anon, authenticated;

-- Public bucket URLs work without a broad SELECT (listing) policy.
drop policy if exists "Avatar read" on storage.objects;

create policy "Avatar read own"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
