-- Broadcast job row changes (insert/update/delete) to clients; RLS limits rows per user.
do $$
begin
  alter publication supabase_realtime add table public.jobs;
exception
  when duplicate_object then null;
end $$;
