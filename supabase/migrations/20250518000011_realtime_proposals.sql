-- Broadcast proposal row changes to subscribed clients (RLS still applies per user).
do $$
begin
  alter publication supabase_realtime add table public.proposals;
exception
  when duplicate_object then null;
end $$;
