-- Prolance seed data — local development only.
-- Inserts 3 demo auth users, their profiles, 5 jobs, and a sample conversation.
-- Run with: supabase db reset  (which replays migrations then applies this file)
--
-- Demo logins:
--   client@prolance.dev / demo1234
--   freelancer@prolance.dev / demo1234
--   admin@prolance.dev / admin1234  (is_admin; mock escrow on any job in the app)

-- ---------------------------------------------------------------------------
-- Auth users (Supabase auth schema)
-- ---------------------------------------------------------------------------
insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_user_meta_data, raw_app_meta_data,
  is_super_admin, confirmation_token, recovery_token,
  email_change_token_new, email_change
) values
  -- Client demo user  |  email: client@prolance.dev  |  password: demo1234
  (
    'aaaaaaaa-0001-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'client@prolance.dev',
    crypt('demo1234', gen_salt('bf')),
    now(), now(), now(),
    '{"full_name":"Demo Client","role":"CLIENT"}'::jsonb,
    '{"provider":"email","providers":["email"]}'::jsonb,
    false, '', '', '', ''
  ),
  -- Freelancer demo  |  email: freelancer@prolance.dev  |  password: demo1234
  (
    'aaaaaaaa-0002-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'freelancer@prolance.dev',
    crypt('demo1234', gen_salt('bf')),
    now(), now(), now(),
    '{"full_name":"Demo Freelancer","role":"FREELANCER"}'::jsonb,
    '{"provider":"email","providers":["email"]}'::jsonb,
    false, '', '', '', ''
  ),
  -- Platform demo admin  |  email: admin@prolance.dev  |  password: admin1234
  (
    'aaaaaaaa-0003-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'admin@prolance.dev',
    crypt('admin1234', gen_salt('bf')),
    now(), now(), now(),
    '{"full_name":"Demo Admin","role":"CLIENT"}'::jsonb,
    '{"provider":"email","providers":["email"]}'::jsonb,
    false, '', '', '', ''
  )
on conflict (id) do nothing;

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

-- ---------------------------------------------------------------------------
-- Profiles (trigger would auto-create but seed runs before triggers fire)
-- ---------------------------------------------------------------------------
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
    'Crafting high-quality Flutter apps since 2019. Specialising in Supabase back-ends.',
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
    'Prolance operations and demo escrow.',
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

-- ---------------------------------------------------------------------------
-- Jobs (5 demo listings from the CLIENT user)
-- ---------------------------------------------------------------------------
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
    'We need an experienced Flutter developer to build a complete e-commerce app with Stripe integration, product catalogue, cart, and order management. Both iOS and Android must be delivered.',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    1500, 3000, 'fixed',
    'Mobile Development',
    '["Flutter","Dart","Stripe","REST API"]'::jsonb,
    'Intermediate', '1-3 months',
    3, 'open', now() - interval '2 days'
  ),
  (
    'bbbbbbbb-0002-4000-8000-000000000002',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'Supabase Backend for SaaS Platform',
    'Looking for a Supabase expert to design the database schema, RLS policies, Edge Functions, and Realtime subscriptions for our B2B SaaS platform. Must include auth, multi-tenancy, and billing hooks.',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    2000, 4500, 'fixed',
    'Backend Development',
    '["Supabase","PostgreSQL","TypeScript","Edge Functions"]'::jsonb,
    'Expert', '1-3 months',
    7, 'open', now() - interval '4 days'
  ),
  (
    'bbbbbbbb-0003-4000-8000-000000000003',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'UI/UX Designer for Mobile App Redesign',
    'Redesign our existing iOS app following the latest Material 3 and iOS HIG guidelines. Deliverables: Figma component library, interactive prototype, and design tokens.',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    800, 1800, 'fixed',
    'Design',
    '["Figma","Material 3","Prototyping","Design Systems"]'::jsonb,
    'Intermediate', '< 1 month',
    5, 'open', now() - interval '1 day'
  ),
  (
    'bbbbbbbb-0004-4000-8000-000000000004',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'Node.js REST API Developer (Part-time)',
    'Ongoing part-time role to maintain and extend our Node.js / Express REST API. Tasks include adding new endpoints, writing tests with Jest, and fixing bugs. ~20 hrs/week.',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    35, 55, 'hourly',
    'Backend Development',
    '["Node.js","Express","Jest","PostgreSQL","Docker"]'::jsonb,
    'Intermediate', '3-6 months',
    2, 'open', now() - interval '6 days'
  ),
  (
    'bbbbbbbb-0005-4000-8000-000000000005',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'React Native → Flutter Migration',
    'Migrate our existing React Native app (30 screens) to Flutter. State management with Riverpod, existing REST API stays. Must match the current UI pixel-perfect.',
    'Demo Client',
    'https://i.pravatar.cc/150?img=3',
    4000, 7000, 'fixed',
    'Mobile Development',
    '["Flutter","Dart","Riverpod","React Native"]'::jsonb,
    'Expert', '3-6 months',
    1, 'open', now() - interval '3 days'
  )
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Conversation + messages between CLIENT and FREELANCER about the first job
-- ---------------------------------------------------------------------------
insert into public.conversations (id, participant_ids, last_message_at) values
  (
    'cccccccc-0001-4000-8000-000000000001',
    array[
      'aaaaaaaa-0001-4000-8000-000000000001'::uuid,
      'aaaaaaaa-0002-4000-8000-000000000002'::uuid
    ],
    now() - interval '30 minutes'
  )
on conflict (id) do nothing;

insert into public.messages (id, conversation_id, sender_id, body, created_at) values
  (
    'dddddddd-0001-4000-8000-000000000001',
    'cccccccc-0001-4000-8000-000000000001',
    'aaaaaaaa-0002-4000-8000-000000000002',
    'Merhaba! Flutter E-Commerce App ilanını gördüm, portfolyoma bakabilir misiniz?',
    now() - interval '2 hours'
  ),
  (
    'dddddddd-0002-4000-8000-000000000002',
    'cccccccc-0001-4000-8000-000000000001',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'Tabii, portföyünüze baktım. Çok etkileyici çalışmalarınız var! Bütçe aralığımız 1500–3000$ arasında, uygun mu?',
    now() - interval '90 minutes'
  ),
  (
    'dddddddd-0003-4000-8000-000000000003',
    'cccccccc-0001-4000-8000-000000000001',
    'aaaaaaaa-0002-4000-8000-000000000002',
    'Evet, uygun. Stripe entegrasyonu ve ödeme akışı için yaklaşık 2 hafta ek süre gerekebilir. Toplam 8 hafta içinde teslim edebilirim.',
    now() - interval '60 minutes'
  ),
  (
    'dddddddd-0004-4000-8000-000000000004',
    'cccccccc-0001-4000-8000-000000000001',
    'aaaaaaaa-0001-4000-8000-000000000001',
    'Harika! Resmi teklif gönderebilirsiniz. Escrow sistemi üzerinden çalışacağız, her milestone sonrası ödeme yapılacak.',
    now() - interval '30 minutes'
  )
on conflict (id) do nothing;
