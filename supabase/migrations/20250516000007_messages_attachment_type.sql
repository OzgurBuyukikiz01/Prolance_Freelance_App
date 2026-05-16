-- Add attachment_type and is_read columns to messages

alter table public.messages
  add column if not exists attachment_type text not null default 'text'
    check (attachment_type in ('text', 'image', 'file')),
  add column if not exists is_read boolean not null default false;

-- Existing messages without attachments are plain text
update public.messages
  set attachment_type = 'text'
  where attachment_type = 'text'; -- no-op, ensures column exists

-- Index for unread queries
create index if not exists messages_is_read_idx on public.messages (conversation_id, is_read)
  where is_read = false;
