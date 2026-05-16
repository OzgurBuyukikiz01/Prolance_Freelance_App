-- Ensure proposal status column exists (idempotent; column created in init_schema).

alter table public.proposals
  add column if not exists status text not null default 'pending';

create index if not exists proposals_job_status_idx
  on public.proposals (job_id, status);
