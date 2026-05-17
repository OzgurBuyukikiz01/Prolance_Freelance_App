-- Demo data for hosted Supabase (e.g. cgxzpdhcaxiopdylwstr).
-- Run in Dashboard → SQL Editor (service role / postgres).
--
-- IMPORTANT: Hosted projects require auth.users.instance_id = auth.instances.id.
-- Using 00000000-... causes "Invalid login credentials" for SQL-seeded users.
--
-- Passwords: client + freelancer: demo1234 | admin@prolance.dev: admin1234
--
-- Re-run safe: upserts refresh passwords and instance_id for the three demo UUIDs.

with inst as (select id from auth.instances limit 1)
insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_user_meta_data, raw_app_meta_data,
  is_super_admin, confirmation_token, recovery_token,
  email_change_token_new, email_change
)
select
  'aaaaaaaa-0001-4000-8000-000000000001'::uuid,
  inst.id,
  'authenticated',
  'authenticated',
  'client@prolance.dev',
  crypt('demo1234', gen_salt('bf')),
  now(), now(), now(),
  '{"full_name":"Demo Client","role":"CLIENT"}'::jsonb,
  '{"provider":"email","providers":["email"]}'::jsonb,
  false, '', '', '', ''
from inst
union all
select
  'aaaaaaaa-0002-4000-8000-000000000002'::uuid,
  inst.id,
  'authenticated',
  'authenticated',
  'freelancer@prolance.dev',
  crypt('demo1234', gen_salt('bf')),
  now(), now(), now(),
  '{"full_name":"Demo Freelancer","role":"FREELANCER"}'::jsonb,
  '{"provider":"email","providers":["email"]}'::jsonb,
  false, '', '', '', ''
from inst
union all
select
  'aaaaaaaa-0003-4000-8000-000000000003'::uuid,
  inst.id,
  'authenticated',
  'authenticated',
  'admin@prolance.dev',
  crypt('admin1234', gen_salt('bf')),
  now(), now(), now(),
  '{"full_name":"Demo Admin","role":"CLIENT"}'::jsonb,
  '{"provider":"email","providers":["email"]}'::jsonb,
  false, '', '', '', ''
from inst
on conflict (id) do update set
  instance_id = excluded.instance_id,
  encrypted_password = excluded.encrypted_password,
  email_confirmed_at = excluded.email_confirmed_at,
  raw_user_meta_data = excluded.raw_user_meta_data,
  raw_app_meta_data = excluded.raw_app_meta_data,
  updated_at = now();

insert into auth.identities (
  id, user_id, provider_id, identity_data, provider,
  last_sign_in_at, created_at, updated_at
) values
  (
    'aaaaaaaa-0001-4000-8000-000000000001',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'client@prolance.dev',
    '{"sub":"aaaaaaaa-0001-4000-8000-000000000001","email":"client@prolance.dev"}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    'aaaaaaaa-0002-4000-8000-000000000002',
    'aaaaaaaa-0002-4000-8000-000000000002',
    'freelancer@prolance.dev',
    '{"sub":"aaaaaaaa-0002-4000-8000-000000000002","email":"freelancer@prolance.dev"}'::jsonb,
    'email', now(), now(), now()
  ),
  (
    'aaaaaaaa-0003-4000-8000-000000000003',
    'aaaaaaaa-0003-4000-8000-000000000003',
    'admin@prolance.dev',
    '{"sub":"aaaaaaaa-0003-4000-8000-000000000003","email":"admin@prolance.dev"}'::jsonb,
    'email', now(), now(), now()
  )
on conflict (id) do nothing;

insert into public.profiles (
  id, email, full_name, avatar_url, role,
  skills, location, title, bio, hourly_rate,
  rating, completed_jobs, total_earnings, is_admin
) values
  (
    'aaaaaaaa-0001-4000-8000-000000000001',
    'client@prolance.dev',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    'CLIENT',
    '["Project Management","UX Research"]'::jsonb,
    'Istanbul, Turkey',
    'Product Owner',
    'Building great digital products with talented freelancers worldwide.',
    0, 4.8, 12, 0, false
  ),
  (
    'aaaaaaaa-0002-4000-8000-000000000002',
    'freelancer@prolance.dev',
    'Demo Freelancer',
    'https://i.pravatar.cc/150?img=7',
    'FREELANCER',
    '["Flutter","Dart","Firebase","Supabase","Node.js"]'::jsonb,
    'Ankara, Turkey',
    'Full-Stack Mobile Developer',
    'Crafting high-quality Flutter apps since 2019.',
    75, 4.9, 34, 42000, false
  ),
  (
    'aaaaaaaa-0003-4000-8000-000000000003',
    'admin@prolance.dev',
    'Demo Admin',
    'https://i.pravatar.cc/150?img=12',
    'CLIENT',
    '[]'::jsonb,
    'Istanbul, Turkey',
    'Platform Admin',
    'Prolance operations.',
    0, 5.0, 0, 0, true
  )
on conflict (id) do update
  set full_name = excluded.full_name,
      is_admin = excluded.is_admin,
      updated_at = now();

-- Demo client wallet: $100,000.00 = 10_000_000 cents.
update public.profiles
set demo_balance_cents = 10000000
where id = 'aaaaaaaa-0001-4000-8000-000000000001';

insert into public.jobs (
  id, client_id, title, description,
  client_name, client_avatar,
  budget_min, budget_max, budget_type,
  category, skills, experience_level, duration,
  proposal_count, status, posted_date
) values
  (
    'bbbbbbbb-0001-4000-8000-000000000001',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'Flutter E-Commerce App',
    'We need an experienced Flutter developer to build a complete e-commerce app with Stripe integration.',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    1500, 3000, 'fixed',
    'Mobile Development',
    '["Flutter","Dart","Stripe"]'::jsonb,
    'Intermediate', '1-3 months',
    3, 'open', now() - interval '2 days'
  ),
  (
    'bbbbbbbb-0002-4000-8000-000000000002',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'Supabase Backend for SaaS Platform',
    'Design database schema, RLS policies, and Edge Functions for our B2B SaaS platform.',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    2000, 4500, 'fixed',
    'Backend Development',
    '["Supabase","PostgreSQL","TypeScript"]'::jsonb,
    'Expert', '1-3 months',
    7, 'open', now() - interval '4 days'
  ),
  (
    'bbbbbbbb-0003-4000-8000-000000000003',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'UI/UX Designer for Mobile App Redesign',
    'Redesign our iOS app with Figma and Material 3 guidelines.',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    800, 1800, 'fixed',
    'Design',
    '["Figma","Material 3"]'::jsonb,
    'Intermediate', '< 1 month',
    5, 'open', now() - interval '1 day'
  )
on conflict (id) do nothing;
