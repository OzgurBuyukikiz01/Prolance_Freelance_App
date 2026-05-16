-- Add admin_notes column to tickets for admin comments/resolution notes
alter table public.tickets
  add column if not exists admin_notes text not null default '';

-- Allow admins (service role) to update all tickets via admin panel
-- Normal users only update their own tickets via existing RLS
-- The admin panel uses the service role key which bypasses RLS
