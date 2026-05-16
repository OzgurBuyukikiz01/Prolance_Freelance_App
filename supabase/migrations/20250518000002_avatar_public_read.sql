-- Public read for avatar objects (profile photos use public URLs).
drop policy if exists "Avatar read own" on storage.objects;

create policy "Avatar public read"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'avatars');
