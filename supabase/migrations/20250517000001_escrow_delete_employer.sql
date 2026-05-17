-- Allow job owner to delete their own escrow rows (e.g. rollback after failed proposal accept).

create policy "escrow_delete_employer_funded_or_held"
  on public.escrow_transactions for delete
  to authenticated
  using (
    employer_id = auth.uid()
    and status in ('FUNDED'::public.escrow_status, 'HELD'::public.escrow_status)
  );
