-- Job schedule milestones for portal calendar

create table if not exists public.job_schedule_items (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs (id) on delete cascade,
  proposal_id uuid references public.proposals (id) on delete set null,
  title text not null,
  due_date date not null,
  assignee_id uuid references public.profiles (id) on delete set null,
  created_by uuid not null references public.profiles (id) on delete cascade,
  completed_at timestamptz,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists job_schedule_items_job_id_idx on public.job_schedule_items (job_id);
create index if not exists job_schedule_items_due_date_idx on public.job_schedule_items (due_date);
create index if not exists job_schedule_items_assignee_id_idx on public.job_schedule_items (assignee_id);

drop trigger if exists job_schedule_items_set_updated_at on public.job_schedule_items;
create trigger job_schedule_items_set_updated_at
  before update on public.job_schedule_items
  for each row execute function public.set_updated_at();

alter table public.job_schedule_items enable row level security;

create policy "job_schedule_select_participants"
  on public.job_schedule_items for select
  to authenticated
  using (
    exists (
      select 1 from public.jobs j
      where j.id = job_schedule_items.job_id
        and (
          j.client_id = auth.uid()
          or exists (
            select 1 from public.proposals p
            where p.job_id = j.id
              and p.freelancer_id = auth.uid()
              and p.status = 'accepted'
          )
        )
    )
  );

create policy "job_schedule_insert_participants"
  on public.job_schedule_items for insert
  to authenticated
  with check (
    created_by = auth.uid()
    and exists (
      select 1 from public.jobs j
      where j.id = job_schedule_items.job_id
        and (
          j.client_id = auth.uid()
          or exists (
            select 1 from public.proposals p
            where p.job_id = j.id
              and p.freelancer_id = auth.uid()
              and p.status = 'accepted'
          )
        )
    )
  );

create policy "job_schedule_update_participants"
  on public.job_schedule_items for update
  to authenticated
  using (
    exists (
      select 1 from public.jobs j
      where j.id = job_schedule_items.job_id
        and (
          j.client_id = auth.uid()
          or exists (
            select 1 from public.proposals p
            where p.job_id = j.id
              and p.freelancer_id = auth.uid()
              and p.status = 'accepted'
          )
        )
    )
  );

create policy "job_schedule_delete_participants"
  on public.job_schedule_items for delete
  to authenticated
  using (
    exists (
      select 1 from public.jobs j
      where j.id = job_schedule_items.job_id
        and (
          j.client_id = auth.uid()
          or exists (
            select 1 from public.proposals p
            where p.job_id = j.id
              and p.freelancer_id = auth.uid()
              and p.status = 'accepted'
          )
        )
    )
  );
