-- Row Level Security for Prolance

alter table public.profiles enable row level security;
alter table public.jobs enable row level security;
alter table public.job_saves enable row level security;
alter table public.proposals enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.escrow_transactions enable row level security;
alter table public.tickets enable row level security;
alter table public.reviews enable row level security;
alter table public.notifications enable row level security;
alter table public.admin_audit_log enable row level security;

-- ---------------------------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------------------------
create policy "profiles_select_authenticated"
  on public.profiles for select
  to authenticated
  using (true);

create policy "profiles_insert_own"
  on public.profiles for insert
  to authenticated
  with check (id = auth.uid());

create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- ---------------------------------------------------------------------------
-- Jobs: readable by authenticated; insert/update own as client
-- ---------------------------------------------------------------------------
create policy "jobs_select_authenticated"
  on public.jobs for select
  to authenticated
  using (true);

create policy "jobs_insert_authenticated"
  on public.jobs for insert
  to authenticated
  with check (client_id = auth.uid());

create policy "jobs_update_owner"
  on public.jobs for update
  to authenticated
  using (client_id = auth.uid())
  with check (client_id = auth.uid());

create policy "jobs_delete_owner"
  on public.jobs for delete
  to authenticated
  using (client_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Job saves
-- ---------------------------------------------------------------------------
create policy "job_saves_select_own"
  on public.job_saves for select
  to authenticated
  using (profile_id = auth.uid());

create policy "job_saves_insert_own"
  on public.job_saves for insert
  to authenticated
  with check (profile_id = auth.uid());

create policy "job_saves_delete_own"
  on public.job_saves for delete
  to authenticated
  using (profile_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Proposals
-- ---------------------------------------------------------------------------
create policy "proposals_select_participants"
  on public.proposals for select
  to authenticated
  using (
    freelancer_id = auth.uid()
    or exists (
      select 1 from public.jobs j
      where j.id = proposals.job_id and j.client_id = auth.uid()
    )
  );

create policy "proposals_insert_freelancer"
  on public.proposals for insert
  to authenticated
  with check (freelancer_id = auth.uid());

create policy "proposals_update_freelancer_or_client"
  on public.proposals for update
  to authenticated
  using (
    freelancer_id = auth.uid()
    or exists (
      select 1 from public.jobs j
      where j.id = proposals.job_id and j.client_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- Conversations: participants only
-- ---------------------------------------------------------------------------
create policy "conversations_select_participant"
  on public.conversations for select
  to authenticated
  using (auth.uid() = any (participant_ids));

create policy "conversations_insert_authenticated"
  on public.conversations for insert
  to authenticated
  with check (auth.uid() = any (participant_ids));

create policy "conversations_update_participant"
  on public.conversations for update
  to authenticated
  using (auth.uid() = any (participant_ids));

-- ---------------------------------------------------------------------------
-- Messages
-- ---------------------------------------------------------------------------
create policy "messages_select_conversation_member"
  on public.messages for select
  to authenticated
  using (
    exists (
      select 1 from public.conversations c
      where c.id = messages.conversation_id
        and auth.uid() = any (c.participant_ids)
    )
  );

create policy "messages_insert_sender"
  on public.messages for insert
  to authenticated
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from public.conversations c
      where c.id = messages.conversation_id
        and auth.uid() = any (c.participant_ids)
    )
  );

-- ---------------------------------------------------------------------------
-- Escrow: employer or freelancer on row
-- ---------------------------------------------------------------------------
create policy "escrow_select_parties"
  on public.escrow_transactions for select
  to authenticated
  using (
    employer_id = auth.uid()
    or coalesce(freelancer_id, '00000000-0000-0000-0000-000000000000'::uuid) = auth.uid()
  );

create policy "escrow_insert_employer"
  on public.escrow_transactions for insert
  to authenticated
  with check (employer_id = auth.uid());

create policy "escrow_update_parties"
  on public.escrow_transactions for update
  to authenticated
  using (
    employer_id = auth.uid()
    or coalesce(freelancer_id, '00000000-0000-0000-0000-000000000000'::uuid) = auth.uid()
  );

-- ---------------------------------------------------------------------------
-- Tickets: author reads/writes; admins via service role (bypass RLS)
-- ---------------------------------------------------------------------------
create policy "tickets_select_own"
  on public.tickets for select
  to authenticated
  using (author_id = auth.uid());

create policy "tickets_insert_own"
  on public.tickets for insert
  to authenticated
  with check (author_id = auth.uid());

create policy "tickets_update_own_open"
  on public.tickets for update
  to authenticated
  using (author_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Reviews
-- ---------------------------------------------------------------------------
create policy "reviews_select_related"
  on public.reviews for select
  to authenticated
  using (reviewer_id = auth.uid() or reviewee_id = auth.uid());

create policy "reviews_insert_reviewer"
  on public.reviews for insert
  to authenticated
  with check (reviewer_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Notifications: own only
-- ---------------------------------------------------------------------------
create policy "notifications_select_own"
  on public.notifications for select
  to authenticated
  using (profile_id = auth.uid());

create policy "notifications_update_own"
  on public.notifications for update
  to authenticated
  using (profile_id = auth.uid());

create policy "notifications_insert_service"
  on public.notifications for insert
  to authenticated
  with check (profile_id = auth.uid());

-- Admin audit: no client access (service role only)
create policy "admin_audit_no_client_access"
  on public.admin_audit_log for select
  to authenticated
  using (false);
