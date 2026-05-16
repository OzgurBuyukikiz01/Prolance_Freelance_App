-- Freelancers may withdraw their own pending proposals.
create policy "proposals_delete_freelancer_pending"
  on public.proposals for delete
  to authenticated
  using (freelancer_id = auth.uid() and status = 'pending');
