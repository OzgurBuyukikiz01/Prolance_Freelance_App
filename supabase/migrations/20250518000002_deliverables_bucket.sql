-- Private deliverables bucket (participants read; freelancer uploads under {proposal_id}/...)

insert into storage.buckets (id, name, public)
values ('deliverables', 'deliverables', false)
on conflict (id) do update
  set public = excluded.public;

drop policy if exists "deliverables insert freelancer" on storage.objects;
create policy "deliverables insert freelancer"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'deliverables'
    and exists (
      select 1 from public.proposals p
      where p.id::text = (storage.foldername(name))[1]
        and p.freelancer_id = auth.uid()
    )
  );

drop policy if exists "deliverables read participants" on storage.objects;
create policy "deliverables read participants"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'deliverables'
    and exists (
      select 1 from public.proposals p
      join public.jobs j on j.id = p.job_id
      where p.id::text = (storage.foldername(name))[1]
        and (p.freelancer_id = auth.uid() or j.client_id = auth.uid())
    )
  );
