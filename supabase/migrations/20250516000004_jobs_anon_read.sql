-- Allow anonymous (logged-out) users to browse open jobs for marketing / demo builds.
create policy "jobs_select_anon_open"
  on public.jobs for select
  to anon
  using (status = 'open');
