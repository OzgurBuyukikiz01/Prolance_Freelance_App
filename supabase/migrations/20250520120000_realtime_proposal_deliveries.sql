-- Freelancer uploads only touch proposal_deliveries (+ not always proposals); realtime here keeps client UI in sync.
do $$
begin
  alter publication supabase_realtime add table public.proposal_deliveries;
exception
  when duplicate_object then null;
end $$;
