-- Tighten chat-attachments read access to uploader or conversation participants.

drop policy if exists "Chat attachments read" on storage.objects;
drop policy if exists "chat_attachments_select_authenticated" on storage.objects;

create policy "Chat attachments read"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'chat-attachments'
    and (
      auth.uid()::text = (storage.foldername(name))[1]
      or exists (
        select 1
        from public.conversations c
        where c.id::text = (storage.foldername(name))[2]
          and auth.uid() = any (c.participant_ids)
      )
    )
  );
