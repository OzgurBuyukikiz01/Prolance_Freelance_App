-- Dispatch FCM push when a notification row is inserted.
--
-- Option A (this migration): pg_net HTTP POST to Edge Function send-push.
--   Requires pg_net enabled (Supabase Dashboard → Database → Extensions).
--   Set secrets in Vault or configure:
--     app.settings.supabase_url  → https://YOUR_PROJECT.supabase.co
--     app.settings.service_role_key → service role JWT
--
-- Option B (recommended if pg_net secrets are awkward): Supabase Dashboard
--   → Database → Webhooks → on public.notifications INSERT
--   → URL: https://YOUR_PROJECT.supabase.co/functions/v1/send-push
--   → HTTP Headers: Authorization: Bearer <SERVICE_ROLE_KEY>
--   → Body: {"notificationId": "{{ record.id }}"}

create extension if not exists pg_net with schema extensions;

create or replace function public.dispatch_push_for_notification()
returns trigger
language plpgsql
security definer
set search_path = public, net
as $$
declare
  base_url text;
  service_key text;
  request_id bigint;
begin
  base_url := coalesce(
    nullif(current_setting('app.settings.supabase_url', true), ''),
    nullif(current_setting('app.settings.api_external_url', true), '')
  );
  service_key := nullif(current_setting('app.settings.service_role_key', true), '');

  if base_url is null or service_key is null then
    -- Secrets not configured — rely on Database Webhook (Option B) or skip silently.
    return new;
  end if;

  select net.http_post(
    url := rtrim(base_url, '/') || '/functions/v1/send-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_key
    ),
    body := jsonb_build_object('notificationId', new.id::text)
  ) into request_id;

  return new;
end;
$$;

drop trigger if exists on_notification_insert_push on public.notifications;
create trigger on_notification_insert_push
  after insert on public.notifications
  for each row
  execute function public.dispatch_push_for_notification();
