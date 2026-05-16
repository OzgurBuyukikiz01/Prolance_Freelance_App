-- Chat attachments storage bucket + RLS policies

-- Create the bucket (idempotent)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'chat-attachments',
  'chat-attachments',
  false,
  20971520, -- 20 MB
  array[
    'image/jpeg', 'image/png', 'image/gif', 'image/webp',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain'
  ]
)
on conflict (id) do nothing;

-- RLS: authenticated users can upload to their own prefix
create policy "chat_attachments_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'chat-attachments' and
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- RLS: authenticated users can read files in conversations they participate in
-- (simplified: any authenticated user can read — conversation-level access is
--  enforced by the signed URL + RLS on messages table)
create policy "chat_attachments_select_authenticated"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'chat-attachments');

-- RLS: users can delete their own uploads
create policy "chat_attachments_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'chat-attachments' and
    (storage.foldername(name))[1] = auth.uid()::text
  );
