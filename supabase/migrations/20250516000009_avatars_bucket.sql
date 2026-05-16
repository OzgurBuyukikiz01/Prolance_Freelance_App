-- Public avatars bucket for profile photos.

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update
  set public = excluded.public;

drop policy if exists "Avatar upload" on storage.objects;
create policy "Avatar upload"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Avatar update own" on storage.objects;
create policy "Avatar update own"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Avatar read" on storage.objects;
create policy "Avatar read"
  on storage.objects
  for select
  to authenticated
  using (bucket_id = 'avatars');
