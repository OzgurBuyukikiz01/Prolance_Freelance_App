-- One-off repair for demo users on hosted Supabase.
-- Symptom: "Invalid login credentials" / app shows "Incorrect email or password"
-- Common causes:
--   1) auth.users.instance_id was set to 00000000-... (must match auth.instances.id)
--   2) Wrong password hash from an old seed
--
-- Run in Supabase Dashboard → SQL Editor. Safe to run multiple times.
-- Fixes by email (covers self-registered admin@prolance.dev with any user id).

update auth.users u
set
  instance_id = (select id from auth.instances limit 1),
  encrypted_password = case u.email
    when 'client@prolance.dev' then crypt('demo1234', gen_salt('bf'))
    when 'freelancer@prolance.dev' then crypt('demo1234', gen_salt('bf'))
    when 'admin@prolance.dev' then crypt('admin1234', gen_salt('bf'))
    else u.encrypted_password
  end,
  email_confirmed_at = coalesce(u.email_confirmed_at, now()),
  updated_at = now()
where u.email in (
  'client@prolance.dev',
  'freelancer@prolance.dev',
  'admin@prolance.dev'
);

-- App reads profiles.is_admin for demo escrow on any job.
update public.profiles
set is_admin = true, updated_at = now()
where email = 'admin@prolance.dev';
