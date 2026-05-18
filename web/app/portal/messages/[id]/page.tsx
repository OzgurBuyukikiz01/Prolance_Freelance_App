import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import { ChatClient } from '@/components/portal/ChatClient';
import { MagicCard } from '@/components/ui/magic-card';
import { createClient } from '@/lib/supabase/server';

type PageProps = {
  params: Promise<{ id: string }>;
};

export default async function PortalChatPage({ params }: PageProps) {
  const { id } = await params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  const { data: conversation } = await supabase
    .from('conversations')
    .select('id, participant_ids')
    .eq('id', id)
    .single();

  if (!conversation || !conversation.participant_ids.includes(user.id)) {
    notFound();
  }

  const otherId =
    conversation.participant_ids.find((pid: string) => pid !== user.id) ??
    conversation.participant_ids[0];

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name')
    .eq('id', otherId)
    .maybeSingle();

  const { data: messages } = await supabase
    .from('messages')
    .select('id, sender_id, body, created_at')
    .eq('conversation_id', id)
    .order('created_at', { ascending: true });

  return (
    <div className="space-y-4">
      <Link href="/portal/messages" className="text-sm font-medium text-brand hover:text-brand-dark">
        ← Back to Messages
      </Link>
      <MagicCard innerClassName="p-4 sm:p-6">
        <h1 className="text-lg font-bold text-white mb-4 pb-3 border-b border-white/8">
          {profile?.full_name ?? 'Chat'}
        </h1>
        <ChatClient
          conversationId={id}
          currentUserId={user.id}
          initialMessages={messages ?? []}
        />
      </MagicCard>
    </div>
  );
}
