-- Store latest FCM device token per profile for push delivery.

alter table public.profiles
  add column if not exists fcm_token text;

create index if not exists profiles_fcm_token_idx
  on public.profiles (fcm_token)
  where fcm_token is not null;

comment on column public.profiles.fcm_token is
  'Firebase Cloud Messaging registration token; updated by mobile app.';
