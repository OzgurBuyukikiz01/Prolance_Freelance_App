# Supabase messaging (future)

This document maps the Prisma models in [`prisma/schema.prisma`](../../prisma/schema.prisma) to a recommended Supabase Postgres layout for realtime chat.

## Tables

### `conversations`

| Column | Type | Notes |
|--------|------|--------|
| id | uuid PK | |
| participant_ids | uuid[] | Supabase auth user ids |
| last_message_at | timestamptz | |
| created_at | timestamptz | default now() |

### `messages`

| Column | Type | Notes |
|--------|------|--------|
| id | uuid PK | |
| conversation_id | uuid FK | |
| sender_id | uuid | references auth.users |
| body | text | |
| attachment_url | text nullable | Storage public URL |
| created_at | timestamptz | |

## Row Level Security (RLS)

- Enable RLS on `conversations` and `messages`.
- Policy: users may **select** rows where `auth.uid()` is in `participant_ids` (conversations) or parent conversation passes same rule (messages).
- Policy: users may **insert** messages only if they are a participant of the parent conversation.

## Realtime

- Enable Supabase Realtime on `messages` for `INSERT` so [`ChatScreen`](../../../../lib/features/messages/screens/chat_screen.dart) can subscribe instead of polling.

## Flutter wiring

- Replace [`LocalMessageRepository`](../../../../lib/core/repositories/message_repository.dart) with `SupabaseMessageRepository` using `supabase_flutter`.
- Keep the same `MessageRepository` interface so [`MessagesScreen`](../../../../lib/features/messages/screens/messages_screen.dart) requires no UI changes.
